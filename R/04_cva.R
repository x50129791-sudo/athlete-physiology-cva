# 04 - Canonical Variate Analysis (CVA)
# Finds the linear combinations of the 11 measurements that best separate the
# five sports (maximising between-group relative to within-group variance).

if (!exists("athletes")) source("R/01_load_data.R")
if (!exists("sport_cols")) source("R/03_eda.R")
library(candisc)

mlm <- lm(as.matrix(athletes[, vars]) ~ sport, data = athletes)
cva <- candisc(mlm)

# With 5 groups there are at most 4 non-zero eigenvalues; the rest are
# numerical noise, so only the first four are reported.
eig <- cva$eigenvalues[1:4]
eigen_table <- data.frame(
  variate = paste0("Can", 1:4),
  eigenvalue = round(eig, 4),
  pct = round(100 * eig / sum(eig), 1),
  cumulative_pct = round(100 * cumsum(eig) / sum(eig), 1)
)

write.csv(eigen_table, "outputs/tables/cva_eigenvalues.csv", row.names = FALSE)
write.csv(round(cva$coeffs.std, 4), "outputs/tables/cva_standardised_coefficients.csv")
write.csv(round(cva$coeffs.raw, 4), "outputs/tables/cva_raw_coefficients.csv")
write.csv(cva$scores, "outputs/tables/cva_scores.csv", row.names = FALSE)
write.csv(cva$means, "outputs/tables/cva_group_means.csv")

png("outputs/figures/cva_can1_can2.png", width = 1400, height = 1000, res = 150)
plot(cva$scores$Can1, cva$scores$Can2,
     col = sport_cols[as.character(cva$scores$sport)],
     pch = sport_pch[as.character(cva$scores$sport)],
     xlab = sprintf("Can1 (%.1f%%)", eigen_table$pct[1]),
     ylab = sprintf("Can2 (%.1f%%)", eigen_table$pct[2]),
     main = "Separation of sports on the first two canonical variates")
legend("bottomleft", legend = names(sport_cols), col = sport_cols,
       pch = sport_pch, title = "Sport", cex = 0.8)
dev.off()

cat("\n== CVA eigenvalues ==\n")
print(eigen_table, row.names = FALSE)
cat("\n== Standardised coefficients ==\n")
print(round(cva$coeffs.std, 3))
cat("\n== Group means on canonical variates ==\n")
print(round(cva$means, 3))
