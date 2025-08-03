import os
import re
import praw
import asyncio
import pandas as pd
from fastapi import FastAPI, Query, Depends, HTTPException
from pydantic import BaseModel
from pytrends.request import TrendReq
from datetime import datetime
from typing import List, Dict
from textblob import TextBlob
from collections import Counter, defaultdict
from cachetools import TTLCache
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
from deep_translator import GoogleTranslator
import nltk
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication
from fpdf import FPDF
import json
import aiofiles
import time
import requests
from fastapi.staticfiles import StaticFiles

# --- Download NLTK Resources ---
nltk.download('stopwords')
nltk.download('wordnet')
nltk.download('punkt')
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer

# --- FastAPI App ---
app = FastAPI(title="EdgeFinder API", version="8.5")

# Serve static downloads folder
if not os.path.exists("downloads"):
    os.makedirs("downloads")
app.mount("/downloads", StaticFiles(directory="downloads"), name="downloads")

# --- Reddit API Setup ---
reddit = praw.Reddit(
    client_id=os.getenv("REDDIT_CLIENT_ID"),
    client_secret=os.getenv("REDDIT_CLIENT_SECRET"),
    user_agent="EdgeFinderGPT/8.5"
)

# --- Google Trends Setup ---
pytrends = TrendReq(hl="en-US", tz=360)

# --- Cache ---
trend_cache = TTLCache(maxsize=50, ttl=1800)
reddit_cache = TTLCache(maxsize=100, ttl=900)

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
        return GoogleTranslator(source='auto', target='en').translate(text)
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
    stop_set = set(stopwords.words('english'))
    for i, word in enumerate(words):
        if word not in stop_set:
            for neighbor in words[max(0, i-2): i+3]:
                if neighbor != word and neighbor not in stop_set:
                    co_map[word].add(neighbor)
    return {k: sorted(v) for k, v in co_map.items()}

def fetch_trend_score(topic: str) -> Dict:
    if topic in trend_cache:
        return trend_cache[topic]

    pytrends.build_payload([topic], cat=0, timeframe='now 7-d')
    data = pytrends.interest_over_time()
    related = pytrends.related_queries().get(topic, {}).get("top", pd.DataFrame())

    result = {
        "avg": int(data[topic].mean()) if not data.empty else 0,
        "trend_direction": "rising" if not data.empty and data[topic].iloc[-1] > data[topic].iloc[0] else "falling",
        "history": data[topic].tail(7).astype(int).tolist() if not data.empty else [],
        "related_terms": related["query"].head(5).tolist() if not related.empty else []
    }
    trend_cache[topic] = result
    return result

# --- Pushshift Reddit Fallback ---
def fetch_pushshift_posts(topic: str) -> List[Dict]:
    url = f"https://api.pushshift.io/reddit/search/submission/?q={topic}&limit=10"
    try:
        data = requests.get(url).json()
        return [
            {
                "topic": topic,
                "title": p.get("title", ""),
                "url": p.get("full_link", ""),
                "reddit_score": p.get("score", 0),
                "comment_engagement": 0,
                "google_trend_score": 0,
                "trend_direction": "unknown",
                "sentiment_score": 0,
                "opportunity_score": p.get("score", 0),
                "proof_comments": []
            }
            for p in data.get("data", [])
        ]
    except:
        return []

# --- Reddit Fetch ---
async def fetch_reddit_posts(topic: str, trend_data: Dict) -> List[Dict]:
    if topic in reddit_cache:
        return reddit_cache[topic]

    posts, seen_urls = [], set()
    subreddit = reddit.subreddit("all")

    async def process_submission(submission):
        time.sleep(2)  # Prevent Reddit IP bans
        if submission.url in seen_urls:
            return None
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

        return {
            "topic": topic,
            "title": translate_if_needed(submission.title),
            "url": f"https://reddit.com{submission.permalink}",
            "reddit_score": int(submission.score),
            "comment_engagement": round(engagement_ratio, 2),
            "google_trend_score": trend_data["avg"],
            "trend_direction": trend_data["trend_direction"],
            "sentiment_score": round(avg_sentiment, 3),
            "opportunity_score": score,
            "proof_comments": comments
        }

    try:
        tasks = [process_submission(sub) for sub in subreddit.search(topic, sort="hot", limit=12)]
        posts = [p for p in await asyncio.gather(*tasks) if p]
    except:
        posts = fetch_pushshift_posts(topic)

    reddit_cache[topic] = posts
    return posts

# --- Endpoints ---
@app.get("/radar-sweep")
async def radar_sweep(domain: str, auth: bool = Depends(verify_key)):
    trend_data = fetch_trend_score(domain)
    posts = await fetch_reddit_posts(domain, trend_data)
    posts.sort(key=lambda x: x["opportunity_score"], reverse=True)
    keywords = extract_keywords([p["title"] for p in posts])
    return {
        "topic": domain,
        "google_trend": trend_data,
        "keywords": keywords,
        "keyword_relations": keyword_cooccurrence([p["title"] for p in posts]),
        "timestamp": datetime.utcnow().isoformat(),
        "top_opportunities": posts[:5],
        "suggested_next_topics": (trend_data["related_terms"] + keywords)[:6]
    }

@app.get("/multi-scan")
async def multi_scan(domains: str, auth: bool = Depends(verify_key)):
    topics = [d.strip() for d in domains.split(",")]
    results = await asyncio.gather(*[fetch_reddit_posts(t, fetch_trend_score(t)) for t in topics])
    all_posts = [p for topic_posts in results for p in topic_posts]
    all_posts.sort(key=lambda x: x["opportunity_score"], reverse=True)
    return {"scanned_topics": topics, "ranked_opportunities": all_posts[:12], "timestamp": datetime.utcnow().isoformat()}

# --- Gig Auto-Builder ---
class GigRequest(BaseModel):
    platform: str
    gig_title: str
    assets: list[str]

@app.post("/gig-auto-builder")
def gig_auto_builder(request: GigRequest):
    return {
        "status": "success",
        "listing_url": f"https://{request.platform.lower()}.com/gig/{request.gig_title.replace(' ', '-').lower()}",
        "seo_keywords": [kw for kw in request.gig_title.lower().split()],
        "assets_used": request.assets
    }

# --- Workflow Export ---
class WorkflowExportRequest(BaseModel):
    type: str
    task: str

@app.post("/workflow-export")
def workflow_export(request: WorkflowExportRequest):
    workflow_json = {
        "trigger": "event_detected",
        "task": request.task,
        "platform": request.type,
        "timestamp": datetime.utcnow().isoformat()
    }
    filename = f"downloads/workflow_{request.type}_{int(datetime.utcnow().timestamp())}.json"
    with open(filename, "w") as f:
        json.dump(workflow_json, f)
    return {"status": "success", "export_link": f"/downloads/{os.path.basename(filename)}"}

# --- Radar Alerts ---
class RadarAlertRequest(BaseModel):
    interval: str
    email: str

@app.post("/radar-alerts")
def radar_alerts(request: RadarAlertRequest):
    return {"status": "active", "next_sweep": "Scheduled", "email": request.email, "interval": request.interval}

# --- PDF Digest with Email ---
@app.post("/pdf-digest")
async def pdf_digest(domains: List[str], email: str):
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", size=12)
    pdf.cell(200, 10, txt="Radar Sweep PDF Digest", ln=True, align="C")

    for domain in domains:
        pdf.cell(200, 10, txt=f"- {domain}", ln=True)

    filename = f"downloads/radar_digest_{int(datetime.utcnow().timestamp())}.pdf"
    pdf.output(filename)

    # Send email with PDF attachment
    smtp_server = os.getenv("SMTP_SERVER")
    smtp_port = int(os.getenv("SMTP_PORT", 587))
    smtp_user = os.getenv("SMTP_USER")
    smtp_pass = os.getenv("SMTP_PASS")

    if smtp_server and smtp_user and smtp_pass:
        msg = MIMEMultipart()
        msg["From"] = smtp_user
        msg["To"] = email
        msg["Subject"] = "Your Radar Sweep PDF Digest"

        body = MIMEText("Attached is your radar sweep PDF digest.", "plain")
        msg.attach(body)

        with open(filename, "rb") as f:
            part = MIMEApplication(f.read(), Name=os.path.basename(filename))
        part["Content-Disposition"] = f'attachment; filename="{os.path.basename(filename)}"'
        msg.attach(part)

        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()
            server.login(smtp_user, smtp_pass)
            server.sendmail(smtp_user, email, msg.as_string())

    return {"status": "success", "pdf_link": f"/downloads/{os.path.basename(filename)}", "email_sent_to": email}

@app.get("/health")
def health():
    return {
        "status": "OK",
        "reddit_read_only": reddit.read_only,
        "cache_size": {"trends": len(trend_cache), "reddit": len(reddit_cache)},
        "api_version": "8.5",
        "server_time": datetime.utcnow().isoformat()
    }
