# AI Research Oracle

**Status: Concept/Early Development**

AI Research Oracle is a planned machine learning system that aims to predict which AI papers will become influential before they accumulate citations. The concept is to analyze early signals from the first week after publication—author metrics, social buzz, GitHub implementations, and topic momentum—to forecast future impact.

## 🌐 Language / Język

📖 **English** (current) | [📖 **Polski**](https://github.com/hretheum/ai_oracle/tree/main/docs-pl) | [📚 **Documentation**](https://hretheum.github.io/ai_oracle/)

## Current Reality

- **Development Stage**: Pre-MVP, architecture design phase
- **Code Written**: ~0% (planning stage)
- **Users**: 0
- **Revenue**: $0
- **Team**: 1-2 people (part-time)

## The Problem We're Solving

- 2,000+ AI papers published daily on ArXiv
- Researchers need 1-3 years to see which papers accumulate citations
- By then, competitive advantage from early adoption is lost
- Current curation tools can only look backward, not forward

## Proposed Solution

Build an ML system that:
1. Collects early signals (first 7 days after publication)
2. Predicts which papers will be in top 20% by citations after 2 years
3. Tracks predictions publicly to build trust
4. Learns from outcomes to improve accuracy

## Technical Approach (Planned)

### Early Signals to Track:
- Author h-index and institutional affiliation
- GitHub repos created within 72 hours
- Twitter/Reddit discussion volume
- Technical novelty indicators

### Target Metrics:
- Prediction accuracy: 70%+ (to be validated)
- Papers to analyze: 10,000+ for training
- Latency: <10 minutes from publication

## Business Model (Hypothesis)

1. **Free Tier**: Weekly newsletter with top 5 predictions
2. **Researcher Tier**: $19/month for API access
3. **Team/Lab Tier**: $199/month for bulk access
4. **Enterprise**: Custom pricing for white-label

**Assumptions to Validate:**
- Researchers will pay for time-saving tools
- 70% accuracy is achievable and valuable
- Early signals actually correlate with long-term impact

## Development Roadmap

### Phase 0 (Current): Foundation
- [ ] Set up data collection infrastructure
- [ ] Create database schema
- [ ] Collect first 1,000 papers with metadata

### Phase 1: Data Collection
- [ ] Build automated pipeline for ArXiv + social signals
- [ ] Gather historical data (2020-2022) for training
- [ ] Validate that signals exist and are collectible

### Phase 2: ML Development
- [ ] Train first model (even if only 60% accurate)
- [ ] Build evaluation framework
- [ ] Test on historical data

### Phase 3: MVP Launch
- [ ] Make first 10 public predictions
- [ ] Launch basic newsletter
- [ ] Get first 100 beta users

## Budget Reality

**Estimated Monthly Costs (when operational):**
- Data APIs: ~$150 (Twitter, etc.)
- Infrastructure: ~$50 (hosting, compute)
- Tools: ~$50 (Make.com, Airtable)
- **Total: ~$250/month**

## Honest Risks

1. **Technical Risk**: Maybe early signals don't predict impact
2. **Market Risk**: Researchers might not care enough to pay
3. **Competition Risk**: Google Scholar could add this feature
4. **Execution Risk**: Building accurate ML is hard

## How to Contribute

We're in early stages and welcome:
- Feedback on the concept
- Introductions to AI researchers
- Technical expertise in ML/NLP
- Historical citation data for validation

## Contact

- Email: [your-email]
- GitHub: [this-repo]
- Status Updates: [blog/twitter]

## 🔗 Quick Links

- 📚 **[Live Documentation](https://hretheum.github.io/ai_oracle/)** - Complete project documentation
- 🌐 **[Polish Version](https://github.com/hretheum/ai_oracle/tree/main/docs-pl)** - Dokumentacja po polsku
- 📋 **[Roadmap](https://hretheum.github.io/ai_oracle/operations/roadmap/)** - Development timeline
- 🎯 **[Business Plan](https://hretheum.github.io/ai_oracle/strategy/business-plan/)** - Complete strategy
- 🔧 **[Implementation Guide](https://hretheum.github.io/ai_oracle/technical/implementation-guide/)** - How to build it

---

*"We're building something that might predict research impact. Emphasis on might. Join us in finding out if it works."*