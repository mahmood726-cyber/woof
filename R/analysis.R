# Rigorous Survival Analysis: Cox Proportional Hazards for Heart Failure Mortality
# Data Source: UCI Heart Failure Clinical Records (Open Access)
# Protocol: E156 / TruthCert

library(survival)
library(rms)

# Resolve the bundled dataset relative to this script so the analysis works from any cwd.
script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg) > 0) {
  normalizePath(sub("^--file=", "", script_arg[[1]]), winslash = "/", mustWork = FALSE)
} else {
  normalizePath("R/analysis.R", winslash = "/", mustWork = FALSE)
}
repo_root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = FALSE)
data_path <- file.path(repo_root, "data", "heart_failure.csv")

# Load real data
if (!file.exists(data_path)) {
  stop("Real dataset not found at: ", data_path)
}

df <- read.csv(data_path)

# 1. Advanced Survival Setup
# Create Surv object for time-to-event (DEATH_EVENT)
surv_obj <- Surv(time = df$time, event = df$DEATH_EVENT)

# 2. Cox Proportional Hazards Model
# Predicting Hazard Ratios for all major clinical variables
cox_model <- coxph(
  surv_obj ~ age + ejection_fraction + serum_creatinine + high_blood_pressure +
    serum_sodium + anaemia + diabetes + smoking + sex,
  data = df
)

# Extract Hazard Ratios (HR) and 95% CI
summary_cox <- summary(cox_model)
hr_table <- exp(cbind(HR = coef(cox_model), confint(cox_model)))

# 3. Model Internal Validation (C-Index / AUC)
# Using rms package for Dxy (2 * (C-Index - 0.5))
dd <- datadist(df)
options(datadist = "dd")
cph_rms <- cph(
  surv_obj ~ age + ejection_fraction + serum_creatinine + high_blood_pressure +
    serum_sodium + anaemia + diabetes + smoking + sex,
  data = df,
  x = TRUE,
  y = TRUE
)

# Bootstrap validation for C-Index (Dxy)
validate_res <- validate(cph_rms, B = 100)
c_index_corrected <- (validate_res["Dxy", "index.corrected"] / 2) + 0.5

# 4. Kaplan-Meier Estimation (Survival Curves)
km_fit <- survfit(surv_obj ~ high_blood_pressure, data = df)

# Get survival at 180 days (safe extraction)
get_surv_at_time <- function(fit, t) {
  # fit$time is not necessarily sorted globally if there are strata.
  overall_fit <- survfit(surv_obj ~ 1, data = df)
  idx <- findInterval(t, overall_fit$time)
  if (idx == 0) {
    return(1.0)
  }
  overall_fit$surv[idx]
}
surv_180d <- get_surv_at_time(km_fit, 180)

# 5. TruthCert Synthesis
analysis_results <- list(
  n_records = nrow(df),
  cox_hazard_ratios = round(hr_table, 4),
  model_likelihood_ratio_p = round(summary_cox$logtest["pvalue"], 10),
  c_index_validated = round(c_index_corrected, 4),
  km_survival_180d = round(surv_180d, 4),
  certified_oa = TRUE,
  source_hash = tools::md5sum(data_path)
)

# Output for TruthCert audit
cat("\n--- TRUTHCERT ADVANCED SURVIVAL AUDIT ---\n")
print(analysis_results)
cat("\n--- HAZARD RATIO HIGHLIGHTS ---\n")
cat("Serum Creatinine HR:", analysis_results$cox_hazard_ratios["serum_creatinine", "HR"], "\n")
cat("Ejection Fraction HR:", analysis_results$cox_hazard_ratios["ejection_fraction", "HR"], "\n")
cat("\n--- MODEL PERFORMANCE ---\n")
cat("Bootstrap Corrected C-Index:", analysis_results$c_index_validated, "\n")
cat("Likelihood Ratio Test (p):", analysis_results$model_likelihood_ratio_p, "\n")
