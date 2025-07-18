# 🔍 PHASE 1: Data Collection Pipeline

[← Back to Master Roadmap](./ROADMAP_MASTER.md) | [← Previous: Phase 0](./phase_0_foundation.md)

## Overview
Budowa pipeline'u do zbierania papers i early signals. Fokus na automatyzacji i skalowalności.

## Duration & Resources
- **Total Time**: 1 tydzień (40h pracy)
- **Required Skills**: API integration, Make.com basics
- **Budget**: $0-100 (Twitter API optional)

## Success Criteria
- [ ] 1000+ papers collected with metadata
- [ ] Early signals for 100+ high-score papers
- [ ] Historical data ready for ML training
- [ ] Automated daily collection running

---

## 1.1 ArXiv Crawler Block [8h]

### Prerequisites
- Make.com account active
- Airtable Papers table ready

### Tasks
- [ ] **1.1.1** Create ArXiv crawler scenario (30 min)
  - New scenario: "Oracle - ArXiv Daily Crawler"
  - Schedule trigger: Daily 6:00 UTC
  - ✓ **Validation**: Trigger scheduled

- [ ] **1.1.2** Configure ArXiv API module (45 min)
  ```
  HTTP Request module:
  - URL: http://export.arxiv.org/api/query
  - Method: GET
  - Query String:
    * search_query: cat:cs.AI OR cat:cs.LG OR cat:cs.CL
    * start: 0
    * max_results: 50
    * sortBy: submittedDate
    * sortOrder: descending
  ```
  - ✓ **Validation**: Returns XML with papers

- [ ] **1.1.3** Parse XML response (1h)
  - Add XML Parser module
  - Map to JSON structure
  - Extract all entry nodes
  - ✓ **Validation**: See array of papers

- [ ] **1.1.4** Iterator setup (30 min)
  - Add Iterator module
  - Input: parsed entries array
  - ✓ **Validation**: Processes each paper

- [ ] **1.1.5** Data mapping (1h)
  ```
  For each paper, extract:
  - title: {{entry.title}}
  - arxiv_id: {{split(entry.id; "/")[last]}}
  - authors: {{join(map(entry.author; "name"); ", ")}}
  - abstract: {{entry.summary}}
  - pdf_url: {{first(map(filter(entry.link; href; contains(href; "pdf")); "href"))}}
  - submitted_date: {{parseDate(entry.published; "YYYY-MM-DD")}}
  ```
  - ✓ **Validation**: All fields mapped correctly

- [ ] **1.1.6** Save to Airtable (45 min)
  - Add Airtable "Create Record" module
  - Map all fields
  - Set error handling
  - ✓ **Validation**: Test paper saved

- [ ] **1.1.7** Duplicate check (30 min)
  - Before save, search for existing arxiv_id
  - Skip if exists
  - ✓ **Validation**: No duplicates created

### Quality Gate
Run full scenario, 50+ papers collected? → ✅ Proceed

---

## 1.2 Author Metrics Collector [6h]

### Tasks
- [ ] **1.2.1** Add Semantic Scholar module (1h)
  - After Iterator, add Router
  - First route: Author lookup
  - HTTP Request to SS API
  - ✓ **Validation**: Returns author data

- [ ] **1.2.2** Extract first author (30 min)
  ```javascript
  // Get first author name
  const authors = {{split(5.authors; ",")}}
  const firstAuthor = {{trim(first(authors))}}
  ```
  - ✓ **Validation**: Clean author name

- [ ] **1.2.3** Search for author (45 min)
  ```
  URL: https://api.semanticscholar.org/graph/v1/author/search
  Query: {{firstAuthor}}
  Fields: authorId,name,hIndex,citationCount
  ```
  - ✓ **Validation**: Returns author matches

- [ ] **1.2.4** Get h-index (30 min)
  - Parse response
  - Find best match by name similarity
  - Extract h-index
  - ✓ **Validation**: Numeric h-index or 0

- [ ] **1.2.5** Check institution (45 min)
  ```javascript
  // Top institutions list
  const topUnis = ["MIT", "Stanford", "CMU", "Berkeley", "Google", "DeepMind", "OpenAI"]
  const hasTop = topUnis.some(uni => 
    {{5.authors}}.toLowerCase().includes(uni.toLowerCase())
  )
  ```
  - ✓ **Validation**: Boolean true/false

### Quality Gate
Author metrics collected for 20+ papers? → ✅ Proceed

---

## 1.3 Social Signals Collector [8h]

### Tasks
- [ ] **1.3.1** Twitter mentions counter (2h) `OPTIONAL`
  - If no Twitter API, skip to 1.3.4
  - Add Twitter search module
  - Search: arxiv_id OR paper title
  - Count mentions in 24h
  - ✓ **Validation**: Number ≥ 0

- [ ] **1.3.2** GitHub implementation finder (2h)
  ```
  GitHub Search API:
  - Query: "{arxiv_id}" OR "{first 30 chars of title}"
  - Sort: stars
  - Created: >submitted_date
  ```
  - ✓ **Validation**: List of repos or empty

- [ ] **1.3.3** Calculate GitHub signal (1h)
  ```javascript
  const hasImplementation = {{length(12.items) > 0}}
  const totalStars = {{sum(map(12.items; "stargazers_count"))}}
  const repoCount = {{length(12.items)}}
  ```
  - ✓ **Validation**: Numeric values

- [ ] **1.3.4** Alternative signals (1h)
  - If no Twitter, use:
    * GitHub stars as proxy
    * Author reputation
    * Institution prestige
  - ✓ **Validation**: Some signal collected

### Quality Gate
Social signals for 50+ papers? → ✅ Proceed

---

## 1.4 Early Signals Score Calculator [4h]

### Tasks
- [ ] **1.4.1** Create scoring function (1h)
  ```javascript
  // In Make.com Tools module
  let score = 0;
  
  // Author (40 pts max)
  score += Math.min({{authorHIndex}} / 2, 15);
  score += {{hasTopInstitution}} ? 10 : 0;
  
  // Social (30 pts max)  
  score += Math.min({{twitterMentions}} / 10, 10);
  score += {{hasGitHub}} ? 5 : 0;
  score += Math.min({{githubStars}} / 10, 5);
  
  // Content (20 pts max)
  const hasCode = {{contains(lower(abstract); "github.com")}} ? 5 : 0;
  const hasSOTA = {{contains(lower(abstract); "state-of-the-art")}} ? 7 : 0;
  score += hasCode + hasSOTA;
  
  return Math.min(score, 100);
  ```
  - ✓ **Validation**: Returns 0-100

- [ ] **1.4.2** Update Airtable record (30 min)
  - Add score to paper record
  - Set needs_prediction flag
  - ✓ **Validation**: Score visible in Airtable

### Quality Gate
100+ papers scored? High-score papers identified? → ✅ Proceed

---

## 1.5 Historical Data Collection [8h]

### Purpose
Need 2020-2022 papers with known citations for ML training

### Tasks
- [ ] **1.5.1** Create historical crawler (1h)
  - Duplicate daily crawler
  - Name: "Oracle - Historical Backfill"
  - Manual trigger
  - ✓ **Validation**: Can run manually

- [ ] **1.5.2** Modify date range (30 min)
  ```
  For each month 2020-2022:
  - search_query: cat:cs.AI AND submittedDate:[20200101 TO 20200131]
  - max_results: 500
  ```
  - ✓ **Validation**: Returns old papers

- [ ] **1.5.3** Add citation lookup (2h)
  - After basic info, call Semantic Scholar
  - Get current citation count
  - Store as "citations_current"
  - ✓ **Validation**: Citation counts added

- [ ] **1.5.4** Run monthly batches (4h)
  - Process one month at a time
  - Monitor rate limits
  - Total goal: 10,000+ papers
  - ✓ **Validation**: Papers from 2020-2022 in DB

### Quality Gate
5000+ historical papers with citations? → ✅ Phase 1 Complete!

---

## 1.6 Data Quality Checks [2h]

### Tasks
- [ ] **1.6.1** Verify data completeness (30 min)
  - Check for null values
  - Validate date ranges
  - ✓ **Validation**: <5% missing data

- [ ] **1.6.2** Check signal distribution (30 min)
  - Score distribution graph
  - Author h-index range
  - ✓ **Validation**: Normal distribution

- [ ] **1.6.3** Export for ML training (1h)
  - Export historical data to CSV
  - Include all features
  - ✓ **Validation**: Clean CSV file

---

## Troubleshooting Guide

### Common Issues
1. **ArXiv rate limit**: Add 3-second delay between requests
2. **Semantic Scholar 404**: Some papers not indexed, skip
3. **GitHub rate limit**: Use authenticated requests
4. **Make.com timeout**: Process smaller batches

### Optimization Tips
- Cache author lookups (same author multiple papers)
- Batch process by date ranges
- Use Make.com data stores for deduplication

---

## Phase Completion Checklist
- [ ] Daily crawler operational
- [ ] 1000+ recent papers collected
- [ ] 5000+ historical papers with citations
- [ ] Early signals scoring working
- [ ] Data exported for ML training

## Metrics Achieved
- Papers collected: _____
- Average score: _____
- High-score papers (>60): _____
- Historical papers: _____

## Next Phase
[→ Phase 2: ML Model Development](./phase_2_ml_development.md)

---

**Time Tracking**
- Estimated: 40h
- Actual: ___h
- Blockers: ___________