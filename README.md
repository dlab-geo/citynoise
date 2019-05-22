# 500 Cities Noise Project

This site contains code and maps from the 500 Cities Noise Project.

To view the map open this url in your browser: [https://dlab-geo.github.io/dnlproj/](https://dlab-geo.github.io/dnlproj/)


## About the Map 

The noise map displays census tract level estimates of noise, categorized as below, slightly exceeding, and exceeding the U.S. EPA day-night average sound level (DNL) limit of <55 decibels (dB). Points (census tract centroids) display values in the small-scale map and census tract boundaries appear when the user zooms in to a specific city.


## A bit about the noise data:

The noise exposure data was obtained from a geospatial model of environmental sound levels derived from empirical acoustical data and modeling of land features (topography, climate, hydrology, and anthropogenic activity) (Mennitt and Fristrup 2016). We have previously used this model in a nationwide environmental justice analysis (Casey et al. 2017). Noise exposures were estimated from a random forest model that utilizes a tree-based machine learning algorithm to combine spatial data with over 1.5 million hours of long-term noise measurements at 492 urban and rural sites in the contiguous U.S. from 2000–2014 to produce ambient sound estimates at a 270m resolution. Complete information on explanatory variables in the model are provided by the National Park Service (Sherrill 2012). The model has been shown to perform well under cross-validation tests, with a median absolute deviation of 1.7 dB in urban areas (Casey et al. 2017). The main map provides low, medium, and high cut-points based on cross-sectional day-night average sound (DNL), 24-hour average noise with penalties added for evening and nighttime noise. We also display average nighttime noise, L50, night, where night is defined as 22:00–7:00 hours with low, medium, and high cut-points that correspond to the levels below, slightly exceeding, and exceeding the World Health Organization (WHO) recommended nighttime noise level of 40 dB. The WHO recommends nighttime Leq fall below 40 dB. They describe 40 dB as the lowest observable adverse effect level for nighttime noise (WHO 2011).

 

REFERENCES

Casey JA, Morello-Frosch R, Mennitt DJ, Fristrup K, Ogburn EL, James P. 2017. Race/ethnicity, socioeconomic status, residential segregation, and spatial variation in noise exposure in the contiguous United States. Environ Health Perspect 125(7):077017. 10.1289/EHP898.

Mennitt DJ, Fristrup KM. 2016. Influence factors and spatiotemporal patterns of environmental sound levels in the contiguous United States. Noise Control Eng J 64(3):342-353.

Sherrill K. 2012. GIS Metrics - Soundscape Modeling, Standard Operating Procedure. Natural Resource Report NPS/NRSS/IMD/NRR—2012/596. Fort Collins, Colorado:National Park Service. Available:  http://irmafiles.nps.gov/reference/holding/460450 [accessed 09 Jan 2017].

World Health Organization. 2011. Burden of Disease From Environmental Noise. Available: http://www.euro.who.int/__data/assets/pdf_file/0008/136466/e94888.pdf accessed [14 Jul 2015].
