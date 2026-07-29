#!/usr/bin/env Rscript

# Publication-quality native-population-density map.
# Required packages: sf, dplyr, ggplot2, scales.

required <- c("sf", "dplyr", "ggplot2", "scales")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Install required R packages: ", paste(missing, collapse = ", "))

library(sf)
library(dplyr)
library(ggplot2)
library(scales)

repo_root <- normalizePath(getwd())
spatial_file <- file.path(repo_root, "data", "spatial", "map1930.shp")
census_file <- file.path(repo_root, "data", "administrative_units.csv")
assets_dir <- file.path(repo_root, "assets")

units <- read.csv(census_file, fileEncoding = "UTF-8", stringsAsFactors = FALSE) |>
  select(AREA_2, CODE_2, nativetotal)

if (anyDuplicated(units[c("AREA_2", "CODE_2")])) {
  stop("AREA_2 and CODE_2 must uniquely identify census units.")
}

boundaries <- st_read(spatial_file, quiet = TRUE) |>
  left_join(units, by = c("AREA_2", "CODE_2"))

if (anyNA(boundaries$nativetotal)) {
  stop("One or more polygons did not match a census unit.")
}

# Dissolve multipart polygons before calculating density. EPSG:6933 is an
# equal-area CRS suitable for a consistent archipelago-wide area measure.
map_units <- boundaries |>
  group_by(AREA_2, CODE_2, NAME_2) |>
  summarise(nativetotal = first(nativetotal), .groups = "drop") |>
  st_transform(6933) |>
  mutate(
    area_km2 = as.numeric(st_area(geometry)) / 1e6,
    natives_per_km2 = nativetotal / area_km2
  )

# A generous buffer prevents the outer islands from feeling pressed against the
# frame when the figure is rendered at README scale.
bounds <- st_bbox(map_units)
x_pad <- (bounds$xmax - bounds$xmin) * 0.055
y_pad <- (bounds$ymax - bounds$ymin) * 0.07

plot <- ggplot(map_units) +
  geom_sf(aes(fill = natives_per_km2), colour = "#f8fbff", linewidth = 0.04) +
  # A quiet, light-to-dark sequential palette (ColorBrewer YlGnBu): lower
  # density recedes while the densely populated units remain legible.
  scale_fill_gradientn(
    colours = c("#edf8b1", "#c7e9b4", "#7fcdbb", "#41b6c4", "#225ea8", "#081d58"),
    trans = "log10",
    limits = c(1, 8000),
    oob = squish,
    breaks = c(1, 20, 400, 8000),
    labels = label_number(accuracy = 1, big.mark = ""),
    name = "Native population density (per km²)",
    guide = guide_colourbar(
      direction = "horizontal",
      title.position = "top",
      title.hjust = 0.5,
      label.position = "bottom",
      barwidth = grid::unit(32, "lines"),
      barheight = grid::unit(0.9, "lines")
    )
  ) +
  coord_sf(
    xlim = c(bounds$xmin - x_pad, bounds$xmax + x_pad),
    ylim = c(bounds$ymin - y_pad, bounds$ymax + y_pad),
    expand = FALSE
  ) +
  theme_void() +
  theme(
    # The reference's restrained type treatment, retained below the map so the
    # legend never obscures the small islands in the lower archipelago.
    legend.position = "bottom",
    legend.justification = "center",
    legend.background = element_rect(fill = alpha("#f5f5f2", 0), colour = NA),
    legend.box.margin = margin(t = 8, r = 0, b = 0, l = 0),
    legend.title = element_text(family = "Avenir Next", size = 10.5,
                                colour = "#4e4d47", hjust = 0.5),
    legend.text = element_text(family = "Avenir Next", size = 8.5,
                               colour = "#4e4d47"),
    plot.background = element_rect(fill = "#f5f5f2", colour = NA),
    panel.background = element_rect(fill = "#f5f5f2", colour = NA),
    plot.margin = margin(8, 12, 8, 12)
  )

ggsave(file.path(assets_dir, "native-population-density-1930.png"), plot,
       width = 7.5, height = 4.5, dpi = 240, bg = "#f5f5f2")
