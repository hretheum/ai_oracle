#!/bin/bash

# AI Research Oracle - Documentation Reorganization Script
# Purpose: Unify documentation structure and eliminate duplications
# Date: July 2025

set -e # Exit on error

echo "🚀 Starting AI Research Oracle documentation reorganization..."

# Create backup
echo "📦 Creating backup..."
cp -r . ../growth-automation-backup-$(date +%Y%m%d-%H%M%S)

# Create new directory structure
echo "📁 Creating new directory structure..."
mkdir -p docs/strategy
mkdir -p docs/technical
mkdir -p docs/operations
mkdir -p docs/resources
mkdir -p docs-pl
mkdir -p .github/workflows

# Move and consolidate strategic documents
echo "📄 Consolidating strategic documents..."

# Merge pivot summaries into one
if [ -f "docs/ORACLE_PIVOT_SUMMARY.md" ] && [ -f "docs/PIVOT_SUMMARY.md" ]; then
    echo "# AI Research Oracle - Pivot Story" > docs/strategy/pivot-story.md
    echo "" >> docs/strategy/pivot-story.md
    echo "## Summary" >> docs/strategy/pivot-story.md
    cat docs/PIVOT_SUMMARY.md >> docs/strategy/pivot-story.md
    rm -f docs/ORACLE_PIVOT_SUMMARY.md
    rm -f docs/PIVOT_SUMMARY.md
fi

# Move master plan
if [ -f "docs/MASTER_PLAN.md" ]; then
    mv docs/MASTER_PLAN.md docs/strategy/business-plan.md
fi

# Extract and centralize algorithms
echo "📊 Extracting algorithms documentation..."
cat > docs/technical/algorithms.md << 'EOF'
# Early Signals Score Algorithm

## Overview
The Early Signals Score (0-100) predicts future paper impact based on indicators from the first 7 days after publication.

## Signal Weights
- **40%** - Author metrics (h-index, institutional affiliation)
- **35%** - Code implementations (GitHub repos within 72 hours)
- **20%** - Social signals (Twitter mentions, Reddit discussions)
- **5%** - Technical novelty (new methods, benchmarks)

## Implementation Details
[To be added during Phase 2 development]

## Validation Methodology
- Historical data: Papers from 2020-2022
- Success metric: Top 20% by citations after 24 months
- Baseline comparison: Random (20%), h-index only (51%)
- Target accuracy: 70%+
EOF

# Centralize metrics and KPIs
echo "📈 Creating unified metrics document..."
cat > docs/operations/metrics.md << 'EOF'
# AI Research Oracle - Metrics & KPIs

## Success Metrics

### Technical Targets
- Prediction accuracy: 70%+ (predicting top 20% papers)
- Papers analyzed: 10,000+ in first 6 months
- API response time: <500ms
- System uptime: 99%+

### Business Targets (6 months)
- Newsletter subscribers: 5,000
- Paid API users: 20
- Monthly Recurring Revenue: $10,000
- Customer Acquisition Cost: <$20

### Validation Metrics
- Model iterations: 5+ versions
- A/B test improvements: 10%+ per quarter
- User retention: 60%+ after 3 months

## Current Status
- **Stage**: Pre-MVP (Concept validation)
- **Users**: 0
- **Revenue**: $0
- **Next milestone**: First 100 beta users (August 2025)
EOF

# Create budget document
echo "💰 Creating budget documentation..."
cat > docs/operations/budget.md << 'EOF'
# AI Research Oracle - Budget & ROI

## Monthly Costs (Operational)

### Phase 1-2 (MVP)
- Make.com: $29
- Airtable: $20
- Hosting: $20
- **Total: $69/month**

### Phase 3-4 (Growth)
- Twitter API: $100
- Make.com Teams: $29
- ML API hosting: $40
- Beehiiv: $31
- Other tools: $50
- **Total: $250/month**

### Phase 5-6 (Scale)
- All above: $250
- Enhanced ML compute: $200
- Monitoring tools: $50
- Team tools: $100
- **Total: $600/month**

## Revenue Projections

### Conservative Scenario
- Month 6: 250 paid users × $19 = $4,750 MRR
- Month 12: 1,000 paid users × $19 = $19,000 MRR
- Break-even: Month 8

### Realistic Scenario
- Month 6: 100 paid users = $1,900 MRR
- Month 12: 500 paid users = $9,500 MRR
- Break-even: Month 10

## Unit Economics (Target)
- Customer Acquisition Cost: $20
- Customer Lifetime Value: $342 (18 months)
- LTV:CAC Ratio: 17:1
EOF

# Move technical documents
echo "🔧 Organizing technical documentation..."
[ -f "docs/IMPLEMENTATION_GUIDE.md" ] && mv docs/IMPLEMENTATION_GUIDE.md docs/technical/implementation-guide.md
[ -f "docs/API_INTEGRATION_SPECS.md" ] && mv docs/API_INTEGRATION_SPECS.md docs/technical/api-reference.md
[ -f "docs/ML_TRAINING_GUIDE.md" ] && mv docs/ML_TRAINING_GUIDE.md docs/technical/ml-training-guide.md

# Move operational documents
echo "📋 Moving operational documents..."
[ -f "docs/NEWSLETTER_STRATEGY.md" ] && mv docs/NEWSLETTER_STRATEGY.md docs/operations/newsletter-strategy.md

# Handle roadmap
echo "🗺️ Consolidating roadmap..."
if [ -d "docs/roadmap" ]; then
    # Create consolidated roadmap
    cat > docs/operations/roadmap.md << 'EOF'
# AI Research Oracle - Development Roadmap

## Timeline: July 2025 - December 2025

### Phase 0: Foundation (July 19-21, 2025)
- Environment setup
- API accounts creation
- Database schema design
- **Success Gate**: All systems connected

### Phase 1: Data Collection (July 22-28, 2025)
- ArXiv crawler implementation
- Social signals collection
- First 1,000 papers gathered
- **Success Gate**: Pipeline processes 100 papers/day

### Phase 2: ML Development (July 29 - August 4, 2025)
- Feature engineering
- Model training (XGBoost baseline)
- Historical validation
- **Success Gate**: 60%+ accuracy on test set

### Phase 3: MVP Launch (August 5-11, 2025)
- First 10 public predictions
- Basic web interface
- Newsletter launch
- **Success Gate**: 100 beta users signed up

### Phase 4: Growth Automation (August 12-25, 2025)
- Full pipeline automation
- Multi-channel publishing
- Performance optimization
- **Success Gate**: 500 active users

### Phase 5: Optimization (September 2025)
- Model improvements
- A/B testing framework
- Advanced features
- **Success Gate**: 70% accuracy achieved

### Phase 6: Enterprise (October-November 2025)
- API productization
- Enterprise features
- Acquisition preparation
- **Success Gate**: First paying enterprise customer

## Risk Management
See detailed risk register in each phase document.
EOF
    
    # Archive detailed phase docs
    mkdir -p docs/resources/archive/phases
    mv docs/roadmap/phase_*.md docs/resources/archive/phases/ 2>/dev/null || true
    [ -f "docs/roadmap/ROADMAP_MASTER.md" ] && rm -f docs/roadmap/ROADMAP_MASTER.md
    rmdir docs/roadmap 2>/dev/null || true
fi

# Move resources
echo "📚 Organizing resources..."
[ -f "resources/case-study-example.md" ] && mv resources/case-study-example.md docs/resources/
[ -f "resources/platform_comparison.md" ] && mv resources/platform_comparison.md docs/resources/

# Update main README to use honest version
echo "📝 Updating README..."
if [ -f "README_HONEST.md" ]; then
    mv README.md README_OLD.md
    mv README_HONEST.md README.md
fi

# Create documentation index
echo "📖 Creating documentation index..."
cat > docs/index.md << 'EOF'
# AI Research Oracle Documentation

Welcome to the AI Research Oracle documentation. This project aims to predict which AI research papers will become influential using machine learning analysis of early signals.

## Quick Navigation

### 📋 Strategic Documents
- [Business Plan](strategy/business-plan.md) - Complete business strategy
- [Pivot Story](strategy/pivot-story.md) - How we arrived at this solution
- [Metrics & KPIs](operations/metrics.md) - Success metrics and targets

### 🔧 Technical Documentation
- [Implementation Guide](technical/implementation-guide.md) - Step-by-step setup
- [API Reference](technical/api-reference.md) - API specifications
- [Algorithms](technical/algorithms.md) - Early Signals Score explained
- [ML Training](technical/ml-training-guide.md) - Model development guide

### 📊 Operations
- [Roadmap](operations/roadmap.md) - Development timeline
- [Budget & ROI](operations/budget.md) - Financial projections
- [Newsletter Strategy](operations/newsletter-strategy.md) - Content strategy

### 📚 Resources
- [Case Studies](resources/case-study-example.md) - Example implementations
- [Platform Comparison](resources/platform_comparison.md) - Tool analysis
- [Gamma Pitch Deck](GAMMA_PITCH_DECK_PROMPT.md) - Pitch deck prompt

## Project Status

**Current Stage**: Pre-MVP (Concept Validation)
**Start Date**: July 19, 2025
**Target Launch**: August 5, 2025 (MVP with 100 beta users)

## Contributing

See [Contributing Guide](../CONTRIBUTING.md) for details on how to help.
EOF

# Create MkDocs configuration
echo "⚙️ Creating MkDocs configuration..."
cat > mkdocs.yml << 'EOF'
site_name: AI Research Oracle
site_description: Predicting AI paper impact using early signals
site_author: AI Research Oracle Team
site_url: https://yourusername.github.io/ai-research-oracle

theme:
  name: material
  language: en
  palette:
    - scheme: default
      primary: indigo
      accent: orange
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - scheme: slate
      primary: indigo
      accent: orange
      toggle:
        icon: material/brightness-4
        name: Switch to light mode
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - navigation.top
    - search.suggest
    - search.highlight
    - content.code.copy

plugins:
  - search
  - awesome-pages
  - git-revision-date-localized:
      enable_creation_date: true

nav:
  - Home: index.md
  - Strategy:
    - Business Plan: strategy/business-plan.md
    - Pivot Story: strategy/pivot-story.md
  - Technical:
    - Implementation: technical/implementation-guide.md
    - API Reference: technical/api-reference.md
    - Algorithms: technical/algorithms.md
    - ML Training: technical/ml-training-guide.md
  - Operations:
    - Roadmap: operations/roadmap.md
    - Metrics: operations/metrics.md
    - Budget: operations/budget.md
    - Newsletter: operations/newsletter-strategy.md
  - Resources:
    - Case Studies: resources/case-study-example.md
    - Platforms: resources/platform_comparison.md
    - Pitch Deck: GAMMA_PITCH_DECK_PROMPT.md

extra:
  social:
    - icon: fontawesome/brands/github
      link: https://github.com/yourusername/ai-research-oracle
    - icon: fontawesome/brands/twitter
      link: https://twitter.com/AIResearchOracle

markdown_extensions:
  - pymdownx.highlight:
      anchor_linenums: true
  - pymdownx.superfences
  - pymdownx.tabbed:
      alternate_style: true
  - admonition
  - pymdownx.details
  - pymdownx.emoji:
      emoji_index: !!python/name:materialx.emoji.twemoji
      emoji_generator: !!python/name:materialx.emoji.to_svg
EOF

# Create GitHub Actions workflow for documentation
echo "🚀 Creating GitHub Actions workflow..."
cat > .github/workflows/deploy-docs.yml << 'EOF'
name: Deploy Documentation

on:
  push:
    branches: [main]
    paths:
      - 'docs/**'
      - 'docs-pl/**'
      - 'mkdocs.yml'
      - 'README.md'
  workflow_dispatch:

permissions:
  contents: write
  pages: write
  id-token: write

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
          
      - uses: actions/setup-python@v4
        with:
          python-version: '3.x'
          
      - name: Install dependencies
        run: |
          pip install mkdocs-material
          pip install mkdocs-awesome-pages-plugin
          pip install mkdocs-git-revision-date-localized-plugin
          
      - name: Build documentation
        run: mkdocs build
        
      - name: Deploy to GitHub Pages
        run: mkdocs gh-deploy --force
EOF

# Create requirements for docs
echo "📋 Creating documentation requirements..."
cat > requirements-docs.txt << 'EOF'
mkdocs==1.5.3
mkdocs-material==9.5.3
mkdocs-awesome-pages-plugin==2.9.2
mkdocs-git-revision-date-localized-plugin==1.2.4
pygments==2.17.2
pymdown-extensions==10.7
EOF

# Clean up old structure
echo "🧹 Cleaning up old structure..."
rm -rf resources 2>/dev/null || true
[ -f "docs/GAMMA_PITCH_DECK_PROMPT.md" ] && mv docs/GAMMA_PITCH_DECK_PROMPT.md docs/

# Create .gitignore for docs
echo "📝 Creating .gitignore..."
cat >> .gitignore << 'EOF'

# Documentation build
site/
.cache/

# MkDocs
mkdocs-material/

# OS
.DS_Store
Thumbs.db
EOF

# Final summary
echo "✅ Reorganization complete!"
echo ""
echo "📊 Summary of changes:"
echo "- Created unified documentation structure"
echo "- Eliminated duplications"
echo "- Centralized metrics, algorithms, and budget"
echo "- Prepared for MkDocs deployment"
echo ""
echo "📝 Next steps:"
echo "1. Review the changes"
echo "2. Run: pip install -r requirements-docs.txt"
echo "3. Run: mkdocs serve (to preview locally)"
echo "4. Commit and push to trigger GitHub Pages deployment"
echo ""
echo "🌐 Your documentation will be available at:"
echo "https://[yourusername].github.io/ai-research-oracle/"