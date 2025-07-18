# 🤖 FAZA 2: Rozwój modelu ML

[← Powrót do głównego planu](./ROADMAP_MASTER.md) | [← Poprzednia: Faza 1](./phase_1_data_collection.md)

## Przegląd
Budowa i deployment modelu ML do przewidywania cytowań. Od prostego modelu do produkcyjnego API.

## Czas trwania i zasoby
- **Całkowity czas**: 1 tydzień (40h pracy)
- **Wymagane umiejętności**: Python, podstawowe ML, rozwój API
- **Budżet**: $20-50/miesiąc (hosting)

## Kryteria sukcesu
- [ ] Dokładność modelu >60% na zbiorze testowym
- [ ] API wdrożone i odpowiadające
- [ ] Pierwsze 10 predykcji wygenerowanych
- [ ] Integracja z Make.com działa

---

## 2.1 Blok przygotowania danych [8h]

### Wymagania wstępne
- Dane historyczne wyeksportowane z Fazy 1
- Środowisko Python gotowe

### Zadania
- [ ] **2.1.1** Załaduj i eksploruj dane (1h)
  ```python
  import pandas as pd
  import numpy as np
  import matplotlib.pyplot as plt
  
  # Załaduj dane
  df = pd.read_csv('oracle_historical_papers.csv')
  print(f"Łącznie artykułów: {len(df)}")
  print(f"Zakres dat: {df['submitted_date'].min()} do {df['submitted_date'].max()}")
  print(f"Zakres cytowań: {df['citations_current'].min()} do {df['citations_current'].max()}")
  
  # Podstawowe statystyki
  df.describe()
  ```
  - ✓ **Walidacja**: Dane załadowane, brak błędów

- [ ] **2.1.2** Oczyść dane (1h)
  ```python
  # Usuń artykuły zbyt świeże (< 2 lat)
  df['years_old'] = (pd.Timestamp.now() - pd.to_datetime(df['submitted_date'])).dt.days / 365
  df_clean = df[df['years_old'] >= 2].copy()
  
  # Usuń wartości odstające (artykuły z 1000+ cytowań)
  df_clean = df_clean[df_clean['citations_current'] < 1000]
  
  # Obsłuż brakujące wartości
  df_clean['author_h_index'].fillna(0, inplace=True)
  df_clean['github_repos'].fillna(0, inplace=True)
  ```
  - ✓ **Walidacja**: Brak wartości null, rozsądne zakresy

- [ ] **2.1.3** Inżynieria cech (2h)
  ```python
  # Utwórz cechy
  df_clean['has_code'] = df_clean['abstract'].str.contains('github.com|code available', case=False).astype(int)
  df_clean['claims_sota'] = df_clean['abstract'].str.contains('state-of-the-art|sota|outperform', case=False).astype(int)
  df_clean['title_length'] = df_clean['title'].str.split().str.len()
  df_clean['abstract_length'] = df_clean['abstract'].str.split().str.len()
  df_clean['author_count'] = df_clean['authors'].str.count(',') + 1
  
  # Cechy binarne dla top instytucji
  top_institutions = ['MIT', 'Stanford', 'CMU', 'Berkeley', 'Google', 'DeepMind']
  df_clean['has_top_institution'] = df_clean['authors'].apply(
      lambda x: any(inst in str(x) for inst in top_institutions)
  ).astype(int)
  ```
  - ✓ **Walidacja**: Nowe cechy utworzone

- [ ] **2.1.4** Utwórz zmienną docelową (1h)
  ```python
  # Normalizuj cytowania według wieku
  df_clean['citations_per_year'] = df_clean['citations_current'] / df_clean['years_old']
  
  # Dla predykcji 3-letniej (nasz główny cel)
  df_clean['citations_3yr_estimated'] = df_clean['citations_per_year'] * 3
  
  # Transformacja logarytmiczna dla lepszego rozkładu
  df_clean['citations_3yr_log'] = np.log1p(df_clean['citations_3yr_estimated'])
  ```
  - ✓ **Walidacja**: Zmienna docelowa rozłożona normalnie

### Brama jakości
Czysty zbiór danych z 3000+ artykułami i cechami? → ✅ Kontynuuj

---

## 2.2 Blok trenowania modelu [8h]

### Zadania
- [ ] **2.2.1** Przygotuj dane treningowe (1h)
  ```python
  # Wybierz cechy
  feature_cols = [
      'author_h_index', 'has_top_institution', 'author_count',
      'has_code', 'claims_sota', 'title_length', 'abstract_length',
      'github_repos', 'early_signals_score'
  ]
  
  X = df_clean[feature_cols]
  y = df_clean['citations_3yr_estimated']
  
  # Podziel dane
  from sklearn.model_selection import train_test_split
  X_train, X_test, y_train, y_test = train_test_split(
      X, y, test_size=0.2, random_state=42
  )
  ```
  - ✓ **Walidacja**: Podział treningowy/testowy utworzony

- [ ] **2.2.2** Trenuj modele bazowe (2h)
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
      print(f"{name}: MAE={mae:.2f}, R²={r2:.3f}, Dokładność 20%={accuracy_20pct:.2%}")
  ```
  - ✓ **Walidacja**: Przynajmniej jeden model >60% dokładności

- [ ] **2.2.3** Optymalizuj najlepszy model (2h)
  ```python
  # Zakładając, że RF działał najlepiej
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
  - ✓ **Walidacja**: Poprawiona dokładność

- [ ] **2.2.4** Analiza ważności cech (1h)
  ```python
  importances = pd.DataFrame({
      'feature': feature_cols,
      'importance': best_model.feature_importances_
  }).sort_values('importance', ascending=False)
  
  print("Najważniejsze cechy:")
  print(importances)
  
  # Wizualizuj
  importances.plot(kind='barh', x='feature', y='importance')
  plt.title('Ważność cech dla predykcji cytowań')
  plt.tight_layout()
  plt.savefig('feature_importance.png')
  ```
  - ✓ **Walidacja**: h-index autora w top 3 cechach

### Brama jakości
Dokładność modelu >60% w marginesie 20%? → ✅ Kontynuuj

---

## 2.3 Blok wdrożenia modelu [8h]

### Zadania
- [ ] **2.3.1** Zapisz model (30 min)
  ```python
  import joblib
  
  # Zapisz model i metadane
  model_data = {
      'model': best_model,
      'features': feature_cols,
      'version': '1.0',
      'training_date': pd.Timestamp.now().isoformat(),
      'metrics': results
  }
  
  joblib.dump(model_data, 'oracle_model_v1.pkl')
  ```
  - ✓ **Walidacja**: Plik utworzony

- [ ] **2.3.2** Utwórz Flask API (2h)
  ```python
  # app.py
  from flask import Flask, request, jsonify
  import joblib
  import pandas as pd
  import numpy as np
  
  app = Flask(__name__)
  
  # Załaduj model
  model_data = joblib.load('oracle_model_v1.pkl')
  model = model_data['model']
  features = model_data['features']
  
  @app.route('/predict', methods=['POST'])
  def predict():
      try:
          # Pobierz cechy z żądania
          data = request.json
          
          # Utwórz dataframe
          df = pd.DataFrame([data['features']])
          
          # Zapewnij obecność wszystkich cech
          for feat in features:
              if feat not in df.columns:
                  df[feat] = 0
          
          # Przewiduj
          prediction = model.predict(df[features])[0]
          
          # Oblicz pewność (prosta wersja)
          confidence = min(0.85, max(0.5, 0.6 + (prediction / 1000)))
          
          # Oszacuj percentyl
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
  - ✓ **Walidacja**: API odpowiada lokalnie

- [ ] **2.3.3** Testuj API lokalnie (1h)
  ```bash
  # Uruchom serwer
  python app.py
  
  # Testuj predykcję
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
  - ✓ **Walidacja**: Zwraca JSON z predykcją

- [ ] **2.3.4** Wdróż na Railway (2h)
  - Utwórz requirements.txt
  - Dodaj Procfile: `web: gunicorn app:app`
  - Wypchnij do GitHub
  - Połącz Railway z repo
  - Wdróż
  - ✓ **Walidacja**: Publiczny URL działa

### Brama jakości
API wdrożone i odpowiadające? → ✅ Kontynuuj

---

## 2.4 Blok integracji Make.com [4h]

### Zadania
- [ ] **2.4.1** Utwórz scenariusz predykcji (1h)
  - Nowy scenariusz: "Oracle - ML Predictions"
  - Wyzwalacz: Codziennie o 10:00 UTC
  - ✓ **Walidacja**: Scenariusz utworzony

- [ ] **2.4.2** Pobierz artykuły o wysokim wyniku (30 min)
  - Moduł wyszukiwania Airtable
  - Filtr: `AND({needs_prediction}, NOT({predicted}))`
  - Limit: 10
  - ✓ **Walidacja**: Zwraca artykuły

- [ ] **2.4.3** Wywołaj API predykcji (1h)
  ```
  Moduł HTTP Request:
  - URL: https://your-api.railway.app/predict
  - Metoda: POST
  - Nagłówki: Content-Type: application/json
  - Treść: {
      "features": {
        "author_h_index": {{item.author_h_index}},
        "has_top_institution": {{if(item.has_top_institution; 1; 0)}},
        ...
      }
    }
  ```
  - ✓ **Walidacja**: Zwraca predykcje

- [ ] **2.4.4** Aktualizuj Airtable (30 min)
  - Aktualizuj rekord z predykcjami
  - Ustaw predicted = true
  - Dodaj prediction_date
  - ✓ **Walidacja**: Rekordy zaktualizowane

### Brama jakości
10 artykułów przewidzianych przez automatyzację? → ✅ Faza 2 ukończona!

---

## 2.5 Kontrola jakości pierwszych predykcji [4h]

### Zadania
- [ ] **2.5.1** Przegląd ręczny (1h)
  - Sprawdź 10 predykcji
  - Czy mają intuicyjny sens?
  - ✓ **Walidacja**: Brak oczywistych błędów

- [ ] **2.5.2** Utwórz treść predykcyjną (2h)
  - Dla top 5 predykcji
  - Napisz wyjaśnienia
  - Utwórz wizualizacje
  - ✓ **Walidacja**: Treść gotowa

- [ ] **2.5.3** Udokumentuj metodologię (1h)
  - Jakie cechy używamy
  - Jak trenujemy model
  - Aktualne metryki dokładności
  - ✓ **Walidacja**: Opublikowane na stronie

---

## Lista kontrolna ukończenia fazy
- [ ] Model wytrenowany z >60% dokładnością
- [ ] API wdrożone i stabilne
- [ ] Integracja Make.com działa
- [ ] Pierwsze 10+ predykcji wykonanych
- [ ] Metodologia udokumentowana

## Osiągnięte metryki
- Dokładność modelu (margines 20%): ____%
- Czas odpowiedzi API: ____ms
- Wykonane predykcje: ____
- Predykcje o wysokiej pewności: ____

## Następna faza
[→ Faza 3: Uruchomienie MVP](./phase_3_mvp_launch.md)

---

**Śledzenie czasu**
- Szacowany: 40h
- Faktyczny: ___h
- Blokery: ___________