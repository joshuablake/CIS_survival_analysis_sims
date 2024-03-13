library(dplyr)
library(tibble)
library(tidyr)

read_CIS_testing_schedules = function(filename = here::here("data/cis_schedules.csv")) {
    readr::read_csv(filename, col_types = readr::cols(.default = "integer")) |>
        rowid_to_column("individual") |>
        pivot_longer(!c(individual, first_pos_date), names_to = "test_num", values_to = "test_time",
                    values_drop_na = TRUE) |>
        transmute(individual, test_time = as.integer(test_time))
}

process_SARAH_curves = function(filename = here::here("data/2021-07-19_clearance_curves.csv")) {
    readr::read_csv(
        filename, 
        col_types = readr::cols(.default = "double")
    ) |>
    transmute(
        time = timevar + 1,
        S = cis,
    ) |>
    add_row(time = 1, S = 1) |>
    arrange(time) |>
    mutate(
        F = c(1 - lead(S)[-n()], 1),
        f = diff(c(0, F)),
        lambda = if_else(S == 0, 0, f / S)
    )

}

combine_SARAH_ATACCC = function(SARAH_clearance_curve, ATACCC_curve) {
    SARAH_clearance_curve |>
      mutate(
        ataccc_l = c(ATACCC_curve$lambda, rep(NA, n() - nrow(ATACCC_curve))),
        ataccc_f = c(ATACCC_curve$f, rep(NA, n() - nrow(ATACCC_curve))),
        combined_f = if_else(time <= 30, ataccc_f, f)
      ) |>
      transmute(
        time,
        f = combined_f / sum(combined_f),
        F = cumsum(f),
        S = c(1, 1 - lag(F)[-1]),
        lambda = if_else(S == 0, 0, f / S),
      )
}

curve_to_duration = function(curve) {
    curve |>
        filter(time >= 1) |>
        arrange(time) |>
        pull(f) |>
        cisSimulation::duration_custom()
}

get_raw_truth_curve = function() {
    combine_SARAH_ATACCC(
        process_SARAH_curves(),
        atacccDurationEstimates::ataccc_posterior_summary_stats()
    )
}

get_truth_curve = function() {
    get_raw_truth_curve() |>
        curve_to_duration()
}