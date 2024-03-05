basic_sim = function(truth, test_times, sensitivity, sample_size = 4800,
                     epoch_start_time = 15, epoch_end_time = 65, inf_times = -50:epoch_end_time) {
  if (is.na(sensitivity)) {
    testing = cisSimulation::sensitivity_linear()
  } else {
    testing = cisSimulation::sensitivity_fixed(sensitivity)
  }

  # Require at least one test during the epoch
  test_times = test_times |>
    group_by(individual) |>
    filter(min(test_time) <= epoch_end_time, max(test_time) >= epoch_start_time)

  sim_results = cisSimulation::simulate_cis(
    positive_duration = truth,
    n_indivs = n_distinct(test_times$individual),
    testing_times = cisSimulation::testing_custom(test_times),
    infection_times = cisSimulation::infections_flat(inf_times),
    testing = testing
  )
  all_episodes = cisSimulation::simulation_to_episodes(sim_results) |>
    mutate(first_test = purrr::map_int(test_times, min))
  n_captures = sum(all_episodes$type == "captured" & all_episodes$first_pos <= max(inf_times))
  observed_episodes = all_episodes |> 
    filter(type == "captured", first_pos <= epoch_end_time, first_pos >= epoch_start_time) |>
    slice_sample(n = sample_size)

  max_S = max(observed_episodes$next_neg - observed_episodes$prev_neg) + 1

  custom_matrices = function(episodes) {
    cisDurationModel::form_tS_matrices(
      test_time_list = purrr::map(episodes$test_times, ~.x[.x <= max(inf_times)]),
      times = inf_times,
      max_S = max_S,
      min_times = episodes$first_test,
      max_N = 2
    )
  }

  return(lst(
    tests = sim_results,
    episodes = observed_episodes,
    n_obs = nrow(episodes),
    tS_matrix_all = custom_matrices(all_episodes),
    tS_matrix_captures = custom_matrices(observed_episodes),
    prop_captured = n_captures / nrow(all_episodes),
  ))
}

tbl_simulation_scenarios = tibble(
    truth = "ATACCC",
    sensitivity = c(0.6, 0.8, 1, NA_real_),
    make_call = list(basic_sim),
  ) |>
  mutate(
    args = map(sensitivity, ~list(sym("ataccc_truth"), sym("cis_test_times"), .x)),
    name = paste0("ATACCC_fixed-sens-", if_else(is.na(sensitivity), "varied", as.character(sensitivity)))
  )
