# 03 - Exploratory data analysis
# Pairwise relationships and per-sport distributions of each measurement.

if (!exists("athletes")) source("R/01_load_data.R")

sport_cols <- c(B_Ball = "#d62728", Gym = "#1f77b4", Row = "#9467bd",
                Swim = "#7f7f7f", T_Sprnt = "#17becf")
sport_pch <- c(B_Ball = 19, Gym = 10, Row = 4, Swim = 8, T_Sprnt = 15)

# Group summaries (mean and SD of every measurement by sport)
means <- aggregate(athletes[, vars], by = list(sport = athletes$sport), FUN = mean)
sds <- aggregate(athletes[, vars], by = list(sport = athletes$sport), FUN = sd)
write.csv(means, "outputs/tables/eda_group_means.csv", row.names = FALSE)
write.csv(sds, "outputs/tables/eda_group_sds.csv", row.names = FALSE)

png("outputs/figures/eda_pairs.png", width = 1600, height = 1600, res = 150)
pairs(athletes[, vars],
      col = sport_cols[as.character(athletes$sport)],
      pch = sport_pch[as.character(athletes$sport)],
      lower.panel = NULL, cex = 0.7,
      main = "Scatterplot matrix of physiological measurements")
par(xpd = TRUE)
legend("bottomleft", legend = names(sport_cols), col = sport_cols,
       pch = sport_pch, title = "Sport", cex = 0.9, bty = "n")
dev.off()

png("outputs/figures/eda_boxplots.png", width = 1800, height = 1200, res = 150)
par(mfrow = c(3, 4), mar = c(4, 4, 2, 1))
for (v in vars) {
  boxplot(athletes[[v]] ~ athletes$sport, col = sport_cols, main = v,
          xlab = "", ylab = v, las = 2, cex.axis = 0.8)
}
dev.off()

cat("\n== Group means ==\n")
print(means, digits = 3, row.names = FALSE)
cat("\nCorrelations above 0.8 (absolute):\n")
r <- cor(athletes[, vars])
high <- which(abs(r) > 0.8 & upper.tri(r), arr.ind = TRUE)
print(data.frame(var1 = rownames(r)[high[, 1]], var2 = colnames(r)[high[, 2]],
                 r = round(r[high], 2)), row.names = FALSE)
