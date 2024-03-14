library(atacccDurationEstimates)
library(cisDurationModel)
library(dplyr)
library(tidyr)
source("R/utils.R")

tbl_perf_test = tibble(
    sensitivity.model = 1,
    sensitivity.simulation = 1,
    survival_prior = c("ATACCC", "RW2", "vague"),
)

tbl_imperf_well_specified = expand_grid(
    sensitivity.model = c(0.6, 0.8),
    survival_prior = c("ATACCC", "vague"),
) |>
    mutate(
        sensitivity.simulation = sensitivity.model
    )

tbl_imperf_mis_specified = expand_grid(
    sensitivity.model = c(0.6, 0.8, 1.0),
    survival_prior = "ATACCC",
    sensitivity.simulation = c(0.8, NA),
)

tbl_runs = bind_rows(
    tbl_perf_test,
    tbl_imperf_well_specified,
    tbl_imperf_mis_specified
) |>
    mutate(
        prior_func = case_match(
            survival_prior,
            "vague" ~ list(cisDurationModel::surv_prior_independent),
            "RW2" ~ list(function() surv_prior_RW2_sigma("exponential(10)")),
            "ATACCC" ~ list(function() surv_prior_informative_hiearchy(
                ataccc_logit_hazard_mean("hakki"),
                ataccc_logit_hazard_covar("hakki"),
                1000 * expit(-0.4 * ((1:40) - 20))
                
            )),
        ),
        name = glue::glue(
            "sens.model.{sensitivity.model}_sens.sim.{sensitivity.simulation}_prior.{survival_prior}"
        )
    )
