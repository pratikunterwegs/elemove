#!/usr/bin/env python
# coding: utf-8

# <a href="https://colab.research.google.com/github/pratikunterwegs/elemove/blob/master/temp_kruger.ipynb" target="_parent"><img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/></a>

# In[ ]:


import subprocess

try:
    import geemap
except ImportError:
    print('geemap package not installed. Installing ...')
    subprocess.check_call(["python", '-m', 'pip', 'install', 'geemap'])

# Checks whether this notebook is running on Google Colab
try:
    import google.colab
    import geemap.eefolium as geemap
except:
    import geemap

# Authenticates and initializes Earth Engine
import ee

try:
    ee.Initialize()
except Exception as e:
    ee.Authenticate()
    ee.Initialize()


# In[38]:


geometry = ee.Geometry.Polygon(
        [[[77.26686452041235, 13.344492655458648],
          [77.26803063514615, 12.69020162411501],
          [78.31220864869454, 12.698000169170149],
          [78.31998125667042, 13.342950249131635]]])
table = ee.FeatureCollection("users/pratik_unterwegs/ele_ext")
table2 = ee.FeatureCollection("users/pratik_unterwegs/kruger_clip")
l5 = ee.ImageCollection("LANDSAT/LT05/C01/T1_SR")

## define function to clip and process
def get_temp(image):
    temp = image.select('B6')
    temp_clip = temp.clip(table)
    temp_clip = temp_clip.divide(10)
    temp_clip = temp_clip.subtract(273).rename('temp')
    return image.addBands([temp_clip])


# start and end data
start_date = '2007-08-01'
end_date = '2009-08-30'

# filter landsat 5 data for time, cloud cover, and thermal band
l5_filtered = l5.filterBounds(table.geometry())
l5_filtered_date = l5_filtered.filterDate('2007-08-01', '2009-08-30')
l5_filtered_clouds = l5_filtered_date.filterMetadata('CLOUD_COVER', 'less_than', 10)

# map get temp over iamges
l5_temp = l5_filtered_clouds.map(get_temp)
l5_temp_mean = l5_temp.select('temp').mean()


# In[45]:


# var rgb_viz = {min: 20, max: 35, bands:['B6'],
#   palette: ["#0D0887FF", "#4C02A1FF", "#7E03A8FF", "#A92395FF", "#CC4678FF", 
#             "#E56B5DFF","#F89441FF", "#FDC328FF", "#F0F921FF"]
# };
sld_ramp =   '<RasterSymbolizer>' +     '<ColorMap type="ramp" extended="false" >' +       '<ColorMapEntry color="#0000FF" quantity="20" label="0"/>' +       '<ColorMapEntry color="#FFFF00" quantity="30" label="300" />' +       '<ColorMapEntry color="#FF0000" quantity="40.5" label="500" />' +     '</ColorMap>' +   '</RasterSymbolizer>';

# print layers
# vis = {'bands': ['temp']}
Map = geemap.Map(center=[-24.1005, 31.9], zoom=10)
Map.addLayer(l5_temp_mean.sldStyle(sld_ramp), {}, 'temp')
# # Map.addLayer(table2)
Map.addLayerControl()

Map


# In[46]:


# export image to drive
geemap.ee_export_image_to_drive(l5_temp_mean, description='kruger_landsat5_temp', folder='kruger_landsat5', region=table.geometry(), scale=30)

