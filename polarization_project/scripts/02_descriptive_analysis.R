# =============================================================
# Script 02: Descriptive Analysis of Polarization Patterns
# Project:   Polarization Among Local Elected Officials
# Author:    Dilyara Begalykyzy
# =============================================================
# Purpose:
#   Produce systematic descriptive statistics documenting
#   variation in polarization measures across party, jurisdiction
#   type, district competitiveness, and tenure.
#
#   Descriptive analysis is the essential first step before
#   modeling: it surfaces patterns, flags unexpected distributions,
#   and motivates the regression specifications in Script 03.
#
#   Output: summary tables saved to output/ for reference.
# =============================================================

library(tidyverse)

if (!dir.exists("output")) dir.create("output")

# ------------------------------------------------------------------
# 1. Load cleaned data
# ------------------------------------------------------------------

data <- read.csv("data/officials_clean.csv") %>%
  mutate(
    party             = factor(party, levels = c("Democrat", "Independent", "Republican")),
    jurisdiction_type = factor(jurisdiction_type, levels = c("rural", "suburban", "urban")),
    age_group         = factor(age_group, levels = c("under_40", "40_to_55", "over_55"),
                               ordered = TRUE),
    tenure_group      = factor(tenure_group,
                               levels = c("0-2 years", "3-6 years", "7-10 years", "11+ years"),
                               ordered = TRUE)
  )

cat("Data loaded:", nrow(data), "officials\n")

# ------------------------------------------------------------------
# 2. Overall polarization summary
# ------------------------------------------------------------------

cat("\n=== Overall Summary: Polarization Measures ===\n")
data %>%
  summarise(
    n                       = n(),
    mean_ideological_dist   = round(mean(ideological_distance), 2),
    sd_ideological_dist     = round(sd(ideological_distance), 2),
    mean_cross_party_collab = round(mean(cross_party_collab), 2),
    sd_cross_party_collab   = round(sd(cross_party_collab), 2),
    mean_polarization_index = round(mean(polarization_index), 3),
    pct_collab_identity     = round(mean(collaborative_identity) * 100, 1)
  ) %>%
  print()

# ------------------------------------------------------------------
# 3. Polarization by party
# ------------------------------------------------------------------

cat("\n=== Polarization by Party ===\n")
party_summary <- data %>%
  group_by(party) %>%
  summarise(
    n                   = n(),
    mean_ideo_dist      = round(mean(ideological_distance), 2),
    mean_cross_collab   = round(mean(cross_party_collab), 2),
    mean_polar_index    = round(mean(polarization_index), 3),
    pct_collab_identity = round(mean(collaborative_identity) * 100, 1),
    .groups = "drop"
  )
print(party_summary)

# ------------------------------------------------------------------
# 4. Polarization by jurisdiction type
# ------------------------------------------------------------------

cat("\n=== Polarization by Jurisdiction Type ===\n")
jur_summary <- data %>%
  group_by(jurisdiction_type) %>%
  summarise(
    n                   = n(),
    mean_ideo_dist      = round(mean(ideological_distance), 2),
    mean_cross_collab   = round(mean(cross_party_collab), 2),
    mean_polar_index    = round(mean(polarization_index), 3),
    pct_collab_identity = round(mean(collaborative_identity) * 100, 1),
    .groups = "drop"
  )
print(jur_summary)

# ------------------------------------------------------------------
# 5. Polarization by district competitiveness
# ------------------------------------------------------------------

cat("\n=== Polarization by District Competitiveness ===\n")
comp_summary <- data %>%
  mutate(district_type = ifelse(competitive_dist == 1, "Competitive", "Safe seat")) %>%
  group_by(district_type) %>%
  summarise(
    n                   = n(),
    mean_ideo_dist      = round(mean(ideological_distance), 2),
    mean_cross_collab   = round(mean(cross_party_collab), 2),
    mean_polar_index    = round(mean(polarization_index), 3),
    pct_collab_identity = round(mean(collaborative_identity) * 100, 1),
    .groups = "drop"
  )
print(comp_summary)

# ------------------------------------------------------------------
# 6. Polarization by tenure
# ------------------------------------------------------------------

cat("\n=== Polarization by Tenure Group ===\n")
tenure_summary <- data %>%
  group_by(tenure_group) %>%
  summarise(
    n                = n(),
    mean_ideo_dist   = round(mean(ideological_distance), 2),
    mean_cross_collab = round(mean(cross_party_collab), 2),
    mean_polar_index = round(mean(polarization_index), 3),
    .groups = "drop"
  )
print(tenure_summary)

# ------------------------------------------------------------------
# 7. Cross-tab: party × jurisdiction type
# ------------------------------------------------------------------

cat("\n=== Mean Polarization Index: Party x Jurisdiction Type ===\n")
crosstab <- data %>%
  group_by(party, jurisdiction_type) %>%
  summarise(
    n                = n(),
    mean_polar_index = round(mean(polarization_index), 3),
    .groups = "drop"
  ) %>%
  pivot_wider(names_from = jurisdiction_type,
              values_from = c(n, mean_polar_index))
print(crosstab)

# ------------------------------------------------------------------
# 8. Save summary tables
# ------------------------------------------------------------------

write.csv(party_summary,  "output/descriptives_by_party.csv",        row.names = FALSE)
write.csv(jur_summary,    "output/descriptives_by_jurisdiction.csv",  row.names = FALSE)
write.csv(comp_summary,   "output/descriptives_by_competitiveness.csv", row.names = FALSE)
write.csv(tenure_summary, "output/descriptives_by_tenure.csv",        row.names = FALSE)

cat("\nSummary tables saved to output/\n")
