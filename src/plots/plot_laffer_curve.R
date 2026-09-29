library(ggplot2)
library(showtext)
library(latex2exp)

font_add("LibertinusSerif", "LibertinusSerif-Regular.ttf")
showtext_auto()

data <- read.csv("data/cap_tax_rate_grid.csv")

# Obtain maximum gov't tax revenue and index to find
# corresponding capital income tax rate
max_id <- which.max(data$govt_cap_tax_revenue)
max_value <- max(data$govt_cap_tax_revenue, na.rm = TRUE)

# Plot Laffer curve
data |>
  ggplot(aes(cap_tax_rate, govt_cap_tax_revenue)) +
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
    y = TeX(r"(Government tax revenue $(\tau^k r \tilde{K})$)")
  ) +
  coord_cartesian(expand = FALSE, ylim = c(0, 0.52)) +
  scale_y_continuous(breaks = seq(0.05,0.5, by = 0.1)) +
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
  "output/laffer_curve.pdf",
  width = 20,
  height = 20 * 0.64,
  dpi = 500,
  units = "cm"
)
