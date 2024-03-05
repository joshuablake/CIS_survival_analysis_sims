library(dplyr)
library(purrr)
library(tidyr)
setwd(here::here("."))
source(here::here("R/data.R"))
source(here::here("10_sims/simulations.R"))

cis_test_times = read_CIS_testing_schedules()
ataccc_truth = get_truth_curve()

NUM_SCENARIOS = nrow(tbl_simulation_scenarios)
SIMS_PER_BATCH = 5
BATCHES_PER_SCENARIO = 200
JOB_NUM = commandArgs(trailingOnly = TRUE)[1] |> as.integer()

set.seed(JOB_NUM)
batch_num = (JOB_NUM - 1) %% BATCHES_PER_SCENARIO + 1
scenario_num = (JOB_NUM - 1) %/% BATCHES_PER_SCENARIO + 1
scenario_info = tbl_simulation_scenarios[scenario_num,]

print(paste(
  "Running scenario",
  scenario_num,
  "batch",
  batch_num,
  "with",
  SIMS_PER_BATCH,
  "simulations",
  "(Job number", JOB_NUM, ")"
))

sim_results = map(
  1:SIMS_PER_BATCH,
  ~do.call(scenario_info$make_call[[1]], scenario_info$args[[1]])
)

all_results = list(
  sim_results = sim_results,
  scenario_name = scenario_info$name[[1]],
  batch_num = batch_num,
  sensitivity = scenario_info$sensitivity[[1]]
)

saveRDS(
  all_results,
  paste0("~/rds/hpc-work/PhD_survival_analysis/10_sims/results_", JOB_NUM, ".rds")
)