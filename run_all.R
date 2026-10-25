# Run the full analysis from the repository root:
#   Rscript run_all.R
# Required packages: DAAG, candisc, MASS

scripts <- c(
  "R/01_load_data.R",
  "R/02_data_quality_checks.R",
  "R/03_eda.R",
  "R/04_cva.R",
  "R/05_classify_new_athletes.R",
  "R/06_aper_split.R"
)

for (s in scripts) {
  cat("\n\n########", s, "########\n")
  source(s)
}

writeLines(capture.output(sessionInfo()), "sessionInfo.txt")
cat("\nDone. Tables in outputs/tables, figures in outputs/figures.\n")
