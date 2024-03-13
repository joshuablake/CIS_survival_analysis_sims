library(dplyr)
library(tidyr)
source(here::here("R/data.R"))

bind_rows(
    atacccDurationEstimates::ataccc_posterior_summary_stats() |>
        select(time, f, F, S, lambda) |>
        mutate(source = "ATACCC"),
    process_SARAH_curves() |>
        mutate(source = "SARAH (CIS)"),
    get_raw_truth_curve() |>
        mutate(source = "Combined")
)  |>
    saveRDS(paste0(output_dir, "output/input_curves.rds"))
