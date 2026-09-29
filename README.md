# What is an optimal capital income tax?

This repository computes a full general equilibrium overlapping generations (OLG) model with many generations and a a pension system. The code assumes a stationary population distribution with 1 percent population growth per year in which households live with certainty until an age of 79 (model age 60) and retire at age 65 (model age 46). The population size is normalized to 1. TFP grows by 1.03 percent per year; the capital share is 0.3845; the capital depreciation rate is 3.71 percent; the social security replacement rate 40 percent; and households have a discount factor and CRRA parameter equal to 1.011 and 2, respectively.

## Solving the model
`solve_capital_tax_rate_grid.m` solves the model on a capital tax income grid between 0 and 1, and computes the endogenous labor income tax, total lifetime utility of a household, and the government tax revenue for all solutions. The solver function, using the shooting method to solve the household optimization, is contained in the function script `olg_solver.m`.

## Plots
The plot module produces three plots:
- *The Tax mix*: labor income tax as a function of the capital income tax.
- *The household welfare*: total lifetime utility of a given household as a function of the capital income tax.
- *The Laffer Curve*: government tax revenue as a function of the capital income tax.

The repository can be ran by running `run.sh` from the command line.

**All Matlab scripts are based on provided code by: Markus Pettersson, Stockholm University.**
