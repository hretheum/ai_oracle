# Szczegółowy plan integracji API dla systemu AI Research Oracle 🔮

## Przegląd: API dla predykcji wpływu

System Oracle potrzebuje API do zbierania **wczesnych sygnałów** (pierwsze 7 dni) które pozwolą przewidzieć przyszłe cytowania. Priorytet: szybkie sygnały społeczne i śledzenie implementacji.

## 1. ArXiv API - Źródło artykułów (FUNDAMENT)

### Konfiguracja w Make.com
```
Moduł: HTTP Request
URL: http://export.arxiv.org/api/query
Metoda: GET
Nagłówki: Nie wymagane
Limit: 1 żądanie na 3 sekundy
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
1. **Moduł XML Parser**
   - Wejście: HTTP Response Body
   - Element główny: `feed`
   - Wyodrębnij: tablicę `entry[]`

2. **Moduł Iterator**
   - Tablica: `entry[]`
   - Mapuj każdy artykuł

3. **Mapowanie danych**:
   ```
   title: {{entry.title}}
   arxiv_id: {{split(entry.id, "/")[last]}}
   authors: {{map(entry.author; "name")}}
   abstract: {{entry.summary}}
   pdf_url: {{filter(entry.link; title = "pdf")[0].href}}
   published: {{entry.published}}
   ```

## 2. Semantic Scholar API - Metryki autorów (KRYTYCZNE dla wczesnych sygnałów)

### Konfiguracja - Wyszukiwanie autora
```
Moduł: HTTP Request
URL: https://api.semanticscholar.org/graph/v1/author/search
Metoda: GET
Nagłówki: Brak (dostępny darmowy poziom)
```

### Parametry zapytania:
```
query={author_name}
fields=authorId,name,hIndex,citationCount,paperCount
```

### Mapowanie danych:
```javascript
// Wyodrębnij maksymalny h-index spośród wszystkich autorów
const authors = {{map(entry.author; "name")}};
const hIndexes = [];

for(let author of authors) {
  const result = searchAuthor(author);
  if(result) hIndexes.push(result.hIndex);
}

const maxHIndex = Math.max(...hIndexes);
```

## 3. Twitter API v2 - Śledzenie buzzu społecznościowego (NOWY PRIORYTET!)

### Konfiguracja
```
Moduł: HTTP Request
URL: https://api.twitter.com/2/tweets/search/recent
Metoda: GET
Nagłówki: 
  Authorization: Bearer {{twitter_bearer_token}}
```

### Parametry wyszukiwania:
```javascript
{
  "query": `("${arxiv_id}" OR "${paper_title}") -is:retweet`,
  "max_results": 100,
  "tweet.fields": "public_metrics,author_id,created_at",
  "expansions": "author_id"
}
```

### Ekstrakcja metryk:
```javascript
// Oblicz zaangażowanie w ciągu 24h
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

## 4. GitHub API - Śledzenie implementacji (WYSOKA WARTOŚĆ SYGNAŁU!)

### Wyszukiwanie implementacji
```
Moduł: GitHub - Search Repositories
Zapytanie: "{paper_title}" OR "{arxiv_id}" language:python created:>{published_date}
Sortuj: stars
Kolejność: desc
```

### Konfiguracja API:
```
URL: https://api.github.com/search/repositories
Nagłówki: 
  Authorization: Bearer {{github_token}}
  Accept: application/vnd.github.v3+json
```

### Ekstrakcja sygnału:
```javascript
// Sprawdź wczesne implementacje
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

## 5. Altmetric API - Buzz akademicki (OPCJONALNE ale WARTOŚCIOWE)

### Konfiguracja
```
Moduł: HTTP Request
URL: https://api.altmetric.com/v1/arxiv/{arxiv_id}
Metoda: GET
Nagłówki:
  Authorization: Bearer {{altmetric_key}}
```

### Wartościowe metryki:
```javascript
{
  "mendeley_readers_count": 45,  // Silny predyktor!
  "twitter_mentions": 23,
  "news_mentions": 2,
  "blog_mentions": 5,
  "policy_mentions": 1,
  "score": 67.5  // Wynik uwagi Altmetric
}
```

## 6. Crossref Event Data - Darmowa alternatywa dla Altmetric

### Konfiguracja
```
URL: https://api.eventdata.crossref.org/v1/events
Metoda: GET
Brak autoryzacji wymaganej!
```

### Zapytanie o artykuł ArXiv:
```
obj-id=https://arxiv.org/abs/{arxiv_id}
from-collected-date={published_date}
```

### Parsowanie wydarzeń:
```javascript
const events = response.message.events;
const eventCounts = {
  twitter: events.filter(e => e.source_id === "twitter").length,
  reddit: events.filter(e => e.source_id === "reddit").length,
  wikipedia: events.filter(e => e.source_id === "wikipedia").length,
  news: events.filter(e => e.source_id === "newsfeed").length
};
```

## 7. Reddit API - Sygnały społeczności akademickiej

### Konfiguracja OAuth
```javascript
// Pobierz token dostępu
const tokenResponse = await fetch('https://www.reddit.com/api/v1/access_token', {
  method: 'POST',
  headers: {
    'Authorization': 'Basic ' + btoa(client_id + ':' + client_secret),
    'Content-Type': 'application/x-www-form-urlencoded'
  },
  body: 'grant_type=client_credentials'
});
```

### Wyszukaj r/MachineLearning
```
URL: https://oauth.reddit.com/r/MachineLearning/search
Nagłówki:
  Authorization: Bearer {{reddit_token}}
  User-Agent: AIResearchOracle/1.0
Parametry:
  q: {arxiv_id} OR {paper_title}
  restrict_sr: true
  sort: hot
  limit: 25
```

### Ekstrakcja sygnału:
```javascript
const redditSignal = {
  posts_count: results.length,
  total_score: sum(results.map(p => p.score)),
  total_comments: sum(results.map(p => p.num_comments)),
  has_discussion: results.some(p => p.num_comments > 10),
  highest_score: max(results.map(p => p.score))
};
```

## 8. Algorytm agregacji wczesnych sygnałów

### Główna funkcja punktacji
```javascript
function calculateEarlySignalsScore(paper, signals) {
  let score = 0;
  
  // SYGNAŁY AUTORÓW (40 punktów max)
  const authorScore = {
    hIndex: Math.min(signals.maxAuthorHIndex / 2, 15),
    topInstitution: signals.hasTopInstitution ? 10 : 0,
    trackRecord: signals.authorPrevBreakthroughs ? 10 : 0,
    industry: signals.hasIndustryAuthor ? 5 : 0
  };
  score += sum(Object.values(authorScore));
  
  // BUZZ SPOŁECZNOŚCIOWY (30 punktów max)
  const socialScore = {
    twitterMentions: Math.min(signals.twitter.mentions_24h / 10, 10),
    githubStars: signals.github.has_implementation ? 
                 Math.min(signals.github.total_stars_7d / 10, 5) : 0,
    redditScore: Math.min(signals.reddit.highest_score / 50, 5),
    mendeleyReaders: Math.min(signals.altmetric.mendeley_readers / 20, 5),
    newsPickup: signals.altmetric.news_mentions > 0 ? 5 : 0
  };
  score += sum(Object.values(socialScore));
  
  // SYGNAŁY TREŚCI (20 punktów max)
  const contentScore = {
    hasCode: paper.abstract.toLowerCase().includes('github.com') ? 5 : 0,
    hasDataset: paper.abstract.toLowerCase().includes('dataset') ? 3 : 0,
    claimsSOTA: /state-of-the-art|sota|outperform/i.test(paper.abstract) ? 7 : 0,
    novelMethod: /novel|first|new approach|propose/i.test(paper.abstract) ? 5 : 0
  };
  score += sum(Object.values(contentScore));
  
  // DYNAMIKA TEMATU (10 punktów max)
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

## 9. Integracja API predykcji ML

### Niestandardowy endpoint API
```
URL: https://your-oracle-api.herokuapp.com/predict
Metoda: POST
Nagłówki:
  Content-Type: application/json
  X-API-Key: {{oracle_api_key}}
```

### Treść żądania:
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

### Odpowiedź:
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
        "Silny track record autora",
        "Wczesna adopcja GitHub",
        "Nowatorska metodologia"
      ]
    }
  },
  "similar_papers": [...],
  "recommended_actions": [
    "Monitoruj cotygodniowo",
    "Oznacz do newslettera VC"
  ]
}
```

## 10. Schemat Airtable - zaktualizowany dla Oracle

### Tabela Papers - nowe pola:
```javascript
{
  // Istniejące pola...
  
  // Pola wczesnych sygnałów
  "early_signals_score": number(0-100),
  "author_max_h_index": number,
  "has_top_institution": checkbox,
  "has_industry_author": checkbox,
  
  // Sygnały społecznościowe
  "twitter_mentions_24h": number,
  "twitter_mentions_7d": number,
  "github_repos_7d": number,
  "github_stars_7d": number,
  "reddit_score": number,
  "mendeley_readers": number,
  
  // Predykcje
  "needs_prediction": formula("early_signals_score > 60"),
  "predicted": checkbox,
  "predicted_citations_1yr": number,
  "predicted_citations_3yr": number,
  "prediction_confidence": number(0-1),
  "breakthrough_probability": number(0-1),
  "prediction_date": date,
  
  // Śledzenie
  "actual_citations_1yr": number,
  "actual_citations_3yr": number,
  "prediction_accuracy": formula,
  "checked_date": date
}
```

### Tabela Predictions (NOWA):
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

## 11. Limitowanie i optymalizacja

### Zarządzanie limitami API:
```javascript
const rateLimits = {
  arxiv: { requests: 1, per: 3000 },      // 1 na 3s
  twitter: { requests: 300, per: 900000 }, // 300 na 15min
  github: { requests: 30, per: 60000 },    // 30 na minutę
  reddit: { requests: 60, per: 60000 },    // 60 na minutę
  altmetric: { requests: 1000, per: 86400000 } // 1000 na dzień
};

// Implementuj wykładnicze wycofanie
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

## 12. Optymalizacja kosztów

### Miesięczna alokacja budżetu:
```
Twitter API Basic: $100 (niezbędne dla sygnałów społecznościowych)
Make.com Teams: $29 (zwiększone operacje)
Hosting ML: $20 (Heroku/Railway)
Altmetric: $50 (opcjonalne ale wartościowe)
GitHub: $0 (darmowy poziom wystarczający)
Reddit: $0 (darmowy poziom)
ArXiv: $0 (zawsze darmowe)
Semantic Scholar: $0 (darmowy poziom)

Razem: $199/miesiąc (poniżej celu $200)
```

### Optymalizacja operacji:
1. **Przetwarzanie wsadowe**: Grupuj artykuły według daty publikacji
2. **Warunkowe API**: Wywołuj drogie API tylko dla artykułów o wysokim wyniku
3. **Cachowanie**: Przechowuj metryki autorów przez 30 dni
4. **Inteligentne planowanie**: Rozłóż wywołania API przez cały dzień

## 13. Szybki priorytet implementacji

### Tydzień 1 - Główne wczesne sygnały:
1. Crawler ArXiv ✓
2. Wyszukiwanie h-index autora ✓
3. Licznik wzmianek Twitter ✓
4. Podstawowy algorytm punktacji ✓

### Tydzień 2 - Rozszerzone sygnały:
1. Tracker implementacji GitHub
2. Monitor dyskusji Reddit
3. Integracja Altmetric/Crossref
4. API predykcji ML

### Tydzień 3 - Automatyzacja:
1. Pełny pipeline Make.com
2. Automatyzacja Airtable
3. Generowanie treści
4. Publiczny tracker

---

*Pamiętaj: Celem jest przewidywanie wpływu, nie czekanie na niego. Każda integracja API powinna przyczyniać się do wykrywania wczesnych sygnałów w ciągu pierwszych 7 dni od publikacji.* 🔮