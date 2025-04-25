Simulation studies to test survival analysis of the CIS data to determine duration of positivity.

This code depends on R packages for [running the simulation studies](https://github.com/joshuablake/cisSimulation) and [fitting the models](https://github.com/joshuablake/cisDurationModel), both of which need to be downloaded from GitHub.
The renv environment should automatically install these and the other dependencies.

The files in `data/` are statistical data from ONS which is Crown Copyright. The use of the ONS statistical data in this work does not imply the endorsement of the ONS in relation to the interpretation or analysis of the statistical data. This work uses research datasets which may not exactly reproduce National Statistics aggregates.

## Running instructions

This repo requires the GitHub packages [cisSimulation](https://github.com/joshuablake/cisSimulation), for simulating data, and [cisDurationModel], for implementation of the models.
Other dependencies are specified in `renv.lock`.

To run and analyse the simulations, SLURM scripts need to be submitted in the following order.
The submission scripts will need editing for your specific set-up.

1. `10_sims/SLURM_run` to run the simulations.
2. `10_sims/SLURM_output` to consolidate the different simulation batches into a single output file.
3. `20_sims/SLURM` to analyse the simulation outputs, estimating the duration distribution.

The file `00_durations.R` will output a file containing the different duration distributions used as ground truth within the simulations in step 1 and in constructing the priors for the analysis in step 3.
