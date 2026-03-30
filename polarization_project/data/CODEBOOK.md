# Data Codebook

## officials.csv / officials_clean.csv

| Variable | Type | Description |
|---|---|---|
| `official_id` | integer | Unique official identifier |
| `jurisdiction_id` | integer | Jurisdiction identifier (links to jurisdictions.csv) |
| `party` | character | Party affiliation: Democrat, Republican, Independent |
| `office_type` | character | mayor, council_member, commissioner |
| `years_in_office` | integer | Years serving in current or prior local office |
| `vote_share` | numeric | Vote share in most recent election (0–1) |
| `gender` | character | female, male, nonbinary |
| `age_group` | character | under_40, 40_to_55, over_55 |
| `jurisdiction_type` | character | rural, suburban, urban |
| `median_income_k` | numeric | Jurisdiction median household income (thousands USD) |
| `pct_college` | numeric | Share of jurisdiction adults with college degree (0–1) |
| `competitive_dist` | integer | 1 = competitive district (last election margin < 10 pts); 0 = safe seat |
| `ideological_distance` | numeric | Self-reported ideological distance from typical opposing-party official (1–7 scale; higher = more distant) |
| `cross_party_collab` | numeric | Frequency of working across party lines (1–5 scale; higher = more frequent) |
| `collaborative_identity` | integer | Binary: 1 = endorses "public servant over partisan" identity; 0 = does not |
| `polarization_index` | numeric | Composite index: average of rescaled ideological_distance and inverse cross_party_collab (0–1; higher = more polarized). Constructed in 01_data_cleaning.R |
| `tenure_group` | character | Categorical tenure: 0-2 years, 3-6 years, 7-10 years, 11+ years |
| `college_quartile` | integer | Jurisdiction college share quartile (1–4) |

## jurisdictions.csv

| Variable | Type | Description |
|---|---|---|
| `jurisdiction_id` | integer | Unique jurisdiction identifier |
| `jurisdiction_type` | character | rural, suburban, urban |
| `median_income_k` | numeric | Median household income (thousands USD) |
| `pct_college` | numeric | Share of adults with college degree (0–1) |
| `competitive_dist` | integer | 1 = competitive district; 0 = safe seat |

## Notes

- All data are **simulated** for portfolio demonstration purposes.
- The data generation script is `data/generate_data.R`.
- Variable distributions and relationships are structured to reflect real patterns documented in the legislative polarization literature (e.g., Shor & McCarty 2011; Caughey & Warshaw 2018; Kirkland 2014).
- The `collaborative_identity` variable is modeled on survey instruments used in programs like the Washington Collaborative Elected Leaders Institute (WA-CELI) and NCSL legislator surveys.
