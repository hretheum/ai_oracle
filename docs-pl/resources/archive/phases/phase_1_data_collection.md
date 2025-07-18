# 🔍 FAZA 1: Pipeline zbierania danych

[← Powrót do głównego planu](./ROADMAP_MASTER.md) | [← Poprzednia: Faza 0](./phase_0_foundation.md)

## Przegląd
Budowa pipeline'u do zbierania artykułów i wczesnych sygnałów. Fokus na automatyzacji i skalowalności.

## Czas trwania i zasoby
- **Całkowity czas**: 1 tydzień (40h pracy)
- **Wymagane umiejętności**: Integracja API, podstawy Make.com
- **Budżet**: $0-100 (Twitter API opcjonalne)

## Kryteria sukcesu
- [ ] 1000+ artykułów zebranych z metadanymi
- [ ] Wczesne sygnały dla 100+ artykułów o wysokim wyniku
- [ ] Dane historyczne gotowe do trenowania ML
- [ ] Automatyczne codzienne zbieranie działa

---

## 1.1 Blok crawlera ArXiv [8h]

### Wymagania wstępne
- Konto Make.com aktywne
- Tabela Papers w Airtable gotowa

### Zadania
- [ ] **1.1.1** Utwórz scenariusz crawlera ArXiv (30 min)
  - Nowy scenariusz: "Oracle - ArXiv Daily Crawler"
  - Wyzwalacz harmonogramu: Codziennie 6:00 UTC
  - ✓ **Walidacja**: Wyzwalacz zaplanowany

- [ ] **1.1.2** Skonfiguruj moduł ArXiv API (45 min)
  ```
  Moduł HTTP Request:
  - URL: http://export.arxiv.org/api/query
  - Metoda: GET
  - Query String:
    * search_query: cat:cs.AI OR cat:cs.LG OR cat:cs.CL
    * start: 0
    * max_results: 50
    * sortBy: submittedDate
    * sortOrder: descending
  ```
  - ✓ **Walidacja**: Zwraca XML z artykułami

- [ ] **1.1.3** Parsuj odpowiedź XML (1h)
  - Dodaj moduł XML Parser
  - Mapuj do struktury JSON
  - Wyodrębnij wszystkie węzły entry
  - ✓ **Walidacja**: Widzisz tablicę artykułów

- [ ] **1.1.4** Konfiguracja iteratora (30 min)
  - Dodaj moduł Iterator
  - Wejście: sparsowana tablica entries
  - ✓ **Walidacja**: Przetwarza każdy artykuł

- [ ] **1.1.5** Mapowanie danych (1h)
  ```
  Dla każdego artykułu, wyodrębnij:
  - title: {{entry.title}}
  - arxiv_id: {{split(entry.id; "/")[last]}}
  - authors: {{join(map(entry.author; "name"); ", ")}}
  - abstract: {{entry.summary}}
  - pdf_url: {{first(map(filter(entry.link; href; contains(href; "pdf")); "href"))}}
  - submitted_date: {{parseDate(entry.published; "YYYY-MM-DD")}}
  ```
  - ✓ **Walidacja**: Wszystkie pola zmapowane poprawnie

- [ ] **1.1.6** Zapisz do Airtable (45 min)
  - Dodaj moduł Airtable "Create Record"
  - Mapuj wszystkie pola
  - Ustaw obsługę błędów
  - ✓ **Walidacja**: Testowy artykuł zapisany

- [ ] **1.1.7** Sprawdzanie duplikatów (30 min)
  - Przed zapisem, szukaj istniejącego arxiv_id
  - Pomiń jeśli istnieje
  - ✓ **Walidacja**: Brak tworzonych duplikatów

### Brama jakości
Uruchom pełny scenariusz, zebrano 50+ artykułów? → ✅ Kontynuuj

---

## 1.2 Kolektor metryk autorów [6h]

### Zadania
- [ ] **1.2.1** Dodaj moduł Semantic Scholar (1h)
  - Po Iterator, dodaj Router
  - Pierwsza trasa: Wyszukiwanie autora
  - HTTP Request do SS API
  - ✓ **Walidacja**: Zwraca dane autora

- [ ] **1.2.2** Wyodrębnij pierwszego autora (30 min)
  ```javascript
  // Pobierz imię pierwszego autora
  const authors = {{split(5.authors; ",")}}
  const firstAuthor = {{trim(first(authors))}}
  ```
  - ✓ **Walidacja**: Czyste imię autora

- [ ] **1.2.3** Szukaj autora (45 min)
  ```
  URL: https://api.semanticscholar.org/graph/v1/author/search
  Query: {{firstAuthor}}
  Fields: authorId,name,hIndex,citationCount
  ```
  - ✓ **Walidacja**: Zwraca dopasowania autora

- [ ] **1.2.4** Pobierz h-index (30 min)
  - Parsuj odpowiedź
  - Znajdź najlepsze dopasowanie po podobieństwie nazwy
  - Wyodrębnij h-index
  - ✓ **Walidacja**: Numeryczny h-index lub 0

- [ ] **1.2.5** Sprawdź instytucję (45 min)
  ```javascript
  // Lista top instytucji
  const topUnis = ["MIT", "Stanford", "CMU", "Berkeley", "Google", "DeepMind", "OpenAI"]
  const hasTop = topUnis.some(uni => 
    {{5.authors}}.toLowerCase().includes(uni.toLowerCase())
  )
  ```
  - ✓ **Walidacja**: Boolean true/false

### Brama jakości
Metryki autorów zebrane dla 20+ artykułów? → ✅ Kontynuuj

---

## 1.3 Kolektor sygnałów społecznościowych [8h]

### Zadania
- [ ] **1.3.1** Licznik wzmianek na Twitterze (2h) `OPCJONALNE`
  - Jeśli brak Twitter API, przejdź do 1.3.4
  - Dodaj moduł wyszukiwania Twitter
  - Szukaj: arxiv_id LUB tytuł artykułu
  - Policz wzmianki w 24h
  - ✓ **Walidacja**: Liczba ≥ 0

- [ ] **1.3.2** Wyszukiwarka implementacji GitHub (2h)
  ```
  GitHub Search API:
  - Query: "{arxiv_id}" OR "{pierwsze 30 znaków tytułu}"
  - Sort: stars
  - Created: >submitted_date
  ```
  - ✓ **Walidacja**: Lista repozytoriów lub pusta

- [ ] **1.3.3** Oblicz sygnał GitHub (1h)
  ```javascript
  const hasImplementation = {{length(12.items) > 0}}
  const totalStars = {{sum(map(12.items; "stargazers_count"))}}
  const repoCount = {{length(12.items)}}
  ```
  - ✓ **Walidacja**: Wartości numeryczne

- [ ] **1.3.4** Alternatywne sygnały (1h)
  - Jeśli brak Twittera, użyj:
    * Gwiazdki GitHub jako proxy
    * Reputacja autora
    * Prestiż instytucji
  - ✓ **Walidacja**: Zebrano jakiś sygnał

### Brama jakości
Sygnały społecznościowe dla 50+ artykułów? → ✅ Kontynuuj

---

## 1.4 Kalkulator Early Signals Score [4h]

### Zadania
- [ ] **1.4.1** Utwórz funkcję punktacji (1h)
  ```javascript
  // W module Tools Make.com
  let score = 0;
  
  // Autor (40 pkt max)
  score += Math.min({{authorHIndex}} / 2, 15);
  score += {{hasTopInstitution}} ? 10 : 0;
  
  // Społecznościowe (30 pkt max)  
  score += Math.min({{twitterMentions}} / 10, 10);
  score += {{hasGitHub}} ? 5 : 0;
  score += Math.min({{githubStars}} / 10, 5);
  
  // Treść (20 pkt max)
  const hasCode = {{contains(lower(abstract); "github.com")}} ? 5 : 0;
  const hasSOTA = {{contains(lower(abstract); "state-of-the-art")}} ? 7 : 0;
  score += hasCode + hasSOTA;
  
  return Math.min(score, 100);
  ```
  - ✓ **Walidacja**: Zwraca 0-100

- [ ] **1.4.2** Aktualizuj rekord Airtable (30 min)
  - Dodaj wynik do rekordu artykułu
  - Ustaw flagę needs_prediction
  - ✓ **Walidacja**: Wynik widoczny w Airtable

### Brama jakości
100+ artykułów ocenionych? Zidentyfikowano artykuły o wysokim wyniku? → ✅ Kontynuuj

---

## 1.5 Zbieranie danych historycznych [8h]

### Cel
Potrzebujemy artykułów z lat 2020-2022 ze znanymi cytowaniami do trenowania ML

### Zadania
- [ ] **1.5.1** Utwórz crawler historyczny (1h)
  - Zduplikuj dzienny crawler
  - Nazwa: "Oracle - Historical Backfill"
  - Wyzwalacz ręczny
  - ✓ **Walidacja**: Można uruchomić ręcznie

- [ ] **1.5.2** Zmodyfikuj zakres dat (30 min)
  ```
  Dla każdego miesiąca 2020-2022:
  - search_query: cat:cs.AI AND submittedDate:[20200101 TO 20200131]
  - max_results: 500
  ```
  - ✓ **Walidacja**: Zwraca stare artykuły

- [ ] **1.5.3** Dodaj wyszukiwanie cytowań (2h)
  - Po podstawowych informacjach, wywołaj Semantic Scholar
  - Pobierz aktualną liczbę cytowań
  - Zapisz jako "citations_current"
  - ✓ **Walidacja**: Liczby cytowań dodane

- [ ] **1.5.4** Uruchom miesięczne partie (4h)
  - Przetwarzaj jeden miesiąc na raz
  - Monitoruj limity
  - Cel ogólny: 10,000+ artykułów
  - ✓ **Walidacja**: Artykuły z 2020-2022 w bazie

### Brama jakości
5000+ historycznych artykułów z cytowaniami? → ✅ Faza 1 ukończona!

---

## 1.6 Kontrole jakości danych [2h]

### Zadania
- [ ] **1.6.1** Weryfikuj kompletność danych (30 min)
  - Sprawdź wartości null
  - Waliduj zakresy dat
  - ✓ **Walidacja**: <5% brakujących danych

- [ ] **1.6.2** Sprawdź rozkład sygnałów (30 min)
  - Wykres rozkładu wyników
  - Zakres h-index autorów
  - ✓ **Walidacja**: Rozkład normalny

- [ ] **1.6.3** Eksport do trenowania ML (1h)
  - Eksportuj dane historyczne do CSV
  - Włącz wszystkie cechy
  - ✓ **Walidacja**: Czysty plik CSV

---

## Przewodnik rozwiązywania problemów

### Częste problemy
1. **Limit ArXiv**: Dodaj 3-sekundowe opóźnienie między żądaniami
2. **Semantic Scholar 404**: Niektóre artykuły nie zindeksowane, pomiń
3. **Limit GitHub**: Użyj uwierzytelnionych żądań
4. **Timeout Make.com**: Przetwarzaj mniejsze partie

### Wskazówki optymalizacji
- Cachuj wyszukiwania autorów (ten sam autor wiele artykułów)
- Przetwarzaj partiami według zakresów dat
- Użyj data stores Make.com do deduplikacji

---

## Lista kontrolna ukończenia fazy
- [ ] Dzienny crawler operacyjny
- [ ] 1000+ ostatnich artykułów zebranych
- [ ] 5000+ historycznych artykułów z cytowaniami
- [ ] Punktacja wczesnych sygnałów działa
- [ ] Dane wyeksportowane do trenowania ML

## Osiągnięte metryki
- Zebrane artykuły: _____
- Średni wynik: _____
- Artykuły o wysokim wyniku (>60): _____
- Artykuły historyczne: _____

## Następna faza
[→ Faza 2: Rozwój modelu ML](./phase_2_ml_development.md)

---

**Śledzenie czasu**
- Szacowany: 40h
- Faktyczny: ___h
- Blokery: ___________