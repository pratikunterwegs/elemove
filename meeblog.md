
# Mapping Animal Movement: Art and Reproducibility

## Introduction

In December 2020 I was pointed to the BES Mapping Animal Movements Contest, and the "R Map" category stood out to me.
I've wanted to work with the spatial ecology of animals, and especially the movement of birds since 2014.
That led me to do my master's thesis project in Martin Wikelski's department at the Max Planck Institute for Ornithology (now MPI Animal Behaviour) in 2017, working on the migration of Arctic geese.

However, by the summer of 2017 I realised I couldn't seamlessly move from my master's to a PhD (which are more of a job in Europe).
I got in touch with [Maria Thaker](), faculty at the Centre for Ecological Sciences at the Indian Institute of Science, who I knew had been working with elephant movement, and essentially asked for a job.
I began as a research assistant with Maria and [Abi Vanak]() at ATREE (the Ashoka Trust for Research in Ecology and the Environment).

Maria and Abi had worked with elephant movement during their postdocs at the University of KwaZulu Natal.
The elephants were tagged in 2007 in Kruger National Park, and had been transmitting for approximately two years until 2009.
The movement data had remained under-analysed since then, with only a single paper, [Vanak et al.]() about the effect of rainfall.

I was brought in as the equivalent of a script-doctor, to see whether I could resurrect the long-dormant data.
The idea I had to go on was that Kruger elephants frequented water sources during the hottest part of the day, and moved faster when it was warmer.

## About the Map and AM253

The map highlights the path of a single female elephant bearing the tag AM253. She was tagged in August 2007, and her tag expired in December, 2008. In the intervening period, the tag transmitted a position every thirty minutes.

Thirteen other elephants were tagged around the same time, and some of these are also shown on the map to give a sense of how densely Kruger is criss-crossed by elephant herds.

There are only three other 'vector' features on the main map: the courses of rivers, the locations of waterholes, and the boundary of Kruger. The inset maps show the location of Kruger in Africa, and the southern half of Kruger, with the tracks of all the elephants in this study, respectively.

The background layer, a 'raster', represents the average temperature sensed by the LANDSAT-5 satellite over the two year period of this study.
I used LANDSAT-5 because it was the appropriate satellite for the time period (2007), and had a decent spatial resolution (30 metres).

LANDSAT-5's sensors collect reflected solar radiation, which is then processed by USGS/NASA to provide several useful products.
Here, I used the surface reflectance in the thermal range to calculate the temperature, taking care to avoid including data from periods when the area was covered by clouds.

This layer is also a spatial composite, i.e., it is formed by stitching together multiple LANDSAT-5 'scenes'.
This is because the study area in southern Kruger lies at the juncture of three LANDSAT-5 scenes, and there is some overlap.

I used Google Earth Engine to acquire this data; GEE performs this stitching, as well as the averaging of the multiple scenes taken over two years (approximately once per fortnight).
The heavy computation happens on the GEE servers, significantly increasing speed, as well as improving the accessibility of the data.

In the map, the temperature layer is down-sampled to 200 metres resolution; this was mostly to avoid very long image rendering times when making the map.

## Mapping as Exploratory Data Analysis

Mapping animal movements is a key component of exploratory data analysis.

At the large scale, simply dividing a study area into grid cells and counting the number of animal locations in each cell can reveal where one or more tracked animals spends its time.

It's also important to plot the tracks of individual animals, not only as points representing the locations, but also as lines 'joining the dots'.
Large tracking datasets can contain errors that are only evident to researchers when they look at an approximation of the animal's path and ask, "Does the animal move this way?"

I encountered this issue with the raw elephant dataset, in which the projection from geographic coordinates to UTM coordinates had gone wrong for some elephants. This was not evident when examining the locations as positions, but was obvious once the points were joined by lines.

Mapping can also reveal interesting behaviours that can only be observed after significant effort in the field (though I'm all in favour of more time in the field).

For instance, the 'looping' behaviour of AM253 to water sources is the focus of this map. She isn't the only elephant to loop. She also doesn't _always_ loop, and sometimes follows riverbanks.
Other elephants, far to the north in Kenya, also do this.

Seeing this looping behaviour allowed us to focus our study on elephant movements between visits to water sources.
We recognised that we should segment the data by these visits, because we could at least guess at their function: to access water, or resources found near water.

This led to us being able to show that elephants move nearly twice when arriving at, or leaving water sources, than when they are not immediately in transit to water.

## Mapping as Art

Maps make for great art, but making 'beautiful' maps is difficult, not least because appeal is subjective.

As with many other areas of science (other than data collection, please!): when in doubt, copy. Growing up in early 2000s India, I read hard copies of National Geographic Magazine, which has long had amazing graphics.
During my master's, I was introduced to the _art_ of mapping by James Cheshire. James' book with Oliver Uberti, _Where the Animals Go_ was a source of inspiration as well.

I picked up other tips and tricks from knowing something of art generally: build up an image in layers, use colours that don't clash, highlight the phenomenon of interest.
Interestingly, some of these approaches are very much in line with the 'grammar of graphics' approach of `ggplot`, which I used to make this map.

## Mapping in R

### Visualisation in R

R's great advantage over other languages is visualisaton. The two main mapping packages in R are `ggplot2` and `tmap`. Most users are familiar with `ggplot` for general visualisation, while `tmap` is not as well known and is mapping specific.

`ggplot`'s advantage is that it is already widely used in other contexts, and its many extensions. Here, I used the `ggspatial` and `ggtext` packages to add the scale bars and north arrow, and to add the text box, respectively. `ggplot`'s emergence as a mainstay of spatial visualisation is due to its `geom_sf` function, which can handle `sf` objects.

The development of the `sf` package has significantly improved the ease of geocomputation in R, which previously relied on the `sp` package (among others). While many R packages rely on `sp` (such as `raster`), `sf` is the better choice for new projects due to its consistent function naming, ease of reading and writing to different formats, and compatibility with `ggplot`.

I plotted the elephant paths shown in this map as `sf` `LINESTRING` objects, adding colour and thickness for emphasis.

Plotting rasters is not straightforward in `ggplot`. There are two main options: the `stars` package and its associated `geom_stars`, or converting a raster dataset into a dataframe with regular coordinate intervals and using `geom_tile`.

Here, I chose the second approach because I'm an infrequent `stars` user; since making the map I've tried `geom_stars` which works just as well, and is very convenient.

I coloured the temperature raster using the `scico` package's 'VikO' palette. I tried out a number of palettes from the `scico`, `pals` (providing the Kovesi palettes), `RColorBrewer`, and `colorspace` packages, choosing VikO because of its aesthetic appeal (over the regular Vik palette) and because it is perceptually uniform.

I chose a diverging palette to indicate relative extremes of the thermal landscape; that there are areas significantly warmer and cooler than the mean. This approach is not to be recommended for material that will be printed in black and white, as the equal saturation of the two extremes makes it impossible to distinguish the upper and lower extremes of the palette.

Insets set the context for a map. I specifically chose a minimalist inset to show the location of the study area in Africa generally, and South Africa in particular. I chose to show the full elephant data in the inset to give an honest idea of how much data I was showing in the main map, and what was being left out.

I added a grey layer over the areas of the map beyond the boundaries of Kruger. While these areas are functionally quite similar, and elephant use them frequently, I thought it was important to show the distinction.

The grey borders around the map are a result of the area I wanted to show not fitting a 16:9 aspect ratio, a common ratio for computer screens. To avoid unsightly white areas, I chose a shade of grey to match the grey screen I had placed over the areas outside Kruger.

### Getting data in R

In 2019, I had worked with an intern from Movebank to publish the data on the Movebank data repository. Getting the data was thus very easy using the `move` package. I converted the `Movestack` object into an `sf` `LINESTRING` object using a series of simple inline functions. I saved the `sf` object as a geopackage, which is more convenient than a shapefile in that there's only one file to keep track of.

The river course data was also easy to acquire, using the `osmdata` package, which queries and retrieves data from the OpenStreetMap database. The boundaries of Africa and South Africa were equally easily obtained using the `rnaturalearth` package.
The Kruger boundary and the locations of waterholes were provided during my work on this project, and originally come from the South African National Park service.

### LANDSAT data

I used Python to get the LANDSAT-5 data from Google Earth Engine, using the `ee` package, which is the Python GEE API package. The `rgee` R package provides a similar functionality from within R, but uses `reticulate` to interface with `ee`. I cut out the middleman, as it were, and used `ee` directly.

I found Quisheng Wu's `geemap` package a great tool for visualisation of the data I was working with, and the associated tutorials a very good resource for help with `ee` generally.

## Reproducibility in R

I adopted a relatively relaxed understanding of reproducibility: given the data, the code would be reproducible if it could produce the map I had entered for this contest. To do this, I set up a continuous integeration/deployment pipeline using Github Actions (GHA).

First, I created an RStudio project in the folder where I was working. Using a project anchors R to the project directory, which is set as the working directory.

Using the `usethis` package, I created a `DESCRIPTION` file, which is usually reserved for packages. This file tricks other services into reading its contents, especially the dependencies, i.e., the R packages required by the project.

GHA automatically reads the dependencies and installs them, as well as the programs required by those dependencies. For instance, GDAL (the Geospatial Data Abstraction Library) is key to nearly all spatial analyses, and is installed as a requirement of the `rgdal` package, which is itself key to `sf` and `raster`.

I used the R package [`renv`]() to make sure that the packages (and the package versions) I used are available to the pipeline. `renv` creates a lockfile, a registry of packages the current project uses, from which those packages can be installed.

Finally, to check whether the entire pipeline works, I used `bookdown`. This R package is really for making HTML or PDF documents, but works equally well for sequentially executing a series of Rmarkdown files. An obvious alternative is `rmarkdown`.

GHA runs this pipeline every time I upload changes to Github, and reports whether the code ran successfully, and if not, where it failed.
It runs the pipeline on Linux, Windows, and Mac virtual machines (or more likely, containers). This means that though I use Linux, I'm pretty sure that this code works for Windows and Mac users.

## The Limits of Reproducibility

Reproducibility inevitably breaks down at certain scales.
There are irreproducible parts of this project, that have to be taken on faith. The data provided by SANParks are taken on authority, as being from a trusted source. Similarly, it would impossible to reproduce the primary data collection, such as which elephants were captured and fitted with transmitters.
These data are taken on faith from the original researchers, highlighting the role of trust in the scientific community.

Code too is not exempt from reproducibility limits. For instance, restoring the `renv` lockfile is very difficult without an internet connection, as packages may need to be downloaded. In ten years, code in R or another language may no longer be reproducible due to software and hardware changes, as many researchers found in the 10-year reproducibility challenge. The raster processing in Python, using Google Earth Engine, is dependent on Google maintaining this service.

I would advocate for a pragmatic view of reproducibility, in which code:
1. Is treated as a documentation of methods that should be scrutinised just as the written text of a paper is (both for being appropriate code, as well as questionable practices),
2. Is expected to be reproducible at a timescale that matters to the research.
For instance, a code pipeline that must routinely output updated results using different datasets should be reproducible.

Overall, the main beneficiaries of reproducible code are the researcher, and the researcher's future self. As many readers will know, much time can be saved if code written 6 months or a few years ago can be made to run successfully and repurposed to a new task. 
