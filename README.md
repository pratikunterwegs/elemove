
# Kruger Elephant Movement

![](https://github.com/pratikunterwegs/elemove/blob/master/figures/fig_map_wide.png)

## About this project and data

### Movement data
This dataset tracks 14 adult female elephants over some 2 years in Kruger National Park, South Africa, and has been used for a number of projects, including seasonal movements, movement in response to fire, and in response to the thermal landscape.

These projects were led by [Rob Slotow*](https://www.ucl.ac.uk/biosciences/people/professor-rob-slotow), [Maria Thaker](https://mariathaker.weebly.com/), and [Abi Vanak](https://www.atree.org/users/dr-abi-tamim-vanak). See the data access section for citation details.

I worked on this data in 2017 -- 2018 while a research assistant with Maria Thaker and Abi Vanak at CES, IISc, and ATREE, in Bangalore, India.
I also uploaded the data to Movebank in 2018, and together with Candace Vinciguerra from _Movebank_, published the dataset under the project leaders' names in the data repository. The data now forms part of the _Movebank_ homepage animation, which is very cool to see.

### Landscape data

I used LANDSAT 5's surface reflectance product (band 6) to get the morning temperature over Kruger. The final single-raster data layers is the two year mean, with cloud cover removed. Landsat 5 has anomalies in its images which are fortunately not over Kruger, or at least don't affect scenes over Kruger too much. By my calculations (in 2018), Landsat 5 passed over Kruger at around 9 am in the morning, every two weeks or so. I might be mistaken.

Other landscape data (waterholes and Kruger boundary) were provided by Maria Thaker and Abi Vanak, originally from SANParks.

I accessed the rivers from OpenStreetMap, and show only the non-seasonal rivers (as determined by OSM contributors).

## Movement data access

The tracking dataset collected for use in this work is available from Movebank: https://doi.org/10.5441/001/1.403h24q5 and can be cited as

Slotow R, Thaker M, Vanak AT (2019) Data from: Fine-scale tracking of ambient temperature and movement reveals shuttling behavior of elephants to water. Movebank Data Repository. doi:10.5441/001/1.403h24q5

## Published work

This dataset was used in Thaker M, Gupte PR, Prins HHT, et al (2019) Fine-Scale Tracking of Ambient Temperature and Movement Reveals Shuttling Behavior of Elephants to Water. Front Ecol Evol 7:. doi: 10.3389/fevo.2019.00004

Link to the paper: [Thaker, Gupte, et al. (2019)](https://www.frontiersin.org/articles/10.3389/fevo.2019.00004/full)

---

* Rob Slotow's page at UKZN (and UKZN pages generally) appear to be down.
