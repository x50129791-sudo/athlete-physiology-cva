# 05 - Classify two athletes of unknown sport
# Project the new athletes onto Can1 and Can2 (after centring on the training
# means) and assign each to the sport whose group mean is nearest.

if (!exists("cva")) source("R/04_cva.R")

new_athletes <- data.frame(
  rcc = c(4.35, 4.53), wcc = c(7.8, 5.0), hc = c(41.4, 40.7), hg = c(14.1, 14.0),
  ferr = c(30, 41), bmi = c(22.03, 17.79), ssf = c(117.8, 56.8),
  pcBfat = c(23.3, 12.55), lbm = c(48.32, 38.3), ht = c(169.1, 156.9), wt = c(63, 44.8),
  row.names = c("unknown1", "unknown2")
)

centred <- sweep(as.matrix(new_athletes[, vars]), 2, colMeans(athletes[, vars]))
new_scores <- centred %*% cva$coeffs.raw[, 1:2]

group_centres <- as.matrix(cva$means[, 1:2])
distances <- t(apply(new_scores, 1, function(s)
  sqrt(colSums((t(group_centres) - s)^2))))
predicted <- colnames(distances)[apply(distances, 1, which.min)]

result <- data.frame(
  athlete = rownames(new_scores),
  Can1 = round(new_scores[, 1], 4),
  Can2 = round(new_scores[, 2], 4),
  round(distances, 4),
  predicted_sport = predicted
)
write.csv(result, "outputs/tables/new_athlete_classification.csv", row.names = FALSE)

png("outputs/figures/new_athletes.png", width = 1400, height = 1000, res = 150)
group_n <- table(athletes$sport)
plot(group_centres, pch = 17, col = sport_cols[rownames(group_centres)],
     cex = 1 + group_n / 8,
     xlim = range(c(group_centres[, 1], new_scores[, 1])) + c(-1, 1),
     ylim = range(c(group_centres[, 2], new_scores[, 2])) + c(-1, 1),
     xlab = "Can1", ylab = "Can2",
     main = "Unknown athletes relative to sport group means")
text(group_centres, labels = rownames(group_centres), pos = 1, cex = 0.8)
points(new_scores, pch = c(19, 17), cex = 1.4)
text(new_scores, labels = rownames(new_scores), pos = 3, col = "darkred", cex = 0.8)
dev.off()

cat("\n== New athlete classification (nearest group mean on Can1/Can2) ==\n")
print(result, row.names = FALSE)
