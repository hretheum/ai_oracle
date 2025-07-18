# Algorytm wyniku wczesnych sygnałów

## Przegląd
Wynik wczesnych sygnałów (0-100) przewiduje przyszły wpływ artykułu na podstawie wskaźników z pierwszych 7 dni po publikacji.

## Wagi sygnałów
- **40%** - Metryki autorów (h-index, afiliacja instytucjonalna)
- **35%** - Implementacje kodu (repozytoria GitHub w ciągu 72 godzin)
- **20%** - Sygnały społecznościowe (wzmianki na Twitterze, dyskusje na Reddit)
- **5%** - Nowość techniczna (nowe metody, benchmarki)

## Szczegóły implementacji
[Do dodania podczas rozwoju Fazy 2]

## Metodologia walidacji
- Dane historyczne: Artykuły z lat 2020-2022
- Metryka sukcesu: Top 20% według cytowań po 24 miesiącach
- Porównanie bazowe: Losowe (20%), tylko h-index (51%)
- Docelowa dokładność: 70%+