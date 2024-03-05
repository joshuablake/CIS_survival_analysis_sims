library(dplyr)
library(tidyr)
source(here::here("20_sims/define_runs.R"))

JOB_NUM = commandArgs(trailingOnly = TRUE)[1] |> as.integer()
set.seed(JOB_NUM)

stopifnot(JOB_NUM <= nrow(tbl_runs))
scenario_info = tbl_runs[JOB_NUM,]

read_sims = function(sensivitiy) {
    file_number = case_match(
        sensivitiy,
        0.6 ~ 1,
        0.8 ~ 201,
        1.0 ~ 401,
        NA ~ 601
    )
    paste0("~/rds/hpc-work/PhD_survival_analysis/10_sims/results_", file_number, ".rds") |>
        readRDS()
}


run = function(episodes, tS_matrix_all, n_obs, prop_captured, prior_func, sensitivity.model) {
    infer_duration(
        pa_model = pa_double_censor(
            episodes$prev_neg, episodes$first_pos, episodes$last_pos, episodes$next_neg
        ),
        pt_model = pt_total(tS_matrix_all, mu_n = n_obs * 1/prop_captured, r_n = 1),
        survival_prior = prior_func(),
        sensitivity_model = fixed_sensitivity(sensitivity.model),
        stan_args = list(cores = 4, chains = 4),
        run_stan = TRUE
    )
}

print(glue::glue(
    "Running scenario {scenario_info$name} (job number {JOB_NUM})"
))
print("--------------------------------------------------------------")

print("Reading sim data")
sim_out = read_sims(scenario_info$sensitivity.simulation)
sim_data = sim_out$sim_results[[1]]
print("Starting Stan")
result = run(
    sim_data$episodes,
    sim_data$tS_matrix_all,
    sim_data$n_obs,
    sim_data$prop_captured,
    scenario_info$prior_func[[1]],
    scenario_info$sensitivity.model
)
print("Saving result")
saveRDS(
    result,
    paste0("~/rds/hpc-work/PhD_survival_analysis/20_sims/results_", JOB_NUM, ".rds")
)
print("Finished")