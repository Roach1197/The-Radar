import os
import praw
from fastapi import FastAPI, Query
from pytrends.request import TrendReq

app = FastAPI(title="EdgeFinder API", version="1.0")

# --- Reddit API Setup ---
reddit = praw.Reddit(
    client_id=os.getenv("REDDIT_CLIENT_ID"),
    client_secret=os.getenv("REDDIT_CLIENT_SECRET"),
    user_agent="EdgeFinderGPT/1.0"
)

@app.get("/radar-sweep")
def radar_sweep(domain: str = Query("AI", description="Topic to scan (e.g. AI, side hustle)")):
    results = []

    # --- Reddit Scan ---
    subreddits = "Entrepreneur+SideHustle+AItools+SmallBusiness"
    subreddit = reddit.subreddit(subreddits)
    for post in subreddit.hot(limit=15):
        if domain.lower() in post.title.lower():
            results.append({
                "title": f"Reddit: {post.title}",
                "scores": {"ease": 7, "roi": 8, "novelty": 8},
                "proof_links": [f"https://reddit.com{post.permalink}"]
            })

    # --- Google Trends Scan ---
    pytrends = TrendReq(hl='en-US', tz=360)
    pytrends.build_payload([domain], cat=0, timeframe='now 7-d', geo='', gprop='')
    rising = pytrends.related_queries()[domain]['rising']

    if rising is not None:
        for _, row in rising.head(5).iterrows():
            results.append({
                "title": f"Google Trend: {row['query']}",
                "scores": {"ease": 6, "roi": 7, "novelty": 9},
                "proof_links": ["https://trends.google.com"]
            })

    return {"results": results}
