# library(ggplot2)
library(tidybayes)
source(here::here("20_sims/define_runs.R"))
source(here::here("R/utils.R"))

tbl_fits = tbl_runs |>
    tibble::rowid_to_column("job_num") |>
    filter(job_num != 10) |> # jobs 6 and 10 are duplicates
    mutate(
        fit_file_name = glue::glue(
            "{output_dir}20_sims/results_{job_num}.rds"
        ),
        fit = purrr::map(fit_file_name, readRDS),
    )

tbl_summaries = tbl_fits |>
    mutate(
        summaries = purrr::map(
            fit,
            ~spread_draws(.x, S[time], lambda[time]) |>
                median_qi()
        )
    ) |>
    select(!fit) |>
    unnest(summaries)

tbl_summaries |>
    filter(sensitivity.simulation == 1, sensitivity.model == 1) |>
    saveRDS(paste0(output_dir, "output/perfect_posteriors.rds"))

tbl_summaries |>
    saveRDS(paste0(output_dir, "output/all_posteriors.rds"))
