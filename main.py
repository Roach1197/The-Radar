import os
import re
import praw
import asyncio
import pandas as pd
from fastapi import FastAPI, Query, Depends, HTTPException
from pytrends.request import TrendReq
from datetime import datetime
from typing import List, Dict
from textblob import TextBlob
from collections import Counter, defaultdict
from cachetools import TTLCache
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
from langdetect import detect
from deep_translator import GoogleTranslator
import nltk

# --- Download NLTK Resources ---
nltk.download('stopwords')
nltk.download('wordnet')
nltk.download('punkt')
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer

# --- FastAPI App ---
app = FastAPI(title="EdgeFinder API", version="7.0")

# --- Reddit API Setup ---
reddit = praw.Reddit(
    client_id=os.getenv("REDDIT_CLIENT_ID"),
    client_secret=os.getenv("REDDIT_CLIENT_SECRET"),
    user_agent="EdgeFinderGPT/7.0"
)

# --- Google Trends Setup ---
pytrends = TrendReq(hl="en-US", tz=360)

# --- Cache ---
trend_cache = TTLCache(maxsize=50, ttl=1800)  # 30 min trends
reddit_cache = TTLCache(maxsize=100, ttl=900)  # 15 min Reddit posts

# --- Sentiment Analyzer ---
sentiment_analyzer = SentimentIntensityAnalyzer()

# --- API Key Security ---
API_KEY = os.getenv("EDGEFINDER_API_KEY")
def verify_key(x_api_key: str = Query(None)):
    if API_KEY and x_api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Unauthorized")
    return True

# --- Helpers ---
def clean_text(text: str) -> str:
    return re.sub(r"[^\x00-\x7F]+", "", text).strip().lower()

def calculate_opportunity_score(upvotes, trend, sentiment, engagement):
    return int((upvotes * 0.4) + (trend * 0.3) + (sentiment * 0.2) + (engagement * 0.1))

def analyze_sentiment(text: str) -> float:
    return sentiment_analyzer.polarity_scores(text)["compound"]

def translate_if_needed(text: str) -> str:
    try:
        lang = detect(text)
        if lang != "en":
            return GoogleTranslator(source='auto', target='en').translate(text)
        return text
    except:
        return text

def extract_keywords(posts: List[str]) -> List[str]:
    lemmatizer = WordNetLemmatizer()
    stops = set(stopwords.words('english'))
    words = " ".join(posts).split()
    filtered = [lemmatizer.lemmatize(w) for w in words if w.isalpha() and w not in stops]
    return [w for w, _ in Counter(filtered).most_common(12)]

def keyword_cooccurrence(posts: List[str]) -> Dict[str, List[str]]:
    words = [clean_text(w) for w in " ".join(posts).split() if w.isalpha()]
    co_map = defaultdict(set)
    for i, word in enumerate(words):
        if word not in stopwords.words('english'):
            for neighbor in words[max(0, i-2): i+3]:
                if neighbor != word and neighbor not in stopwords.words('english'):
                    co_map[word].add(neighbor)
    return {k: list(v) for k, v in co_map.items()}

def fetch_trend_score(topic: str) -> Dict:
    if topic in trend_cache:
        return trend_cache[topic]
    pytrends.build_payload([topic], cat=0, timeframe='now 7-d')
    data = pytrends.interest_over_time()
    related = pytrends.related_queries().get(topic, {}).get("top", pd.DataFrame())
    result = {
        "avg": int(data[topic].mean()) if not data.empty else 0,
        "trend_direction": "rising" if not data.empty and data[topic].iloc[-1] > data[topic].iloc[0] else "falling",
        "history": data[topic].tail(7).tolist() if not data.empty else [],
        "related_terms": related["query"].head(5).tolist() if not related.empty else []
    }
    trend_cache[topic] = result
    return result

async def fetch_reddit_posts(topic: str, trend_data: Dict) -> List[Dict]:
    if topic in reddit_cache:
        return reddit_cache[topic]
    posts, seen_urls = [], set()
    subreddit = reddit.subreddit("all")

    for submission in subreddit.search(topic, sort="hot", limit=12):
        if submission.url in seen_urls:
            continue
        seen_urls.add(submission.url)

        comments = []
        submission.comments.replace_more(limit=0)
        for c in submission.comments[:3]:
            translated = translate_if_needed(c.body)
            comments.append({
                "author": c.author.name if c.author else "Unknown",
                "body": translated[:250],
                "sentiment": analyze_sentiment(translated)
            })

        avg_sentiment = sum(c["sentiment"] for c in comments) / len(comments) if comments else 0
        engagement_ratio = len(comments) / max(submission.score, 1)
        score = calculate_opportunity_score(submission.score, trend_data["avg"], avg_sentiment, engagement_ratio)

        posts.append({
            "topic": topic,
            "title": translate_if_needed(submission.title),
            "url": f"https://reddit.com{submission.permalink}",
            "reddit_score": submission.score,
            "comment_engagement": round(engagement_ratio, 2),
            "google_trend_score": trend_data["avg"],
            "trend_direction": trend_data["trend_direction"],
            "sentiment_score": round(avg_sentiment, 3),
            "opportunity_score": score,
            "proof_comments": comments
        })
    reddit_cache[topic] = posts
    return posts

# --- Endpoints ---
@app.get("/radar-sweep")
async def radar_sweep(domain: str, auth: bool = Depends(verify_key)):
    trend_data = fetch_trend_score(domain)
    posts = await fetch_reddit_posts(domain, trend_data)
    posts.sort(key=lambda x: x["opportunity_score"], reverse=True)
    keywords = extract_keywords([p["title"] for p in posts])
    result = {
        "topic": domain,
        "google_trend": trend_data,
        "keywords": keywords,
        "keyword_relations": keyword_cooccurrence([p["title"] for p in posts]),
        "timestamp": datetime.utcnow().isoformat(),
        "top_opportunities": posts[:5],
        "suggested_next_topics": (trend_data["related_terms"] + keywords)[:6]
    }
    return result

@app.get("/multi-scan")
async def multi_scan(domains: str, auth: bool = Depends(verify_key)):
    topics = [d.strip() for d in domains.split(",")]
    tasks = [fetch_reddit_posts(t, fetch_trend_score(t)) for t in topics]
    results = await asyncio.gather(*tasks)
    all_posts = [p for topic_posts in results for p in topic_posts]
    all_posts.sort(key=lambda x: x["opportunity_score"], reverse=True)
    return {"scanned_topics": topics, "ranked_opportunities": all_posts[:12], "timestamp": datetime.utcnow().isoformat()}

@app.get("/health")
def health():
    return {
        "status": "OK",
        "reddit_read_only": reddit.read_only,
        "cache_size": {"trends": len(trend_cache), "reddit": len(reddit_cache)},
        "api_version": "7.0",
        "server_time": datetime.utcnow().isoformat()
    }

@app.get("/")
def root():
    return {
        "status": "EdgeFinder API is live!",
        "endpoints": ["/radar-sweep", "/multi-scan", "/health"],
        "version": "7.0"
    }
