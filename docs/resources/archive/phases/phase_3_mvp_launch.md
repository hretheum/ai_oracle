# 🚀 PHASE 3: MVP Launch

[← Back to Master Roadmap](./ROADMAP_MASTER.md) | [← Previous: Phase 2](./phase_2_ml_development.md)

## Overview
Publiczny launch Oracle z pierwszymi predykcjami, tracker website i podstawowym newsletterem.

## Duration & Resources
- **Total Time**: 1 tydzień (40h pracy)
- **Required Skills**: Basic web dev, content writing, Make.com
- **Budget**: $20-50 (domain, hosting)

## Success Criteria
- [ ] 20+ public predictions made
- [ ] Tracker website live
- [ ] 50+ newsletter subscribers
- [ ] First media mention

---

## 3.1 Public Tracker Website [8h]

### Prerequisites
- Domain registered
- Hosting ready (Vercel recommended)

### Tasks
- [ ] **3.1.1** Setup Next.js project (1h)
  ```bash
  npx create-next-app@latest oracle-tracker
  cd oracle-tracker
  npm install axios recharts
  ```
  - ✓ **Validation**: Dev server running

- [ ] **3.1.2** Create API routes (2h)
  ```javascript
  // pages/api/predictions.js
  export default async function handler(req, res) {
    // Fetch from Airtable
    const predictions = await fetchPredictions();
    res.json({ predictions });
  }
  ```
  - ✓ **Validation**: API returns data

- [ ] **3.1.3** Build main page (3h)
  - Hero: "AI Research Oracle - We Predict Impact"
  - Stats: Total predictions, accuracy rate
  - Recent predictions list
  - ✓ **Validation**: Page displays data

- [ ] **3.1.4** Deploy to Vercel (1h)
  - Connect GitHub repo
  - Set environment variables
  - Deploy
  - ✓ **Validation**: Live URL working

### Quality Gate
Website live with real predictions? → ✅ Proceed

---

## 3.2 First Predictions Campaign [8h]

### Tasks
- [ ] **3.2.1** Select top 10 papers (1h)
  - Highest confidence predictions
  - Diverse topics
  - ✓ **Validation**: List ready

- [ ] **3.2.2** Write prediction posts (3h)
  - Template per prediction
  - Why it matters
  - Early signals breakdown
  - ✓ **Validation**: 10 posts written

- [ ] **3.2.3** Create visuals (2h)
  - Prediction cards
  - Signal charts
  - ✓ **Validation**: Images ready

- [ ] **3.2.4** Schedule posts (1h)
  - LinkedIn: 2 per week
  - Twitter: Daily
  - ✓ **Validation**: Calendar set

### Quality Gate
First prediction published? → ✅ Proceed

---

## 3.3 Newsletter Setup [6h]

### Tasks
- [ ] **3.3.1** Configure Beehiiv (1h)
  - Create publication
  - Design template
  - ✓ **Validation**: Test email works

- [ ] **3.3.2** Create welcome series (2h)
  - Email 1: What is Oracle?
  - Email 2: How we predict
  - Email 3: First predictions
  - ✓ **Validation**: Series active

- [ ] **3.3.3** First newsletter (2h)
  - Top 5 predictions
  - Methodology intro
  - CTA: Track predictions
  - ✓ **Validation**: Sent to test list

### Quality Gate
Newsletter infrastructure ready? → ✅ Proceed

---

## 3.4 Launch Announcement [8h]

### Tasks
- [ ] **3.4.1** Write launch post (2h)
  - Problem: Can't evaluate fresh papers
  - Solution: ML predictions
  - Proof: Early examples
  - ✓ **Validation**: Post polished

- [ ] **3.4.2** Create launch video (2h)
  - 60-second explainer
  - Show prediction process
  - ✓ **Validation**: Video uploaded

- [ ] **3.4.3** Reach out to AI communities (2h)
  - r/MachineLearning
  - HackerNews
  - AI Twitter
  - ✓ **Validation**: Posts live

- [ ] **3.4.4** Direct outreach (2h)
  - 10 AI researchers
  - 5 AI journalists
  - Personal messages
  - ✓ **Validation**: Messages sent

### Quality Gate
Launch announced in 5+ places? → ✅ Proceed

---

## 3.5 Early Feedback Loop [6h]

### Tasks
- [ ] **3.5.1** Setup analytics (1h)
  - Google Analytics
  - Tracker visits
  - Newsletter opens
  - ✓ **Validation**: Data flowing

- [ ] **3.5.2** Create feedback form (1h)
  - Prediction accuracy
  - Feature requests
  - ✓ **Validation**: Form working

- [ ] **3.5.3** Monitor reactions (2h)
  - Social mentions
  - Comments
  - DMs
  - ✓ **Validation**: Response log

- [ ] **3.5.4** Quick iterations (2h)
  - Fix reported issues
  - Clarify confusion
  - ✓ **Validation**: v1.1 deployed

### Quality Gate
Positive feedback > negative? → ✅ Phase 3 Complete!

---

## 3.6 Success Metrics Tracking [4h]

### Tasks
- [ ] **3.6.1** Create metrics dashboard (2h)
  - Prediction count
  - Subscriber growth
  - Engagement rates
  - ✓ **Validation**: Dashboard live

- [ ] **3.6.2** Week 1 report (1h)
  - What worked
  - What didn't
  - Next steps
  - ✓ **Validation**: Report shared

---

## Launch Week Checklist
- [ ] Tracker website live
- [ ] 10+ predictions published
- [ ] Newsletter launched
- [ ] 50+ subscribers
- [ ] Analytics working
- [ ] Feedback collected

## Metrics Achieved
- Predictions made: ____
- Website visitors: ____
- Newsletter subscribers: ____
- Social engagement: ____
- Media mentions: ____

## Next Phase
[→ Phase 4: Growth & Automation](./phase_4_growth_automation.md)

---

**Time Tracking**
- Estimated: 40h
- Actual: ___h
- MVP Live Date: _______