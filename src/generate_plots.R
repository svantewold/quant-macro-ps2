source("src/plots/plot_tax_mix.R")
message(paste0("\nLabor income tax when capital income is untaxed:\n", data$lab_tax_rate[1], "\n"))

source("src/plots/plot_welfare.R")
message(paste0("Welfare is maximized when the capital income tax rate is:\n", data$cap_tax_rate[max_id], "\n"))

source("src/plots/plot_laffer_curve.R")
message(paste0("Government tax revenue is maximized when the capital income tax rate is:\n", data$cap_tax_rate[max_id]))
