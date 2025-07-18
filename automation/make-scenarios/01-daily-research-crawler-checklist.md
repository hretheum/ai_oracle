# Daily Research Crawler - Checklist

## ✅ Przed rozpoczęciem

- [ ] Konto Make.com (darmowe lub Teams plan)
- [ ] Konto Airtable (darmowe wystarczy)
- [ ] (Opcjonalnie) Semantic Scholar API key
- [ ] Przetestowany skrypt `test-arxiv-api.py`

## ✅ Kroki konfiguracji w Make.com

### 1. Podstawowy scenariusz
- [ ] Utworzony nowy scenariusz "Daily Research Crawler"
- [ ] Skonfigurowany Schedule trigger (6:00 UTC)
- [ ] HTTP Request do ArXiv API
- [ ] XML Parser podłączony
- [ ] Iterator ustawiony na entry[]

### 2. Baza danych
- [ ] Airtable base "AI Research Pipeline" utworzona
- [ ] Tabela "Research_Papers" z polami:
  - [ ] title
  - [ ] authors
  - [ ] abstract
  - [ ] arxiv_id
  - [ ] pdf_url
  - [ ] submitted_date
  - [ ] relevance_score
  - [ ] citation_count

### 3. Zapisywanie danych
- [ ] Airtable "Create record" skonfigurowany
- [ ] Wszystkie pola zmapowane
- [ ] Test zapisu pojedynczego rekordu

### 4. Opcjonalne rozszerzenia
- [ ] Text parser do wyciągania ArXiv ID
- [ ] Semantic Scholar API dla cytowań
- [ ] Relevance score calculation
- [ ] Error handlers dodane

### 5. Testowanie
- [ ] "Run once" wykonane pomyślnie
- [ ] Dane pojawiły się w Airtable
- [ ] Brak błędów w execution log

### 6. Uruchomienie produkcyjne
- [ ] Scenariusz włączony (ON)
- [ ] Sequential processing włączone
- [ ] Monitoring ustawiony (email/Slack)

## ⚠️ Limity do pamiętania

- **ArXiv API**: 1 request per 3 seconds
- **Airtable Free**: 1,200 records per base
- **Make.com Free**: 1,000 operations/month
- **Semantic Scholar**: 5,000 requests/day (z kluczem)

## 🚀 Następne kroki

1. **Tydzień 1-2**: Monitoruj działanie, dostosuj relevance scoring
2. **Tydzień 3-4**: Dodaj Content Generator (Scenario 2)
3. **Miesiąc 2**: Uruchom publikację na LinkedIn/Twitter

## 🔧 Troubleshooting

### Problem: ArXiv zwraca pusty wynik
- Sprawdź formatowanie query string
- Upewnij się, że używasz poprawnych kategorii

### Problem: Airtable nie zapisuje
- Sprawdź nazwy pól (case sensitive!)
- Upewnij się, że typy pól się zgadzają

### Problem: Za dużo operacji
- Zmniejsz max_results w ArXiv query
- Uruchamiaj co 2 dni zamiast codziennie
- Filtruj papers przed zapisem (np. tylko z ostatnich 24h)

## 📊 Metryki sukcesu (po 1 miesiącu)

- [ ] 500+ papers przeanalizowanych
- [ ] 50+ high-relevance papers zidentyfikowanych
- [ ] <5% błędów w scenariuszu
- [ ] Czas wykonania <2 minuty
