# 🚀 FAZA 3: Uruchomienie MVP

[← Powrót do głównego planu](./ROADMAP_MASTER.md) | [← Poprzednia: Faza 2](./phase_2_ml_development.md)

## Przegląd
Publiczne uruchomienie Oracle z pierwszymi predykcjami, strona trackera i podstawowy newsletter.

## Czas trwania i zasoby
- **Całkowity czas**: 1 tydzień (40h pracy)
- **Wymagane umiejętności**: Podstawy web dev, pisanie treści, Make.com
- **Budżet**: $20-50 (domena, hosting)

## Kryteria sukcesu
- [ ] 20+ publicznych predykcji wykonanych
- [ ] Strona trackera na żywo
- [ ] 50+ subskrybentów newslettera
- [ ] Pierwsza wzmianka w mediach

---

## 3.1 Publiczna strona trackera [8h]

### Wymagania wstępne
- Domena zarejestrowana
- Hosting gotowy (Vercel rekomendowany)

### Zadania
- [ ] **3.1.1** Konfiguracja projektu Next.js (1h)
  ```bash
  npx create-next-app@latest oracle-tracker
  cd oracle-tracker
  npm install axios recharts
  ```
  - ✓ **Walidacja**: Serwer deweloperski działa

- [ ] **3.1.2** Utwórz trasy API (2h)
  ```javascript
  // pages/api/predictions.js
  export default async function handler(req, res) {
    // Pobierz z Airtable
    const predictions = await fetchPredictions();
    res.json({ predictions });
  }
  ```
  - ✓ **Walidacja**: API zwraca dane

- [ ] **3.1.3** Zbuduj główną stronę (3h)
  - Hero: "AI Research Oracle - Przewidujemy wpływ"
  - Statystyki: Łączne predykcje, wskaźnik dokładności
  - Lista ostatnich predykcji
  - ✓ **Walidacja**: Strona wyświetla dane

- [ ] **3.1.4** Wdróż na Vercel (1h)
  - Połącz repo GitHub
  - Ustaw zmienne środowiskowe
  - Wdróż
  - ✓ **Walidacja**: Publiczny URL działa

### Brama jakości
Strona na żywo z prawdziwymi predykcjami? → ✅ Kontynuuj

---

## 3.2 Kampania pierwszych predykcji [8h]

### Zadania
- [ ] **3.2.1** Wybierz top 10 artykułów (1h)
  - Najwyższa pewność predykcji
  - Różnorodne tematy
  - ✓ **Walidacja**: Lista gotowa

- [ ] **3.2.2** Napisz posty predykcyjne (3h)
  - Szablon na predykcję
  - Dlaczego to ważne
  - Rozbicie wczesnych sygnałów
  - ✓ **Walidacja**: 10 postów napisanych

- [ ] **3.2.3** Utwórz wizualizacje (2h)
  - Karty predykcji
  - Wykresy sygnałów
  - ✓ **Walidacja**: Obrazy gotowe

- [ ] **3.2.4** Zaplanuj posty (1h)
  - LinkedIn: 2 na tydzień
  - Twitter: Codziennie
  - ✓ **Walidacja**: Kalendarz ustawiony

### Brama jakości
Pierwsza predykcja opublikowana? → ✅ Kontynuuj

---

## 3.3 Konfiguracja newslettera [6h]

### Zadania
- [ ] **3.3.1** Skonfiguruj Beehiiv (1h)
  - Utwórz publikację
  - Zaprojektuj szablon
  - ✓ **Walidacja**: Email testowy działa

- [ ] **3.3.2** Utwórz serię powitalną (2h)
  - Email 1: Czym jest Oracle?
  - Email 2: Jak przewidujemy
  - Email 3: Pierwsze predykcje
  - ✓ **Walidacja**: Seria aktywna

- [ ] **3.3.3** Pierwszy newsletter (2h)
  - Top 5 predykcji
  - Wprowadzenie do metodologii
  - CTA: Śledź predykcje
  - ✓ **Walidacja**: Wysłany do listy testowej

### Brama jakości
Infrastruktura newslettera gotowa? → ✅ Kontynuuj

---

## 3.4 Ogłoszenie uruchomienia [8h]

### Zadania
- [ ] **3.4.1** Napisz post o uruchomieniu (2h)
  - Problem: Nie można ocenić świeżych artykułów
  - Rozwiązanie: Predykcje ML
  - Dowód: Wczesne przykłady
  - ✓ **Walidacja**: Post dopracowany

- [ ] **3.4.2** Utwórz film uruchomieniowy (2h)
  - 60-sekundowe wyjaśnienie
  - Pokaż proces predykcji
  - ✓ **Walidacja**: Film przesłany

- [ ] **3.4.3** Dotrzyj do społeczności AI (2h)
  - r/MachineLearning
  - HackerNews
  - AI Twitter
  - ✓ **Walidacja**: Posty opublikowane

- [ ] **3.4.4** Bezpośredni kontakt (2h)
  - 10 badaczy AI
  - 5 dziennikarzy AI
  - Osobiste wiadomości
  - ✓ **Walidacja**: Wiadomości wysłane

### Brama jakości
Uruchomienie ogłoszone w 5+ miejscach? → ✅ Kontynuuj

---

## 3.5 Wczesna pętla feedbacku [6h]

### Zadania
- [ ] **3.5.1** Konfiguracja analityki (1h)
  - Google Analytics
  - Wizyty trackera
  - Otwarcia newslettera
  - ✓ **Walidacja**: Dane płyną

- [ ] **3.5.2** Utwórz formularz feedbacku (1h)
  - Dokładność predykcji
  - Prośby o funkcje
  - ✓ **Walidacja**: Formularz działa

- [ ] **3.5.3** Monitoruj reakcje (2h)
  - Wzmianki społecznościowe
  - Komentarze
  - Wiadomości prywatne
  - ✓ **Walidacja**: Log odpowiedzi

- [ ] **3.5.4** Szybkie iteracje (2h)
  - Napraw zgłoszone problemy
  - Wyjaśnij niejasności
  - ✓ **Walidacja**: v1.1 wdrożone

### Brama jakości
Pozytywny feedback > negatywny? → ✅ Faza 3 ukończona!

---

## 3.6 Śledzenie metryk sukcesu [4h]

### Zadania
- [ ] **3.6.1** Utwórz dashboard metryk (2h)
  - Liczba predykcji
  - Wzrost subskrybentów
  - Wskaźniki zaangażowania
  - ✓ **Walidacja**: Dashboard na żywo

- [ ] **3.6.2** Raport z tygodnia 1 (1h)
  - Co zadziałało
  - Co nie
  - Następne kroki
  - ✓ **Walidacja**: Raport udostępniony

---

## Lista kontrolna tygodnia uruchomienia
- [ ] Strona trackera na żywo
- [ ] 10+ predykcji opublikowanych
- [ ] Newsletter uruchomiony
- [ ] 50+ subskrybentów
- [ ] Analityka działa
- [ ] Feedback zebrany

## Osiągnięte metryki
- Wykonane predykcje: ____
- Odwiedzający stronę: ____
- Subskrybenci newslettera: ____
- Zaangażowanie społecznościowe: ____
- Wzmianki w mediach: ____

## Następna faza
[→ Faza 4: Wzrost i automatyzacja](./phase_4_growth_automation.md)

---

**Śledzenie czasu**
- Szacowany: 40h
- Faktyczny: ___h
- Data uruchomienia MVP: _______