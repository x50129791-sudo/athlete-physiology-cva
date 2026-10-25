# 02 - Data quality checks
# Run before any modelling: completeness, duplicates, plausibility,
# internal consistency between derived measures, and within-group outliers.

if (!exists("athletes")) source("R/01_load_data.R")

# Broad screening limits for adult female athletes. These are wide
# plausibility bounds to catch recording errors, not clinical reference ranges.
limits <- data.frame(
  variable = vars,
  lower = c(3.0, 2.0, 25, 8, 5, 12, 20, 3, 25, 130, 30),
  upper = c(7.0, 20, 60, 20, 500, 40, 250, 45, 100, 215, 150)
)

x <- athletes[, vars]

# 1. Completeness and plausibility, one row per variable
quality <- data.frame(
  variable = vars,
  n_missing = colSums(is.na(x)),
  pct_missing = round(100 * colMeans(is.na(x)), 1),
  min = sapply(x, min, na.rm = TRUE),
  max = sapply(x, max, na.rm = TRUE),
  lower_limit = limits$lower,
  upper_limit = limits$upper,
  n_out_of_range = mapply(function(v, lo, hi) sum(v < lo | v > hi, na.rm = TRUE),
                          x, limits$lower, limits$upper)
)
rownames(quality) <- NULL

# 2. Duplicate records (identical measurements on every variable)
n_duplicates <- sum(duplicated(x))

# 3. Internal consistency: derived measures should agree with their inputs
bmi_calc <- athletes$wt / (athletes$ht / 100)^2
lbm_calc <- athletes$wt * (1 - athletes$pcBfat / 100)
consistency <- data.frame(
  athlete = seq_len(nrow(athletes)),
  sport = athletes$sport,
  bmi_recorded = athletes$bmi,
  bmi_from_ht_wt = round(bmi_calc, 2),
  bmi_diff = round(athletes$bmi - bmi_calc, 2),
  lbm_recorded = athletes$lbm,
  lbm_from_wt_fat = round(lbm_calc, 2),
  lbm_diff = round(athletes$lbm - lbm_calc, 2)
)
bmi_flags <- subset(consistency, abs(bmi_diff) > 0.5)
lbm_flags <- subset(consistency, abs(lbm_diff) > 2)

# 4. Values more than 3 SD from their own sport's mean
z_within <- sapply(vars, function(v) ave(athletes[[v]], athletes$sport,
                                         FUN = function(g) (g - mean(g)) / sd(g)))
outlier_idx <- which(abs(z_within) > 3, arr.ind = TRUE)
outliers <- data.frame(
  athlete = outlier_idx[, "row"],
  sport = athletes$sport[outlier_idx[, "row"]],
  variable = vars[outlier_idx[, "col"]],
  value = x[outlier_idx],
  z_within_sport = round(z_within[outlier_idx], 2)
)

# 5. Group sizes: small groups limit what can be concluded about them
group_sizes <- as.data.frame(table(sport = athletes$sport), responseName = "n")
group_sizes$pct <- round(100 * group_sizes$n / sum(group_sizes$n), 1)

write.csv(quality, "outputs/tables/dq_variable_summary.csv", row.names = FALSE)
write.csv(consistency, "outputs/tables/dq_consistency_checks.csv", row.names = FALSE)
write.csv(outliers, "outputs/tables/dq_within_sport_outliers.csv", row.names = FALSE)
write.csv(group_sizes, "outputs/tables/dq_group_sizes.csv", row.names = FALSE)

cat("\n== Data quality summary ==\n")
print(quality, row.names = FALSE)
cat("\nDuplicate records:", n_duplicates, "\n")
cat("BMI inconsistent with height/weight (|diff| > 0.5):", nrow(bmi_flags), "\n")
cat("LBM inconsistent with weight/body fat (|diff| > 2 kg):", nrow(lbm_flags), "\n")
cat("Values > 3 SD from own sport mean:", nrow(outliers), "\n")
if (nrow(outliers) > 0) print(outliers, row.names = FALSE)
cat("\nGroup sizes:\n")
print(group_sizes, row.names = FALSE)
