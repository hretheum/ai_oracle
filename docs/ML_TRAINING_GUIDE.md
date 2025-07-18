# 🤖 ML Model Training Guide for AI Research Oracle

## Quick Start: Your First Prediction Model in 48h

### Day 1: Collect Historical Data

#### Step 1: Download Papers from 2020-2021
```python
import requests
import pandas as pd
from datetime import datetime, timedelta

def collect_historical_papers(start_date, end_date):
    papers = []
    current = start_date
    
    while current <= end_date:
        # ArXiv API call
        query = f"cat:cs.AI AND submittedDate:[{current} TO {current + timedelta(days=7)}]"
        response = requests.get(
            "http://export.arxiv.org/api/query",
            params={
                "search_query": query,
                "max_results": 1000,
                "sortBy": "submittedDate"
            }
        )
        
        # Parse and store
        papers.extend(parse_arxiv_response(response.text))
        current += timedelta(days=7)
        time.sleep(3)  # Rate limit
    
    return pd.DataFrame(papers)

# Collect 2 years of data
papers_df = collect_historical_papers(
    datetime(2020, 1, 1),
    datetime(2021, 12, 31)
)
```

#### Step 2: Get Current Citations
```python
def get_current_citations(arxiv_id):
    # Use Semantic Scholar API
    response = requests.get(
        f"https://api.semanticscholar.org/v1/paper/arXiv:{arxiv_id}",
        params={"fields": "citationCount,influentialCitationCount"}
    )
    if response.status_code == 200:
        data = response.json()
        return data.get('citationCount', 0)
    return 0

# Add citations to dataframe
papers_df['citations_current'] = papers_df['arxiv_id'].apply(get_current_citations)

# Calculate citations at different time points
papers_df['years_old'] = (datetime.now() - papers_df['published_date']).dt.days / 365
papers_df['citations_per_year'] = papers_df['citations_current'] / papers_df['years_old']
```

### Day 2: Extract Early Signals Features

#### Step 3: Author Features
```python
def extract_author_features(authors_list):
    features = {
        'author_count': len(authors_list),
        'max_h_index': 0,
        'has_top_institution': False,
        'has_industry_author': False
    }
    
    top_unis = ['MIT', 'Stanford', 'CMU', 'Berkeley', 'Oxford', 'Cambridge']
    companies = ['Google', 'DeepMind', 'OpenAI', 'Meta', 'Microsoft']
    
    for author in authors_list:
        # Get h-index from Semantic Scholar
        h_index = get_author_h_index(author['name'])
        features['max_h_index'] = max(features['max_h_index'], h_index)
        
        # Check affiliations
        affiliation = author.get('affiliation', '')
        if any(uni in affiliation for uni in top_unis):
            features['has_top_institution'] = True
        if any(company in affiliation for company in companies):
            features['has_industry_author'] = True
    
    return features
```

#### Step 4: Content Features
```python
def extract_content_features(paper):
    abstract = paper['abstract'].lower()
    title = paper['title'].lower()
    
    return {
        'abstract_length': len(abstract.split()),
        'title_length': len(title.split()),
        'has_code': 'github.com' in abstract or 'code available' in abstract,
        'claims_sota': any(term in abstract for term in 
                          ['state-of-the-art', 'sota', 'outperform', 'beat']),
        'claims_novel': any(term in abstract for term in 
                           ['novel', 'first', 'new approach', 'propose']),
        'mentions_dataset': 'dataset' in abstract or 'benchmark' in abstract,
        'mentions_realworld': 'real-world' in abstract or 'practical' in abstract
    }
```

#### Step 5: Simulate Early Social Signals
```python
def estimate_early_signals(paper):
    """
    Since we can't get historical Twitter data easily,
    we'll estimate based on paper characteristics
    """
    signals = {
        'estimated_tweets_7d': 0,
        'estimated_github_7d': 0,
        'estimated_reddit_7d': 0
    }
    
    # Papers with code get more GitHub attention
    if paper['has_code']:
        signals['estimated_github_7d'] = np.random.poisson(3)
    
    # SOTA claims get Twitter attention
    if paper['claims_sota']:
        signals['estimated_tweets_7d'] = np.random.poisson(10)
    
    # Industry authors get more social buzz
    if paper['has_industry_author']:
        signals['estimated_tweets_7d'] += np.random.poisson(15)
        signals['estimated_reddit_7d'] = np.random.poisson(5)
    
    # Top institutions get baseline attention
    if paper['has_top_institution']:
        signals['estimated_tweets_7d'] += np.random.poisson(5)
    
    return signals
```

### Day 3: Train Your Model

#### Step 6: Prepare Training Data
```python
# Combine all features
feature_columns = [
    'author_count', 'max_h_index', 'has_top_institution', 'has_industry_author',
    'abstract_length', 'title_length', 'has_code', 'claims_sota', 
    'claims_novel', 'mentions_dataset', 'mentions_realworld',
    'estimated_tweets_7d', 'estimated_github_7d', 'estimated_reddit_7d'
]

X = papers_df[feature_columns]
y = papers_df['citations_current']

# Convert booleans to int
bool_columns = X.select_dtypes(include=['bool']).columns
X[bool_columns] = X[bool_columns].astype(int)

# Split data
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)
```

#### Step 7: Train Multiple Models
```python
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.linear_model import LinearRegression, Ridge
from sklearn.metrics import mean_absolute_error, r2_score
import joblib

models = {
    'linear': LinearRegression(),
    'ridge': Ridge(alpha=1.0),
    'rf': RandomForestRegressor(n_estimators=100, max_depth=10, random_state=42),
    'gbm': GradientBoostingRegressor(n_estimators=100, learning_rate=0.1, random_state=42)
}

results = {}

for name, model in models.items():
    # Train
    model.fit(X_train, y_train)
    
    # Predict
    y_pred = model.predict(X_test)
    
    # Evaluate
    mae = mean_absolute_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)
    
    results[name] = {
        'mae': mae,
        'r2': r2,
        'model': model
    }
    
    print(f"{name}: MAE={mae:.2f}, R²={r2:.3f}")

# Save best model
best_model_name = max(results, key=lambda x: results[x]['r2'])
best_model = results[best_model_name]['model']
joblib.dump(best_model, 'oracle_model_v1.pkl')
```

#### Step 8: Feature Importance Analysis
```python
# For Random Forest, get feature importance
if best_model_name == 'rf':
    importance = pd.DataFrame({
        'feature': feature_columns,
        'importance': best_model.feature_importances_
    }).sort_values('importance', ascending=False)
    
    print("\nTop 10 Most Important Features:")
    print(importance.head(10))
    
    # Visualize
    import matplotlib.pyplot as plt
    plt.figure(figsize=(10, 6))
    plt.barh(importance.head(10)['feature'], importance.head(10)['importance'])
    plt.xlabel('Importance')
    plt.title('Top 10 Feature Importance for Citation Prediction')
    plt.tight_layout()
    plt.savefig('feature_importance.png')
```

### Day 4: Create Prediction Pipeline

#### Step 9: Real-time Feature Extraction
```python
def extract_features_for_new_paper(arxiv_id):
    """Extract all features for a fresh paper"""
    
    # Get paper details
    paper = fetch_arxiv_paper(arxiv_id)
    
    # Author features
    author_features = extract_author_features(paper['authors'])
    
    # Content features
    content_features = extract_content_features(paper)
    
    # Real social signals (not estimates)
    social_features = {
        'twitter_mentions_7d': count_twitter_mentions(arxiv_id, days=7),
        'github_repos_7d': count_github_repos(arxiv_id, days=7),
        'reddit_score_7d': get_reddit_score(arxiv_id, days=7)
    }
    
    # Combine all features
    features = {**author_features, **content_features, **social_features}
    
    return features
```

#### Step 10: Make Predictions with Confidence
```python
def predict_impact(arxiv_id, model_path='oracle_model_v1.pkl'):
    # Load model
    model = joblib.load(model_path)
    
    # Get features
    features = extract_features_for_new_paper(arxiv_id)
    
    # Prepare for prediction
    X = pd.DataFrame([features])[feature_columns]
    X[bool_columns] = X[bool_columns].astype(int)
    
    # Predict
    prediction = model.predict(X)[0]
    
    # Calculate confidence (based on feature strength)
    confidence = calculate_confidence(features, prediction)
    
    # Estimate percentile
    percentile = estimate_percentile(prediction)
    
    return {
        'arxiv_id': arxiv_id,
        'predicted_citations_3yr': int(prediction),
        'predicted_citations_1yr': int(prediction * 0.3),  # rough estimate
        'predicted_citations_5yr': int(prediction * 1.8),  # rough estimate
        'confidence': confidence,
        'percentile': percentile,
        'features': features
    }
```

### Day 5: Deploy as API

#### Step 11: Simple Flask API
```python
from flask import Flask, request, jsonify
import joblib
import pandas as pd

app = Flask(__name__)

# Load model at startup
model = joblib.load('oracle_model_v1.pkl')

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Get paper ID
        arxiv_id = request.json['arxiv_id']
        
        # Extract features
        features = extract_features_for_new_paper(arxiv_id)
        
        # Prepare for prediction
        X = pd.DataFrame([features])[feature_columns]
        X[bool_columns] = X[bool_columns].astype(int)
        
        # Predict
        prediction = model.predict(X)[0]
        
        # Calculate extras
        confidence = min(0.85, max(0.5, prediction / 100))  # Simple confidence
        percentile = calculate_percentile(prediction)
        
        return jsonify({
            'success': True,
            'prediction': {
                'citations_1yr': int(prediction * 0.3),
                'citations_3yr': int(prediction),
                'citations_5yr': int(prediction * 1.8),
                'confidence': float(confidence),
                'percentile': int(percentile)
            },
            'features_used': features
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

#### Step 12: Deploy to Production
```bash
# requirements.txt
flask==2.0.1
pandas==1.3.3
numpy==1.23.0
scikit-learn==0.24.2
joblib==1.0.1
requests==2.26.0
gunicorn==20.1.0

# Procfile (for Heroku)
web: gunicorn app:app

# Deploy
git init
git add .
git commit -m "Oracle API v1"
heroku create ai-research-oracle-api
git push heroku main
```

## Advanced Improvements

### Better Features
```python
# Network features
'coauthor_network_size': count_unique_coauthors(author),
'author_recent_papers': count_papers_last_2_years(author),
'author_citation_velocity': author_citations_per_year,

# Topic features
'topic_papers_last_year': count_papers_in_topic(keywords),
'topic_growth_rate': calculate_topic_growth(keywords),
'keywords_trending_score': get_trending_score(keywords),

# Timing features
'published_day_of_week': paper.published_date.weekday(),
'published_near_conference': days_to_nearest_conference(date),
'competition_same_week': count_similar_papers_same_week(),
```

### Ensemble Approach
```python
# Train multiple models
models = {
    'rf': RandomForestRegressor(),
    'xgb': XGBRegressor(),
    'nn': build_neural_network()
}

# Weighted predictions
weights = {'rf': 0.4, 'xgb': 0.4, 'nn': 0.2}
final_prediction = sum(
    models[name].predict(X) * weight 
    for name, weight in weights.items()
)
```

### Confidence Calibration
```python
def calculate_confidence(features, prediction):
    # Base confidence on feature quality
    confidence = 0.5
    
    # Strong author signal
    if features['max_h_index'] > 30:
        confidence += 0.1
    
    # Strong social signal
    if features['twitter_mentions_7d'] > 20:
        confidence += 0.1
    
    # Has code implementation
    if features['has_code']:
        confidence += 0.05
    
    # Novel claims with evidence
    if features['claims_novel'] and features['has_code']:
        confidence += 0.1
    
    # Cap confidence
    return min(0.9, confidence)
```

## Testing Your Oracle

### Backtest on 2022 Papers
```python
# Get 2022 papers
test_papers = collect_historical_papers(
    datetime(2022, 1, 1),
    datetime(2022, 12, 31)
)

# Make predictions
predictions = []
for _, paper in test_papers.iterrows():
    pred = predict_impact(paper['arxiv_id'])
    predictions.append(pred)

# Wait for actual citations (or check now for 2022)
# Calculate accuracy metrics
```

### A/B Test Content
```python
# Version A: Just prediction
"This paper will get 156 citations"

# Version B: With confidence  
"This paper will get 156 citations (78% confidence)"

# Version C: With explanation
"This paper will get 156 citations because:
- Lead author h-index: 45
- 25 tweets in first week  
- 3 GitHub implementations"

# Track which gets more engagement
```

## Launch Checklist

### Technical
- [ ] Model trained on 10,000+ papers
- [ ] API deployed and tested
- [ ] Prediction accuracy >60%
- [ ] Feature extraction automated
- [ ] Error handling robust

### Content
- [ ] 20 predictions ready
- [ ] Methodology documented
- [ ] Accuracy disclaimer clear
- [ ] Success stories prepared
- [ ] FAQs answered

### Business
- [ ] Pricing strategy set
- [ ] Legal review done
- [ ] Support system ready
- [ ] Tracking analytics live
- [ ] Press kit prepared

## Remember

1. **Start Simple**: Linear regression beats no prediction
2. **Be Transparent**: Share your accuracy openly
3. **Iterate Fast**: New model version every month
4. **Focus on Value**: Even 60% accuracy helps researchers
5. **Build Trust**: Admit mistakes, celebrate wins

---

*This guide gets you from zero to working Oracle in 5 days. The key is starting simple and improving based on real data. Your first model won't be perfect, but it will be infinitely better than waiting 3 years for citations!* 🔮