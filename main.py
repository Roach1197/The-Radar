import os
import praw
import asyncio
import pandas as pd
from fastapi import FastAPI, Query, Depends, HTTPException
from pytrends.request import TrendReq
from datetime import datetime
from typing import List, Dict
from textblob import TextBlob
from collections import Counter
from cachetools import TTLCache
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
from langdetect import detect
from deep_translator import GoogleTranslator
import nltk

# Download NLTK resources
nltk.download('stopwords')
nltk.download('wordnet')
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer

# --- FastAPI App ---
app = FastAPI(title="EdgeFinder API", version="6.0")

# --- Reddit API Setup ---
reddit = praw.Reddit(
    client_id=os.getenv("REDDIT_CLIENT_ID"),
    client_secret=os.getenv("REDDIT_CLIENT_SECRET"),
    user_agent="EdgeFinderGPT/6.0"
)

# --- Google Trends Setup ---
pytrends = TrendReq(hl="en-US", tz=360)

# --- Cache (15 min TTL) ---
cache = TTLCache(maxsize=100, ttl=900)

# --- Sentiment Analyzer ---
sentiment_analyzer = SentimentIntensityAnalyzer()

# --- API Key Security (Optional) ---
API_KEY = os.getenv("EDGEFINDER_API_KEY")
def verify_key(x_api_key: str = Query(None)):
    if API_KEY and x_api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Unauthorized")
    return True

# --- Helpers ---
def calculate_opportunity_score(reddit_score, trend_score, sentiment_score):
    return int((reddit_score * 0.5) + (trend_score * 0.3) + (sentiment_score * 0.2))

def fetch_trend_score(topic: str) -> Dict:
    pytrends.build_payload([topic], cat=0, timeframe='now 7-d', geo='', gprop='')
    data = pytrends.interest_over_time()
    if data.empty:
        return {"avg": 0, "trend_direction": "neutral"}
    avg = int(data[topic].mean())
    trend_direction = "rising" if data[topic].iloc[-1] > data[topic].iloc[0] else "falling"
    return {"avg": avg, "trend_direction": trend_direction}

def analyze_sentiment(text: str) -> float:
    return sentiment_analyzer.polarity_scores(text)["compound"]

def extract_keywords(posts: List[str]) -> List[str]:
    lemmatizer = WordNetLemmatizer()
    stops = set(stopwords.words('english'))
    words = " ".join(posts).lower().split()
    filtered = [lemmatizer.lemmatize(w) for w in words if w.isalpha() and w not in stops]
    common = [w for w, _ in Counter(filtered).most_common(10)]
    return common

def translate_if_needed(text: str) -> str:
    try:
        lang = detect(text)
        if lang != "en":
            return GoogleTranslator(source='auto', target='en').translate(text)
        return text
    except:
        return text

async def fetch_reddit_posts(topic: str, trend_data: Dict) -> List[Dict]:
    subreddit = reddit.subreddit("all")
    posts = []
    seen_urls = set()

    for submission in subreddit.search(topic, sort="hot", limit=10):
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
        score = calculate_opportunity_score(submission.score, trend_data["avg"], avg_sentiment)

        posts.append({
            "topic": topic,
            "title": translate_if_needed(submission.title),
            "url": f"https://reddit.com{submission.permalink}",
            "reddit_score": submission.score,
            "google_trend_score": trend_data["avg"],
            "trend_direction": trend_data["trend_direction"],
            "sentiment_score": round(avg_sentiment, 3),
            "opportunity_score": score,
            "proof_comments": comments
        })
    return posts

# --- Endpoints ---
@app.get("/radar-sweep")
async def radar_sweep(domain: str, auth: bool = Depends(verify_key)):
    if domain in cache:
        return cache[domain]

    trend_data = fetch_trend_score(domain)
    posts = await fetch_reddit_posts(domain, trend_data)
    posts.sort(key=lambda x: x["opportunity_score"], reverse=True)
    keywords = extract_keywords([p["title"] for p in posts])

    result = {
        "topic": domain,
        "google_trend": trend_data,
        "keywords": keywords,
        "timestamp": datetime.utcnow().isoformat(),
        "top_opportunities": posts[:5],
        "suggested_next_topics": keywords[:5]
    }
    cache[domain] = result
    return result

@app.get("/multi-scan")
async def multi_scan(domains: str, auth: bool = Depends(verify_key)):
    topics = [d.strip() for d in domains.split(",")]
    tasks = [fetch_reddit_posts(t, fetch_trend_score(t)) for t in topics]
    results = await asyncio.gather(*tasks)
    all_posts = [p for topic_posts in results for p in topic_posts]
    all_posts.sort(key=lambda x: x["opportunity_score"], reverse=True)
    return {
        "scanned_topics": topics,
        "ranked_opportunities": all_posts[:10],
        "timestamp": datetime.utcnow().isoformat()
    }

@app.get("/radar-deep-scan")
async def radar_deep_scan(domain: str, auth: bool = Depends(verify_key)):
    trend_data = fetch_trend_score(domain)
    posts = await fetch_reddit_posts(domain, trend_data)
    posts.sort(key=lambda x: x["opportunity_score"], reverse=True)
    return {
        "topic": domain,
        "google_trend": trend_data,
        "deep_opportunities": posts[:5],
        "timestamp": datetime.utcnow().isoformat()
    }

@app.get("/export")
async def export_data(domain: str, format: str = "json", auth: bool = Depends(verify_key)):
    if domain not in cache:
        await radar_sweep(domain)
    data = cache[domain]["top_opportunities"]
    df = pd.DataFrame(data)
    if format == "csv":
        file = f"{domain}_radar_export.csv"
        df.to_csv(file, index=False)
        return {"file": file}
    return cache[domain]

@app.get("/")
def root():
    return {
        "status": "EdgeFinder API is live!",
        "endpoints": ["/radar-sweep", "/multi-scan", "/radar-deep-scan", "/export"]
    }
