
# Mapping Animal Movement: Art and Reproducibility

## Introduction

In December 2020 I was pointed to the BES Mapping Animal Movements Contest, and the "R Map" category stood out to me.
I decided to enter a map made showing the movement of 14 savanna elephants _Loxodonta africana_ tagged in Kruger National Park, South Africa.

This data was part of the postdocs of [Maria Thaker](https://mariathaker.weebly.com/) and [Abi Vanak](https://www.atree.org/users/dr-abi-tamim-vanak), for whom I worked between my masters and my PhD.
Together with Rob Slotow and Herbert Prins, we wrote a [paper about how Kruger elephants move in response to temperature](https://www.frontiersin.org/articles/10.3389/fevo.2019.00004/full).

The source code and the figures can be found here: https://github.com/pratikunterwegs/elemove

## About the Map and AM253

The map highlights the path of the female elephant _AM253_ (the tag number), whose tag transmitted between August 2007 and December 2008; one position every thirty minutes. Some of the thirteen other elephants are also shown to give a sense of how densely Kruger is criss-crossed by elephant herds.

The background layer is a raster representing the average temperature sensed by the LANDSAT-5 satellite over the two year period of this study.
The map has three other vector features: the perennial rivers, the locations of waterholes, and the boundary of Kruger.

I wanted to show these extra layers because they are important to the story we were trying to tell. The temperature layer conveys that the 'thermal landscape' of Kruger is quite variable; the warmer areas might represent significant constraints to large mammals.

The rivers and waterholes are almost literal oases: large mammals can visit these, replenish water stores, and attempt to move into or through warmer areas, where thermoregulatory water loss is likely to be a serious issue.

## Mapping as Exploratory Data Analysis

Mapping animal movements is a key component of exploratory data analysis.

<!-- At the large scale, simply dividing a study area into grid cells and counting the number of animal locations in each cell can reveal where one or more tracked animals spends its time. -->

It's also important to plot lines 'joining the dots' between animal positions. Large tracking datasets can contain errors that are only evident to researchers when they look at an approximation of the animal's path and ask, ["Does the animal move this way?"](https://wildlife.onlinelibrary.wiley.com/doi/abs/10.1111/j.1937-2817.2010.tb01258.x)

In the raw elephant dataset, the projection from geographic coordinates to UTM coordinates had gone wrong for some elephants. This was not evident when examining the locations as positions, but was obvious once the points were joined by lines.

Mapping can also reveal interesting behaviours that can only be observed after significant effort in the field.
For instance, the 'looping' behaviour of AM253 to water sources is the focus of this map.

<!-- While we looked into whether this indicated strong individual preferences for one water source over another, we found this was not so.
Rather, this is likely the outcome of environmental constraints; the heavily visited points were probably the only available water sources. -->

Seeing this looping behaviour allowed us to focus our study on elephant movements between visits to water sources.
We recognised that we should segment the data by these visits, because we could at least guess at their function: to access water, or resources found near water.

This led to us being able to show that elephants move nearly twice when arriving at, or leaving water sources, than when they are not immediately in transit to water.

## Mapping as Art

Maps make for great art, but making 'beautiful' maps is difficult, not least because appeal is subjective.
As with many other areas of science (other than primary data collection, please!): when in doubt, copy.

Growing up in early 2000s India, I read hard copies of _National Geographic Magazine_, which has long had fantastic graphics.
During my master's, I was introduced to the _art_ of mapping by James Cheshire at the Animove Summer School. James' book with Oliver Uberti, [_Where the Animals Go_](http://wheretheanimalsgo.com/) was a source of inspiration as well.

I picked up other tips and tricks from knowing something of art generally: build up an image in layers, use colours that don't clash, highlight the phenomenon of interest.
Interestingly, some of these approaches are very much in line with the ['grammar of graphics' approach of ggplot`](https://vita.had.co.nz/papers/layered-grammar.html), which I used to make this map.

## Mapping in R

### Getting temperature data aka Flirting with Python

I used LANDSAT-5 for the temperature layer because it was the appropriate satellite for the time period (2007), and had a decent spatial resolution (30 metres). This data excludes periods when Kruger was mostly covered by clouds. The temperature layer is also a spatial composite, i.e., it is formed by stitching together multiple LANDSAT-5 'scenes'; Kruger lies at the juncture of three scenes.

I used [Google Earth Engine (GEE)](https://earthengine.google.com/) to acquire this data; GEE performs this stitching, as well as the averaging of the multiple scenes taken over two years (approximately once per fortnight). The heavy computation happens on the GEE servers, significantly increasing speed. By collecting these data for use at one point, GEE also improves data accessibility.

I used Python to get the LANDSAT-5 data from Google Earth Engine, using the `ee` package, which is [the Python GEE API package](https://developers.google.com/earth-engine/guides/python_install). The [`rgee` R package](https://r-spatial.github.io/rgee/) provides a similar functionality from within R, but uses `reticulate` to interface with `ee`. I cut out the middleman, as it were, and used `ee` directly.

I found Qiusheng Wu's [`geemap` package](https://github.com/giswqs/geemap) a great tool for visualisation of the data I was working with, and the associated tutorials a very good resource for help with `ee` generally.

### Getting elephants and boundaries

In 2019, Candice Vinciguerra from Movebank had helped me publish the data on the [Movebank data repository](https://www.movebank.org/cms/movebank-main) (It now forms part of the animation on the starting page).
Getting the data was thus very easy using the `move` package, which I then saved as a geopackage.

<!-- I converted the `Movestack` object into an `sf` `LINESTRING` object using a series of simple inline functions. I saved the `sf` object as a geopackage, which is more convenient than a shapefile in that there's only one file to keep track of. -->

The river course data was also easy to acquire, using the [`osmdata` package](https://docs.ropensci.org/osmdata/), which queries and retrieves data from the OpenStreetMap database. The boundaries of Africa and South Africa were equally easily obtained using the [`rnaturalearth` package](https://docs.ropensci.org/rnaturalearth/).
The Kruger boundary and the locations of waterholes were provided during my work on this project, and originally come from the South African National Park service.


### Choosing Tools

R's great advantage over other languages is visualisaton. The two main mapping packages in R are `ggplot2` and `tmap`. `ggplot`'s emergence as a mainstay of spatial visualisation is due to its `geom_sf` function, which can handle `sf` spatial objects.

One of `ggplot`'s advantage's is its many extensions. Here, I used the [`ggspatial`](https://github.com/paleolimbot/ggspatial/) and [`ggtext`](https://github.com/wilkelab/ggtext) extension packages to add the scale bars and north arrow, and to add the text box, respectively.

Plotting rasters is not straightforward in `ggplot`. There are two main options: the [`stars` package](https://r-spatial.github.io/stars/) and its associated `geom_stars`, or converting a raster dataset into a dataframe with regular coordinate intervals and using `geom_tile`.

Here, I chose the second approach because I'm an infrequent `stars` user; since making the map I've tried `geom_stars` which works just as well, and is very convenient.

### Choosing Colours

I coloured the temperature raster using the [`scico` package's](https://github.com/thomasp85/scico) 'VikO' palette. I tried out a number of palettes from the `scico`, `pals` (providing the [Kovesi palettes](https://peterkovesi.com/projects/colourmaps/)), `RColorBrewer`, and `colorspace` packages, choosing VikO because of its aesthetic appeal.

I chose a diverging palette to indicate relative extremes of the thermal landscape; that there are areas significantly warmer and cooler than the mean. This approach is not to be recommended for material that will be printed in grayscale.

I also chose colours for the tracks and waterholes from the `scico` package, and colours for the background and other elements to (1) convey the sense of a semi-arid environment, and (2) gel well with the main colours I had already chosen.

### Setting the Context with Insets

Insets set the context for a map. I specifically chose a minimalist inset to show the location of the study area in Africa generally, and South Africa in particular. I chose to show the full elephant data in the inset to give an honest idea of how much data I was showing in the main map, and what was being left out.

I added a grey layer over the areas of the map beyond the boundaries of Kruger. While these areas are functionally quite similar, and elephant use them frequently, I thought it was important to show the distinction.

The grey borders around the map are a result of the area I wanted to show not fitting a 16:9 aspect ratio, a common ratio for computer screens. To avoid unsightly white areas, I chose a shade of grey to match the grey screen I had placed over the areas outside Kruger.

## Reproducibility in R

I adopted a relatively relaxed understanding of reproducibility: given the data, the code would be reproducible if it could produce the map I had entered for this contest. To do this, I set up a continuous integeration/deployment pipeline using [Github Actions (GHA)](https://github.com/features/actions).

First, I created an RStudio project in the folder where I was working. Using a project anchors R to the project directory, which is set as the working directory.

Using the [`usethis` package, I created a `DESCRIPTION` file](https://www.rostrum.blog/2020/08/09/ghactions-pkgs/), which is usually reserved for packages. This file tricks GHA into reading its contents, especially the dependencies, i.e., the R packages required by the project.

GHA automatically reads the dependencies and installs them, as well as the programs required by those dependencies. For instance, GDAL (the Geospatial Data Abstraction Library) is key to nearly all spatial analyses, and is installed as a requirement of the `rgdal` package, which is itself key to `sf` and `raster`.

I used the R package [`renv`](https://rstudio.github.io/renv/) to make sure that the packages (and the package versions) I used are available to the pipeline. `renv` creates a lockfile, a registry of packages the current project uses, from which those packages can be installed.

Finally, to check whether the entire pipeline works, I used `bookdown`. This R package is really for making HTML or PDF documents, but works equally well for sequentially executing a series of Rmarkdown files. An obvious alternative is `rmarkdown`.

GHA runs this pipeline every time I upload changes to Github, and reports whether the code ran successfully, and if not, where it failed (you can see this reports [here](https://github.com/pratikunterwegs/elemove/actions)).
GHA runs the pipeline on Linux, Windows, and Mac containers. This means that though I use Linux, I'm pretty sure that this code works for Windows and Mac users.

## The Limits of Reproducibility

Reproducibility inevitably breaks down at certain scales.
There are irreproducible parts of this project, that have to be taken on faith. The data provided by SANParks are taken on authority, as being from a trusted source.

Similarly, it would impossible to reproduce the primary data collection, such as which elephants were captured and fitted with transmitters.
These data are taken on faith from the original researchers, highlighting the role of trust in the scientific community.

Code too is not exempt from reproducibility limits. For instance, restoring the `renv` lockfile is very difficult without an internet connection, as packages may need to be downloaded.

In ten years, code in R or another language may no longer be reproducible due to software and hardware changes, as many researchers found in the [10-year reproducibility challenge](https://www.nature.com/articles/d41586-020-02462-7). The raster processing in Python, using Google Earth Engine, is dependent on Google maintaining this service.

Researchers then, should be pragmatic about reproducibility. Who is it for --- the researcher themselves, the reviewers of their manuscript, their students, their funders --- to whom is this effort owed, and by whom? These are issues --- that this effort disproportionately falls upon early career researchers and is rarely rewarded, that open source code generally seems to have even less diversity than the rest of programming [(1)](https://www.wired.com/2017/06/diversity-open-source-even-worse-tech-overall/), [(2)](https://www.pnas.org/content/117/39/24154) --- that need to be addressed.
