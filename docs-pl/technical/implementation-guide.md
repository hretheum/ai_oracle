# Praktyczny przewodnik wdrożenia - edycja AI Research Oracle 🔮

## Wprowadzenie
Ten przewodnik przeprowadzi Cię krok po kroku przez wdrożenie systemu AI Research Oracle - jedynego systemu przewidującego przyszły wpływ publikacji naukowych AI na podstawie wczesnych sygnałów i uczenia maszynowego. Zamiast czekać 3 lata na cytowania, przewidujemy je w 7 dni!

## Dlaczego Oracle? Problem z cytowaniami
- **Fakt**: Artykuły potrzebują 1-3 lat na zdobycie cytowań
- **Problem**: Nie można ocenić wartości świeżych publikacji
- **Rozwiązanie**: Wczesne sygnały (Twitter, GitHub, autor) + ML = predykcje od dnia 1
- **Wartość**: Badacze i VC mogą inwestować czas/pieniądze mądrze

## Część 1: Konfiguracja infrastruktury dla Oracle
### 1.1 Make.com - Konfiguracja dla wczesnych sygnałów

# Praktyczny przewodnik: Konfiguracja AI Research Oracle w Make.com

## 🚀 Dzienny crawler badań z wczesnymi sygnałami - krok po kroku

Ten przewodnik przeprowadzi Cię przez konfigurację systemu, który nie tylko pobiera artykuły, ale też **przewiduje ich przyszły wpływ** na podstawie sygnałów z pierwszych 7 dni.

## Przygotowanie (45 minut)

### 1. Załóż potrzebne konta
- ✅ **Make.com** - https://www.make.com (zacznij od planu Core)
- ✅ **Airtable** - https://airtable.com (darmowe konto)
- ✅ **Twitter Developer** - https://developer.twitter.com (poziom Basic $100/mo)
- ✅ **GitHub** - Personal access token (darmowy)
- ✅ **Semantic Scholar** - klucz API (darmowy)

### 2. Przygotuj bazę w Airtable - schemat Oracle

1. Zaloguj się do Airtable
2. Kliknij "Create a base" → "Start from scratch"
3. Nazwij bazę: "AI Research Oracle"
4. Utwórz tabelę "Papers" z polami:

```
| Nazwa pola             | Typ pola         | Uwagi                         |
|------------------------|------------------|-------------------------------|
| paper_id               | Autonumber       | Klucz główny                  |
| title                  | Single line text | Tytuł pracy                   |
| authors                | Long text        | Lista autorów                 |
| abstract               | Long text        | Streszczenie                  |
| arxiv_id               | Single line text | ID z ArXiv                    |
| pdf_url                | URL              | Link do PDF                   |
| submitted_date         | Date             | Data publikacji               |
| early_signals_score    | Number           | Punktacja (0-100)             |
| author_max_h_index     | Number           | Najwyższy h-index             |
| twitter_mentions_24h   | Number           | Wzmianki w 24h                |
| github_repos_7d        | Number           | Repozytoria w 7 dni           |
| github_stars_7d        | Number           | Gwiazdki w 7 dni              |
| needs_prediction       | Formula          | {early_signals_score} > 60    |
| predicted_citations_3yr| Number           | Predykcja na 3 lata           |
| prediction_confidence  | Number           | Pewność predykcji (0-1)       |
| prediction_date        | Date             | Kiedy przewidziano            |
```

5. Utwórz drugą tabelę "Predictions":
```
| Nazwa pola         | Typ pola         | Uwagi                    |
|-------------------|------------------|--------------------------|
| prediction_id     | Autonumber       | Klucz główny             |
| paper_link        | Link to Papers   | Połączenie z Papers      |
| predicted_1yr     | Number           | Predykcja 1 rok          |
| predicted_3yr     | Number           | Predykcja 3 lata         |
| predicted_5yr     | Number           | Predykcja 5 lat          |
| confidence        | Number           | Pewność (0-1)            |
| percentile        | Number           | Przewidywany percentyl   |
| breakthrough_prob | Number           | Prawdopodobieństwo hitu  |
| model_version     | Text             | Wersja modelu ML         |
```

## Konfiguracja w Make.com - pipeline Oracle (60 minut)

### Scenariusz 1: Kolektor wczesnych sygnałów

#### Krok 1: Utwórz nowy scenariusz
1. Zaloguj się do Make.com
2. "Create a new scenario"
3. Nazwij: "🔮 Oracle - Kolektor wczesnych sygnałów"

#### Krok 2: Crawler ArXiv (jak wcześniej)
1. Schedule Trigger (Codziennie 6:00 UTC)
2. HTTP Request do ArXiv API
3. XML Parser
4. Iterator przez artykuły

#### Krok 3: Kolektor metryk autorów (NOWE!)
1. Po Iterator dodaj HTTP Request
2. Nazwa: "Pobierz h-index autora"
3. Konfiguracja:
```
URL: https://api.semanticscholar.org/graph/v1/author/search
Metoda: GET
Query String:
  - query: {{first(split(4.authors; ","))}}
  - fields: authorId,name,hIndex,citationCount
```

4. Dodaj "Array aggregator" aby zebrać wszystkich autorów
5. Dodaj "Tools → Basic function":
```javascript
// Pobierz maksymalny h-index
{{max(map(5.array; "hIndex"))}}
```

#### Krok 4: Monitor buzzu Twitter (KLUCZOWE!)
1. Dodaj HTTP Request
2. Nazwa: "Sprawdź wzmianki Twitter"
3. Konfiguracja:
```
URL: https://api.twitter.com/2/tweets/search/recent
Metoda: GET
Nagłówki:
  - Authorization: Bearer {{twitter_bearer_token}}
Query String:
  - query: {{4.arxiv_id}} OR "{{substring(4.title; 0; 50)}}"
  - max_results: 100
  - tweet.fields: public_metrics,created_at
```

4. Parsuj odpowiedź:
```javascript
// Policz wzmianki w ostatnich 24h
const tweets = {{6.data}};
const last24h = tweets.filter(t => {
  const hours = (Date.now() - new Date(t.created_at)) / (1000*60*60);
  return hours <= 24;
});
{{length(last24h)}}
```

#### Krok 5: Tracker implementacji GitHub
1. Dodaj HTTP Request
2. Nazwa: "Szukaj repozytoriów GitHub"
3. Konfiguracja:
```
URL: https://api.github.com/search/repositories
Metoda: GET
Nagłówki:
  - Authorization: token {{github_token}}
  - Accept: application/vnd.github.v3+json
Query String:
  - q: {{4.arxiv_id}} OR "{{substring(4.title; 0; 30)}}"
  - sort: stars
  - order: desc
```

#### Krok 6: Oblicz wynik wczesnych sygnałów
1. Dodaj "Tools → Set multiple variables"
2. Zmienne do ustawienia:
```javascript
// Wynik autora (max 40)
authorScore: {{min(6.maxHIndex / 2; 15) + (hasTopInstitution ? 10 : 0)}}

// Wynik społecznościowy (max 30)
twitterScore: {{min(7.mentions24h / 10; 10)}}
githubScore: {{8.total_count > 0 ? 5 + min(8.items[0].stargazers_count / 10; 5) : 0}}

// Wynik treści (max 20)
hasCode: {{contains(4.abstract; "github.com") ? 5 : 0}}
hasSOTA: {{contains(toLowerCase(4.abstract); "state-of-the-art") ? 7 : 0}}

// Wynik całkowity
totalScore: {{authorScore + twitterScore + githubScore + hasCode + hasSOTA}}
```

#### Krok 7: Zapisz do Airtable z sygnałami
1. Dodaj "Airtable → Create a Record"
2. Mapuj wszystkie pola włącznie z:
   - early_signals_score: {{9.totalScore}}
   - author_max_h_index: {{6.maxHIndex}}
   - twitter_mentions_24h: {{7.mentions24h}}
   - github_repos_7d: {{8.total_count}}
   - needs_prediction: {{9.totalScore > 60}}

### Scenariusz 2: Pipeline predykcji ML (NOWE!)

#### Krok 1: Wyzwalacz tygodniowy
1. Nowy scenariusz: "🔮 Oracle - Predykcje ML"
2. Harmonogram: Co niedzielę 10:00 UTC

#### Krok 2: Pobierz artykuły o wysokim sygnale
1. Airtable → Search records
2. Formuła: `AND({needs_prediction}, NOT({predicted}))`
3. Maksymalne rekordy: 20

#### Krok 3: Przygotuj cechy dla ML
1. Iterator przez artykuły
2. Tools → Set multiple variables
```javascript
features: {
  author_h_index: {{3.fields.author_max_h_index}},
  twitter_mentions: {{3.fields.twitter_mentions_24h}},
  has_github: {{3.fields.github_repos_7d > 0}},
  github_stars: {{3.fields.github_stars_7d}},
  abstract_length: {{length(split(3.fields.abstract; " "))}},
  days_since_publish: {{round((now - 3.fields.submitted_date) / 86400000)}}
}
```

#### Krok 4: Wywołaj API predykcji ML
1. HTTP Request
```
URL: https://your-oracle-api.herokuapp.com/predict
Metoda: POST
Nagłówki:
  - Content-Type: application/json
Body: {
  "arxiv_id": "{{3.fields.arxiv_id}}",
  "features": {{4.features}},
  "model": "v2.1"
}
```

#### Krok 5: Generuj treść Oracle
1. Tools → Text aggregator
2. Szablon:
```
🔮 Predykcja Oracle:

"{{3.fields.title}}"

Przewidywany wpływ: {{5.predictions.citations_3yr}} cytowań do 2028
Pewność: {{round(5.confidence * 100)}}%
Percentyl: Top {{100 - 5.percentile}}%

Wczesne sygnały:
- h-index autora: {{3.fields.author_max_h_index}}
- Buzz Twitter: {{3.fields.twitter_mentions_24h}} wzmianek
- GitHub: {{3.fields.github_repos_7d}} implementacji

Śledź tę predykcję: https://airesearchoracle.com/p/{{3.fields.arxiv_id}}
```

## Testowanie systemu Oracle (30 minut)

### Test 1: Zbieranie wczesnych sygnałów
1. Uruchom "Kolektor wczesnych sygnałów" na 5 artykułach
2. Sprawdź w Airtable:
   - Czy h-index autora się zapisał?
   - Czy wzmianki Twitter są policzone?
   - Czy repozytoria GitHub są znalezione?
   - Czy wynik całkowity ma sens?

### Test 2: Generowanie predykcji
1. Ręcznie ustaw needs_prediction = true dla 2 artykułów
2. Uruchom "Predykcje ML"
3. Sprawdź czy predykcje się wygenerowały

### Test 3: Publikowanie treści
1. Weź wygenerowaną predykcję
2. Opublikuj ręcznie na LinkedIn/Twitter
3. Zmierz zaangażowanie vs zwykły post

## Model ML - szybki start (1 dzień)

### Opcja A: Prosty model w Python
```python
# train_simple_oracle.py
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
import joblib

# Zbierz dane historyczne (artykuły z 2020-2021)
# Możesz użyć Semantic Scholar API do pobrania cytowań

def train_model():
    # Załaduj dane
    df = pd.read_csv('historical_papers.csv')
    
    # Cechy
    features = ['author_h_index', 'twitter_mentions_7d', 
                'has_github', 'abstract_length']
    X = df[features]
    y = df['citations_after_3_years']
    
    # Trenuj
    model = RandomForestRegressor(n_estimators=100)
    model.fit(X, y)
    
    # Zapisz
    joblib.dump(model, 'oracle_model.pkl')
    
    return model
```

### Wdróż na Heroku/Railway
```python
# app.py - Proste API Flask
from flask import Flask, request, jsonify
import joblib
import numpy as np

app = Flask(__name__)
model = joblib.load('oracle_model.pkl')

@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    features = np.array([[
        data['features']['author_h_index'],
        data['features']['twitter_mentions'],
        1 if data['features']['has_github'] else 0,
        data['features']['abstract_length']
    ]])
    
    prediction = model.predict(features)[0]
    
    # Oblicz percentyl (na podstawie twoich danych)
    percentile = calculate_percentile(prediction)
    
    return jsonify({
        'predictions': {
            'citations_3yr': int(prediction),
            'citations_1yr': int(prediction * 0.3),
            'citations_5yr': int(prediction * 1.8)
        },
        'confidence': 0.75,
        'percentile': percentile
    })

if __name__ == '__main__':
    app.run()
```

## Publiczna strona trackera (1 dzień)

### Prosta aplikacja Next.js/React
```jsx
// pages/index.js
import { useEffect, useState } from 'react';

export default function OracleTracker() {
  const [predictions, setPredictions] = useState([]);
  const [stats, setStats] = useState({});
  
  useEffect(() => {
    // Pobierz z Airtable API
    fetchPredictions();
    fetchStats();
  }, []);
  
  return (
    <div className="oracle-container">
      <h1>🔮 AI Research Oracle - Predykcje na żywo</h1>
      
      <div className="stats">
        <div className="stat">
          <h3>Wykonane predykcje</h3>
          <p>{stats.total}</p>
        </div>
        <div className="stat">
          <h3>Wskaźnik dokładności</h3>
          <p>{stats.accuracy}%</p>
        </div>
        <div className="stat">
          <h3>Śledzonych artykułów</h3>
          <p>{stats.papers}</p>
        </div>
      </div>
      
      <h2>Ostatnie predykcje</h2>
      <div className="predictions">
        {predictions.map(p => (
          <PredictionCard key={p.id} prediction={p} />
        ))}
      </div>
    </div>
  );
}

function PredictionCard({ prediction }) {
  const isVerified = prediction.actual_citations !== null;
  
  return (
    <div className={`card ${isVerified ? 'verified' : 'pending'}`}>
      <h3>{prediction.title}</h3>
      <div className="metrics">
        <span>Przewidziane: {prediction.predicted_3yr} cytowań</span>
        {isVerified && <span>Faktyczne: {prediction.actual_citations}</span>}
      </div>
      <div className="confidence">
        Pewność: {(prediction.confidence * 100).toFixed(0)}%
      </div>
      <a href={`/prediction/${prediction.id}`}>Zobacz szczegóły →</a>
    </div>
  );
}
```

## Strategia treści - edycja Oracle

### Tydzień 1: Miękkie uruchomienie
1. **Poniedziałek**: Post "Przedstawiamy AI Research Oracle"
2. **Środa**: Pierwsze 5 predykcji z wyjaśnieniami
3. **Piątek**: "Jak przewidujemy" - post o metodologii

### Tydzień 2: Budowanie wiarygodności
1. **Codziennie**: 1-2 nowe predykcje
2. **Wątek**: "Dlaczego liczba cytowań jest przestarzała"
3. **Artykuł LinkedIn**: "Nauka przewidywania nauki"

### Tydzień 3: Wirusowy rozgłos
1. **Wyzwanie**: Konkurs predykcyjny "Pokonaj Oracle"
2. **Kontrowersyjne**: "Ten artykuł zawiedzie (i oto dlaczego)"
3. **Sukces**: "Przewidzieliśmy ten przełom 6 miesięcy temu"

## Monitorowanie i optymalizacja

### Codzienne kontrole:
- [ ] Status limitów API
- [ ] Nowe artykuły o wysokim wyniku
- [ ] Śledzenie dokładności predykcji
- [ ] Zaangażowanie w mediach społecznościowych

### Cotygodniowa analiza:
- [ ] Które sygnały korelują najlepiej?
- [ ] Metryki wydajności modelu
- [ ] Wskaźniki zaangażowania treści
- [ ] Wzmianki prasowe

### Miesięczny przegląd:
- [ ] Przetrenuj model z nowymi danymi
- [ ] Publikacja raportu dokładności
- [ ] Dostosowanie strategii
- [ ] Dyskusje o partnerstwie

## Rozwiązywanie problemów Oracle

### Problem: "Niska dokładność predykcji"
**Rozwiązania**:
- Dodaj więcej danych treningowych
- Inżynieria lepszych cech
- Skupienie tylko na predykcjach o wysokiej pewności
- Bądź transparentny co do procesu uczenia

### Problem: "Limity API osiągnięte"
**Rozwiązania**:
- Implementuj warstwę cache
- Priorytetyzuj artykuły o wysokim wyniku
- Rozłóż żądania w czasie
- Użyj darmowych alternatyw (Crossref)

### Problem: "Brak sygnałów społecznościowych dla artykułu"
**Rozwiązania**:
- Poczekaj 24-48h przed punktacją
- Użyj alternatywnych sygnałów (pobrania)
- Obniż próg dla sygnałów autorów
- Oznacz jako "niewystarczające dane"

## Lista kontrolna uruchomienia - edycja Oracle

### Techniczne (Dzień 1-2):
- [ ] Punktacja wczesnych sygnałów aktywna
- [ ] Model ML wdrożony
- [ ] API predykcji działa
- [ ] Strona trackera działa
- [ ] Scenariusze Make.com przetestowane

### Treść (Dzień 3-5):
- [ ] 10 predykcji gotowych
- [ ] Ogłoszenie uruchomienia przygotowane
- [ ] Szablony mediów społecznościowych
- [ ] Konfiguracja newslettera
- [ ] Pakiet prasowy przygotowany

### Marketing (Tydzień 1):
- [ ] Uruchomienie na Product Hunt
- [ ] Kontakt z dziennikarzami AI
- [ ] Posty w odpowiednich społecznościach
- [ ] Kontakt z badaczami o feedback
- [ ] Zaplanowane wystąpienia w podcastach

## Sprawdzenie realności budżetu

### Koszty miesiąca 1:
- Make.com Teams: $29
- Twitter API: $100
- Hosting ML: $20
- Domena/Hosting: $20
- **Razem: $169**

### Kiedy skalować:
- **>100 predykcji/tydzień**: Ulepsz infrastrukturę ML
- **>1000 obserwujących**: Uruchom premium newsletter
- **>90% dokładność**: Zacznij pobierać opłaty za API
- **Pokrycie prasowe**: Pozyskaj inwestycję

## 🎯 Metryki sukcesu - pierwsze 30 dni

### Techniczne:
- 100+ przeanalizowanych artykułów
- 50+ wykonanych predykcji
- 70%+ zebranych wczesnych sygnałów
- <5% awarii API

### Wzrost:
- 1,000+ wizyt trackera
- 500+ rejestracji newslettera
- 100+ obserwujących LinkedIn
- 10+ wzmianek w mediach

### Biznes:
- 3+ zapytania o partnerstwo
- 1+ zaproszenie do wystąpienia
- 5+ referencji badaczy
- Pierwsza dyskusja o przychodach

---

💡 **Pamiętaj**: Magia nie tkwi w perfekcyjnych predykcjach - tkwi w byciu JEDYNYM, który robi predykcje. Zacznij prosto, iteruj na podstawie danych i zawsze bądź transparentny co do swojego procesu. Celem jest stać się "Oracle" w 6 miesięcy! 🔮