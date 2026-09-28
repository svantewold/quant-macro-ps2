library(ggplot2)
library(showtext)
library(latex2exp)

font_add("LibertinusSerif", "LibertinusSerif-Regular.ttf")
showtext_auto()

data <- read.csv("data/processed/laffer_curve.csv")

max_id <- which.max(data$govt_cap_tax_revenue)
max_value <- max(data$govt_cap_tax_revenue, na.rm = TRUE)

data |>
  ggplot(aes(cap_tax_rate, govt_cap_tax_revenue)) +
  geom_line(color = "steelblue", lwd = 1.4) +
  geom_vline(xintercept = data$cap_tax_rate[max_id], lty = 5) +
  annotate(
    x = data$cap_tax_rate[max_id],
    y = max_value,
    geom = "point",
    color = "darkorange2",
    size = 5,
    shape = 18
  ) +
  labs(
    x = TeX(r"(Capital tax rate $(\tau^k)$)"),
    y = TeX(r"(Government capital tax revenue $(r \tau^k \tilde{K})$)")
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
  "output/laffer_curve.pdf",
  width = 20,
  height = 20 * 0.64,
  dpi = 500,
  units = "cm"
)
