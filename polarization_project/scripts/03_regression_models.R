# =============================================================
# Script 03: Regression Modeling
# Project:   Polarization Among Local Elected Officials
# Author:    Dilyara Begalykyzy
# =============================================================
# Purpose:
#   Estimate three regression models examining predictors of
#   political polarization and collaborative identity among
#   local elected officials.
#
#   Model 1 — OLS: Predictors of ideological distance
#     Outcome: ideological_distance (continuous, 1–7 scale)
#     Predictors: party, competitive_dist, jurisdiction_type,
#                 years_in_office, pct_college
#
#   Model 2 — OLS: Predictors of cross-party collaboration
#     Outcome: cross_party_collab (continuous, 1–5 scale)
#     Predictors: same set + polarization_index
#
#   Model 3 — Logistic regression: Collaborative identity
#     Outcome: collaborative_identity (binary, 0/1)
#     Predictors: competitive_dist, party, jurisdiction_type,
#                 years_in_office, pct_college
#
#   Logistic regression is the appropriate estimator for the
#   binary outcome. Coefficients are reported as log-odds;
#   marginal effects (probability scale) are also computed
#   for interpretive clarity.
#
# Note on identification:
#   These models are descriptive/associational. The simulated
#   data does not support causal claims. In real research on
#   legislative polarization, identification would require
#   quasi-experimental variation in district competitiveness
#   (e.g., regression discontinuity around electoral thresholds)
#   or longitudinal data tracking officials before/after
#   redistricting events.
# =============================================================

library(tidyverse)
library(broom)

if (!dir.exists("output")) dir.create("output")

# ------------------------------------------------------------------
# 1. Load data
# ------------------------------------------------------------------

data <- read.csv("data/officials_clean.csv") %>%
  mutate(
    party             = factor(party, levels = c("Democrat", "Independent", "Republican")),
    jurisdiction_type = factor(jurisdiction_type, levels = c("rural", "suburban", "urban")),
    age_group         = factor(age_group, levels = c("under_40", "40_to_55", "over_55"))
  )

cat("Data loaded:", nrow(data), "officials\n")

# ------------------------------------------------------------------
# 2. Model 1 — OLS: Ideological distance
# ------------------------------------------------------------------
# Reference categories: party = Democrat, jurisdiction = rural
# Competitive district coded 1 (competitive) vs 0 (safe seat)

model1 <- lm(
  ideological_distance ~ party + competitive_dist + jurisdiction_type +
    years_in_office + pct_college,
  data = data
)

cat("\n=== Model 1: OLS — Ideological Distance ===\n")
summary(model1)

# ------------------------------------------------------------------
# 3. Model 2 — OLS: Cross-party collaboration
# ------------------------------------------------------------------

model2 <- lm(
  cross_party_collab ~ party + competitive_dist + jurisdiction_type +
    years_in_office + pct_college,
  data = data
)

cat("\n=== Model 2: OLS — Cross-Party Collaboration ===\n")
summary(model2)

# ------------------------------------------------------------------
# 4. Model 3 — Logistic regression: Collaborative identity
# ------------------------------------------------------------------
# Outcome: 1 = official endorses "public servant" identity
#          over partisan identity; 0 = does not endorse
#
# Logistic regression is used because the outcome is binary.
# Coefficients represent log-odds; exponentiated = odds ratios.
# Marginal effects (change in predicted probability) computed
# at the mean of all other covariates for interpretive use.

model3 <- glm(
  collaborative_identity ~ party + competitive_dist + jurisdiction_type +
    years_in_office + pct_college,
  data   = data,
  family = binomial(link = "logit")
)

cat("\n=== Model 3: Logistic Regression — Collaborative Identity ===\n")
summary(model3)

# Odds ratios with 95% CIs
cat("\n=== Model 3: Odds Ratios ===\n")
or_table <- tidy(model3, exponentiate = TRUE, conf.int = TRUE) %>%
  select(term, estimate, conf.low, conf.high, p.value) %>%
  mutate(across(where(is.numeric), ~ round(., 3)))
print(or_table)

# Average marginal effect of competitive district (probability scale)
# Predicted probability of endorsing collaborative identity:
#   competitive vs. safe seat, holding all else at observed values
data_comp0 <- data %>% mutate(competitive_dist = 0)
data_comp1 <- data %>% mutate(competitive_dist = 1)

ame_competitive <- mean(
  predict(model3, newdata = data_comp1, type = "response") -
  predict(model3, newdata = data_comp0, type = "response")
)

cat(sprintf(
  "\nAverage marginal effect of competitive district on Pr(collaborative identity): +%.3f\n",
  ame_competitive
))
cat("Interpretation: Officials in competitive districts are on average",
    round(ame_competitive * 100, 1),
    "percentage points more likely to endorse a collaborative public servant identity.\n")

# ------------------------------------------------------------------
# 5. Model fit comparison (Models 1 & 2)
# ------------------------------------------------------------------

fit_comparison <- bind_rows(
  glance(model1) %>% mutate(model = "M1: Ideological Distance"),
  glance(model2) %>% mutate(model = "M2: Cross-Party Collaboration")
) %>%
  select(model, r.squared, adj.r.squared, AIC, nobs) %>%
  mutate(across(where(is.numeric), ~ round(., 3)))

cat("\n=== OLS Model Fit Comparison ===\n")
print(fit_comparison)

# ------------------------------------------------------------------
# 6. Save outputs
# ------------------------------------------------------------------

# Tidy coefficient tables
m1_coefs <- tidy(model1, conf.int = TRUE) %>% mutate(model = "OLS: Ideological Distance")
m2_coefs <- tidy(model2, conf.int = TRUE) %>% mutate(model = "OLS: Cross-Party Collaboration")
m3_coefs <- tidy(model3, conf.int = TRUE) %>% mutate(model = "Logit: Collaborative Identity")

all_coefs <- bind_rows(m1_coefs, m2_coefs, m3_coefs) %>%
  mutate(across(where(is.numeric), ~ round(., 4)))

write.csv(all_coefs,    "output/all_model_coefs.csv", row.names = FALSE)
write.csv(or_table,     "output/logit_odds_ratios.csv", row.names = FALSE)
write.csv(fit_comparison, "output/model_fit_comparison.csv", row.names = FALSE)

# Full regression summaries to text
sink("output/regression_summaries.txt")
cat("=== Model 1: OLS — Ideological Distance ===\n\n")
print(summary(model1))
cat("\n\n=== Model 2: OLS — Cross-Party Collaboration ===\n\n")
print(summary(model2))
cat("\n\n=== Model 3: Logistic Regression — Collaborative Identity ===\n\n")
print(summary(model3))
cat("\n\n=== Odds Ratios (Model 3) ===\n\n")
print(or_table)
cat(sprintf("\nAME of competitive district: +%.3f (%.1f pp)\n",
            ame_competitive, ame_competitive * 100))
sink()

cat("\nAll model outputs saved to output/\n")
