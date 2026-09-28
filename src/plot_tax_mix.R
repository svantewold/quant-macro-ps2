library(ggplot2)
library(showtext)
library(latex2exp)

font_add("LibertinusSerif", "LibertinusSerif-Regular.ttf")
showtext_auto()

data <- read.csv("data/processed/cap_tax_rate_grid.csv")

max_id <- which.max(data$govt_cap_tax_revenue)
max_value <- max(data$govt_cap_tax_revenue, na.rm = TRUE)

data |>
  ggplot(aes(cap_tax_rate, lab_tax_rate)) +
  geom_line(color = "steelblue", lwd = 1.4) +
  geom_vline(xintercept = data$cap_tax_rate[max_id], lty = 5) +
  labs(
    x = TeX(r"(Capital income tax rate $(\tau^k)$)"),
    y = TeX(r"(Labor income tax rate $(\tau^w)$)")
  ) +
  coord_cartesian(expand = FALSE) +
  scale_y_continuous() +
  scale_x_continuous() +
  theme_classic() +
  theme(
    text = element_text(
      color = "black",
      size = 17,
      family = "LibertinusSerif"
    ),
    axis.text = element_text(
      color = "black",
      size = 17,
      family = "LibertinusSerif"
    ),
    panel.grid.major = element_line(color = "grey90"),
    margins = margin(8, 15, 1, 1)
  )
ggsave(
  "output/tax_mix.pdf",
  width = 20,
  height = 20 * 0.64,
  dpi = 500,
  units = "cm"
)
