source(here::here("scripts", "00_utils.R"))
ensure_directories()

tracts_final <- readRDS(here::here("data_processed", "tracts_final.rds")) %>%
  st_drop_geometry() %>%
  mutate(income_quartile = ntile(hhinc, 4))

plot_mean_income <- ggplot(tracts_final, aes(hhinc, bus_rail_mean_tt)) +
  geom_point(alpha = 0.55, color = "#0a4f6d") +
  geom_smooth(method = "lm", se = FALSE, color = "#d1495b") +
  labs(x = "Median household income", y = "Mean travel time (bus + rail, min)", title = "Accessibility and Income") +
  theme_minimal(base_size = 12)

plot_mean_minority <- ggplot(tracts_final, aes(pct_minority, bus_rail_mean_tt)) +
  geom_point(alpha = 0.55, color = "#6c584c") +
  geom_smooth(method = "lm", se = FALSE, color = "#bc4749") +
  labs(x = "Percent minority", y = "Mean travel time (bus + rail, min)", title = "Accessibility and Race/Ethnicity") +
  theme_minimal(base_size = 12)

plot_mean_zero_vehicle <- ggplot(tracts_final, aes(pct_zero_vehicle, bus_rail_mean_tt)) +
  geom_point(alpha = 0.55, color = "#386641") +
  geom_smooth(method = "lm", se = FALSE, color = "#f2a65a") +
  labs(x = "Percent zero-vehicle households", y = "Mean travel time (bus + rail, min)", title = "Accessibility and Vehicle Availability") +
  theme_minimal(base_size = 12)

plot_box_income <- ggplot(tracts_final, aes(factor(income_quartile), bus_rail_n_45)) +
  geom_boxplot(fill = "#8ecae6", color = "#023047") +
  labs(x = "Income quartile", y = "Destinations reachable <= 45 min", title = "Accessibility by Income Quartile") +
  theme_minimal(base_size = 12)

scenario_compare <- tracts_final %>%
  summarise(
    rail_only = mean(rail_only_n_45, na.rm = TRUE),
    bus_rail = mean(bus_rail_n_45, na.rm = TRUE)
  ) %>%
  pivot_longer(everything(), names_to = "scenario", values_to = "avg_n45")

plot_scenario_compare <- ggplot(scenario_compare, aes(scenario, avg_n45, fill = scenario)) +
  geom_col(width = 0.6, show.legend = FALSE) +
  scale_fill_manual(values = c(rail_only = "#577590", bus_rail = "#43aa8b")) +
  labs(x = NULL, y = "Average destinations <= 45 min", title = "Average Accessibility by Scenario") +
  theme_minimal(base_size = 12)

ggsave(here::here("outputs", "figures", "plot_01_mean_tt_vs_income.png"), plot_mean_income, width = 8, height = 5, dpi = 300)
ggsave(here::here("outputs", "figures", "plot_02_mean_tt_vs_minority.png"), plot_mean_minority, width = 8, height = 5, dpi = 300)
ggsave(here::here("outputs", "figures", "plot_03_mean_tt_vs_zero_vehicle.png"), plot_mean_zero_vehicle, width = 8, height = 5, dpi = 300)
ggsave(here::here("outputs", "figures", "plot_04_n45_by_income_quartile.png"), plot_box_income, width = 8, height = 5, dpi = 300)
ggsave(here::here("outputs", "figures", "plot_05_scenario_compare.png"), plot_scenario_compare, width = 7, height = 5, dpi = 300)
