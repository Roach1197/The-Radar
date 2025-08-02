import os
import praw
import asyncio
import aiohttp
import pandas as pd
from fastapi import FastAPI, Query, Depends, HTTPException
from pytrends.request import TrendReq
from datetime import datetime, timedelta
from typing import List, Dict
from textblob import TextBlob
from collections import Counter
from cachetools import TTLCache

# --- FastAPI App ---
app = FastAPI(title="EdgeFinder API", version="5.0")

# --- Reddit API Setup ---
reddit = praw.Reddit(
    client_id=os.getenv("REDDIT_CLIENT_ID"),
    client_secret=os.getenv("REDDIT_CLIENT_SECRET"),
    user_agent="EdgeFinderGPT/5.0"
)

# --- Google Trends Setup ---
pytrends = TrendReq(hl="en-US", tz=360)

# --- Cache (TTL: 15 min) ---
cache = TTLCache(maxsize=100, ttl=900)

# --- API Key Security (Optional) ---
API_KEY = os.getenv("EDGEFINDER_API_KEY")
def verify_key(x_api_key: str = Query(None)):
    if API_KEY and x_api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Unauthorized")
    return True

# --- Helpers ---
def calculate_opportunity_score(reddit_score, trend_score, sentiment_score):
    return int((reddit_score * 0.5) + (trend_score * 0.3) + (sentiment_score * 0.2))

def fetch_trend_score(topic: str) -> int:
    pytrends.build_payload([topic], cat=0, timeframe='now 7-d', geo='', gprop='')
    data = pytrends.interest_over_time()
    return int(data[topic].mean()) if not data.empty else 0

def analyze_sentiment(text: str) -> float:
    return TextBlob(text).sentiment.polarity  # -1 (neg) to +1 (pos)

def extract_keywords(posts: List[str]) -> List[str]:
    words = " ".join(posts).lower().split()
    common = [w for w, _ in Counter(words).most_common(10) if len(w) > 4]
    return common

def translate_text(text: str) -> str:
    # Placeholder: Normally integrate DeepL/Google Translate API
    return text  # Assume English for now; stub for extension

async def fetch_reddit_posts(topic: str, trend_score: int) -> List[Dict]:
    subreddit = reddit.subreddit("all")
    posts = []
    seen_urls = set()

    async for submission in subreddit.search(topic, sort="hot", limit=10):
        if submission.url in seen_urls: continue
        seen_urls.add(submission.url)

        comments = []
        submission.comments.replace_more(limit=0)
        for c in submission.comments[:3]:
            translated = translate_text(c.body)
            sentiment = analyze_sentiment(translated)
            comments.append({
                "author": c.author.name if c.author else "Unknown",
                "body": translated[:250],
                "sentiment": sentiment
            })

        avg_sentiment = sum(c["sentiment"] for c in comments) / len(comments) if comments else 0
        score = calculate_opportunity_score(submission.score, trend_score, avg_sentiment)

        posts.append({
            "topic": topic,
            "title": submission.title,
            "url": f"https://reddit.com{submission.permalink}",
            "reddit_score": submission.score,
            "google_trend_score": trend_score,
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

    trend_score = fetch_trend_score(domain)
    posts = await fetch_reddit_posts(domain, trend_score)
    posts.sort(key=lambda x: x["opportunity_score"], reverse=True)

    keywords = extract_keywords([p["title"] for p in posts])
    result = {
        "topic": domain,
        "google_trend_score": trend_score,
        "keywords": keywords,
        "timestamp": datetime.utcnow().isoformat(),
        "top_opportunities": posts[:5]
    }
    cache[domain] = result
    return result

@app.get("/multi-scan")
async def multi_scan(domains: str, auth: bool = Depends(verify_key)):
    topics = [d.strip() for d in domains.split(",")]
    tasks = [asyncio.create_task(fetch_reddit_posts(t, fetch_trend_score(t))) for t in topics]
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
    trend_score = fetch_trend_score(domain)
    posts = await fetch_reddit_posts(domain, trend_score)
    posts.sort(key=lambda x: x["opportunity_score"], reverse=True)
    return {
        "topic": domain,
        "google_trend_score": trend_score,
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
    return {"status": "EdgeFinder API is live!", "endpoints": ["/radar-sweep", "/multi-scan", "/radar-deep-scan", "/export"]}
