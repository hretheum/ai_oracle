# 🤖 PHASE 2: ML Model Development

[← Back to Master Roadmap](./ROADMAP_MASTER.md) | [← Previous: Phase 1](./phase_1_data_collection.md)

## Overview
Budowa i deployment modelu ML do przewidywania cytowań. Od prostego modelu do production API.

## Duration & Resources
- **Total Time**: 1 tydzień (40h pracy)
- **Required Skills**: Python, basic ML, API development
- **Budget**: $20-50/month (hosting)

## Success Criteria
- [ ] Model accuracy >60% on test set
- [ ] API deployed and responding
- [ ] First 10 predictions generated
- [ ] Integration with Make.com working

---

## 2.1 Data Preparation Block [8h]

### Prerequisites
- Historical data exported from Phase 1
- Python environment ready

### Tasks
- [ ] **2.1.1** Load and explore data (1h)
  ```python
  import pandas as pd
  import numpy as np
  import matplotlib.pyplot as plt
  
  # Load data
  df = pd.read_csv('oracle_historical_papers.csv')
  print(f"Total papers: {len(df)}")
  print(f"Date range: {df['submitted_date'].min()} to {df['submitted_date'].max()}")
  print(f"Citations range: {df['citations_current'].min()} to {df['citations_current'].max()}")
  
  # Basic stats
  df.describe()
  ```
  - ✓ **Validation**: Data loaded, no errors

- [ ] **2.1.2** Clean data (1h)
  ```python
  # Remove papers too recent (< 2 years old)
  df['years_old'] = (pd.Timestamp.now() - pd.to_datetime(df['submitted_date'])).dt.days / 365
  df_clean = df[df['years_old'] >= 2].copy()
  
  # Remove outliers (papers with 1000+ citations)
  df_clean = df_clean[df_clean['citations_current'] < 1000]
  
  # Handle missing values
  df_clean['author_h_index'].fillna(0, inplace=True)
  df_clean['github_repos'].fillna(0, inplace=True)
  ```
  - ✓ **Validation**: No null values, reasonable ranges

- [ ] **2.1.3** Feature engineering (2h)
  ```python
  # Create features
  df_clean['has_code'] = df_clean['abstract'].str.contains('github.com|code available', case=False).astype(int)
  df_clean['claims_sota'] = df_clean['abstract'].str.contains('state-of-the-art|sota|outperform', case=False).astype(int)
  df_clean['title_length'] = df_clean['title'].str.split().str.len()
  df_clean['abstract_length'] = df_clean['abstract'].str.split().str.len()
  df_clean['author_count'] = df_clean['authors'].str.count(',') + 1
  
  # Binary features for top institutions
  top_institutions = ['MIT', 'Stanford', 'CMU', 'Berkeley', 'Google', 'DeepMind']
  df_clean['has_top_institution'] = df_clean['authors'].apply(
      lambda x: any(inst in str(x) for inst in top_institutions)
  ).astype(int)
  ```
  - ✓ **Validation**: New features created

- [ ] **2.1.4** Create target variable (1h)
  ```python
  # Normalize citations by age
  df_clean['citations_per_year'] = df_clean['citations_current'] / df_clean['years_old']
  
  # For 3-year prediction (our main target)
  df_clean['citations_3yr_estimated'] = df_clean['citations_per_year'] * 3
  
  # Log transform for better distribution
  df_clean['citations_3yr_log'] = np.log1p(df_clean['citations_3yr_estimated'])
  ```
  - ✓ **Validation**: Target variable distributed normally

### Quality Gate
Clean dataset with 3000+ papers and features? → ✅ Proceed

---

## 2.2 Model Training Block [8h]

### Tasks
- [ ] **2.2.1** Prepare training data (1h)
  ```python
  # Select features
  feature_cols = [
      'author_h_index', 'has_top_institution', 'author_count',
      'has_code', 'claims_sota', 'title_length', 'abstract_length',
      'github_repos', 'early_signals_score'
  ]
  
  X = df_clean[feature_cols]
  y = df_clean['citations_3yr_estimated']
  
  # Split data
  from sklearn.model_selection import train_test_split
  X_train, X_test, y_train, y_test = train_test_split(
      X, y, test_size=0.2, random_state=42
  )
  ```
  - ✓ **Validation**: Train/test split created

- [ ] **2.2.2** Train baseline models (2h)
  ```python
  from sklearn.linear_model import LinearRegression, Ridge
  from sklearn.ensemble import RandomForestRegressor
  from sklearn.metrics import mean_absolute_error, r2_score
  
  models = {
      'linear': LinearRegression(),
      'ridge': Ridge(alpha=1.0),
      'rf': RandomForestRegressor(n_estimators=100, random_state=42)
  }
  
  results = {}
  for name, model in models.items():
      model.fit(X_train, y_train)
      y_pred = model.predict(X_test)
      
      mae = mean_absolute_error(y_test, y_pred)
      r2 = r2_score(y_test, y_pred)
      accuracy_20pct = np.mean(np.abs(y_pred - y_test) / y_test < 0.2)
      
      results[name] = {
          'mae': mae,
          'r2': r2,
          'accuracy_20pct': accuracy_20pct
      }
      print(f"{name}: MAE={mae:.2f}, R²={r2:.3f}, 20% Accuracy={accuracy_20pct:.2%}")
  ```
  - ✓ **Validation**: At least one model >60% accuracy

- [ ] **2.2.3** Optimize best model (2h)
  ```python
  # Assuming RF performed best
  from sklearn.model_selection import GridSearchCV
  
  param_grid = {
      'n_estimators': [100, 200],
      'max_depth': [10, 20, None],
      'min_samples_split': [2, 5, 10]
  }
  
  grid_search = GridSearchCV(
      RandomForestRegressor(random_state=42),
      param_grid,
      cv=5,
      scoring='neg_mean_absolute_error'
  )
  
  grid_search.fit(X_train, y_train)
  best_model = grid_search.best_estimator_
  ```
  - ✓ **Validation**: Improved accuracy

- [ ] **2.2.4** Feature importance analysis (1h)
  ```python
  importances = pd.DataFrame({
      'feature': feature_cols,
      'importance': best_model.feature_importances_
  }).sort_values('importance', ascending=False)
  
  print("Top features:")
  print(importances)
  
  # Visualize
  importances.plot(kind='barh', x='feature', y='importance')
  plt.title('Feature Importance for Citation Prediction')
  plt.tight_layout()
  plt.savefig('feature_importance.png')
  ```
  - ✓ **Validation**: Author h-index in top 3 features

### Quality Gate
Model accuracy >60% within 20% margin? → ✅ Proceed

---

## 2.3 Model Deployment Block [8h]

### Tasks
- [ ] **2.3.1** Save model (30 min)
  ```python
  import joblib
  
  # Save model and metadata
  model_data = {
      'model': best_model,
      'features': feature_cols,
      'version': '1.0',
      'training_date': pd.Timestamp.now().isoformat(),
      'metrics': results
  }
  
  joblib.dump(model_data, 'oracle_model_v1.pkl')
  ```
  - ✓ **Validation**: File created

- [ ] **2.3.2** Create Flask API (2h)
  ```python
  # app.py
  from flask import Flask, request, jsonify
  import joblib
  import pandas as pd
  import numpy as np
  
  app = Flask(__name__)
  
  # Load model
  model_data = joblib.load('oracle_model_v1.pkl')
  model = model_data['model']
  features = model_data['features']
  
  @app.route('/predict', methods=['POST'])
  def predict():
      try:
          # Get features from request
          data = request.json
          
          # Create dataframe
          df = pd.DataFrame([data['features']])
          
          # Ensure all features present
          for feat in features:
              if feat not in df.columns:
                  df[feat] = 0
          
          # Predict
          prediction = model.predict(df[features])[0]
          
          # Calculate confidence (simple version)
          confidence = min(0.85, max(0.5, 0.6 + (prediction / 1000)))
          
          # Estimate percentile
          if prediction < 10:
              percentile = 50
          elif prediction < 50:
              percentile = 75
          elif prediction < 200:
              percentile = 90
          else:
              percentile = 95
          
          return jsonify({
              'success': True,
              'predictions': {
                  'citations_1yr': int(prediction * 0.3),
                  'citations_3yr': int(prediction),
                  'citations_5yr': int(prediction * 1.8)
              },
              'confidence': round(confidence, 2),
              'percentile': percentile,
              'model_version': model_data['version']
          })
          
      except Exception as e:
          return jsonify({
              'success': False,
              'error': str(e)
          }), 400
  
  @app.route('/health', methods=['GET'])
  def health():
      return jsonify({'status': 'healthy', 'model_version': model_data['version']})
  
  if __name__ == '__main__':
      app.run(debug=True, port=5000)
  ```
  - ✓ **Validation**: API responds locally

- [ ] **2.3.3** Test API locally (1h)
  ```bash
  # Start server
  python app.py
  
  # Test prediction
  curl -X POST http://localhost:5000/predict \
    -H "Content-Type: application/json" \
    -d '{
      "features": {
        "author_h_index": 25,
        "has_top_institution": 1,
        "author_count": 3,
        "has_code": 1,
        "claims_sota": 1,
        "title_length": 12,
        "abstract_length": 250,
        "github_repos": 2,
        "early_signals_score": 75
      }
    }'
  ```
  - ✓ **Validation**: Returns prediction JSON

- [ ] **2.3.4** Deploy to Railway (2h)
  - Create requirements.txt
  - Add Procfile: `web: gunicorn app:app`
  - Push to GitHub
  - Connect Railway to repo
  - Deploy
  - ✓ **Validation**: Public URL working

### Quality Gate
API deployed and responding? → ✅ Proceed

---

## 2.4 Make.com Integration Block [4h]

### Tasks
- [ ] **2.4.1** Create prediction scenario (1h)
  - New scenario: "Oracle - ML Predictions"
  - Trigger: Daily at 10:00 UTC
  - ✓ **Validation**: Scenario created

- [ ] **2.4.2** Get high-score papers (30 min)
  - Airtable search module
  - Filter: `AND({needs_prediction}, NOT({predicted}))`
  - Limit: 10
  - ✓ **Validation**: Returns papers

- [ ] **2.4.3** Call prediction API (1h)
  ```
  HTTP Request module:
  - URL: https://your-api.railway.app/predict
  - Method: POST
  - Headers: Content-Type: application/json
  - Body: {
      "features": {
        "author_h_index": {{item.author_h_index}},
        "has_top_institution": {{if(item.has_top_institution; 1; 0)}},
        ...
      }
    }
  ```
  - ✓ **Validation**: Returns predictions

- [ ] **2.4.4** Update Airtable (30 min)
  - Update record with predictions
  - Set predicted = true
  - Add prediction_date
  - ✓ **Validation**: Records updated

### Quality Gate
10 papers predicted via automation? → ✅ Phase 2 Complete!

---

## 2.5 First Predictions Quality Check [4h]

### Tasks
- [ ] **2.5.1** Manual review (1h)
  - Check 10 predictions
  - Do they make intuitive sense?
  - ✓ **Validation**: No obvious errors

- [ ] **2.5.2** Create prediction content (2h)
  - For top 5 predictions
  - Write explanations
  - Create visualizations
  - ✓ **Validation**: Content ready

- [ ] **2.5.3** Document methodology (1h)
  - What features we use
  - How we train the model
  - Current accuracy metrics
  - ✓ **Validation**: Published on site

---

## Phase Completion Checklist
- [ ] Model trained with >60% accuracy
- [ ] API deployed and stable
- [ ] Make.com integration working
- [ ] First 10+ predictions made
- [ ] Methodology documented

## Metrics Achieved
- Model accuracy (20% margin): ____%
- API response time: ____ms
- Predictions made: ____
- High confidence predictions: ____

## Next Phase
[→ Phase 3: MVP Launch](./phase_3_mvp_launch.md)

---

**Time Tracking**
- Estimated: 40h
- Actual: ___h
- Blockers: ___________