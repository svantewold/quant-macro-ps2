library(ggplot2)
library(showtext)
library(latex2exp)

font_add("LibertinusSerif", "LibertinusSerif-Regular.ttf")
showtext_auto()

data <- read.csv("data/cap_tax_rate_grid.csv")

max_id <- which.max(data$welfare)
max_value <- max(data$welfare, na.rm = TRUE)

data |>
  ggplot(aes(cap_tax_rate, welfare)) +
  geom_line(color = "steelblue", lwd = 1.4) +
  geom_vline(xintercept = data$cap_tax_rate[max_id], lty = 5) +
  annotate(
    x = data$cap_tax_rate[max_id],
    y = max_value,
    geom = "point",
    color = "darkorange4",
    size = 4,
    shape = 16
  ) +
  labs(
    x = TeX(r"(Capital income tax rate $(\tau^k)$)"),
    y = TeX(r"(Household welfare $(W_t)$)")
  ) +
  coord_cartesian(
    expand = FALSE, 
    ylim = c(-155, -100)
  ) +
  scale_y_continuous() +
  scale_x_continuous(n.breaks = 10) +
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
  "output/welfare_curve.pdf",
  width = 20,
  height = 20 * 0.64,
  dpi = 500,
  units = "cm"
)
