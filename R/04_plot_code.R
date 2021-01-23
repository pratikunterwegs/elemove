#' ---
#' output: html_document
#' editor_options: 
#'   chunk_output_type: console
#' ---
#' 
#' # Mapping Elephant Movement
#' 
#' ## Load libraries
#' 
## -----------------------------------------------------------------------------
# load libraries
# for data
library(sf)
library(raster)
library(rnaturalearth)
library(data.table)
library(glue)
# for plotting
library(ggplot2)
library(ggspatial)
library(ggtext)
library(scico)

#' 
#' ## Load data
#' 
#' ### Prepare extent
#' 
## -----------------------------------------------------------------------------
# prepare bounding box
bbox <- c(
  xmin = 330000,
  xmax = 393000,
  ymin = 7260000,
  ymax = 7298050
)
bbox_sf <- st_bbox(bbox)
bbox_sf <- st_as_sfc(bbox_sf)
st_crs(bbox_sf) <- 32736

#' 
#' ### Load movement data
#' 
## -----------------------------------------------------------------------------
# get data
data <- st_read("data/data_lines_elephants.gpkg")

# get data 253
data_253 <- data[data$id == "AM253", ]

# get other data
data_rest <- data[data$id %in% c("AM255", "AM99", "AM239", "AM308"), ]

#' 
#' ### Load boundary data
#' 
## -----------------------------------------------------------------------------
# get kruger data
kruger <- st_read("data/kruger_clip/kruger_clip.shp")
kruger <- st_transform(kruger, 32736)

# get inversion
kruger_invert <- st_difference(
  st_as_sfc(st_bbox(kruger)),
  kruger
)

# get kruger point -- this is hardcoded but could also be a centroid
kruger_point <- st_point(c(31.5, -24))
kruger_point <- st_sfc(kruger_point, crs = 4326)
kruger_point <- st_transform(kruger_point, 32736)

#' 
## -----------------------------------------------------------------------------
# get africa for inset
africa <- st_read("data/africa.gpkg")
africa <- st_transform(africa, 32736)

#' 
## -----------------------------------------------------------------------------
# get rivers
rivers <- st_read("data/rivers_kruger.gpkg")
rivers <- st_transform(rivers[is.na(rivers$seasonal), ], 32736)

# waterholes
waterholes <- st_read("data/waterholes/")

#' 
## -----------------------------------------------------------------------------
# get temperature
if (!file.exists("data/kruger_temp_200m.tif")) {
  res_init <- res(raster("data/kruger_temperature_UTM.tif"))
  res_final <- res_init * 200 / res_init
  gdalUtils::gdalwarp(
    srcfile = "data/kruger_temperature_UTM.tif",
    dstfile = "data/kruger_temp_200m.tif",
    tr = c(res_final), r = "average",
    te = c(bbox(raster("data/kruger_temperature_UTM.tif")))
  )
}

# read in cropped raster
temp <- raster("data/kruger_temp_200m.tif")

temp <- raster::crop(temp, as(bbox_sf, "Spatial"))
temp <- cbind(coordinates(temp), values(temp))
temp <- data.table(temp)
temp <- temp[V3 > 22, ]
setnames(temp, "V3", "temp")

#' 
## -----------------------------------------------------------------------------
# prepare a blue
blue <- scico::scico(3, palette = "nuuk")[1]

#' 
#' ## Make Africa Inset
#' 
## -----------------------------------------------------------------------------
fig_inset_a <-
  ggplot() +
  geom_sf(
    data = africa,
    fill = "tan",
    show.legend = F,
    col = NA
  ) +
  geom_sf(
    data = africa[africa$name == "South Africa", ],
    fill = "sienna",
    col = NA
  ) +
  geom_sf(
    data = kruger_point,
    size = 5,
    fill = NA,
    shape = 21,
    colour = "grey20",
    stroke = 1
  ) +
  scale_y_continuous(
    breaks = seq(-22, -34, -6)
  ) +
  theme_void(base_size = 8) +
  theme(
    panel.background = element_rect(
      fill = "powderblue",
      colour = "grey20"
    ),
    plot.margin = unit(rep(2, 4), "mm")
  ) +
  coord_sf(
    expand = T
  )

#' 
#' ## Make Kruger Inset
#' 
## -----------------------------------------------------------------------------
pal <- scico(7, palette = "turku")

fig_inset_b <-
  ggplot() +
  geom_sf(
    data = kruger,
    fill = "tan",
    alpha = 0.8,
    col = NA,
    lwd = 0.3
  ) +
  geom_sf(
    data = data,
    lwd = c(0.1),
    lty = 1,
    alpha = c(0.3),
    col = pal[2]
  ) +
  annotate(
    geom = "rect",
    fill = NA,
    col = "grey20",
    lwd = 0.3,
    xmin = bbox["xmin"],
    xmax = bbox["xmax"],
    ymin = bbox["ymin"],
    ymax = bbox["ymax"]
  ) +
  annotation_scale(
    bar_cols = c("grey50", "grey70"),
    height = unit(1, units = "mm"),
    text_family = "IBM Plex Sans"
  ) +
  theme_void() +
  coord_sf(
    crs = 32736,
    expand = FALSE,
    xlim = c(325000, NA)
  ) +
  theme(
    panel.background = element_rect(
      fill = "grey75"
    ),
    panel.border = element_rect(
      colour = "grey20",
      fill = NA
    ),
    plot.margin = unit(rep(1, 4), "mm")
  )

#' 
#' ## Make Main Figure
#' 
#' ### Prepare textbox
#' 
## -----------------------------------------------------------------------------
textbox <- glue(
  "**Kruger Elephants Shuttle to Water**

  African elephants move as they please, \\
  ignoring park boundaries when it suits them. \\
  Yet they need water to help them \\
  through the thermal landscape (_blue: cool, orange: warm_; LANDSAT 5 \\
  2007 -- 2009 average). \\
  In Kruger, elephants frequent water sources during the afternoon, the \\
  hottest part of the day; arriving and leaving at high speed. \\
  Here, elephant _AM253_ (red) and her herd seem anchored to specific \\
  water sources, tracing loops to and from them, \\
  while avoiding other herds (grey). \\
  Elephants apparently also avoid the cooler conditions of _Acacia_ woodland, \\
  seen here as the central blue patch. \\
  Read more: _Thaker, Gupte, et al. (2019). Front. Ecol. Evol._"
)
# texttitle = "Elephants Shuttle to Water"
textdata <- data.table(
  x = bbox["xmin"] + 5000,
  y = bbox["ymax"] - 9000,
  label = textbox
)

#' 
#' ### Prepare movement plot
#' 
## -----------------------------------------------------------------------------
# make plot
fig_main <-
  ggplot() +
  geom_sf(
    data = kruger,
    col = NA,
    fill = "antiquewhite",
  ) +
  geom_tile(
    data = temp,
    aes(x, y, fill = temp),
    show.legend = F,
    alpha = 0.4
  ) +
  geom_sf(
    data = rivers[is.na(rivers$seasonal), ],
    lwd = 1,
    col = blue,
    alpha = 0.35
  ) +
  geom_sf(
    data = data_rest,
    lwd = c(0.15),
    lty = 1,
    alpha = c(0.2, 0.7, 0.3, 0.15),
    col = pal[c(2, 3, 2, 3)]
  ) +
  geom_sf(
    data = data_253,
    lwd = 0.2,
    alpha = 1,
    col = scico::scico(7,
      palette = "bilbao"
    )[6]
  ) +
  geom_sf(
    data = waterholes,
    col = blue,
    alpha = 0.45
  ) +
  geom_sf(
    data = kruger,
    col = "grey50",
    lwd = 0.3,
    fill = NA,
    lty = 2
  ) +
  geom_sf(
    data = kruger_invert,
    fill = alpha("grey80", 0.35),
    col = NA
  ) +
  coord_sf(
    xlim = bbox[c("xmin", "xmax")],
    ylim = bbox[c("ymin", "ymax")],
    expand = FALSE
  )

#' 
#' ### Add decoration
#' 
## -----------------------------------------------------------------------------
fig_main <-
  fig_main +
  annotation_north_arrow(
    style = north_arrow_minimal(
      text_family = "IBM Plex Sans",
      text_size = 10,
      text_col = "grey50",
      line_col = "grey50",
      fill = "grey50"
    ),
    location = "br"
  ) +
  annotation_scale(
    bar_cols = c("grey50", "grey90"),
    height = unit(1, units = "mm"),
    text_family = "IBM Plex Sans"
  ) +
  theme_void() +
  theme(
    panel.background = element_rect(
      colour = "grey",
      fill = alpha("grey", 0.5)
    ),
    plot.margin = unit(rep(5, 4), "mm")
  )

#' 
#' ### Add insets
#' 
## -----------------------------------------------------------------------------
fig_main <-
  fig_main +
  annotation_custom(
    grob = ggplotGrob(
      fig_inset_b
    ),
    xmin = bbox[c("xmin")] + 1000,
    xmax = bbox[c("xmin")] + 7500,
    ymax = bbox["ymin"] + 13500,
    ymin = bbox["ymin"] + 1000
  ) +
  annotation_custom(
    grob = ggplotGrob(
      fig_inset_a
    ),
    xmin = bbox[c("xmin")] + 1000,
    xmax = bbox[c("xmin")] + 7500,
    ymax = bbox["ymin"] + 21000,
    ymin = bbox["ymin"] + 13600
  )

#' 
#' ### Add text box
#' 
## -----------------------------------------------------------------------------
fig_main <-
  fig_main +
  geom_textbox(
    data = textdata,
    aes(
      x, y,
      label = label
    ),
    family = "IBM Plex Sans",
    size = 3,
    colour = "grey20",
    fill = alpha("aliceblue", 0.5),
    box.color = alpha("grey", 0.5)
  )

#' 
## -----------------------------------------------------------------------------
textlabels <- data.table(
  x = bbox["xmax"] - c(8000, 18000),
  xend = bbox["xmax"] - c(5000, 6000),
  y = bbox["ymin"] + c(23500, 15000),
  yend = bbox["ymin"] + c(12000, 9000),
  label = c("Warmer\nMarula\nSavanna", "Cooler\nAcacia\nThickets")
)

#' 
#' ### Add some labels
#' 
## -----------------------------------------------------------------------------
fig_main <-
  fig_main +
  annotate(
    geom = "text",
    x = bbox[c("xmin")] +
      c(20000, 30000),
    y = bbox["ymin"] +
      c(12600, 15400),
    label = c(
      "Private\nNature\nReserves",
      "Kruger\nNational\nPark"
    ),
    fontface = "italic",
    family = "IBM Plex Serif",
    alpha = c(0.55, 0.5),
    size = c(4, 5)
  ) +
  geom_text(
    data = textlabels,
    aes(x, y,
      label = label
    ),
    fontface = "italic",
    family = "IBM Plex Serif",
    alpha = c(0.5, 0.5),
    size = c(3, 3)
  )

#' 
#' ### Make options
#' 
## -----------------------------------------------------------------------------
# op1 = fig_main +
#   scale_fill_gradientn(
#     colours = scico(20,
#       palette = "romaO",
#       direction = -1,
#       begin = 0., end = 1
#     )
#   )
#
# op2 = fig_main +
#   scale_fill_distiller(
#     palette = "RdYlBu"
#   )

fig_main <- fig_main +
  scale_fill_gradientn(
    colours = scico(20,
      palette = "vikO",
      direction = 1,
      begin = 0., end = 1
    )
  )

#' 
#' 
#' ### Save figure
#' 
## -----------------------------------------------------------------------------
# wide 16:9
ggsave(fig_main,
  filename = "figures/fig_map_wide.png",
  height = 9, width = 16,
  bg = "grey"
)
# a low res version
ggsave(fig_main,
  filename = "figures/fig_map_wide_low_res.png",
  height = 9, width = 16,
  bg = "grey",
  dpi = 72
)

