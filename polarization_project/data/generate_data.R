# =============================================================
# Data Generation Script
# Project: Polarization Among Local Elected Officials
# Author:  Dilyara Begalykyzy
# =============================================================
# Purpose:
#   Generate a simulated dataset of local elected officials
#   structured to mirror the kind of administrative + survey
#   data used in studies of political polarization.
#
#   Variables reflect real data sources:
#     - Official party registration (public record)
#     - Vote share in last election (public record)
#     - Survey responses on cross-partisan collaboration
#       (modeled on WA-CELI and NCSL legislator surveys)
#     - Jurisdiction characteristics (Census-style)
#
#   N = 200 officials across 40 jurisdictions (5 per jurisdiction)
#   This mirrors a multi-level structure common in criminal legal
#   and legislative research (officials nested within jurisdictions).
# =============================================================

set.seed(42)

library(tidyverse)

n_officials     <- 200
n_jurisdictions <- 40

# ------------------------------------------------------------------
# 1. Jurisdiction-level characteristics
# ------------------------------------------------------------------

jurisdictions <- tibble(
  jurisdiction_id   = 1:n_jurisdictions,
  jurisdiction_type = sample(c("urban", "suburban", "rural"),
                             n_jurisdictions, replace = TRUE,
                             prob = c(0.3, 0.4, 0.3)),
  median_income_k   = round(rnorm(n_jurisdictions, mean = 62, sd = 18), 1),
  pct_college       = round(runif(n_jurisdictions, 0.18, 0.62), 3),
  competitive_dist  = sample(c(0, 1), n_jurisdictions, replace = TRUE,
                             prob = c(0.55, 0.45))  # 1 = margin < 10pts
)

# ------------------------------------------------------------------
# 2. Official-level characteristics
# ------------------------------------------------------------------

officials <- tibble(
  official_id     = 1:n_officials,
  jurisdiction_id = rep(1:n_jurisdictions, each = 5),
  party           = sample(c("Democrat", "Republican", "Independent"),
                           n_officials, replace = TRUE,
                           prob = c(0.45, 0.45, 0.10)),
  office_type     = sample(c("mayor", "council_member", "commissioner"),
                           n_officials, replace = TRUE,
                           prob = c(0.15, 0.65, 0.20)),
  years_in_office = sample(1:16, n_officials, replace = TRUE),
  vote_share      = round(runif(n_officials, 0.42, 0.88), 3),
  gender          = sample(c("female", "male", "nonbinary"),
                           n_officials, replace = TRUE,
                           prob = c(0.38, 0.60, 0.02)),
  age_group       = sample(c("under_40", "40_to_55", "over_55"),
                           n_officials, replace = TRUE,
                           prob = c(0.18, 0.42, 0.40))
)

# ------------------------------------------------------------------
# 3. Survey responses — polarization measures
# ------------------------------------------------------------------
# Items adapted from legislative polarization surveys (e.g., NCSL,
# Place-Based Policy Network) and WA-CELI pre-program instrument.
#
# ideological_distance: self-reported distance from "typical"
#   member of the opposing party (1 = very close, 7 = very far)
# cross_party_collab: frequency of working across party lines
#   (1 = never, 5 = very often)
# collaborative_identity: agrees with "I see myself primarily as a
#   public servant, not a partisan" (1 = strongly disagree, 5 = agree)
# ------------------------------------------------------------------

# Polarization is higher for:
#   - Safe seat holders (low competitive pressure)
#   - More years in office
#   - Rural jurisdictions
# Cross-party collaboration is higher for:
#   - Competitive districts
#   - Independent officials
#   - Higher education jurisdictions

officials <- officials %>%
  left_join(jurisdictions, by = "jurisdiction_id") %>%
  mutate(
    # Base ideological distance
    ideological_distance = round(
      4.0
      + 0.8  * (party == "Republican")
      - 0.5  * (party == "Independent")
      - 0.6  * competitive_dist
      + 0.04 * years_in_office
      + 0.5  * (jurisdiction_type == "rural")
      - 0.4  * (jurisdiction_type == "urban")
      + rnorm(n_officials, 0, 0.8),
      1
    ),
    ideological_distance = pmin(pmax(ideological_distance, 1), 7),

    # Cross-party collaboration frequency
    cross_party_collab = round(
      3.0
      - 0.4  * (party == "Republican")
      - 0.3  * (party == "Democrat")
      + 0.8  * (party == "Independent")
      + 0.5  * competitive_dist
      + 0.6  * pct_college
      - 0.02 * years_in_office
      + rnorm(n_officials, 0, 0.6),
      1
    ),
    cross_party_collab = pmin(pmax(cross_party_collab, 1), 5),

    # Collaborative identity (binary outcome for logistic regression)
    # 1 = endorses public servant identity over partisan identity
    collab_identity_prob = plogis(
      -0.5
      + 0.7  * competitive_dist
      + 0.4  * (party == "Independent")
      - 0.3  * (party == "Republican")
      + 0.8  * pct_college
      - 0.03 * years_in_office
      + 0.4  * (jurisdiction_type == "urban")
      + rnorm(n_officials, 0, 0.4)
    ),
    collaborative_identity = rbinom(n_officials, 1, collab_identity_prob)
  ) %>%
  select(-collab_identity_prob)

# ------------------------------------------------------------------
# 4. Save datasets
# ------------------------------------------------------------------

write.csv(officials,     "data/officials.csv",     row.names = FALSE)
write.csv(jurisdictions, "data/jurisdictions.csv", row.names = FALSE)

cat("Dataset generated.\n")
cat("Officials:", nrow(officials), "\n")
cat("Jurisdictions:", nrow(jurisdictions), "\n")
cat("Party breakdown:\n")
print(table(officials$party))
cat("Collaborative identity (1 = endorses):", sum(officials$collaborative_identity),
    "/", nrow(officials), "\n")
