# Plan utworzenia dwujęzycznej dokumentacji z automatycznym pipeline

## 📋 Executive Summary

Plan wdrożenia w pełni automatycznej, dwujęzycznej dokumentacji (PL/EN) dla projektu AI Research Oracle, publikowanej przez GitHub Pages z automatycznymi aktualizacjami przy każdej zmianie.

## 🎯 Cele

1. **Dwujęzyczność**: Pełna dokumentacja w językach polskim i angielskim
2. **Automatyzacja**: Pipeline tłumaczący i publikujący bez manualnej interwencji
3. **Synchronizacja**: Automatyczne utrzymanie spójności między wersjami
4. **Profesjonalizm**: Dokumentacja na poziomie enterprise

## 🏗️ Architektura rozwiązania

```
Repository Structure:
├── docs/                 # English documentation (primary)
├── docs-pl/              # Polish documentation (auto-translated + reviewed)
├── .github/
│   └── workflows/
│       ├── translate.yml # Auto-translation workflow
│       └── deploy.yml    # GitHub Pages deployment
├── translations/
│   ├── glossary.json     # Technical terms dictionary
│   └── overrides.json    # Manual translation overrides
└── mkdocs.yml           # Multi-language config
```

## 📊 Fazy implementacji

### Faza 1: Przygotowanie infrastruktury (Dzień 1)

#### 1.1 Setup MkDocs z i18n
```bash
pip install mkdocs-material
pip install mkdocs-static-i18n
pip install mkdocs-git-revision-date-localized-plugin
```

#### 1.2 Konfiguracja multi-language w mkdocs.yml
```yaml
plugins:
  - i18n:
      default_language: en
      languages:
        en:
          name: English
          build: true
        pl:
          name: Polski
          build: true
      nav_translations:
        pl:
          Home: Strona główna
          Strategy: Strategia
          Technical: Dokumentacja techniczna
          Operations: Operacje
```

#### 1.3 Struktura katalogów
```bash
# Run reorganize_docs.sh first
./reorganize_docs.sh

# Then create Polish mirror
cp -r docs/ docs-pl/
```

### Faza 2: Pipeline tłumaczenia (Dzień 2-3)

#### 2.1 GitHub Action dla automatycznego tłumaczenia
```yaml
# .github/workflows/translate.yml
name: Auto-translate Documentation

on:
  push:
    paths:
      - 'docs/**/*.md'
  workflow_dispatch:

jobs:
  translate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.x'
          
      - name: Install translation tools
        run: |
          pip install deep-translator
          pip install python-frontmatter
          
      - name: Translate documents
        env:
          DEEPL_API_KEY: ${{ secrets.DEEPL_API_KEY }}
        run: |
          python scripts/translate_docs.py
          
      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v5
        with:
          title: 'Auto-translation update'
          commit-message: 'chore: update Polish translations'
          branch: auto-translation-update
          delete-branch: true
```

#### 2.2 Skrypt tłumaczenia (scripts/translate_docs.py)
```python
#!/usr/bin/env python3
import os
import frontmatter
from deep_translator import DeeplTranslator
import json

# Load glossary and overrides
with open('translations/glossary.json', 'r') as f:
    glossary = json.load(f)
    
with open('translations/overrides.json', 'r') as f:
    overrides = json.load(f)

def translate_file(source_path, target_path):
    with open(source_path, 'r') as f:
        post = frontmatter.load(f)
    
    # Check if manual override exists
    if source_path in overrides:
        translated_content = overrides[source_path]
    else:
        # Auto-translate
        translator = DeeplTranslator(
            api_key=os.environ['DEEPL_API_KEY'],
            source='en',
            target='pl'
        )
        
        # Apply glossary terms
        content = post.content
        for term_en, term_pl in glossary.items():
            content = content.replace(term_en, f"{{GLOSSARY:{term_en}}}")
        
        # Translate
        translated = translator.translate(content)
        
        # Restore glossary terms
        for term_en, term_pl in glossary.items():
            translated = translated.replace(f"{{GLOSSARY:{term_en}}}", term_pl)
        
        translated_content = translated
    
    # Save translated file
    post.content = translated_content
    with open(target_path, 'w') as f:
        f.write(frontmatter.dumps(post))

# Process all files
for root, dirs, files in os.walk('docs'):
    for file in files:
        if file.endswith('.md'):
            source = os.path.join(root, file)
            target = source.replace('docs/', 'docs-pl/')
            os.makedirs(os.path.dirname(target), exist_ok=True)
            translate_file(source, target)
```

### Faza 3: Glossary i quality control (Dzień 4)

#### 3.1 Słownik terminów technicznych
```json
// translations/glossary.json
{
  "Early Signals Score": "Wskaźnik Wczesnych Sygnałów",
  "prediction accuracy": "dokładność predykcji",
  "machine learning": "uczenie maszynowe",
  "citation": "cytowanie",
  "paper": "publikacja",
  "research impact": "wpływ badawczy",
  "API": "API",
  "newsletter": "newsletter",
  "MVP": "MVP",
  "roadmap": "mapa drogowa"
}
```

#### 3.2 Manual overrides dla krytycznych sekcji
```json
// translations/overrides.json
{
  "docs/index.md": "# Dokumentacja AI Research Oracle\n\nWitamy w dokumentacji...",
  "docs/README.md": "# AI Research Oracle\n\n**AI Research Oracle** przewiduje..."
}
```

### Faza 4: CI/CD Pipeline (Dzień 5)

#### 4.1 Kompletny workflow deployment
```yaml
# .github/workflows/deploy-bilingual.yml
name: Deploy Bilingual Documentation

on:
  push:
    branches: [main]
  pull_request:
    types: [closed]
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        
      - name: Install dependencies
        run: |
          pip install -r requirements-docs.txt
          pip install mkdocs-static-i18n
          
      - name: Build multi-language site
        run: |
          mkdocs build
          
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./site
```

#### 4.2 Pre-commit hooks dla quality
```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: check-translations
        name: Check translation consistency
        entry: python scripts/check_translations.py
        language: python
        files: '^docs/.*\.md$'
```

### Faza 5: Monitoring i maintenance (Dzień 6-7)

#### 4.1 Translation status dashboard
```python
# scripts/translation_status.py
def generate_status_report():
    status = {
        "total_files": 0,
        "translated": 0,
        "outdated": 0,
        "missing": 0
    }
    
    # Compare timestamps and generate report
    # Output as markdown table in docs/translation-status.md
```

#### 4.2 Automated quality checks
- Broken links detection
- Missing translations alert
- Terminology consistency check
- SEO meta tags validation

## 🚀 Pipeline uruchomienia

### Krok 1: Inicjalizacja
```bash
# 1. Run reorganization
./reorganize_docs.sh

# 2. Install dependencies
pip install -r requirements-docs.txt

# 3. Setup translation tools
pip install deep-translator python-frontmatter

# 4. Initialize git hooks
pre-commit install
```

### Krok 2: Pierwsze tłumaczenie
```bash
# 1. Add DeepL API key to GitHub Secrets

# 2. Create initial Polish structure
cp -r docs/ docs-pl/

# 3. Run initial translation
python scripts/translate_docs.py

# 4. Review and adjust critical sections
```

### Krok 3: Deploy
```bash
# 1. Commit changes
git add .
git commit -m "feat: add bilingual documentation"

# 2. Push to trigger deployment
git push origin main

# 3. Check GitHub Pages
# https://[username].github.io/ai-research-oracle/
```

## 📊 Metryki sukcesu

1. **Coverage**: 100% dokumentów dostępnych w obu językach
2. **Sync time**: <24h między aktualizacją EN a PL
3. **Quality score**: >90% accuracy w tłumaczeniach technicznych
4. **Build time**: <5 minut dla pełnego deployu

## 🔧 Maintenance

### Cotygodniowe
- Review automatically translated content
- Update glossary with new terms
- Check translation status report

### Comiesięczne
- Full quality audit
- Performance optimization
- User feedback integration

## 💰 Koszty

- **DeepL API**: ~$20/miesiąc (przy 100k znaków/miesiąc)
- **GitHub Actions**: Darmowe (public repo)
- **GitHub Pages**: Darmowe
- **Łącznie**: $20/miesiąc

## 🎯 Rezultat końcowy

Po wdrożeniu będziesz mieć:

1. **Profesjonalną dokumentację** dostępną w 2 językach
2. **Automatyczny pipeline** tłumaczący każdą zmianę
3. **GitHub Pages** z ładnym UI (Material theme)
4. **Version control** dla wszystkich tłumaczeń
5. **SEO-friendly** URLs dla obu języków
6. **Monitoring** jakości i kompletności

Dokumentacja będzie dostępna pod adresami:
- `https://[username].github.io/ai-research-oracle/` (EN)
- `https://[username].github.io/ai-research-oracle/pl/` (PL)

## 🚦 Ready to go?

1. ✅ Uruchom `reorganize_docs.sh`
2. ✅ Skonfiguruj GitHub Secrets (DEEPL_API_KEY)
3. ✅ Stwórz wymagane skrypty Python
4. ✅ Push do GitHub
5. ✅ Włącz GitHub Pages w settings

Całość powinna być live w ciągu 30 minut! 🚀