# 06 - Apparent error rate from a 70/30 train/test split
# Linear discriminant analysis trained on 70% of athletes, evaluated on 30%.
# set.seed(123) fixes the split so the result can be reproduced.

if (!exists("athletes")) source("R/01_load_data.R")
library(MASS)

set.seed(123)
train_idx <- sample(nrow(athletes), 0.7 * nrow(athletes))
train <- athletes[train_idx, ]
test <- athletes[-train_idx, ]

lda_formula <- as.formula(paste("sport ~", paste(vars, collapse = " + ")))
lda_fit <- lda(lda_formula, data = train)
pred <- predict(lda_fit, test)

confusion <- table(Predicted = pred$class, Actual = test$sport)
aper <- mean(pred$class != test$sport)

# Accuracy within each sport, and how many of each sport reached the test set
by_sport <- data.frame(
  sport = levels(athletes$sport),
  n_total = as.vector(table(athletes$sport)),
  n_train = as.vector(table(train$sport)),
  n_test = as.vector(table(test$sport)),
  n_correct = as.vector(tapply(pred$class == test$sport, test$sport, sum))
)
by_sport$n_correct[is.na(by_sport$n_correct)] <- 0
by_sport$accuracy_pct <- ifelse(by_sport$n_test > 0,
                                round(100 * by_sport$n_correct / by_sport$n_test, 1), NA)

write.csv(as.data.frame.matrix(confusion), "outputs/tables/aper_confusion_matrix.csv")
write.csv(by_sport, "outputs/tables/aper_by_sport.csv", row.names = FALSE)

cat("\n== Confusion matrix (test set, n =", nrow(test), ") ==\n")
print(confusion)
cat("\nAPER:", round(aper, 4), " | accuracy:", round(100 * (1 - aper), 1), "%\n")
cat("\n== Per-sport breakdown ==\n")
print(by_sport, row.names = FALSE)
if (any(by_sport$n_test == 0)) {
  cat("\nNote: no test athletes for",
      paste(by_sport$sport[by_sport$n_test == 0], collapse = ", "),
      "- the APER says nothing about these groups.\n")
}
