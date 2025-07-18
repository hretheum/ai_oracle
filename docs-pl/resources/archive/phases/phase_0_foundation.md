# 📋 FAZA 0: Konfiguracja fundamentów

[← Powrót do głównego planu](./ROADMAP_MASTER.md)

## Przegląd
Konfiguracja fundamentów projektu Oracle. Wszystkie zadania są atomowe i mogą być wykonane niezależnie.

## Czas trwania i zasoby
- **Całkowity czas**: 3 dni (24h pracy)
- **Wymagane umiejętności**: Podstawowe techniczne, ML jeszcze nie potrzebne
- **Budżet**: $0 (darmowe plany)

## Kryteria sukcesu
- [ ] Wszystkie konta utworzone i zweryfikowane
- [ ] Schemat bazy danych w pełni zaimplementowany
- [ ] Środowisko deweloperskie działa
- [ ] Pierwsze testowe wywołanie API zakończone sukcesem

---

## 0.1 Blok konfiguracji kont [4h]

### Zadania
- [ ] **0.1.1** Utwórz konto Make.com (15 min)
  - Wejdź na make.com
  - Zarejestruj się emailem
  - Zweryfikuj email
  - ✓ **Walidacja**: Masz dostęp do dashboardu
  
- [ ] **0.1.2** Utwórz konto Airtable (10 min)
  - Wejdź na airtable.com
  - Zarejestruj się
  - Pomiń onboarding
  - ✓ **Walidacja**: Możesz utworzyć bazę

- [ ] **0.1.3** Konto Twitter Developer (45 min)
  - Aplikuj na developer.twitter.com
  - Wypełnij przypadek użycia "Academic Research"
  - Czekaj na zatwierdzenie (może być natychmiastowe)
  - ✓ **Walidacja**: Masz Bearer Token
  
- [ ] **0.1.4** GitHub Personal Access Token (5 min)
  - Ustawienia → Ustawienia deweloperskie → PAT
  - Wygeneruj nowy token (klasyczny)
  - Wybierz: public_repo, read:user
  - ✓ **Walidacja**: Token działa z curl

- [ ] **0.1.5** Semantic Scholar API (10 min)
  - Zarejestruj się na semanticscholar.org/product/api
  - Otrzymaj klucz API natychmiast
  - ✓ **Walidacja**: Testowe zapytanie zwraca dane

- [ ] **0.1.6** Konto Heroku/Railway (20 min)
  - Wybierz Railway (łatwiejszy, nowoczesny)
  - Zarejestruj się przez GitHub
  - ✓ **Walidacja**: Możesz utworzyć projekt

### Brama jakości
Wszystkie konta aktywne? → ✅ Kontynuuj | ❌ Debuguj problemy

---

## 0.2 Blok schematu bazy danych [3h]

### Wymagania wstępne
- Konto Airtable aktywne

### Zadania
- [ ] **0.2.1** Utwórz bazę "AI Research Oracle" (5 min)
  - Od zera, nie z szablonu
  - ✓ **Walidacja**: Baza pojawia się w workspace

- [ ] **0.2.2-0.2.15** Utwórz pola tabeli Papers (45 min)
  ```
  Każde pole (3 min każde):
  - paper_id (Autonumber)
  - arxiv_id (Pojedyncza linia)
  - title (Pojedyncza linia)
  - authors (Długi tekst)
  - abstract (Długi tekst)
  - pdf_url (URL)
  - submitted_date (Data)
  - early_signals_score (Liczba, 0-100)
  - author_max_h_index (Liczba)
  - twitter_mentions_24h (Liczba)
  - github_repos_7d (Liczba)
  - has_code (Checkbox)
  - needs_prediction (Formuła: {early_signals_score} > 60)
  - predicted (Checkbox)
  - prediction_date (Data)
  ```
  - ✓ **Walidacja**: Wszystkie pola widoczne i poprawnego typu

- [ ] **0.2.16** Utwórz tabelę Predictions (30 min)
  ```
  Pola:
  - prediction_id (Autonumber)
  - paper_link (Link do Papers)
  - predicted_citations_1yr (Liczba)
  - predicted_citations_3yr (Liczba)
  - predicted_citations_5yr (Liczba)
  - confidence (Liczba, 0-1)
  - percentile (Liczba, 0-100)
  - model_version (Pojedyncza linia)
  ```
  - ✓ **Walidacja**: Możesz linkować do tabeli Papers

- [ ] **0.2.17** Utwórz widoki (15 min)
  - "High Score Papers": Filtr {early_signals_score} > 60
  - "Needs Prediction": Filtr {needs_prediction} = TRUE()
  - "Recent Predictions": Sortuj po prediction_date DESC
  - ✓ **Walidacja**: Widoki pokazują przefiltrowane dane poprawnie

### Brama jakości
Czy możesz ręcznie dodać testowy artykuł i zobaczyć go w widokach? → ✅ Kontynuuj

---

## 0.3 Blok środowiska deweloperskiego [2h]

### Zadania
- [ ] **0.3.1** Zainstaluj Python 3.8+ (30 min)
  ```bash
  # Mac: brew install python@3.9
  # Windows: Pobierz z python.org
  # Linux: sudo apt install python3.9
  ```
  - ✓ **Walidacja**: `python3 --version` pokazuje 3.8+

- [ ] **0.3.2** Utwórz strukturę projektu (10 min)
  ```bash
  mkdir -p oracle_project/{data,models,api,scripts,notebooks}
  cd oracle_project
  python3 -m venv venv
  ```
  - ✓ **Walidacja**: Foldery istnieją, venv utworzone

- [ ] **0.3.3** Zainstaluj podstawowe pakiety (10 min)
  ```bash
  source venv/bin/activate  # Windows: venv\Scripts\activate
  pip install pandas numpy scikit-learn requests flask
  pip install jupyter matplotlib seaborn joblib
  pip freeze > requirements.txt
  ```
  - ✓ **Walidacja**: `pip list` pokazuje wszystkie pakiety

- [ ] **0.3.4** Testuj połączenia API (20 min)
  ```python
  # test_apis.py
  import requests
  
  # Test ArXiv
  arxiv_response = requests.get(
      "http://export.arxiv.org/api/query?search_query=cat:cs.AI&max_results=1"
  )
  print(f"ArXiv: {arxiv_response.status_code}")
  
  # Test Semantic Scholar  
  ss_response = requests.get(
      "https://api.semanticscholar.org/v1/paper/arXiv:2010.00001"
  )
  print(f"Semantic Scholar: {ss_response.status_code}")
  ```
  - ✓ **Walidacja**: Oba zwracają 200 OK

### Brama jakości
Wszystkie API odpowiadają? Środowisko działa? → ✅ Przejdź do Fazy 1

---

## 0.4 Blok wstępnej konfiguracji Make.com [2h]

### Zadania
- [ ] **0.4.1** Utwórz pierwszy scenariusz (10 min)
  - Nazwa: "Oracle - Test Connection"
  - ✓ **Walidacja**: Scenariusz utworzony

- [ ] **0.4.2** Dodaj połączenie Airtable (15 min)
  - Dodaj moduł Airtable
  - Połącz z kluczem API
  - Wybierz bazę i tabelę
  - ✓ **Walidacja**: Widzisz tabelę Papers

- [ ] **0.4.3** Testuj przepływ danych (20 min)
  - Dodaj moduł HTTP → ArXiv API
  - Dodaj Airtable Create Record
  - Mapuj pola
  - Uruchom raz
  - ✓ **Walidacja**: Rekord pojawia się w Airtable

### Brama jakości
Testowy artykuł pomyślnie zapisany w Airtable? → ✅ Faza 0 ukończona!

---

## Przewodnik rozwiązywania problemów

### Częste problemy
1. **Twitter API odrzucone**: Użyj powodu "Academic research", bądź konkretny
2. **Błąd formuły Airtable**: Sprawdź składnię, użyj {} dla nazw pól
3. **Problemy z wersją Python**: Użyj pyenv lub conda
4. **Limit Make.com**: Pozostań poniżej 1000 operacji dla testów

### Jeśli zablokowany
- Tymczasowo pomiń Twitter API (nie krytyczne dla MVP)
- Użyj Google Colab jeśli lokalny Python zawodzi
- Spróbuj Zapier jeśli problemy z Make.com

---

## Lista kontrolna ukończenia fazy
- [ ] Wszystkie konta utworzone
- [ ] Schemat bazy danych kompletny
- [ ] Środowisko deweloperskie działa
- [ ] Pierwszy testowy przepływ danych udany
- [ ] Udokumentowane wszelkie problemy

## Następna faza
[→ Faza 1: Pipeline zbierania danych](./phase_1_data_collection.md)

---

**Śledzenie czasu**
- Szacowany: 24h
- Faktyczny: ___h
- Blokery: ___________