# 📋 PHASE 0: Foundation Setup

[← Back to Master Roadmap](./ROADMAP_MASTER.md)

## Overview
Konfiguracja fundamentów projektu Oracle. Wszystkie zadania są atomowe i mogą być wykonane niezależnie.

## Duration & Resources
- **Total Time**: 3 dni (24h pracy)
- **Required Skills**: Basic technical, no ML needed yet
- **Budget**: $0 (free tiers)

## Success Criteria
- [ ] All accounts created and verified
- [ ] Database schema fully implemented
- [ ] Development environment working
- [ ] First test API call successful

---

## 0.1 Account Setup Block [4h]

### Tasks
- [ ] **0.1.1** Create Make.com account (15 min)
  - Go to make.com
  - Sign up with email
  - Verify email
  - ✓ **Validation**: Can access dashboard
  
- [ ] **0.1.2** Create Airtable account (10 min)
  - Go to airtable.com
  - Sign up
  - Skip onboarding
  - ✓ **Validation**: Can create base

- [ ] **0.1.3** Twitter Developer Account (45 min)
  - Apply at developer.twitter.com
  - Fill "Academic Research" use case
  - Wait for approval (can be instant)
  - ✓ **Validation**: Have Bearer Token
  
- [ ] **0.1.4** GitHub Personal Access Token (5 min)
  - Settings → Developer settings → PAT
  - Generate new token (classic)
  - Select: public_repo, read:user
  - ✓ **Validation**: Token works with curl

- [ ] **0.1.5** Semantic Scholar API (10 min)
  - Register at semanticscholar.org/product/api
  - Get API key immediately
  - ✓ **Validation**: Test query returns data

- [ ] **0.1.6** Heroku/Railway account (20 min)
  - Choose Railway (easier, modern)
  - Sign up with GitHub
  - ✓ **Validation**: Can create project

### Quality Gate
All accounts active? → ✅ Proceed | ❌ Debug issues

---

## 0.2 Database Schema Block [3h]

### Prerequisites
- Airtable account active

### Tasks
- [ ] **0.2.1** Create base "AI Research Oracle" (5 min)
  - From scratch, not template
  - ✓ **Validation**: Base appears in workspace

- [ ] **0.2.2-0.2.15** Create Papers table fields (45 min)
  ```
  Each field (3 min each):
  - paper_id (Autonumber)
  - arxiv_id (Single line)
  - title (Single line)
  - authors (Long text)
  - abstract (Long text)
  - pdf_url (URL)
  - submitted_date (Date)
  - early_signals_score (Number, 0-100)
  - author_max_h_index (Number)
  - twitter_mentions_24h (Number)
  - github_repos_7d (Number)
  - has_code (Checkbox)
  - needs_prediction (Formula: {early_signals_score} > 60)
  - predicted (Checkbox)
  - prediction_date (Date)
  ```
  - ✓ **Validation**: All fields visible and correct type

- [ ] **0.2.16** Create Predictions table (30 min)
  ```
  Fields:
  - prediction_id (Autonumber)
  - paper_link (Link to Papers)
  - predicted_citations_1yr (Number)
  - predicted_citations_3yr (Number)
  - predicted_citations_5yr (Number)
  - confidence (Number, 0-1)
  - percentile (Number, 0-100)
  - model_version (Single line)
  ```
  - ✓ **Validation**: Can link to Papers table

- [ ] **0.2.17** Create views (15 min)
  - "High Score Papers": Filter {early_signals_score} > 60
  - "Needs Prediction": Filter {needs_prediction} = TRUE()
  - "Recent Predictions": Sort by prediction_date DESC
  - ✓ **Validation**: Views show filtered data correctly

### Quality Gate
Can you manually add a test paper and see it in views? → ✅ Proceed

---

## 0.3 Development Environment Block [2h]

### Tasks
- [ ] **0.3.1** Install Python 3.8+ (30 min)
  ```bash
  # Mac: brew install python@3.9
  # Windows: Download from python.org
  # Linux: sudo apt install python3.9
  ```
  - ✓ **Validation**: `python3 --version` shows 3.8+

- [ ] **0.3.2** Create project structure (10 min)
  ```bash
  mkdir -p oracle_project/{data,models,api,scripts,notebooks}
  cd oracle_project
  python3 -m venv venv
  ```
  - ✓ **Validation**: Folders exist, venv created

- [ ] **0.3.3** Install base packages (10 min)
  ```bash
  source venv/bin/activate  # Windows: venv\Scripts\activate
  pip install pandas numpy scikit-learn requests flask
  pip install jupyter matplotlib seaborn joblib
  pip freeze > requirements.txt
  ```
  - ✓ **Validation**: `pip list` shows all packages

- [ ] **0.3.4** Test API connections (20 min)
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
  - ✓ **Validation**: Both return 200 OK

### Quality Gate
All APIs responding? Environment working? → ✅ Proceed to Phase 1

---

## 0.4 Make.com Initial Setup Block [2h]

### Tasks
- [ ] **0.4.1** Create first scenario (10 min)
  - Name: "Oracle - Test Connection"
  - ✓ **Validation**: Scenario created

- [ ] **0.4.2** Add Airtable connection (15 min)
  - Add Airtable module
  - Connect with API key
  - Select base and table
  - ✓ **Validation**: Can see Papers table

- [ ] **0.4.3** Test data flow (20 min)
  - Add HTTP module → ArXiv API
  - Add Airtable Create Record
  - Map fields
  - Run once
  - ✓ **Validation**: Record appears in Airtable

### Quality Gate
Test paper successfully saved to Airtable? → ✅ Phase 0 Complete!

---

## Troubleshooting Guide

### Common Issues
1. **Twitter API rejected**: Use "Academic research" reason, be specific
2. **Airtable formula error**: Check syntax, use {} for field names
3. **Python version issues**: Use pyenv or conda
4. **Make.com limit**: Stay under 1000 ops for testing

### If Blocked
- Skip Twitter API temporarily (not critical for MVP)
- Use Google Colab if local Python fails
- Try Zapier if Make.com issues

---

## Phase Completion Checklist
- [ ] All accounts created
- [ ] Database schema complete
- [ ] Dev environment working
- [ ] First test data flow successful
- [ ] Documented any issues

## Next Phase
[→ Phase 1: Data Collection Pipeline](./phase_1_data_collection.md)

---

**Time Tracking**
- Estimated: 24h
- Actual: ___h
- Blockers: ___________