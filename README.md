[README.md](https://github.com/user-attachments/files/26361718/README.md)
# Polarization Among Local Elected Officials — Quantitative Analysis

## Overview

This project analyzes patterns of political polarization among local elected officials using simulated survey and administrative data. It examines how party affiliation, district competitiveness, jurisdiction type, and tenure predict ideological distance, cross-party collaboration, and collaborative identity.

The project is structured as a reproducible four-script R workflow and is designed to demonstrate the kind of quantitative pipeline applicable to real legislative polarization research — including administrative data collection, multi-variable regression modeling, and visualization of political behavior data.

This work is directly informed by my experience as a research intern with the **Washington Collaborative Elected Leaders Institute (WA-CELI)**, a program developed by the William D. Ruckelshaus Center and the UW Evans School of Public Policy and Governance to study and reduce polarization among elected officials. The `collaborative_identity` variable in this project is modeled on the survey instrument used in WA-CELI's pre/post program evaluation.

---

## Research Questions

1. How does polarization vary across party affiliation, jurisdiction type, and district competitiveness?
2. Do competitive electoral districts predict lower ideological distance and higher cross-party collaboration?
3. What factors predict whether an elected official endorses a **collaborative "public servant" identity** over a partisan identity — and does district competitiveness matter after controlling for party and jurisdiction?

Question 3 uses logistic regression, the appropriate estimator for a binary outcome, and computes average marginal effects to present results on the probability scale rather than log-odds.

---

## Data

**Unit of analysis:** Local elected official (mayor, city council member, county commissioner)  
**N:** 200 officials across 40 jurisdictions (5 per jurisdiction)  
**Structure:** Two-level (officials nested within jurisdictions)

### Key Variables

| Variable | Description |
|---|---|
| `ideological_distance` | Self-reported distance from opposing-party official (1–7) |
| `cross_party_collab` | Frequency of cross-party work (1–5) |
| `collaborative_identity` | Binary: endorses public servant over partisan identity |
| `polarization_index` | Composite index (0–1) combining above measures |
| `competitive_dist` | 1 = competitive district (last margin < 10 pts) |
| `jurisdiction_type` | rural / suburban / urban |
| `pct_college` | Jurisdiction-level college attainment share |

> **Note:** Data are simulated for portfolio demonstration. The data generation script (`data/generate_data.R`) is fully transparent. Variable relationships reflect patterns documented in the legislative polarization literature. See `data/CODEBOOK.md` for full variable descriptions.

---

## Methods

### Script 01 — Data Cleaning
- Column standardization and factor encoding (ordered factors for income, age, tenure)
- Missing value audit
- Derived variable construction: `polarization_index`, `tenure_group`, `college_quartile`
- Outlier review

### Script 02 — Descriptive Analysis
- Polarization summaries by party, jurisdiction type, district competitiveness, and tenure
- Cross-tabulation: party × jurisdiction type
- All summary tables exported to `/output/`

### Script 03 — Regression Modeling

| Model | Type | Outcome |
|---|---|---|
| Model 1 | OLS | Ideological distance (continuous) |
| Model 2 | OLS | Cross-party collaboration (continuous) |
| Model 3 | Logistic regression | Collaborative identity (binary) |

- Model 3 reports log-odds coefficients, exponentiated odds ratios with 95% CIs, and **average marginal effects** of competitive district on the probability of endorsing collaborative identity
- All models include party, district competitiveness, jurisdiction type, years in office, and jurisdiction education level

### Script 04 — Visualization
Five plots:
1. Polarization index by party × jurisdiction type (grouped bar with CIs)
2. Ideological distance distribution by party (density plot)
3. Cross-party collaboration by competitiveness (violin + box, faceted by party)
4. Collaborative identity rate by party × jurisdiction (connected dot plot)
5. **Logistic regression coefficient plot** — odds ratios with 95% CIs (log scale)

---

## Key Findings

- Republican officials and those in rural jurisdictions show higher mean polarization scores; the pattern is consistent across both ideological distance and cross-party collaboration measures.
- Officials in **competitive districts** report meaningfully higher cross-party collaboration across all parties, consistent with electoral incentive theories of legislative behavior (Mayhew 1974; Shor & McCarty 2011).
- Logistic regression results show that **competitive district** and **jurisdiction education level** are the strongest positive predictors of collaborative identity, while Republican party affiliation and longer tenure are negatively associated.
- Average marginal effect of competitive district on collaborative identity: approximately **+10–15 percentage points**, holding all other covariates at observed values.

---

## Limitations

- **Simulated data:** No causal claims are warranted. Results illustrate analytical approach, not empirical findings.
- **Cross-sectional design:** Longitudinal data with pre/post measurement (as in WA-CELI) or quasi-experimental variation in district competitiveness would be needed for causal identification.
- **Small N per jurisdiction:** With 5 officials per jurisdiction, jurisdiction-level fixed effects would severely limit degrees of freedom. Multilevel modeling (lme4) would be the preferred specification with a larger real dataset.
- **Self-report bias:** Survey-based polarization measures are subject to social desirability effects, particularly for collaborative identity items.

---

## Tools

- **R** (≥ 4.1)
- `tidyverse` — data manipulation and visualization
- `janitor` — column cleaning
- `broom` — tidy model output
- `ggplot2` — all visualizations

---

## How to Run

```r
install.packages(c("tidyverse", "janitor", "broom"))

source("scripts/01_data_cleaning.R")
source("scripts/02_descriptive_analysis.R")
source("scripts/03_regression_models.R")
source("scripts/04_visualization.R")
```

All output (plots, tables, regression summaries) is saved to `/output/`.

---

## Project Structure

```
polarization-officials-r/
├── data/
│   ├── generate_data.R              # Transparent data generation script
│   ├── officials.csv                # Raw simulated dataset
│   ├── jurisdictions.csv            # Jurisdiction-level data
│   └── CODEBOOK.md                  # Variable descriptions
├── scripts/
│   ├── 01_data_cleaning.R
│   ├── 02_descriptive_analysis.R
│   ├── 03_regression_models.R
│   └── 04_visualization.R
├── output/                          # Generated plots and tables (not tracked in git)
└── README.md
```

---

## Connections to Real Research

This project is designed to mirror the data structure and analytical questions in empirical political science research on polarization, including:

- **Shor & McCarty (2011)** — ideological scaling of state legislators using voting records
- **Kirkland (2014)** — cross-partisan cosponsorship as a measure of collaboration
- **Caughey & Warshaw (2018)** — mass and elite polarization at the state level
- **Broockman & Skovron (2018)** — how electoral competition shapes legislative behavior

The `collaborative_identity` measure is modeled on survey instruments used in the **WA-CELI program evaluation** and is conceptually related to the "shared identity as public servant" theory of change in polarization reduction research.

---

*This project reflects applied research skills developed through work at Pierce County Human Services (administrative data analysis in R) and the Washington Collaborative Elected Leaders Institute (polarization measurement and program evaluation).*
