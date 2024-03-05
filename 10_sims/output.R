library(dplyr)
library(purrr)
library(tidyr)

read_job = function(job_num) {
    num_batches = 200
    file_name = paste0(
        "~/rds/hpc-work/PhD_survival_analysis/10_sims/results_",
        job_num,
        ".rds"
    )
    sim_out = readRDS(file_name)
    imap(
        sim_out$sim_results,
        ~pluck(.x, "episodes") |>
            mutate(
                sim_num = .y
            )
    ) |>
        bind_rows() |>
        mutate(
            sensitivity = sim_out$sensitivity,
            batch_num = (job_num - 1) %% num_batches + 1
        )
}

tbl_sims = map(1:800, read_job) |>
    bind_rows() |>
    mutate(
        .draw = (batch_num - 1) * max(sim_num) + sim_num
    )

saveRDS(
    tbl_sims,
    "~/rds/hpc-work/PhD_survival_analysis/output/sims.rds"
)