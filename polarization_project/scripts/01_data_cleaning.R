# =============================================================
# Script 01: Data Cleaning and Preprocessing
# Project:   Polarization Among Local Elected Officials
# Author:    Dilyara Begalykyzy
# =============================================================
# Purpose:
#   Load official-level and jurisdiction-level datasets,
#   inspect structure, handle missing values, encode factors,
#   construct analysis variables, and export a clean merged file.
#
#   Data structure: 200 officials nested within 40 jurisdictions
#   (5 officials per jurisdiction) — a two-level structure common
#   in studies of political behavior across legislative contexts.
# =============================================================

library(tidyverse)
library(janitor)

# ------------------------------------------------------------------
# 1. Load data
# ------------------------------------------------------------------

officials     <- read.csv("data/officials.csv")
jurisdictions <- read.csv("data/jurisdictions.csv")

cat("Officials loaded:     ", nrow(officials), "rows\n")
cat("Jurisdictions loaded: ", nrow(jurisdictions), "rows\n")

glimpse(officials)

# ------------------------------------------------------------------
# 2. Missing value audit
# ------------------------------------------------------------------

missing_summary <- officials %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "n_missing") %>%
  filter(n_missing > 0)

if (nrow(missing_summary) == 0) {
  cat("\nNo missing values detected.\n")
} else {
  cat("\n=== Missing Values ===\n")
  print(missing_summary)
}

# ------------------------------------------------------------------
# 3. Factor encoding
# ------------------------------------------------------------------
# Ordered factors preserve meaningful ordinality in summaries
# and allow correct interpretation in regression models.

officials <- officials %>%
  mutate(
    party = factor(party, levels = c("Democrat", "Independent", "Republican")),

    office_type = factor(office_type,
                         levels = c("council_member", "commissioner", "mayor")),

    jurisdiction_type = factor(jurisdiction_type,
                               levels = c("rural", "suburban", "urban")),

    age_group = factor(age_group,
                       levels = c("under_40", "40_to_55", "over_55"),
                       ordered = TRUE),

    gender = factor(gender, levels = c("female", "male", "nonbinary")),

    # Competitive district: binary indicator (margin < 10 pts in last election)
    competitive_dist = as.integer(competitive_dist),

    # Collaborative identity: binary outcome for logistic regression
    # 1 = endorses "public servant" identity over partisan identity
    collaborative_identity = as.integer(collaborative_identity)
  )

# ------------------------------------------------------------------
# 4. Construct analysis variables
# ------------------------------------------------------------------

officials <- officials %>%
  mutate(
    # Polarization index: average of ideological distance and
    # inverse of cross-party collaboration (both rescaled to 0–1)
    # Higher = more polarized
    polarization_index = (
      (ideological_distance - 1) / 6 +
      (5 - cross_party_collab) / 4
    ) / 2,

    # Tenure group: categorize years in office for descriptive analysis
    tenure_group = case_when(
      years_in_office <= 2  ~ "0-2 years",
      years_in_office <= 6  ~ "3-6 years",
      years_in_office <= 10 ~ "7-10 years",
      TRUE                  ~ "11+ years"
    ) %>% factor(levels = c("0-2 years", "3-6 years", "7-10 years", "11+ years"),
                 ordered = TRUE),

    # College education quartile (jurisdiction-level)
    college_quartile = ntile(pct_college, 4)
  )

# ------------------------------------------------------------------
# 5. Descriptive check
# ------------------------------------------------------------------

cat("\n=== Party Distribution ===\n")
print(table(officials$party))

cat("\n=== Jurisdiction Type ===\n")
print(table(officials$jurisdiction_type))

cat("\n=== Collaborative Identity (1 = endorses public servant identity) ===\n")
print(table(officials$collaborative_identity))

cat("\n=== Polarization Index Summary ===\n")
summary(officials$polarization_index)

# ------------------------------------------------------------------
# 6. Export cleaned dataset
# ------------------------------------------------------------------

write.csv(officials, "data/officials_clean.csv", row.names = FALSE)
cat("\nCleaned dataset saved to data/officials_clean.csv\n")
cat("Final N:", nrow(officials), "officials across",
    n_distinct(officials$jurisdiction_id), "jurisdictions\n")
