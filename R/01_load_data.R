# 01 - Load the analysis dataset
# 50 female elite athletes from five sports, taken from the public Australian
# Institute of Sport (AIS) data in the DAAG package. The row indices reproduce
# the 50-athlete subset used in the original coursework exactly.

library(DAAG)

vars <- c("rcc", "wcc", "hc", "hg", "ferr", "bmi", "ssf", "pcBfat", "lbm", "ht", "wt")

ais_rows <- c(1:12, 14:35, 59:67, 77, 85, 88, 89, 97, 99, 100)

athletes <- ais[ais_rows, c(vars, "sex", "sport")]
athletes$sport <- droplevels(athletes$sport)
rownames(athletes) <- NULL

stopifnot(nrow(athletes) == 50, all(athletes$sex == "f"))

dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)

cat("Loaded", nrow(athletes), "athletes,", length(vars), "measurements\n")
print(table(athletes$sport))
