# Szczegółowy Plan Integracji API dla AI Research Oracle System 🔮

## Overview: APIs dla Predykcji Wpływu

Oracle system potrzebuje API do zbierania **early signals** (pierwsze 7 dni) które pozwolą przewidzieć przyszłe cytowania. Priorytet: szybkie sygnały społeczne i implementation tracking.

## 1. ArXiv API - Źródło Papers (FOUNDATION)

### Konfiguracja w Make.com
```
Module: HTTP Request
URL: http://export.arxiv.org/api/query
Method: GET
Headers: None required
Rate Limit: 1 request per 3 seconds
```

### Parametry zapytania:
```json
{
  "search_query": "cat:cs.AI OR cat:cs.LG OR cat:cs.CL OR cat:cs.CV",
  "start": 0,
  "max_results": 50,
  "sortBy": "submittedDate",
  "sortOrder": "descending"
}
```

### Parsowanie XML w Make.com:
1. **XML Parser Module**
   - Input: HTTP Response Body
   - Root element: `feed`
   - Extract: `entry[]` array

2. **Iterator Module**
   - Array: `entry[]`
   - Map each paper

3. **Data Mapping**:
   ```
   title: {{entry.title}}
   arxiv_id: {{split(entry.id, "/")[last]}}
   authors: {{map(entry.author; "name")}}
   abstract: {{entry.summary}}
   pdf_url: {{filter(entry.link; title = "pdf")[0].href}}
   published: {{entry.published}}
   ```

## 2. Semantic Scholar API - Author Metrics (CRITICAL for Early Signals)

### Konfiguracja - Author Search
```
Module: HTTP Request
URL: https://api.semanticscholar.org/graph/v1/author/search
Method: GET
Headers: None (free tier available)
```

### Parametry zapytania:
```
query={author_name}
fields=authorId,name,hIndex,citationCount,paperCount
```

### Mapowanie danych:
```javascript
// Extract max h-index among all authors
const authors = {{map(entry.author; "name")}};
const hIndexes = [];

for(let author of authors) {
  const result = searchAuthor(author);
  if(result) hIndexes.push(result.hIndex);
}

const maxHIndex = Math.max(...hIndexes);
```

## 3. Twitter API v2 - Social Buzz Tracking (NEW PRIORITY!)

### Konfiguracja
```
Module: HTTP Request
URL: https://api.twitter.com/2/tweets/search/recent
Method: GET
Headers: 
  Authorization: Bearer {{twitter_bearer_token}}
```

### Search Parameters:
```javascript
{
  "query": `("${arxiv_id}" OR "${paper_title}") -is:retweet`,
  "max_results": 100,
  "tweet.fields": "public_metrics,author_id,created_at",
  "expansions": "author_id"
}
```

### Metrics Extraction:
```javascript
// Calculate engagement within 24h
const tweets24h = tweets.filter(t => 
  (Date.now() - new Date(t.created_at)) < 24*60*60*1000
);

const metrics = {
  mentions_24h: tweets24h.length,
  total_retweets: sum(tweets24h.map(t => t.public_metrics.retweet_count)),
  total_likes: sum(tweets24h.map(t => t.public_metrics.like_count)),
  unique_authors: new Set(tweets24h.map(t => t.author_id)).size,
  has_influencer: checkInfluencers(tweets24h.map(t => t.author_id))
};
```

## 4. GitHub API - Implementation Tracking (HIGH SIGNAL VALUE!)

### Search for Implementations
```
Module: GitHub - Search Repositories
Query: "{paper_title}" OR "{arxiv_id}" language:python created:>{published_date}
Sort: stars
Order: desc
```

### API Configuration:
```
URL: https://api.github.com/search/repositories
Headers: 
  Authorization: Bearer {{github_token}}
  Accept: application/vnd.github.v3+json
```

### Signal Extraction:
```javascript
// Check for early implementations
const implementations = searchResults.items.filter(repo => {
  const daysSinceCreated = (Date.now() - new Date(repo.created_at)) / (1000*60*60*24);
  return daysSinceCreated <= 7;
});

const githubSignal = {
  has_implementation: implementations.length > 0,
  total_stars_7d: sum(implementations.map(r => r.stargazers_count)),
  implementation_count: implementations.length,
  fastest_implementation_hours: min(implementations.map(r => 
    (new Date(r.created_at) - new Date(paper.published)) / (1000*60*60)
  ))
};
```

## 5. Altmetric API - Academic Buzz (OPTIONAL but VALUABLE)

### Konfiguracja
```
Module: HTTP Request
URL: https://api.altmetric.com/v1/arxiv/{arxiv_id}
Method: GET
Headers:
  Authorization: Bearer {{altmetric_key}}
```

### Valuable Metrics:
```javascript
{
  "mendeley_readers_count": 45,  // Strong predictor!
  "twitter_mentions": 23,
  "news_mentions": 2,
  "blog_mentions": 5,
  "policy_mentions": 1,
  "score": 67.5  // Altmetric attention score
}
```

## 6. Crossref Event Data - Free Alternative to Altmetric

### Configuration
```
URL: https://api.eventdata.crossref.org/v1/events
Method: GET
No auth required!
```

### Query for ArXiv paper:
```
obj-id=https://arxiv.org/abs/{arxiv_id}
from-collected-date={published_date}
```

### Parse Events:
```javascript
const events = response.message.events;
const eventCounts = {
  twitter: events.filter(e => e.source_id === "twitter").length,
  reddit: events.filter(e => e.source_id === "reddit").length,
  wikipedia: events.filter(e => e.source_id === "wikipedia").length,
  news: events.filter(e => e.source_id === "newsfeed").length
};
```
## 7. Reddit API - Academic Community Signals

### OAuth Setup
```javascript
// Get access token
const tokenResponse = await fetch('https://www.reddit.com/api/v1/access_token', {
  method: 'POST',
  headers: {
    'Authorization': 'Basic ' + btoa(client_id + ':' + client_secret),
    'Content-Type': 'application/x-www-form-urlencoded'
  },
  body: 'grant_type=client_credentials'
});
```

### Search r/MachineLearning
```
URL: https://oauth.reddit.com/r/MachineLearning/search
Headers:
  Authorization: Bearer {{reddit_token}}
  User-Agent: AIResearchOracle/1.0
Params:
  q: {arxiv_id} OR {paper_title}
  restrict_sr: true
  sort: hot
  limit: 25
```

### Signal Extraction:
```javascript
const redditSignal = {
  posts_count: results.length,
  total_score: sum(results.map(p => p.score)),
  total_comments: sum(results.map(p => p.num_comments)),
  has_discussion: results.some(p => p.num_comments > 10),
  highest_score: max(results.map(p => p.score))
};
```

## 8. Early Signals Aggregation Algorithm

### Master Scoring Function
```javascript
function calculateEarlySignalsScore(paper, signals) {
  let score = 0;
  
  // AUTHOR SIGNALS (40 points max)
  const authorScore = {
    hIndex: Math.min(signals.maxAuthorHIndex / 2, 15),
    topInstitution: signals.hasTopInstitution ? 10 : 0,
    trackRecord: signals.authorPrevBreakthroughs ? 10 : 0,
    industry: signals.hasIndustryAuthor ? 5 : 0
  };
  score += sum(Object.values(authorScore));
  
  // SOCIAL BUZZ (30 points max)
  const socialScore = {
    twitterMentions: Math.min(signals.twitter.mentions_24h / 10, 10),
    githubStars: signals.github.has_implementation ? 
                 Math.min(signals.github.total_stars_7d / 10, 5) : 0,
    redditScore: Math.min(signals.reddit.highest_score / 50, 5),
    mendeleyReaders: Math.min(signals.altmetric.mendeley_readers / 20, 5),
    newsPickup: signals.altmetric.news_mentions > 0 ? 5 : 0
  };
  score += sum(Object.values(socialScore));
  
  // CONTENT SIGNALS (20 points max)
  const contentScore = {
    hasCode: paper.abstract.toLowerCase().includes('github.com') ? 5 : 0,
    hasDataset: paper.abstract.toLowerCase().includes('dataset') ? 3 : 0,
    claimsSOTA: /state-of-the-art|sota|outperform/i.test(paper.abstract) ? 7 : 0,
    novelMethod: /novel|first|new approach|propose/i.test(paper.abstract) ? 5 : 0
  };
  score += sum(Object.values(contentScore));
  
  // TOPIC MOMENTUM (10 points max)
  const topicScore = {
    trendingKeywords: calculateKeywordTrend(paper.title) * 5,
    emergingField: isEmergingField(paper.categories) ? 5 : 0
  };
  score += sum(Object.values(topicScore));
  
  return {
    total: Math.min(score, 100),
    breakdown: {
      author: sum(Object.values(authorScore)),
      social: sum(Object.values(socialScore)),
      content: sum(Object.values(contentScore)),
      topic: sum(Object.values(topicScore))
    },
    signals: signals
  };
}
```

## 9. ML Prediction API Integration

### Custom API Endpoint
```
URL: https://your-oracle-api.herokuapp.com/predict
Method: POST
Headers:
  Content-Type: application/json
  X-API-Key: {{oracle_api_key}}
```

### Request Body:
```json
{
  "paper": {
    "arxiv_id": "2024.12345",
    "title": "...",
    "abstract": "...",
    "authors": [...],
    "categories": [...]
  },
  "early_signals": {
    "author_metrics": {...},
    "social_metrics": {...},
    "content_features": {...}
  },
  "model_version": "v2.1"
}
```

### Response:
```json
{
  "predictions": {
    "citations": {
      "1_year": 23,
      "3_years": 156,
      "5_years": 412
    },
    "impact": {
      "percentile": 89,
      "category": "high_impact",
      "breakthrough_probability": 0.34
    },
    "confidence": {
      "score": 0.82,
      "factors": [
        "Strong author track record",
        "Early GitHub adoption",
        "Novel methodology"
      ]
    }
  },
  "similar_papers": [...],
  "recommended_actions": [
    "Monitor weekly",
    "Flag for VC newsletter"
  ]
}
```

## 10. Airtable Schema - Updated for Oracle

### Papers Table - New Fields:
```javascript
{
  // Existing fields...
  
  // Early Signals Fields
  "early_signals_score": number(0-100),
  "author_max_h_index": number,
  "has_top_institution": checkbox,
  "has_industry_author": checkbox,
  
  // Social Signals
  "twitter_mentions_24h": number,
  "twitter_mentions_7d": number,
  "github_repos_7d": number,
  "github_stars_7d": number,
  "reddit_score": number,
  "mendeley_readers": number,
  
  // Predictions
  "needs_prediction": formula("early_signals_score > 60"),
  "predicted": checkbox,
  "predicted_citations_1yr": number,
  "predicted_citations_3yr": number,
  "prediction_confidence": number(0-1),
  "breakthrough_probability": number(0-1),
  "prediction_date": date,
  
  // Tracking
  "actual_citations_1yr": number,
  "actual_citations_3yr": number,
  "prediction_accuracy": formula,
  "checked_date": date
}
```

### Predictions Table (NEW):
```javascript
{
  "prediction_id": autonumber,
  "paper_id": link(Papers),
  "prediction_date": date,
  "model_version": text,
  "features_snapshot": long_text(JSON),
  "predicted_values": long_text(JSON),
  "confidence_score": number,
  "public_url": url,
  "social_posts": attachments
}
```

## 11. Rate Limiting & Optimization

### API Limits Management:
```javascript
const rateLimits = {
  arxiv: { requests: 1, per: 3000 },      // 1 per 3s
  twitter: { requests: 300, per: 900000 }, // 300 per 15min
  github: { requests: 30, per: 60000 },    // 30 per minute
  reddit: { requests: 60, per: 60000 },    // 60 per minute
  altmetric: { requests: 1000, per: 86400000 } // 1000 per day
};

// Implement exponential backoff
async function rateLimitedRequest(api, requestFn) {
  const limiter = rateLimiters[api];
  await limiter.removeTokens(1);
  
  try {
    return await requestFn();
  } catch(error) {
    if(error.status === 429) {
      await sleep(Math.pow(2, attempt) * 1000);
      return rateLimitedRequest(api, requestFn);
    }
    throw error;
  }
}
```

## 12. Cost Optimization

### Monthly Budget Allocation:
```
Twitter API Basic: $100 (essential for social signals)
Make.com Teams: $29 (increased operations)
ML Hosting: $20 (Heroku/Railway)
Altmetric: $50 (optional but valuable)
GitHub: $0 (free tier sufficient)
Reddit: $0 (free tier)
ArXiv: $0 (always free)
Semantic Scholar: $0 (free tier)

Total: $199/month (under $200 target)
```

### Operation Optimization:
1. **Batch Processing**: Group papers by publication date
2. **Conditional APIs**: Only call expensive APIs for high-score papers
3. **Caching**: Store author metrics for 30 days
4. **Smart Scheduling**: Spread API calls throughout the day

## 13. Quick Implementation Priority

### Week 1 - Core Early Signals:
1. ArXiv crawler ✓
2. Author h-index lookup ✓
3. Twitter mentions counter ✓
4. Basic scoring algorithm ✓

### Week 2 - Enhanced Signals:
1. GitHub implementation tracker
2. Reddit discussion monitor
3. Altmetric/Crossref integration
4. ML prediction API

### Week 3 - Automation:
1. Full Make.com pipeline
2. Airtable automation
3. Content generation
4. Public tracker

---

*Remember: The goal is to predict impact, not wait for it. Every API integration should contribute to early signal detection within the first 7 days of publication.* 🔮