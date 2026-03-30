# =============================================================
# Script 04: Visualization
# Project:   Polarization Among Local Elected Officials
# Author:    Dilyara Begalykyzy
# =============================================================
# Purpose:
#   Generate five publication-ready plots documenting polarization
#   patterns and regression results.
#
#   Plot 1 — Polarization index by party and jurisdiction type
#   Plot 2 — Ideological distance distribution by party
#   Plot 3 — Cross-party collaboration by district competitiveness
#   Plot 4 — Collaborative identity rate by party and jurisdiction
#   Plot 5 — Coefficient plot: logistic regression (Model 3)
#
#   Plot 5 is analytically central: it presents the logistic
#   regression results visually as odds ratios with 95% CIs,
#   a standard format in political science publications.
# =============================================================

library(tidyverse)

if (!dir.exists("output")) dir.create("output")

# ------------------------------------------------------------------
# 1. Load data
# ------------------------------------------------------------------

data <- read.csv("data/officials_clean.csv") %>%
  mutate(
    party             = factor(party, levels = c("Democrat", "Independent", "Republican")),
    jurisdiction_type = factor(jurisdiction_type, levels = c("rural", "suburban", "urban")),
    tenure_group      = factor(tenure_group,
                               levels = c("0-2 years", "3-6 years", "7-10 years", "11+ years"),
                               ordered = TRUE),
    district_label    = ifelse(competitive_dist == 1, "Competitive", "Safe seat")
  )

coef_data <- read.csv("output/all_model_coefs.csv")
or_data   <- read.csv("output/logit_odds_ratios.csv")

# Shared color palette (party)
party_colors <- c("Democrat" = "#2166ac", "Independent" = "#4dac26", "Republican" = "#d6604d")

# ------------------------------------------------------------------
# 2. Plot 1: Polarization index by party × jurisdiction type
# ------------------------------------------------------------------

polar_summary <- data %>%
  group_by(party, jurisdiction_type) %>%
  summarise(
    mean_polar = mean(polarization_index),
    se_polar   = sd(polarization_index) / sqrt(n()),
    .groups = "drop"
  )

p1 <- ggplot(polar_summary,
             aes(x = jurisdiction_type, y = mean_polar,
                 fill = party, group = party)) +
  geom_col(position = position_dodge(0.75), width = 0.65, alpha = 0.87) +
  geom_errorbar(aes(ymin = mean_polar - 1.96 * se_polar,
                    ymax = mean_polar + 1.96 * se_polar),
                position = position_dodge(0.75), width = 0.2, linewidth = 0.6) +
  scale_fill_manual(values = party_colors) +
  scale_y_continuous(limits = c(0, 0.75), expand = expansion(mult = c(0, 0.05))) +
  labs(
    title    = "Polarization Index by Party and Jurisdiction Type",
    subtitle = "Mean polarization index (0 = least polarized, 1 = most polarized) | Error bars = 95% CI",
    x        = "Jurisdiction type",
    y        = "Mean polarization index",
    fill     = "Party",
    caption  = "Index combines ideological distance and inverse cross-party collaboration (both rescaled 0–1)."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold"),
    plot.caption  = element_text(size = 9, color = "gray50"),
    legend.position = "bottom"
  )

ggsave("output/plot1_polarization_by_party_jurisdiction.png", p1,
       width = 8.5, height = 5.5, dpi = 150)
cat("Saved: plot1\n")

# ------------------------------------------------------------------
# 3. Plot 2: Ideological distance distribution by party
# ------------------------------------------------------------------

p2 <- ggplot(data, aes(x = ideological_distance, fill = party)) +
  geom_density(alpha = 0.55, adjust = 1.2) +
  geom_vline(data = data %>% group_by(party) %>%
               summarise(mean_id = mean(ideological_distance), .groups = "drop"),
             aes(xintercept = mean_id, color = party),
             linetype = "dashed", linewidth = 0.8) +
  scale_fill_manual(values  = party_colors) +
  scale_color_manual(values = party_colors) +
  scale_x_continuous(breaks = 1:7) +
  labs(
    title    = "Distribution of Ideological Distance by Party",
    subtitle = "Self-reported distance from a 'typical' opposing-party official (1 = very close, 7 = very far)",
    x        = "Ideological distance",
    y        = "Density",
    fill     = "Party",
    color    = "Party mean",
    caption  = "Dashed lines mark party means."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title   = element_text(face = "bold"),
    plot.caption = element_text(size = 9, color = "gray50"),
    legend.position = "bottom"
  )

ggsave("output/plot2_ideological_distance_distribution.png", p2,
       width = 8, height = 5, dpi = 150)
cat("Saved: plot2\n")

# ------------------------------------------------------------------
# 4. Plot 3: Cross-party collaboration by competitiveness
# ------------------------------------------------------------------

p3 <- ggplot(data, aes(x = district_label, y = cross_party_collab,
                       fill = district_label)) +
  geom_violin(alpha = 0.6, trim = TRUE, width = 0.85) +
  geom_boxplot(width = 0.18, alpha = 0.9, outlier.shape = NA) +
  scale_fill_manual(values = c("Competitive" = "#1b7837", "Safe seat" = "#762a83")) +
  facet_wrap(~ party) +
  labs(
    title    = "Cross-Party Collaboration by District Competitiveness",
    subtitle = "Frequency of working across party lines (1 = never, 5 = very often)",
    x        = NULL,
    y        = "Cross-party collaboration frequency",
    fill     = "District type",
    caption  = "Officials in competitive districts report higher cross-party collaboration across all parties."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title      = element_text(face = "bold"),
    plot.caption    = element_text(size = 9, color = "gray50"),
    legend.position = "none",
    strip.text      = element_text(face = "bold")
  )

ggsave("output/plot3_collab_by_competitiveness.png", p3,
       width = 9, height = 5.5, dpi = 150)
cat("Saved: plot3\n")

# ------------------------------------------------------------------
# 5. Plot 4: Collaborative identity rate by party × jurisdiction
# ------------------------------------------------------------------

identity_summary <- data %>%
  group_by(party, jurisdiction_type) %>%
  summarise(
    pct_collab = mean(collaborative_identity) * 100,
    n          = n(),
    .groups = "drop"
  )

p4 <- ggplot(identity_summary,
             aes(x = jurisdiction_type, y = pct_collab,
                 color = party, group = party)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 4, aes(shape = party)) +
  scale_color_manual(values = party_colors) +
  scale_y_continuous(limits = c(0, 80),
                     labels = function(x) paste0(x, "%")) +
  labs(
    title    = "Collaborative Identity by Party and Jurisdiction Type",
    subtitle = "% endorsing 'public servant over partisan' identity",
    x        = "Jurisdiction type",
    y        = "% endorsing collaborative identity",
    color    = "Party",
    shape    = "Party",
    caption  = "Collaborative identity: official agrees they see themselves primarily as a public servant, not a partisan."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title   = element_text(face = "bold"),
    plot.caption = element_text(size = 9, color = "gray50"),
    legend.position = "bottom"
  )

ggsave("output/plot4_collaborative_identity_rate.png", p4,
       width = 8, height = 5, dpi = 150)
cat("Saved: plot4\n")

# ------------------------------------------------------------------
# 6. Plot 5: Coefficient plot — logistic regression odds ratios
# ------------------------------------------------------------------
# Standard format in political science: plot OR with 95% CI,
# reference line at 1 (no effect on odds).
# Exclude intercept; label terms clearly.

or_plot_data <- or_data %>%
  filter(term != "(Intercept)") %>%
  mutate(
    term_label = case_when(
      term == "partyIndependent"              ~ "Party: Independent\n(ref: Democrat)",
      term == "partyRepublican"               ~ "Party: Republican\n(ref: Democrat)",
      term == "competitive_dist"              ~ "Competitive district\n(vs. safe seat)",
      term == "jurisdiction_typesuburban"     ~ "Jurisdiction: Suburban\n(ref: Rural)",
      term == "jurisdiction_typeurban"        ~ "Jurisdiction: Urban\n(ref: Rural)",
      term == "years_in_office"               ~ "Years in office",
      term == "pct_college"                   ~ "% college educated\n(jurisdiction)",
      TRUE ~ term
    ),
    significant = ifelse(p.value < 0.05, "p < 0.05", "p ≥ 0.05")
  )

p5 <- ggplot(or_plot_data,
             aes(x = estimate, y = reorder(term_label, estimate),
                 color = significant)) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "gray50", linewidth = 0.7) +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high),
                 height = 0.25, linewidth = 0.8) +
  geom_point(size = 3.5) +
  scale_color_manual(values = c("p < 0.05" = "#1b7837", "p ≥ 0.05" = "gray55")) +
  scale_x_log10() +
  labs(
    title    = "Predictors of Collaborative Identity Among Elected Officials",
    subtitle = "Logistic regression: odds ratios with 95% confidence intervals (log scale)",
    x        = "Odds ratio (log scale)",
    y        = NULL,
    color    = "Significance",
    caption  = paste(
      "Outcome: 1 = official endorses public servant identity over partisan identity.",
      "\nOR > 1 = higher odds of collaborative identity; OR < 1 = lower odds.",
      "\nNote: simulated data — for workflow demonstration only."
    )
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title   = element_text(face = "bold"),
    plot.caption = element_text(size = 9, color = "gray50"),
    legend.position = "bottom",
    axis.text.y  = element_text(size = 10)
  )

ggsave("output/plot5_logit_coefficient_plot.png", p5,
       width = 9, height = 6.5, dpi = 150)
cat("Saved: plot5\n")

cat("\nAll plots saved to output/\n")
