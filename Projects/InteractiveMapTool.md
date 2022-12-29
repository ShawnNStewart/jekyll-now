---
layout: post
title: Interactive Map Generator
---
For my fall 2022 Python Programming course (EPPS 6317), we were tasked with creating a tool using what we had learned about Python. The goal was to create a reusable script. For my project, I created a script in Jupyter Notebook that could be used to take a file input, generate an interactive map, and allow the user to name and save it as an HTML file to be included on the ISSO website. For more details, see the [readme file](https://shawnnstewart.github.io/Projects/InteractiveMapToolreadme). 

# Interactive Map
*Updated 12/10/2022*
*Author: Shawn Stewart*

Every year after fall census day, we use the OSPA report to update our fact sheets, data for Open Doors, and other resources. We will use this same data to update our interactive map on our website. This program will take the OSPA data, process it, and generate an HTML map that can be embedded on the ISSO webpage. 

First, get the OSPA data in CSV format and save it to your computer. 

Then, run each cell below by typing "shift + enter" and enter information as prompted. **It is important to run the cells in order.**

You will be asked to select a file (the csv OSPA report you  just saved) and enter a name for your final output, as well as a directory to save it in. 

### Import modules
This cell sets up the libraries required to run the code. Press "shift + enter" to continue. 


```python
import geopandas
#import fiona
import folium 
from folium.plugins import MarkerCluster
import pandas as pd
import geopandas as gpd
import requests
import json
import tkinter as tk
from tkinter import filedialog
# include this, otherwise an empty box will remain on screen after selecting file
root = tk.Tk()
root.withdraw()
import re
import os
%matplotlib inline
```

### File input


```python
# prompt user to select file, limited to only csv files
file = filedialog.askopenfilename(filetypes=[("csv files", "*.csv")])
```

### Read in the data


```python
# check that the user entered a file. If not, prompt again.
while not file:
    print("You must choose a file to continue")
    file = filedialog.askopenfilename(filetypes=[("csv files", "*.csv")])
# read in the data
df = pd.read_csv(file)
# keep only the columns we care about, and keep only records for F visas.
df = (df[["COUNTRY_DESC_PS", "GENDER", 
          "ACAD_PROG", "ACAD_GROUP", 
          "ACAD_PLAN_DESC", "OPT", "VISA_CATEGORY"]]
      .loc[df.VISA_CATEGORY == "F"])
# get list of unique countries to pass to API
country_list = set(df["COUNTRY_DESC_PS"])
```

### Get longitude/latitude from Nominatim API
This can take a few minutes. If there is an asterisk next to the code block, it's running.

See the Nominatim API documentation for more details on how the search query is structured - https://nominatim.org/release-docs/develop/api/Search/


```python
# create new data frame with long/lat for each country using Nominatim API
# set base URL
base_url = "https://nominatim.openstreetmap.org/search"

# create country dictionary
country_list_dicts = []

# run through each country, getting long/lat for each
for country in country_list:
    # set search parameters
    search_params = {"country": country,
                     "format": "json",
                     # Nominatim requires an email to track usage.
                     "email": "ICTechTeam@utdallas.edu"}
    # make request
    r = requests.get(base_url, params=search_params)
    response_text = r.text
    data = json.loads(response_text)

    try:
       # create a new dictionary for that country
        dict = {"COUNTRY_DESC_PS": country,
                "longitude": data[0]["lon"],
                "latitude": data[0]["lat"]}
        # add it to list of dictionaries
        country_list_dicts.append(dict)

    except:
        pass
    
```


```python
# turn the list of dictionaries into a pandas dataframe
countries = pd.DataFrame(country_list_dicts)

# merge with dataframe with all student information
df_geo = pd.merge(df, countries, on="COUNTRY_DESC_PS")
```

### Create the map


```python
# generate a map that shows the whole world.
m = folium.Map(location=[20, 0], zoom_start=1.5, tiles="OpenStreetMap")
```


```python
# add our data to the map as points
for i in range(0,len(countries)):
        # set variable to check that country matches
        match_country = (df["COUNTRY_DESC_PS"] == countries.loc[i]["COUNTRY_DESC_PS"])
        # set all your variables
        lat = countries.loc[i]['latitude']
        long = countries.loc[i]['longitude']
        # create summmaries from main dataframe, counts of different categories
        # note, pep8 says lines too long, but leaving as is
        total = int(df[(df["COUNTRY_DESC_PS"] == countries.loc[i]["COUNTRY_DESC_PS"])]
                    .count()["COUNTRY_DESC_PS"])
        male = df[match_country & (df["GENDER"] == "M")].count()["GENDER"]
        female = df[match_country & (df["GENDER"] == "F")].count()["GENDER"]
        ugrd = df[match_country & (df["ACAD_PROG"] == "UGRD")].count()["ACAD_PROG"]
        ms = df[match_country & (df["ACAD_PROG"] == "MASTR")].count()["ACAD_PROG"]
        phd = df[match_country & (df["ACAD_PROG"] == "DOCT")].count()["ACAD_PROG"]
        opt = df[match_country & (df["OPT"] == "Y")].count()["OPT"]
        # set radius, so countries with more students get bigger circles
        radius = 1300*(total)
        # adjust the radius size to make the largest countries smaller
        # otherwise they overwhelm the visualization
        if radius > 5000000:
            radius = 150*(total)
        elif radius > 900000:
            radius = 500*(total)
        elif radius < 60000:
            radius = 60000
        # create hover tooltip to show country name
        tooltip_text = countries.loc[i]["COUNTRY_DESC_PS"]
        # set pop up text formatting and labels
        popup_text = """<h4>{}</h4><br>
                    <b>Count</b>: {}<br><br>
                    <b>Undergraduates</b>: {}<br>
                    <b>Master's</b>: {}<br>
                    <b>Doctoral</b>: {}<br><br>
                    <b>On OPT</b>: {}<br><br>
                    <b>Male</b>: {}<br>
                    <b>Female</b>: {}<br>
                    """
        # set pop up text variables
        popup_text = popup_text.format(countries.iloc[i]['COUNTRY_DESC_PS'],
                                       total,
                                       ugrd,
                                       ms,
                                       phd,
                                       opt,
                                       male,
                                       female)
        # generate the circle markers, populating with variables set in loop
        folium.Circle(location=[lat, long],
                      radius=radius,
                      tooltip=tooltip_text,
                      popup=popup_text,
                      fill=True).add_to(m)
```


```python
# preview the map here
m
```




<div style="width:100%;"><div style="position:relative;width:100%;height:0;padding-bottom:60%;"><span style="color:#565656">Make this Notebook Trusted to load map: File -> Trust Notebook</span><iframe srcdoc="&lt;!DOCTYPE html&gt;
&lt;head&gt;    
    &lt;meta http-equiv=&quot;content-type&quot; content=&quot;text/html; charset=UTF-8&quot; /&gt;

        &lt;script&gt;
            L_NO_TOUCH = false;
            L_DISABLE_3D = false;
        &lt;/script&gt;

    &lt;style&gt;html, body {width: 100%;height: 100%;margin: 0;padding: 0;}&lt;/style&gt;
    &lt;style&gt;#map {position:absolute;top:0;bottom:0;right:0;left:0;}&lt;/style&gt;
    &lt;script src=&quot;https://cdn.jsdelivr.net/npm/leaflet@1.6.0/dist/leaflet.js&quot;&gt;&lt;/script&gt;
    &lt;script src=&quot;https://code.jquery.com/jquery-1.12.4.min.js&quot;&gt;&lt;/script&gt;
    &lt;script src=&quot;https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js&quot;&gt;&lt;/script&gt;
    &lt;script src=&quot;https://cdnjs.cloudflare.com/ajax/libs/Leaflet.awesome-markers/2.0.2/leaflet.awesome-markers.js&quot;&gt;&lt;/script&gt;
    &lt;link rel=&quot;stylesheet&quot; href=&quot;https://cdn.jsdelivr.net/npm/leaflet@1.6.0/dist/leaflet.css&quot;/&gt;
    &lt;link rel=&quot;stylesheet&quot; href=&quot;https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css&quot;/&gt;
    &lt;link rel=&quot;stylesheet&quot; href=&quot;https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css&quot;/&gt;
    &lt;link rel=&quot;stylesheet&quot; href=&quot;https://maxcdn.bootstrapcdn.com/font-awesome/4.6.3/css/font-awesome.min.css&quot;/&gt;
    &lt;link rel=&quot;stylesheet&quot; href=&quot;https://cdnjs.cloudflare.com/ajax/libs/Leaflet.awesome-markers/2.0.2/leaflet.awesome-markers.css&quot;/&gt;
    &lt;link rel=&quot;stylesheet&quot; href=&quot;https://cdn.jsdelivr.net/gh/python-visualization/folium/folium/templates/leaflet.awesome.rotate.min.css&quot;/&gt;

            &lt;meta name=&quot;viewport&quot; content=&quot;width=device-width,
                initial-scale=1.0, maximum-scale=1.0, user-scalable=no&quot; /&gt;
            &lt;style&gt;
                #map_1a5a9d7afe5e8792bab5cb12da30d363 {
                    position: relative;
                    width: 100.0%;
                    height: 100.0%;
                    left: 0.0%;
                    top: 0.0%;
                }
            &lt;/style&gt;

&lt;/head&gt;
&lt;body&gt;    

            &lt;div class=&quot;folium-map&quot; id=&quot;map_1a5a9d7afe5e8792bab5cb12da30d363&quot; &gt;&lt;/div&gt;

&lt;/body&gt;
&lt;script&gt;    

            var map_1a5a9d7afe5e8792bab5cb12da30d363 = L.map(
                &quot;map_1a5a9d7afe5e8792bab5cb12da30d363&quot;,
                {
                    center: [20.0, 0.0],
                    crs: L.CRS.EPSG3857,
                    zoom: 1.5,
                    zoomControl: true,
                    preferCanvas: false,
                }
            );





            var tile_layer_7a16d9e3d017b6238aa6da228c5cb70f = L.tileLayer(
                &quot;https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png&quot;,
                {&quot;attribution&quot;: &quot;Data by \u0026copy; \u003ca href=\&quot;http://openstreetmap.org\&quot;\u003eOpenStreetMap\u003c/a\u003e, under \u003ca href=\&quot;http://www.openstreetmap.org/copyright\&quot;\u003eODbL\u003c/a\u003e.&quot;, &quot;detectRetina&quot;: false, &quot;maxNativeZoom&quot;: 18, &quot;maxZoom&quot;: 18, &quot;minZoom&quot;: 0, &quot;noWrap&quot;: false, &quot;opacity&quot;: 1, &quot;subdomains&quot;: &quot;abc&quot;, &quot;tms&quot;: false}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


            var circle_997a2e09fedbba280b9104ffb663eb12 = L.circle(
                [49.4871968, 31.2718321],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_09634f0b0b6d1a0cf626f998782f54cf = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_d438cfb17e9eb8c8725ecf002acc0817 = $(`&lt;div id=&quot;html_d438cfb17e9eb8c8725ecf002acc0817&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Ukraine&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_09634f0b0b6d1a0cf626f998782f54cf.setContent(html_d438cfb17e9eb8c8725ecf002acc0817);



        circle_997a2e09fedbba280b9104ffb663eb12.bindPopup(popup_09634f0b0b6d1a0cf626f998782f54cf)
        ;




            circle_997a2e09fedbba280b9104ffb663eb12.bindTooltip(
                `&lt;div&gt;
                     Ukraine
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_6d32c44d07c12ae1cda6883dd09af764 = L.circle(
                [53.4250605, 27.6971358],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_3ba0cb17cb027edc836b1cbf8e8de21e = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_6cfab308bf74331911d4cb64d5a5005d = $(`&lt;div id=&quot;html_6cfab308bf74331911d4cb64d5a5005d&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Belarus&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_3ba0cb17cb027edc836b1cbf8e8de21e.setContent(html_6cfab308bf74331911d4cb64d5a5005d);



        circle_6d32c44d07c12ae1cda6883dd09af764.bindPopup(popup_3ba0cb17cb027edc836b1cbf8e8de21e)
        ;




            circle_6d32c44d07c12ae1cda6883dd09af764.bindTooltip(
                `&lt;div&gt;
                     Belarus
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_3b19f39b3ef26731efd6ac4488de4fca = L.circle(
                [33.8750629, 35.843409],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_476b4e4d8f2e1972a2f71fc83a45c675 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_0ebee4e1636df44850f149b84ffe1e45 = $(`&lt;div id=&quot;html_0ebee4e1636df44850f149b84ffe1e45&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Lebanon&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 2&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_476b4e4d8f2e1972a2f71fc83a45c675.setContent(html_0ebee4e1636df44850f149b84ffe1e45);



        circle_3b19f39b3ef26731efd6ac4488de4fca.bindPopup(popup_476b4e4d8f2e1972a2f71fc83a45c675)
        ;




            circle_3b19f39b3ef26731efd6ac4488de4fca.bindTooltip(
                `&lt;div&gt;
                     Lebanon
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_ef825bcb57df62e02acfabb4bcd3076d = L.circle(
                [42.6073975, 25.4856617],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_73eca67056c7719aee74cccd1cb28438 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_c539d1eb4e839ef4bb5e840203084d3b = $(`&lt;div id=&quot;html_c539d1eb4e839ef4bb5e840203084d3b&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Bulgaria&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_73eca67056c7719aee74cccd1cb28438.setContent(html_c539d1eb4e839ef4bb5e840203084d3b);



        circle_ef825bcb57df62e02acfabb4bcd3076d.bindPopup(popup_73eca67056c7719aee74cccd1cb28438)
        ;




            circle_ef825bcb57df62e02acfabb4bcd3076d.bindTooltip(
                `&lt;div&gt;
                     Bulgaria
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_0018ad2220e28be8a111f45b0773213e = L.circle(
                [15.2572432, -86.0755145],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_bf3279be69b233f3198d1f753be348e5 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_4fea9298065b0016f9f2daee3b1568d4 = $(`&lt;div id=&quot;html_4fea9298065b0016f9f2daee3b1568d4&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Honduras&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_bf3279be69b233f3198d1f753be348e5.setContent(html_4fea9298065b0016f9f2daee3b1568d4);



        circle_0018ad2220e28be8a111f45b0773213e.bindPopup(popup_bf3279be69b233f3198d1f753be348e5)
        ;




            circle_0018ad2220e28be8a111f45b0773213e.bindTooltip(
                `&lt;div&gt;
                     Honduras
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_2697f9344f4c777824372eb4bd34147f = L.circle(
                [15.9266657, 107.9650855],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 204100, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_d13b9735ecdabce547b94adff12fff66 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_915a9903d7f103e629d93e72fa3e6c56 = $(`&lt;div id=&quot;html_915a9903d7f103e629d93e72fa3e6c56&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Viet Nam&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 157&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 96&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 50&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 10&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 45&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 87&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 70&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_d13b9735ecdabce547b94adff12fff66.setContent(html_915a9903d7f103e629d93e72fa3e6c56);



        circle_2697f9344f4c777824372eb4bd34147f.bindPopup(popup_d13b9735ecdabce547b94adff12fff66)
        ;




            circle_2697f9344f4c777824372eb4bd34147f.bindTooltip(
                `&lt;div&gt;
                     Viet Nam
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_4ad7b8d85f230255526061f96b1f0660 = L.circle(
                [26.2540493, 29.2675469],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_d77459d51eff3e33542cf6639d394e06 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_7697c4e7d23b9089a78e9fa6f4ab2db5 = $(`&lt;div id=&quot;html_7697c4e7d23b9089a78e9fa6f4ab2db5&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Egypt&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 15&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 4&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 8&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 5&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 12&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 3&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_d77459d51eff3e33542cf6639d394e06.setContent(html_7697c4e7d23b9089a78e9fa6f4ab2db5);



        circle_4ad7b8d85f230255526061f96b1f0660.bindPopup(popup_d77459d51eff3e33542cf6639d394e06)
        ;




            circle_4ad7b8d85f230255526061f96b1f0660.bindTooltip(
                `&lt;div&gt;
                     Egypt
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_53d7148066785c3d5326d9794a5e5fce = L.circle(
                [-18.4554963, 29.7468414],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_4b60b4f2abe961b4a35a590e47021331 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_3b64705e2fd221af853e55e9d961c59f = $(`&lt;div id=&quot;html_3b64705e2fd221af853e55e9d961c59f&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Zimbabwe&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_4b60b4f2abe961b4a35a590e47021331.setContent(html_3b64705e2fd221af853e55e9d961c59f);



        circle_53d7148066785c3d5326d9794a5e5fce.bindPopup(popup_4b60b4f2abe961b4a35a590e47021331)
        ;




            circle_53d7148066785c3d5326d9794a5e5fce.bindTooltip(
                `&lt;div&gt;
                     Zimbabwe
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_a72a129593bbd181cb60a605cfdc4ead = L.circle(
                [54.7023545, -3.2765753],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_c5be297a3e428d52efafcbe0b8b23d47 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_88cb7313ca1178f4354751d7e969f5ba = $(`&lt;div id=&quot;html_88cb7313ca1178f4354751d7e969f5ba&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;United Kingdom&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 4&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_c5be297a3e428d52efafcbe0b8b23d47.setContent(html_88cb7313ca1178f4354751d7e969f5ba);



        circle_a72a129593bbd181cb60a605cfdc4ead.bindPopup(popup_c5be297a3e428d52efafcbe0b8b23d47)
        ;




            circle_a72a129593bbd181cb60a605cfdc4ead.bindTooltip(
                `&lt;div&gt;
                     United Kingdom
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_f577fbd65b5bf7c1cb7f9b3461b47453 = L.circle(
                [45.9852129, 24.6859225],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_a105dd6ec8c15019d9603dc0068f3c28 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_f840a405f23da008f96569a4e07cf7aa = $(`&lt;div id=&quot;html_f840a405f23da008f96569a4e07cf7aa&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Romania&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 4&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 2&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_a105dd6ec8c15019d9603dc0068f3c28.setContent(html_f840a405f23da008f96569a4e07cf7aa);



        circle_f577fbd65b5bf7c1cb7f9b3461b47453.bindPopup(popup_a105dd6ec8c15019d9603dc0068f3c28)
        ;




            circle_f577fbd65b5bf7c1cb7f9b3461b47453.bindTooltip(
                `&lt;div&gt;
                     Romania
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_5f15ce8fdc7d529d0ed3759ff8eb6a49 = L.circle(
                [24.4769288, 90.2934413],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 192400, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_49dff12b407d0f0abd4816437fe4b0e0 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_5bdf6f79664699adb393dd2ad8bf65e1 = $(`&lt;div id=&quot;html_5bdf6f79664699adb393dd2ad8bf65e1&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Bangladesh&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 148&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 26&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 25&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 97&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 34&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 101&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 47&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_49dff12b407d0f0abd4816437fe4b0e0.setContent(html_5bdf6f79664699adb393dd2ad8bf65e1);



        circle_5f15ce8fdc7d529d0ed3759ff8eb6a49.bindPopup(popup_49dff12b407d0f0abd4816437fe4b0e0)
        ;




            circle_5f15ce8fdc7d529d0ed3759ff8eb6a49.bindTooltip(
                `&lt;div&gt;
                     Bangladesh
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_ea43126fe1fbde43336579ff5570708b = L.circle(
                [-2.9814344, 23.8222636],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_5dc40f39894d335931fc7af1912061e0 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_a12871409c929677785ff99996baffc8 = $(`&lt;div id=&quot;html_a12871409c929677785ff99996baffc8&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Congo&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_5dc40f39894d335931fc7af1912061e0.setContent(html_a12871409c929677785ff99996baffc8);



        circle_ea43126fe1fbde43336579ff5570708b.bindPopup(popup_5dc40f39894d335931fc7af1912061e0)
        ;




            circle_ea43126fe1fbde43336579ff5570708b.bindTooltip(
                `&lt;div&gt;
                     Congo
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_c22815ca2fd241b15b862e440e056dbc = L.circle(
                [23.6585116, -102.0077097],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_6db11fd99ce31117713d45d62a452927 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_cd41898f5460d229f2e1cdd0044b555b = $(`&lt;div id=&quot;html_cd41898f5460d229f2e1cdd0044b555b&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Mexico&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 46&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 18&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 6&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 21&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 9&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 33&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 13&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_6db11fd99ce31117713d45d62a452927.setContent(html_cd41898f5460d229f2e1cdd0044b555b);



        circle_c22815ca2fd241b15b862e440e056dbc.bindPopup(popup_6db11fd99ce31117713d45d62a452927)
        ;




            circle_c22815ca2fd241b15b862e440e056dbc.bindTooltip(
                `&lt;div&gt;
                     Mexico
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_832214a6624297c16c355f7031b960f9 = L.circle(
                [8.0018709, -66.1109318],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_955321c9845e67032524e931f14169fb = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_6489a2d21639fbadf343463acca03d8f = $(`&lt;div id=&quot;html_6489a2d21639fbadf343463acca03d8f&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Venezuela&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 2&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_955321c9845e67032524e931f14169fb.setContent(html_6489a2d21639fbadf343463acca03d8f);



        circle_832214a6624297c16c355f7031b960f9.bindPopup(popup_955321c9845e67032524e931f14169fb)
        ;




            circle_832214a6624297c16c355f7031b960f9.bindTooltip(
                `&lt;div&gt;
                     Venezuela
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_6d62daada03e90c271601f282b1dae67 = L.circle(
                [25.6242618, 42.3528328],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_2e63f0398600ba21e1ee5a51e2e01fcd = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_d025dc01c2e59026f673598ca8add8f1 = $(`&lt;div id=&quot;html_d025dc01c2e59026f673598ca8add8f1&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Saudi Arabia&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 26&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 6&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 17&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 15&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 11&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_2e63f0398600ba21e1ee5a51e2e01fcd.setContent(html_d025dc01c2e59026f673598ca8add8f1);



        circle_6d62daada03e90c271601f282b1dae67.bindPopup(popup_2e63f0398600ba21e1ee5a51e2e01fcd)
        ;




            circle_6d62daada03e90c271601f282b1dae67.bindTooltip(
                `&lt;div&gt;
                     Saudi Arabia
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_d77ab73087e173459acc76200e63f7d9 = L.circle(
                [39.7837304, -100.445882],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_10adec716ee5be936d40f46a01874dba = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_4c26fa46f2394aa885048d5b9256e6bf = $(`&lt;div id=&quot;html_4c26fa46f2394aa885048d5b9256e6bf&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;United States&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_10adec716ee5be936d40f46a01874dba.setContent(html_4c26fa46f2394aa885048d5b9256e6bf);



        circle_d77ab73087e173459acc76200e63f7d9.bindPopup(popup_10adec716ee5be936d40f46a01874dba)
        ;




            circle_d77ab73087e173459acc76200e63f7d9.bindTooltip(
                `&lt;div&gt;
                     United States
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_87cb7a6f4b9ba7fd56c6ba4a9c79be6a = L.circle(
                [41.000028, 19.9999619],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_c8f94919351e5afd210da4cc780d33f3 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_fcd7a20f45d3c2bc92ce56396cba2e54 = $(`&lt;div id=&quot;html_fcd7a20f45d3c2bc92ce56396cba2e54&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Albania&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 2&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_c8f94919351e5afd210da4cc780d33f3.setContent(html_fcd7a20f45d3c2bc92ce56396cba2e54);



        circle_87cb7a6f4b9ba7fd56c6ba4a9c79be6a.bindPopup(popup_c8f94919351e5afd210da4cc780d33f3)
        ;




            circle_87cb7a6f4b9ba7fd56c6ba4a9c79be6a.bindTooltip(
                `&lt;div&gt;
                     Albania
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_bc0119cc15a58a848332d6fd2e8cb17f = L.circle(
                [4.6125522, 13.1535811],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_5cefb3420b512f648ae107b2e791c91a = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_d6b982589af3fc115ceb164ee150e4ab = $(`&lt;div id=&quot;html_d6b982589af3fc115ceb164ee150e4ab&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Cameroon&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_5cefb3420b512f648ae107b2e791c91a.setContent(html_d6b982589af3fc115ceb164ee150e4ab);



        circle_bc0119cc15a58a848332d6fd2e8cb17f.bindPopup(popup_5cefb3420b512f648ae107b2e791c91a)
        ;




            circle_bc0119cc15a58a848332d6fd2e8cb17f.bindTooltip(
                `&lt;div&gt;
                     Cameroon
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_b0191ea38acd7269451005b35846b627 = L.circle(
                [-0.8999695, 11.6899699],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_3a5e3580b8744cb35747ec8ae30a5219 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_a63a3f388608d4e1818d2d93bca49e44 = $(`&lt;div id=&quot;html_a63a3f388608d4e1818d2d93bca49e44&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Gabon&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_3a5e3580b8744cb35747ec8ae30a5219.setContent(html_a63a3f388608d4e1818d2d93bca49e44);



        circle_b0191ea38acd7269451005b35846b627.bindPopup(popup_3a5e3580b8744cb35747ec8ae30a5219)
        ;




            circle_b0191ea38acd7269451005b35846b627.bindTooltip(
                `&lt;div&gt;
                     Gabon
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_c369428b05199d5e2dea7b14fd059512 = L.circle(
                [9.5293472, 2.2584408],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_86a5d76295527693aaf133780a1c32ba = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_8044a60cd882eba92dcf97ef32db7134 = $(`&lt;div id=&quot;html_8044a60cd882eba92dcf97ef32db7134&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Benin&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_86a5d76295527693aaf133780a1c32ba.setContent(html_8044a60cd882eba92dcf97ef32db7134);



        circle_c369428b05199d5e2dea7b14fd059512.bindPopup(popup_86a5d76295527693aaf133780a1c32ba)
        ;




            circle_c369428b05199d5e2dea7b14fd059512.bindTooltip(
                `&lt;div&gt;
                     Benin
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_ac2bf16ebba7349537b40be01e257d96 = L.circle(
                [17.1750495, 95.9999652],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_901f81e23b5d41fcca660a0ba62fabdc = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_99e1e38bd9bb1d9401834f35c4c45ca2 = $(`&lt;div id=&quot;html_99e1e38bd9bb1d9401834f35c4c45ca2&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Myanmar&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_901f81e23b5d41fcca660a0ba62fabdc.setContent(html_99e1e38bd9bb1d9401834f35c4c45ca2);



        circle_ac2bf16ebba7349537b40be01e257d96.bindPopup(popup_901f81e23b5d41fcca660a0ba62fabdc)
        ;




            circle_ac2bf16ebba7349537b40be01e257d96.bindTooltip(
                `&lt;div&gt;
                     Myanmar
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_2e35d91e932c19ebe058ee88c9f3fe2b = L.circle(
                [39.3763807, 59.3924609],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_752a21f3f718930a7d0fd43dad8bda4a = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_617b2b499352a3d9189afbd8176eda07 = $(`&lt;div id=&quot;html_617b2b499352a3d9189afbd8176eda07&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Turkmenistan&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_752a21f3f718930a7d0fd43dad8bda4a.setContent(html_617b2b499352a3d9189afbd8176eda07);



        circle_2e35d91e932c19ebe058ee88c9f3fe2b.bindPopup(popup_752a21f3f718930a7d0fd43dad8bda4a)
        ;




            circle_2e35d91e932c19ebe058ee88c9f3fe2b.bindTooltip(
                `&lt;div&gt;
                     Turkmenistan
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_edafef68dd69e808b24fb261c101fdeb = L.circle(
                [1.4419683, 38.4313975],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_70c97d40ec50bcba41a3b5341eacd181 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_d7da7518aa2d03990c92084bc4faffb1 = $(`&lt;div id=&quot;html_d7da7518aa2d03990c92084bc4faffb1&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Kenya&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 8&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 5&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 5&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 3&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_70c97d40ec50bcba41a3b5341eacd181.setContent(html_d7da7518aa2d03990c92084bc4faffb1);



        circle_edafef68dd69e808b24fb261c101fdeb.bindPopup(popup_70c97d40ec50bcba41a3b5341eacd181)
        ;




            circle_edafef68dd69e808b24fb261c101fdeb.bindTooltip(
                `&lt;div&gt;
                     Kenya
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_3f93b48df90414e66ffb5e0539451e72 = L.circle(
                [56.8406494, 24.7537645],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_30ecdac2a5d0ba0a1c70147740ad1b6a = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_9823ac3d65656b9a4d34fcc8534eeecd = $(`&lt;div id=&quot;html_9823ac3d65656b9a4d34fcc8534eeecd&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Latvia&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_30ecdac2a5d0ba0a1c70147740ad1b6a.setContent(html_9823ac3d65656b9a4d34fcc8534eeecd);



        circle_3f93b48df90414e66ffb5e0539451e72.bindPopup(popup_30ecdac2a5d0ba0a1c70147740ad1b6a)
        ;




            circle_3f93b48df90414e66ffb5e0539451e72.bindTooltip(
                `&lt;div&gt;
                     Latvia
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_2959b0ba315c07794b4384894255906f = L.circle(
                [1.5333554, 32.2166578],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_464fd397425726ca4afbea7bc00ecdcd = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_f73ac9768f6e4a87a7223b243043b23c = $(`&lt;div id=&quot;html_f73ac9768f6e4a87a7223b243043b23c&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Uganda&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_464fd397425726ca4afbea7bc00ecdcd.setContent(html_f73ac9768f6e4a87a7223b243043b23c);



        circle_2959b0ba315c07794b4384894255906f.bindPopup(popup_464fd397425726ca4afbea7bc00ecdcd)
        ;




            circle_2959b0ba315c07794b4384894255906f.bindTooltip(
                `&lt;div&gt;
                     Uganda
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_c3d67a9c22886671f6b7cae4222c7061 = L.circle(
                [24.0002488, 53.9994829],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_0b01c19bd5f3ee6c90503feeeec64e86 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_adf5104e8bec0d46ed5a3094dcf1860c = $(`&lt;div id=&quot;html_adf5104e8bec0d46ed5a3094dcf1860c&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;United Arab Emirates&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 2&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_0b01c19bd5f3ee6c90503feeeec64e86.setContent(html_adf5104e8bec0d46ed5a3094dcf1860c);



        circle_c3d67a9c22886671f6b7cae4222c7061.bindPopup(popup_0b01c19bd5f3ee6c90503feeeec64e86)
        ;




            circle_c3d67a9c22886671f6b7cae4222c7061.bindTooltip(
                `&lt;div&gt;
                     United Arab Emirates
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_68a196f3515a3c91e514001c0c40d167 = L.circle(
                [35.000074, 104.999927],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 404000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_d1daf6c5e0105ba90358ef587a43c994 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_289079222ec349504a64a2a45824b38b = $(`&lt;div id=&quot;html_289079222ec349504a64a2a45824b38b&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;China&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 808&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 81&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 378&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 346&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 332&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 473&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 334&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_d1daf6c5e0105ba90358ef587a43c994.setContent(html_289079222ec349504a64a2a45824b38b);



        circle_68a196f3515a3c91e514001c0c40d167.bindPopup(popup_d1daf6c5e0105ba90358ef587a43c994)
        ;




            circle_68a196f3515a3c91e514001c0c40d167.bindTooltip(
                `&lt;div&gt;
                     China
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_6e3f430016f9b5c008922724209284f8 = L.circle(
                [12.1360374, -61.6904045],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_d63f9a030cada7c5030a56383bc731e2 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_2816eda9bf770da255ca762c7d4a6011 = $(`&lt;div id=&quot;html_2816eda9bf770da255ca762c7d4a6011&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Grenada&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_d63f9a030cada7c5030a56383bc731e2.setContent(html_2816eda9bf770da255ca762c7d4a6011);



        circle_6e3f430016f9b5c008922724209284f8.bindPopup(popup_d63f9a030cada7c5030a56383bc731e2)
        ;




            circle_6e3f430016f9b5c008922724209284f8.bindTooltip(
                `&lt;div&gt;
                     Grenada
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_4b574caf3310b7877f2fc5e5aa5b0dc2 = L.circle(
                [14.8971921, 100.83273],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_4c61a29140b3f5a4f19acedd7a8115f3 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_f63fa6cc152f2d507ddb40cbd58d2650 = $(`&lt;div id=&quot;html_f63fa6cc152f2d507ddb40cbd58d2650&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Thailand&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 6&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 4&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 4&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_4c61a29140b3f5a4f19acedd7a8115f3.setContent(html_f63fa6cc152f2d507ddb40cbd58d2650);



        circle_4b574caf3310b7877f2fc5e5aa5b0dc2.bindPopup(popup_4c61a29140b3f5a4f19acedd7a8115f3)
        ;




            circle_4b574caf3310b7877f2fc5e5aa5b0dc2.bindTooltip(
                `&lt;div&gt;
                     Thailand
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_5aead15e2cc93648bf2eb0696287c8e4 = L.circle(
                [-28.8166236, 24.991639],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_7e7710101cca38a6baa42c76aec1195e = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_4ae2955e6e37c85d72ced6c4c1e5ea91 = $(`&lt;div id=&quot;html_4ae2955e6e37c85d72ced6c4c1e5ea91&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;South Africa&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 6&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 3&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_7e7710101cca38a6baa42c76aec1195e.setContent(html_4ae2955e6e37c85d72ced6c4c1e5ea91);



        circle_5aead15e2cc93648bf2eb0696287c8e4.bindPopup(popup_7e7710101cca38a6baa42c76aec1195e)
        ;




            circle_5aead15e2cc93648bf2eb0696287c8e4.bindTooltip(
                `&lt;div&gt;
                     South Africa
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_e7c8b96c0cecafbe33f3fc38b15e2f97 = L.circle(
                [42.6384261, 12.674297],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_0a4287b96e2b1678eeba85b99cd99b55 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_551b5adf927fcca71cde51e3b6e3b0b7 = $(`&lt;div id=&quot;html_551b5adf927fcca71cde51e3b6e3b0b7&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Italy&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 7&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 6&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 6&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_0a4287b96e2b1678eeba85b99cd99b55.setContent(html_551b5adf927fcca71cde51e3b6e3b0b7);



        circle_e7c8b96c0cecafbe33f3fc38b15e2f97.bindPopup(popup_0a4287b96e2b1678eeba85b99cd99b55)
        ;




            circle_e7c8b96c0cecafbe33f3fc38b15e2f97.bindTooltip(
                `&lt;div&gt;
                     Italy
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_2a60e07b1c95d8f6b5f0fd3d1145f0ea = L.circle(
                [61.0666922, -107.991707],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_dec7f10ae9d573bba32d56ce15bda194 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_5600f54d26f3d832ea5ff6af49ef8187 = $(`&lt;div id=&quot;html_5600f54d26f3d832ea5ff6af49ef8187&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Canada&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 36&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 17&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 16&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 4&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 13&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 23&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_dec7f10ae9d573bba32d56ce15bda194.setContent(html_5600f54d26f3d832ea5ff6af49ef8187);



        circle_2a60e07b1c95d8f6b5f0fd3d1145f0ea.bindPopup(popup_dec7f10ae9d573bba32d56ce15bda194)
        ;




            circle_2a60e07b1c95d8f6b5f0fd3d1145f0ea.bindTooltip(
                `&lt;div&gt;
                     Canada
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_07a75d4c06f5a0d053190dfd895c08de = L.circle(
                [15.9500319, 37.9999668],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_3ca423a46e20311407299d6480308cb7 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_161a93bc1bd16a6838fa67320a24b732 = $(`&lt;div id=&quot;html_161a93bc1bd16a6838fa67320a24b732&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Eritrea&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_3ca423a46e20311407299d6480308cb7.setContent(html_161a93bc1bd16a6838fa67320a24b732);



        circle_07a75d4c06f5a0d053190dfd895c08de.bindPopup(popup_3ca423a46e20311407299d6480308cb7)
        ;




            circle_07a75d4c06f5a0d053190dfd895c08de.bindTooltip(
                `&lt;div&gt;
                     Eritrea
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_eb14e3b4cbdcb52fa31f6322690bd055 = L.circle(
                [-1.3397668, -79.3666965],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_5b7d4e72710e85f55a16ab34889c1966 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_3762aed7359adf26220bea15284990be = $(`&lt;div id=&quot;html_3762aed7359adf26220bea15284990be&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Ecuador&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 4&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_5b7d4e72710e85f55a16ab34889c1966.setContent(html_3762aed7359adf26220bea15284990be);



        circle_eb14e3b4cbdcb52fa31f6322690bd055.bindPopup(popup_5b7d4e72710e85f55a16ab34889c1966)
        ;




            circle_eb14e3b4cbdcb52fa31f6322690bd055.bindTooltip(
                `&lt;div&gt;
                     Ecuador
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_4bc7bcf7a78ea17d185c2c218ab08841 = L.circle(
                [47.59397, 14.12456],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_88f7a8512968471e308f1ffb70f7488c = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_f5e23d45286bc9cf243876e2e680ed9f = $(`&lt;div id=&quot;html_f5e23d45286bc9cf243876e2e680ed9f&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Austria&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_88f7a8512968471e308f1ffb70f7488c.setContent(html_f5e23d45286bc9cf243876e2e680ed9f);



        circle_4bc7bcf7a78ea17d185c2c218ab08841.bindPopup(popup_88f7a8512968471e308f1ffb70f7488c)
        ;




            circle_4bc7bcf7a78ea17d185c2c218ab08841.bindTooltip(
                `&lt;div&gt;
                     Austria
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_2c09c63931d2859eed24b71f4431daa4 = L.circle(
                [30.3308401, 71.247499],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 89700, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_d54f0c1a415b9051a9ca57dc24425da3 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_b527ee96e2ffeff17df2b9666ea699db = $(`&lt;div id=&quot;html_b527ee96e2ffeff17df2b9666ea699db&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Pakistan&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 69&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 15&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 37&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 17&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 19&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 52&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 17&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_d54f0c1a415b9051a9ca57dc24425da3.setContent(html_b527ee96e2ffeff17df2b9666ea699db);



        circle_2c09c63931d2859eed24b71f4431daa4.bindPopup(popup_d54f0c1a415b9051a9ca57dc24425da3)
        ;




            circle_2c09c63931d2859eed24b71f4431daa4.bindTooltip(
                `&lt;div&gt;
                     Pakistan
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_d7abf798ce9a7e92bab5e566261f0034 = L.circle(
                [8.7800265, 1.0199765],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_02945046f4a50192fff9161c0e56615d = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_b6fe982152b360dfb3d55a5371815ce4 = $(`&lt;div id=&quot;html_b6fe982152b360dfb3d55a5371815ce4&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Togo&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_02945046f4a50192fff9161c0e56615d.setContent(html_b6fe982152b360dfb3d55a5371815ce4);



        circle_d7abf798ce9a7e92bab5e566261f0034.bindPopup(popup_02945046f4a50192fff9161c0e56615d)
        ;




            circle_d7abf798ce9a7e92bab5e566261f0034.bindTooltip(
                `&lt;div&gt;
                     Togo
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_2d1690632f7c4626ba21f984da5af555 = L.circle(
                [38.9597594, 34.9249653],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_c2cf68c3f68d7d9d0f835464c8e5d67c = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_c0bf0af37b115b426e5b11ca685aff87 = $(`&lt;div id=&quot;html_c0bf0af37b115b426e5b11ca685aff87&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Turkey&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 25&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 4&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 18&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 6&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 17&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 8&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_c2cf68c3f68d7d9d0f835464c8e5d67c.setContent(html_c0bf0af37b115b426e5b11ca685aff87);



        circle_2d1690632f7c4626ba21f984da5af555.bindPopup(popup_c2cf68c3f68d7d9d0f835464c8e5d67c)
        ;




            circle_2d1690632f7c4626ba21f984da5af555.bindTooltip(
                `&lt;div&gt;
                     Turkey
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_7dae552a5a19e43cc4d490a1fd88ca8f = L.circle(
                [40.3936294, 47.7872508],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_dca7d0d2e6f55593ca2406a54dbe8679 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_a120486cc3a9196bb2e45bb4e87c5680 = $(`&lt;div id=&quot;html_a120486cc3a9196bb2e45bb4e87c5680&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Azerbaijan&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_dca7d0d2e6f55593ca2406a54dbe8679.setContent(html_a120486cc3a9196bb2e45bb4e87c5680);



        circle_7dae552a5a19e43cc4d490a1fd88ca8f.bindPopup(popup_dca7d0d2e6f55593ca2406a54dbe8679)
        ;




            circle_7dae552a5a19e43cc4d490a1fd88ca8f.bindTooltip(
                `&lt;div&gt;
                     Azerbaijan
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_064c27cc0c2642c75ecdcee35082f292 = L.circle(
                [10.7466905, -61.0840075],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_86cb0af4edc1197582d9ec6f890f729f = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_d0ba5c48426765bf885810caa84eab21 = $(`&lt;div id=&quot;html_d0ba5c48426765bf885810caa84eab21&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Trinidad and Tobago&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_86cb0af4edc1197582d9ec6f890f729f.setContent(html_d0ba5c48426765bf885810caa84eab21);



        circle_064c27cc0c2642c75ecdcee35082f292.bindPopup(popup_86cb0af4edc1197582d9ec6f890f729f)
        ;




            circle_064c27cc0c2642c75ecdcee35082f292.bindTooltip(
                `&lt;div&gt;
                     Trinidad and Tobago
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_25ec96ed7303c161470533e6ae840784 = L.circle(
                [18.1850507, -77.3947693],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_3f5c72520681903cb6cfe4dd82b08392 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_47821d8082933e150f8cd8dfd41a4d98 = $(`&lt;div id=&quot;html_47821d8082933e150f8cd8dfd41a4d98&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Jamaica&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_3f5c72520681903cb6cfe4dd82b08392.setContent(html_47821d8082933e150f8cd8dfd41a4d98);



        circle_25ec96ed7303c161470533e6ae840784.bindPopup(popup_3f5c72520681903cb6cfe4dd82b08392)
        ;




            circle_25ec96ed7303c161470533e6ae840784.bindTooltip(
                `&lt;div&gt;
                     Jamaica
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_14d32a6b7bbbbdea840a4780420eea4a = L.circle(
                [52.865196, -7.9794599],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_0fa31d43f9f89d73e034eccad39cb61f = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_3535cf7b8d9c39d76e3571e2d86050a7 = $(`&lt;div id=&quot;html_3535cf7b8d9c39d76e3571e2d86050a7&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Ireland&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_0fa31d43f9f89d73e034eccad39cb61f.setContent(html_3535cf7b8d9c39d76e3571e2d86050a7);



        circle_14d32a6b7bbbbdea840a4780420eea4a.bindPopup(popup_0fa31d43f9f89d73e034eccad39cb61f)
        ;




            circle_14d32a6b7bbbbdea840a4780420eea4a.bindTooltip(
                `&lt;div&gt;
                     Ireland
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_9863d6c66844a25dd3cbb72b30fbbd3e = L.circle(
                [4.5693754, 102.2656823],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_2163dd99a45c808e4e744144cbc4dbbf = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_90b0b273109d6d83d869401009666a6d = $(`&lt;div id=&quot;html_90b0b273109d6d83d869401009666a6d&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Malaysia&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 8&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 5&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 5&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_2163dd99a45c808e4e744144cbc4dbbf.setContent(html_90b0b273109d6d83d869401009666a6d);



        circle_9863d6c66844a25dd3cbb72b30fbbd3e.bindPopup(popup_2163dd99a45c808e4e744144cbc4dbbf)
        ;




            circle_9863d6c66844a25dd3cbb72b30fbbd3e.bindTooltip(
                `&lt;div&gt;
                     Malaysia
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_eae2e6241adbcc3459345a176942ad89 = L.circle(
                [64.6863136, 97.7453061],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_3208464e03df4f486e2662f49ee04aeb = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_5b1a9a256b6b64772998aa26b627c675 = $(`&lt;div id=&quot;html_5b1a9a256b6b64772998aa26b627c675&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Russian Federation&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 8&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 5&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 4&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 4&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_3208464e03df4f486e2662f49ee04aeb.setContent(html_5b1a9a256b6b64772998aa26b627c675);



        circle_eae2e6241adbcc3459345a176942ad89.bindPopup(popup_3208464e03df4f486e2662f49ee04aeb)
        ;




            circle_eae2e6241adbcc3459345a176942ad89.bindTooltip(
                `&lt;div&gt;
                     Russian Federation
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_f58c219da0b386b1df1fd407638a6a27 = L.circle(
                [-2.4833826, 117.8902853],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_bfda7f992a7f9d94803568d13c182fa8 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_ddb29c68c91e83fa1726519c7d0548d5 = $(`&lt;div id=&quot;html_ddb29c68c91e83fa1726519c7d0548d5&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Indonesia&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 2&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_bfda7f992a7f9d94803568d13c182fa8.setContent(html_ddb29c68c91e83fa1726519c7d0548d5);



        circle_f58c219da0b386b1df1fd407638a6a27.bindPopup(popup_bfda7f992a7f9d94803568d13c182fa8)
        ;




            circle_f58c219da0b386b1df1fd407638a6a27.bindTooltip(
                `&lt;div&gt;
                     Indonesia
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_7a8fbb458a8e4103c08a6c80f63b3921 = L.circle(
                [22.3511148, 78.6677428],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 1004400, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_bfa23554a7354e4bbe73fd41a559da67 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_4da472a74b4aac1e1c8183de09bfc6a2 = $(`&lt;div id=&quot;html_4da472a74b4aac1e1c8183de09bfc6a2&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;India&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 6696&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 186&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 6206&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 296&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1985&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 4084&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 2612&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_bfa23554a7354e4bbe73fd41a559da67.setContent(html_4da472a74b4aac1e1c8183de09bfc6a2);



        circle_7a8fbb458a8e4103c08a6c80f63b3921.bindPopup(popup_bfa23554a7354e4bbe73fd41a559da67)
        ;




            circle_7a8fbb458a8e4103c08a6c80f63b3921.bindTooltip(
                `&lt;div&gt;
                     India
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_1d4fb0e41c651fc306df43e5f6eafd3a = L.circle(
                [24.7736546, -78.0000547],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_8b5f84e7d06cd26c0538dd667d7c25a4 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_951437e095d31ea3d2f4197b975ce41a = $(`&lt;div id=&quot;html_951437e095d31ea3d2f4197b975ce41a&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Bahamas&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_8b5f84e7d06cd26c0538dd667d7c25a4.setContent(html_951437e095d31ea3d2f4197b975ce41a);



        circle_1d4fb0e41c651fc306df43e5f6eafd3a.bindPopup(popup_8b5f84e7d06cd26c0538dd667d7c25a4)
        ;




            circle_1d4fb0e41c651fc306df43e5f6eafd3a.bindTooltip(
                `&lt;div&gt;
                     Bahamas
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_9b62c2883792c68ad6df555a9a8993b7 = L.circle(
                [26.1551249, 50.5344606],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_00579906eb1b8ab7ec3e637e0e335adf = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_7b686c2a34122ecb04551ff0e1c7d7c5 = $(`&lt;div id=&quot;html_7b686c2a34122ecb04551ff0e1c7d7c5&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Bahrain&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_00579906eb1b8ab7ec3e637e0e335adf.setContent(html_7b686c2a34122ecb04551ff0e1c7d7c5);



        circle_9b62c2883792c68ad6df555a9a8993b7.bindPopup(popup_00579906eb1b8ab7ec3e637e0e335adf)
        ;




            circle_9b62c2883792c68ad6df555a9a8993b7.bindTooltip(
                `&lt;div&gt;
                     Bahrain
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_51c770d30c8b604697d4773910013833 = L.circle(
                [13.8250489, -60.975036],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_959553cb689d8dccf3909c2aae004805 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_41962e67d74b2ea2a0c42e01b340316d = $(`&lt;div id=&quot;html_41962e67d74b2ea2a0c42e01b340316d&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Saint Lucia&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_959553cb689d8dccf3909c2aae004805.setContent(html_41962e67d74b2ea2a0c42e01b340316d);



        circle_51c770d30c8b604697d4773910013833.bindPopup(popup_959553cb689d8dccf3909c2aae004805)
        ;




            circle_51c770d30c8b604697d4773910013833.bindTooltip(
                `&lt;div&gt;
                     Saint Lucia
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_8d0a617711adfa120a2f3081fdc96436 = L.circle(
                [-41.5000831, 172.8344077],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_6efe31213d47a614c1d503ff874f542f = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_9848063056338be83e9da6e3b85b31ae = $(`&lt;div id=&quot;html_9848063056338be83e9da6e3b85b31ae&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;New Zealand&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_6efe31213d47a614c1d503ff874f542f.setContent(html_9848063056338be83e9da6e3b85b31ae);



        circle_8d0a617711adfa120a2f3081fdc96436.bindPopup(popup_6efe31213d47a614c1d503ff874f542f)
        ;




            circle_8d0a617711adfa120a2f3081fdc96436.bindTooltip(
                `&lt;div&gt;
                     New Zealand
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_10abac8f43bd8706c681ef7c3de6e703 = L.circle(
                [31.1728205, -7.3362482],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_b37591b41c5dd30a053bfa6e79dcc1bf = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_8aab736dbac21c5e852019ba2d7883a2 = $(`&lt;div id=&quot;html_8aab736dbac21c5e852019ba2d7883a2&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Morocco&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 2&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_b37591b41c5dd30a053bfa6e79dcc1bf.setContent(html_8aab736dbac21c5e852019ba2d7883a2);



        circle_10abac8f43bd8706c681ef7c3de6e703.bindPopup(popup_b37591b41c5dd30a053bfa6e79dcc1bf)
        ;




            circle_10abac8f43bd8706c681ef7c3de6e703.bindTooltip(
                `&lt;div&gt;
                     Morocco
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_57cc0a669a18c1de919d47a6c604f441 = L.circle(
                [10.2116702, 38.6521203],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_f1cc60a83a9c05603fa8e4fc7b012295 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_c434e3d8db7ffeb4bcf053bed287e9a4 = $(`&lt;div id=&quot;html_c434e3d8db7ffeb4bcf053bed287e9a4&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Ethiopia&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 5&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 4&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_f1cc60a83a9c05603fa8e4fc7b012295.setContent(html_c434e3d8db7ffeb4bcf053bed287e9a4);



        circle_57cc0a669a18c1de919d47a6c604f441.bindPopup(popup_f1cc60a83a9c05603fa8e4fc7b012295)
        ;




            circle_57cc0a669a18c1de919d47a6c604f441.bindTooltip(
                `&lt;div&gt;
                     Ethiopia
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_932246d859799be5c9405dfaa34b76ba = L.circle(
                [-23.3165935, -58.1693445],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_795683d622637cf7f0a99541971df33d = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_259625404c37febc2869a38bb02eb12a = $(`&lt;div id=&quot;html_259625404c37febc2869a38bb02eb12a&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Paraguay&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_795683d622637cf7f0a99541971df33d.setContent(html_259625404c37febc2869a38bb02eb12a);



        circle_932246d859799be5c9405dfaa34b76ba.bindPopup(popup_795683d622637cf7f0a99541971df33d)
        ;




            circle_932246d859799be5c9405dfaa34b76ba.bindTooltip(
                `&lt;div&gt;
                     Paraguay
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_8780bdfc44e4a86781335d54f5f75675 = L.circle(
                [46.603354, 1.8883335],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_1cbec4f5c90cde58f97bc8d255f2de52 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_06941d9d07e0ec540b06e8e03c82adc1 = $(`&lt;div id=&quot;html_06941d9d07e0ec540b06e8e03c82adc1&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;France&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_1cbec4f5c90cde58f97bc8d255f2de52.setContent(html_06941d9d07e0ec540b06e8e03c82adc1);



        circle_8780bdfc44e4a86781335d54f5f75675.bindPopup(popup_1cbec4f5c90cde58f97bc8d255f2de52)
        ;




            circle_8780bdfc44e4a86781335d54f5f75675.bindTooltip(
                `&lt;div&gt;
                     France
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_6ede4edb3f9da97efe8da32a00b8a030 = L.circle(
                [7.9897371, -5.5679458],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_7022e5f40391af610326f63a8dfd2cea = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_fdff8c3f5322c301a86d0ec4cd64227e = $(`&lt;div id=&quot;html_fdff8c3f5322c301a86d0ec4cd64227e&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Cote D&#x27;Ivoire&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 9&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 5&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 4&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 4&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 5&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_7022e5f40391af610326f63a8dfd2cea.setContent(html_fdff8c3f5322c301a86d0ec4cd64227e);



        circle_6ede4edb3f9da97efe8da32a00b8a030.bindPopup(popup_7022e5f40391af610326f63a8dfd2cea)
        ;




            circle_6ede4edb3f9da97efe8da32a00b8a030.bindTooltip(
                `&lt;div&gt;
                     Cote D&#x27;Ivoire
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_f43e2a5af235b02193238adacfa79983 = L.circle(
                [39.3260685, -4.8379791],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_e6453b81242e7c122415c7513b6b3f68 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_597c66785e21cd0930aa4fe0951db2a7 = $(`&lt;div id=&quot;html_597c66785e21cd0930aa4fe0951db2a7&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Spain&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_e6453b81242e7c122415c7513b6b3f68.setContent(html_597c66785e21cd0930aa4fe0951db2a7);



        circle_f43e2a5af235b02193238adacfa79983.bindPopup(popup_e6453b81242e7c122415c7513b6b3f68)
        ;




            circle_f43e2a5af235b02193238adacfa79983.bindTooltip(
                `&lt;div&gt;
                     Spain
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_ca3d2216d31023ebccc2ca235c40967d = L.circle(
                [-34.9964963, -64.9672817],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_36a795d9a8d7118bd733a0400061ea3d = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_27f52f30927283ea3a2925a45388ff91 = $(`&lt;div id=&quot;html_27f52f30927283ea3a2925a45388ff91&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Argentina&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_36a795d9a8d7118bd733a0400061ea3d.setContent(html_27f52f30927283ea3a2925a45388ff91);



        circle_ca3d2216d31023ebccc2ca235c40967d.bindPopup(popup_36a795d9a8d7118bd733a0400061ea3d)
        ;




            circle_ca3d2216d31023ebccc2ca235c40967d.bindTooltip(
                `&lt;div&gt;
                     Argentina
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_39984bbf1de7b25e33d31c8ba916467b = L.circle(
                [45.5643442, 17.0118954],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_3e950b5f8c6c0b5a9ae5c535cdc7d796 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_2483f926b87e2284898f5e10e6d9ed6a = $(`&lt;div id=&quot;html_2483f926b87e2284898f5e10e6d9ed6a&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Croatia&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_3e950b5f8c6c0b5a9ae5c535cdc7d796.setContent(html_2483f926b87e2284898f5e10e6d9ed6a);



        circle_39984bbf1de7b25e33d31c8ba916467b.bindPopup(popup_3e950b5f8c6c0b5a9ae5c535cdc7d796)
        ;




            circle_39984bbf1de7b25e33d31c8ba916467b.bindTooltip(
                `&lt;div&gt;
                     Croatia
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_a8f511bf2737562efccbdcc505a0a339 = L.circle(
                [41.32373, 63.9528098],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_f4ef8ef1bcebb751dd19d81ff9dc1fff = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_731939acd28c96797da8ed4205cb732c = $(`&lt;div id=&quot;html_731939acd28c96797da8ed4205cb732c&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Uzbekistan&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_f4ef8ef1bcebb751dd19d81ff9dc1fff.setContent(html_731939acd28c96797da8ed4205cb732c);



        circle_a8f511bf2737562efccbdcc505a0a339.bindPopup(popup_f4ef8ef1bcebb751dd19d81ff9dc1fff)
        ;




            circle_a8f511bf2737562efccbdcc505a0a339.bindTooltip(
                `&lt;div&gt;
                     Uzbekistan
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_3af6029dca0c9aec6cc555bffef67162 = L.circle(
                [19.0974031, -70.3028026],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_d8c5573f7707577d247ab535a3adfc9a = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_04f8ebc70b5e5409744f531f247944d9 = $(`&lt;div id=&quot;html_04f8ebc70b5e5409744f531f247944d9&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Dominican Republic&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_d8c5573f7707577d247ab535a3adfc9a.setContent(html_04f8ebc70b5e5409744f531f247944d9);



        circle_3af6029dca0c9aec6cc555bffef67162.bindPopup(popup_d8c5573f7707577d247ab535a3adfc9a)
        ;




            circle_3af6029dca0c9aec6cc555bffef67162.bindTooltip(
                `&lt;div&gt;
                     Dominican Republic
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_80f97cab02a42f9fcdaa6cf2c90b0ae6 = L.circle(
                [36.5748441, 139.2394179],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_13b41b0f2cc9d5a9d172b0017302ec08 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_0bb3c9f150df5624ec14299d60a432cc = $(`&lt;div id=&quot;html_0bb3c9f150df5624ec14299d60a432cc&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Japan&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 13&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 6&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 4&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 10&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 3&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_13b41b0f2cc9d5a9d172b0017302ec08.setContent(html_0bb3c9f150df5624ec14299d60a432cc);



        circle_80f97cab02a42f9fcdaa6cf2c90b0ae6.bindPopup(popup_13b41b0f2cc9d5a9d172b0017302ec08)
        ;




            circle_80f97cab02a42f9fcdaa6cf2c90b0ae6.bindTooltip(
                `&lt;div&gt;
                     Japan
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_23b670c84acc9a47f36dbdd1c012ad62 = L.circle(
                [28.1083929, 84.0917139],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_1576252f21dad587e20129ab54f51e41 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_837098d06f65377aa9920903e426fbae = $(`&lt;div id=&quot;html_837098d06f65377aa9920903e426fbae&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Nepal&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 35&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 6&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 14&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 15&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 14&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 28&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 7&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_1576252f21dad587e20129ab54f51e41.setContent(html_837098d06f65377aa9920903e426fbae);



        circle_23b670c84acc9a47f36dbdd1c012ad62.bindPopup(popup_1576252f21dad587e20129ab54f51e41)
        ;




            circle_23b670c84acc9a47f36dbdd1c012ad62.bindTooltip(
                `&lt;div&gt;
                     Nepal
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_b7811276b830df1d9282bbd46dd64dd1 = L.circle(
                [59.6749712, 14.5208584],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_aaa93af1548ee35a207d6f5198f4c07e = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_37c0f49254948e3eb391a72380d43526 = $(`&lt;div id=&quot;html_37c0f49254948e3eb391a72380d43526&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Sweden&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_aaa93af1548ee35a207d6f5198f4c07e.setContent(html_37c0f49254948e3eb391a72380d43526);



        circle_b7811276b830df1d9282bbd46dd64dd1.bindPopup(popup_aaa93af1548ee35a207d6f5198f4c07e)
        ;




            circle_b7811276b830df1d9282bbd46dd64dd1.bindTooltip(
                `&lt;div&gt;
                     Sweden
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_db43a20d55ab4a448c2196a7518f7545 = L.circle(
                [12.5433216, 104.8144914],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_3997c41f878b3b64485075685f1adf02 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_833d13558292d7d7f6b1d9e2aef89ddd = $(`&lt;div id=&quot;html_833d13558292d7d7f6b1d9e2aef89ddd&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Cambodia&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_3997c41f878b3b64485075685f1adf02.setContent(html_833d13558292d7d7f6b1d9e2aef89ddd);



        circle_db43a20d55ab4a448c2196a7518f7545.bindPopup(popup_3997c41f878b3b64485075685f1adf02)
        ;




            circle_db43a20d55ab4a448c2196a7518f7545.bindTooltip(
                `&lt;div&gt;
                     Cambodia
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_dcca0eb404ba64e824d0334088b39307 = L.circle(
                [33.7680065, 66.2385139],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_7a7420d485f669ea10e0e00576199d6e = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_03081f4c59173f4db627c943f9b4b915 = $(`&lt;div id=&quot;html_03081f4c59173f4db627c943f9b4b915&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Afghanistan&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_7a7420d485f669ea10e0e00576199d6e.setContent(html_03081f4c59173f4db627c943f9b4b915);



        circle_dcca0eb404ba64e824d0334088b39307.bindPopup(popup_7a7420d485f669ea10e0e00576199d6e)
        ;




            circle_dcca0eb404ba64e824d0334088b39307.bindTooltip(
                `&lt;div&gt;
                     Afghanistan
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_846be0083691f7a1a0606fae176a206f = L.circle(
                [4.8417097, -58.6416891],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_112938f3627dc2fa18fdf1907e2ba971 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_3d91745621cd52afee05f5711890ceed = $(`&lt;div id=&quot;html_3d91745621cd52afee05f5711890ceed&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Guyana&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_112938f3627dc2fa18fdf1907e2ba971.setContent(html_3d91745621cd52afee05f5711890ceed);



        circle_846be0083691f7a1a0606fae176a206f.bindPopup(popup_112938f3627dc2fa18fdf1907e2ba971)
        ;




            circle_846be0083691f7a1a0606fae176a206f.bindTooltip(
                `&lt;div&gt;
                     Guyana
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_0cfaf59d695df0cb92f9afbf41252db1 = L.circle(
                [-11.8775768, 17.5691241],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_1ff91001219875435951d463ae572073 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_180bc32ec44db249a880d3a53b144891 = $(`&lt;div id=&quot;html_180bc32ec44db249a880d3a53b144891&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Angola&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_1ff91001219875435951d463ae572073.setContent(html_180bc32ec44db249a880d3a53b144891);



        circle_0cfaf59d695df0cb92f9afbf41252db1.bindPopup(popup_1ff91001219875435951d463ae572073)
        ;




            circle_0cfaf59d695df0cb92f9afbf41252db1.bindTooltip(
                `&lt;div&gt;
                     Angola
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_f7b11f80c3b0724ac70b529ac4fce16e = L.circle(
                [15.5855545, -90.345759],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_8ae756841a429792a8a27743330dcd25 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_ae529d78145241d7eb19c7a9d295953a = $(`&lt;div id=&quot;html_ae529d78145241d7eb19c7a9d295953a&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Guatemala&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_8ae756841a429792a8a27743330dcd25.setContent(html_ae529d78145241d7eb19c7a9d295953a);



        circle_f7b11f80c3b0724ac70b529ac4fce16e.bindPopup(popup_8ae756841a429792a8a27743330dcd25)
        ;




            circle_f7b11f80c3b0724ac70b529ac4fce16e.bindTooltip(
                `&lt;div&gt;
                     Guatemala
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_f7cd0cbdd34b6884e682abb2f46fc6aa = L.circle(
                [50.6402809, 4.6667145],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_bdac845b035d060db0d3c12bd72011da = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_0c45316a530da59dc96357e533b47e23 = $(`&lt;div id=&quot;html_0c45316a530da59dc96357e533b47e23&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Belgium&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 5&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 4&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_bdac845b035d060db0d3c12bd72011da.setContent(html_0c45316a530da59dc96357e533b47e23);



        circle_f7cd0cbdd34b6884e682abb2f46fc6aa.bindPopup(popup_bdac845b035d060db0d3c12bd72011da)
        ;




            circle_f7cd0cbdd34b6884e682abb2f46fc6aa.bindTooltip(
                `&lt;div&gt;
                     Belgium
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_4fa71b583ed89d945617f91ec5c95457 = L.circle(
                [38.9953683, 21.9877132],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_245127b733d6278443e8d27de34c27bf = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_4b56a382575279d2d4db224afbc6db87 = $(`&lt;div id=&quot;html_4b56a382575279d2d4db224afbc6db87&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Greece&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_245127b733d6278443e8d27de34c27bf.setContent(html_4b56a382575279d2d4db224afbc6db87);



        circle_4fa71b583ed89d945617f91ec5c95457.bindPopup(popup_245127b733d6278443e8d27de34c27bf)
        ;




            circle_4fa71b583ed89d945617f91ec5c95457.bindTooltip(
                `&lt;div&gt;
                     Greece
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_58043947e1b9662053231dd82bad061a = L.circle(
                [33.0955793, 44.1749775],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_93354dd903eafe2122e8aa771d966e09 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_2b090d74cb96fdce0b591ca9bc5cd47b = $(`&lt;div id=&quot;html_2b090d74cb96fdce0b591ca9bc5cd47b&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Iraq&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_93354dd903eafe2122e8aa771d966e09.setContent(html_2b090d74cb96fdce0b591ca9bc5cd47b);



        circle_58043947e1b9662053231dd82bad061a.bindPopup(popup_93354dd903eafe2122e8aa771d966e09)
        ;




            circle_58043947e1b9662053231dd82bad061a.bindTooltip(
                `&lt;div&gt;
                     Iraq
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_21a8202e8b5eac973309c282233b1f9a = L.circle(
                [-17.0568696, -64.9912286],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_31e176d4c7bcfe42299d1718807e09ad = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_b96a5002b7937cf8bb95b3eb3517764b = $(`&lt;div id=&quot;html_b96a5002b7937cf8bb95b3eb3517764b&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Bolivia&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_31e176d4c7bcfe42299d1718807e09ad.setContent(html_b96a5002b7937cf8bb95b3eb3517764b);



        circle_21a8202e8b5eac973309c282233b1f9a.bindPopup(popup_31e176d4c7bcfe42299d1718807e09ad)
        ;




            circle_21a8202e8b5eac973309c282233b1f9a.bindTooltip(
                `&lt;div&gt;
                     Bolivia
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_b992b24a39a3c4f7342b8b70f1a710bc = L.circle(
                [14.4750607, -14.4529612],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_6c9e440d4eaf91884f16ae0a31cbcde4 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_2e445be22b55223cbb285a1b397794f7 = $(`&lt;div id=&quot;html_2e445be22b55223cbb285a1b397794f7&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Senegal&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_6c9e440d4eaf91884f16ae0a31cbcde4.setContent(html_2e445be22b55223cbb285a1b397794f7);



        circle_b992b24a39a3c4f7342b8b70f1a710bc.bindPopup(popup_6c9e440d4eaf91884f16ae0a31cbcde4)
        ;




            circle_b992b24a39a3c4f7342b8b70f1a710bc.bindTooltip(
                `&lt;div&gt;
                     Senegal
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_2111f4da08134dec4b3c3fb0f61a5c9c = L.circle(
                [52.215933, 19.134422],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_dfad8864e0179757a6deccb0ce53d553 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_8f30c57ec2072fa5dcd80d35b77e19a5 = $(`&lt;div id=&quot;html_8f30c57ec2072fa5dcd80d35b77e19a5&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Poland&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_dfad8864e0179757a6deccb0ce53d553.setContent(html_8f30c57ec2072fa5dcd80d35b77e19a5);



        circle_2111f4da08134dec4b3c3fb0f61a5c9c.bindPopup(popup_dfad8864e0179757a6deccb0ce53d553)
        ;




            circle_2111f4da08134dec4b3c3fb0f61a5c9c.bindTooltip(
                `&lt;div&gt;
                     Poland
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_4efeb5a8cfb0e9e3b768da9c8811cafc = L.circle(
                [52.24764975, 5.541246849406163],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_6ebace45b9d2ecc98614530916a67209 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_528026c234d7d31ef3aa8cca4886de75 = $(`&lt;div id=&quot;html_528026c234d7d31ef3aa8cca4886de75&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Netherlands&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_6ebace45b9d2ecc98614530916a67209.setContent(html_528026c234d7d31ef3aa8cca4886de75);



        circle_4efeb5a8cfb0e9e3b768da9c8811cafc.bindPopup(popup_6ebace45b9d2ecc98614530916a67209)
        ;




            circle_4efeb5a8cfb0e9e3b768da9c8811cafc.bindTooltip(
                `&lt;div&gt;
                     Netherlands
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_6b4305fa268885508ee6eb8c4e9b5b9d = L.circle(
                [-31.7613365, -71.3187697],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_66898137f43708dae14578ca7c601302 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_328a834b8048aba308038d89793890d8 = $(`&lt;div id=&quot;html_328a834b8048aba308038d89793890d8&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Chile&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_66898137f43708dae14578ca7c601302.setContent(html_328a834b8048aba308038d89793890d8);



        circle_6b4305fa268885508ee6eb8c4e9b5b9d.bindPopup(popup_66898137f43708dae14578ca7c601302)
        ;




            circle_6b4305fa268885508ee6eb8c4e9b5b9d.bindTooltip(
                `&lt;div&gt;
                     Chile
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_1644601c42c0e3950385a21a07a829f5 = L.circle(
                [16.8259793, -88.7600927],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_9a3ddc58aa4a4873dcef460eafad2e0f = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_b54a023e4da94eaf17bc99775955a3b7 = $(`&lt;div id=&quot;html_b54a023e4da94eaf17bc99775955a3b7&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Belize&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_9a3ddc58aa4a4873dcef460eafad2e0f.setContent(html_b54a023e4da94eaf17bc99775955a3b7);



        circle_1644601c42c0e3950385a21a07a829f5.bindPopup(popup_9a3ddc58aa4a4873dcef460eafad2e0f)
        ;




            circle_1644601c42c0e3950385a21a07a829f5.bindTooltip(
                `&lt;div&gt;
                     Belize
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_67b38a6421b9d2dc3183860f26883185 = L.circle(
                [32.30382, -64.7561647],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_80aa375e00dec7e6767f61cfcbb627e2 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_a32fdc1de515ef588d4376190772201d = $(`&lt;div id=&quot;html_a32fdc1de515ef588d4376190772201d&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Bermuda&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_80aa375e00dec7e6767f61cfcbb627e2.setContent(html_a32fdc1de515ef588d4376190772201d);



        circle_67b38a6421b9d2dc3183860f26883185.bindPopup(popup_80aa375e00dec7e6767f61cfcbb627e2)
        ;




            circle_67b38a6421b9d2dc3183860f26883185.bindTooltip(
                `&lt;div&gt;
                     Bermuda
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_b1ed3302d6e3be58aa005e69e75cb367 = L.circle(
                [55.3500003, 23.7499997],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_acb13001dcdef6c688abca8b28f93b74 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_9463122fe4773c68c8a5ef3ba76b0ea2 = $(`&lt;div id=&quot;html_9463122fe4773c68c8a5ef3ba76b0ea2&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Lithuania&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_acb13001dcdef6c688abca8b28f93b74.setContent(html_9463122fe4773c68c8a5ef3ba76b0ea2);



        circle_b1ed3302d6e3be58aa005e69e75cb367.bindPopup(popup_acb13001dcdef6c688abca8b28f93b74)
        ;




            circle_b1ed3302d6e3be58aa005e69e75cb367.bindTooltip(
                `&lt;div&gt;
                     Lithuania
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_1e03dea06add13e5a3262159fb9ca361 = L.circle(
                [60.5000209, 9.0999715],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_b047f0bd03ddd2fb4e92c0c479fc1f1e = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_17cd67fa335690cbe2f202aa71645478 = $(`&lt;div id=&quot;html_17cd67fa335690cbe2f202aa71645478&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Norway&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_b047f0bd03ddd2fb4e92c0c479fc1f1e.setContent(html_17cd67fa335690cbe2f202aa71645478);



        circle_1e03dea06add13e5a3262159fb9ca361.bindPopup(popup_b047f0bd03ddd2fb4e92c0c479fc1f1e)
        ;




            circle_1e03dea06add13e5a3262159fb9ca361.bindTooltip(
                `&lt;div&gt;
                     Norway
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_ca4218c452856d403cff9c328f82e125 = L.circle(
                [30.8124247, 34.8594762],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_e97a5682170d21ea10b8dcac43e5eb05 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_66238bdd6200583e3d26a01578c6b4d1 = $(`&lt;div id=&quot;html_66238bdd6200583e3d26a01578c6b4d1&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Israel&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_e97a5682170d21ea10b8dcac43e5eb05.setContent(html_66238bdd6200583e3d26a01578c6b4d1);



        circle_ca4218c452856d403cff9c328f82e125.bindPopup(popup_e97a5682170d21ea10b8dcac43e5eb05)
        ;




            circle_ca4218c452856d403cff9c328f82e125.bindTooltip(
                `&lt;div&gt;
                     Israel
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_6469bb50f0f7318fd31c41eaa02d6981 = L.circle(
                [13.8000382, -88.9140683],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_4502db386445e8f86673fedee9b612cf = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_583883fe63babcea6a50ca445d6d6ce2 = $(`&lt;div id=&quot;html_583883fe63babcea6a50ca445d6d6ce2&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;El Salvador&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_4502db386445e8f86673fedee9b612cf.setContent(html_583883fe63babcea6a50ca445d6d6ce2);



        circle_6469bb50f0f7318fd31c41eaa02d6981.bindPopup(popup_4502db386445e8f86673fedee9b612cf)
        ;




            circle_6469bb50f0f7318fd31c41eaa02d6981.bindTooltip(
                `&lt;div&gt;
                     El Salvador
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_75a35f500abc28b8f44f9f289d7a5238 = L.circle(
                [25.3336984, 51.2295295],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_86544118e5f45abb29d12c5f6bb5efbe = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_68f5f0a4d5ae5a7eef093c8d0c7d4f57 = $(`&lt;div id=&quot;html_68f5f0a4d5ae5a7eef093c8d0c7d4f57&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Qatar&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 2&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_86544118e5f45abb29d12c5f6bb5efbe.setContent(html_68f5f0a4d5ae5a7eef093c8d0c7d4f57);



        circle_75a35f500abc28b8f44f9f289d7a5238.bindPopup(popup_86544118e5f45abb29d12c5f6bb5efbe)
        ;




            circle_75a35f500abc28b8f44f9f289d7a5238.bindTooltip(
                `&lt;div&gt;
                     Qatar
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_ccffa1403857cdf92478bead4a9f11f4 = L.circle(
                [7.5554942, 80.7137847],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_c8bed4cefbc4a6ba9ccd13398d2c7957 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_cf6f6c7801e99710be3ee2836df5cde9 = $(`&lt;div id=&quot;html_cf6f6c7801e99710be3ee2836df5cde9&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Sri Lanka&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 42&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 6&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 35&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 11&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 16&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 26&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_c8bed4cefbc4a6ba9ccd13398d2c7957.setContent(html_cf6f6c7801e99710be3ee2836df5cde9);



        circle_ccffa1403857cdf92478bead4a9f11f4.bindPopup(popup_c8bed4cefbc4a6ba9ccd13398d2c7957)
        ;




            circle_ccffa1403857cdf92478bead4a9f11f4.bindTooltip(
                `&lt;div&gt;
                     Sri Lanka
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_fb6972019d9a6c176d7483a48db3cbd0 = L.circle(
                [13.1500331, -59.5250305],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_49607ff00fb88855abc8aaf003df9dcf = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_5b9c2ebf4451714968cf5ffd948b17d1 = $(`&lt;div id=&quot;html_5b9c2ebf4451714968cf5ffd948b17d1&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Barbados&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_49607ff00fb88855abc8aaf003df9dcf.setContent(html_5b9c2ebf4451714968cf5ffd948b17d1);



        circle_fb6972019d9a6c176d7483a48db3cbd0.bindPopup(popup_49607ff00fb88855abc8aaf003df9dcf)
        ;




            circle_fb6972019d9a6c176d7483a48db3cbd0.bindTooltip(
                `&lt;div&gt;
                     Barbados
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_95a73d6f88b606c8d53cbb260549ae53 = L.circle(
                [41.5089324, 74.724091],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_5feda23bd2f82f854877dd9b817c70ed = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_346bf51bb83208a8a9104c68dadadce7 = $(`&lt;div id=&quot;html_346bf51bb83208a8a9104c68dadadce7&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Kyrgyzstan&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_5feda23bd2f82f854877dd9b817c70ed.setContent(html_346bf51bb83208a8a9104c68dadadce7);



        circle_95a73d6f88b606c8d53cbb260549ae53.bindPopup(popup_5feda23bd2f82f854877dd9b817c70ed)
        ;




            circle_95a73d6f88b606c8d53cbb260549ae53.bindTooltip(
                `&lt;div&gt;
                     Kyrgyzstan
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_c69bf2a47b81ba61bf155996a544de93 = L.circle(
                [23.9739374, 120.9820179],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 275600, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_8aeaede29171aa23a9d2bd88ae8b70da = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_0c1b39a2b33405c6ca873b38d6fc10f3 = $(`&lt;div id=&quot;html_0c1b39a2b33405c6ca873b38d6fc10f3&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Taiwan&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 212&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 13&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 176&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 22&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 97&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 116&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 96&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_8aeaede29171aa23a9d2bd88ae8b70da.setContent(html_0c1b39a2b33405c6ca873b38d6fc10f3);



        circle_c69bf2a47b81ba61bf155996a544de93.bindPopup(popup_8aeaede29171aa23a9d2bd88ae8b70da)
        ;




            circle_c69bf2a47b81ba61bf155996a544de93.bindTooltip(
                `&lt;div&gt;
                     Taiwan
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_83683d6f8a54bffb833fd6d175f3ac90 = L.circle(
                [-18.9249604, 46.4416422],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_921e131c911188957a1063d6cf3b44b8 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_bf136f88943ac5226754c207c1a849c4 = $(`&lt;div id=&quot;html_bf136f88943ac5226754c207c1a849c4&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Madagascar&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_921e131c911188957a1063d6cf3b44b8.setContent(html_bf136f88943ac5226754c207c1a849c4);



        circle_83683d6f8a54bffb833fd6d175f3ac90.bindPopup(popup_921e131c911188957a1063d6cf3b44b8)
        ;




            circle_83683d6f8a54bffb833fd6d175f3ac90.bindTooltip(
                `&lt;div&gt;
                     Madagascar
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_1c37da5aa5896e90a9cd5a3de0ddfc4b = L.circle(
                [8.0300284, -1.0800271],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_84f71811588fd5d954ed2134d91e67f3 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_1eb26569a89c241035bea756a54fa864 = $(`&lt;div id=&quot;html_1eb26569a89c241035bea756a54fa864&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Ghana&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 8&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 6&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 7&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_84f71811588fd5d954ed2134d91e67f3.setContent(html_1eb26569a89c241035bea756a54fa864);



        circle_1c37da5aa5896e90a9cd5a3de0ddfc4b.bindPopup(popup_84f71811588fd5d954ed2134d91e67f3)
        ;




            circle_1c37da5aa5896e90a9cd5a3de0ddfc4b.bindTooltip(
                `&lt;div&gt;
                     Ghana
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_c671cf5143e5431fd8eefcd2e39450a4 = L.circle(
                [1.357107, 103.8194992],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_cd45d4807608325b2245ef3cad76610b = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_b4743d2478982dfdb1ef9d6d729df167 = $(`&lt;div id=&quot;html_b4743d2478982dfdb1ef9d6d729df167&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Singapore&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 8&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 5&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 4&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 4&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_cd45d4807608325b2245ef3cad76610b.setContent(html_b4743d2478982dfdb1ef9d6d729df167);



        circle_c671cf5143e5431fd8eefcd2e39450a4.bindPopup(popup_cd45d4807608325b2245ef3cad76610b)
        ;




            circle_c671cf5143e5431fd8eefcd2e39450a4.bindTooltip(
                `&lt;div&gt;
                     Singapore
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_d10f62e696347ba5eade602fce685b39 = L.circle(
                [9.6000359, 7.9999721],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 102700, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_735bfacf4456c6744e70faba7d307157 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_3d8f5e91df551f5992bd17cc892f5d67 = $(`&lt;div id=&quot;html_3d8f5e91df551f5992bd17cc892f5d67&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Nigeria&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 79&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 12&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 41&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 26&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 16&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 45&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 34&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_735bfacf4456c6744e70faba7d307157.setContent(html_3d8f5e91df551f5992bd17cc892f5d67);



        circle_d10f62e696347ba5eade602fce685b39.bindPopup(popup_735bfacf4456c6744e70faba7d307157)
        ;




            circle_d10f62e696347ba5eade602fce685b39.bindTooltip(
                `&lt;div&gt;
                     Nigeria
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_f0dc039816ad9e2611771c01083f8701 = L.circle(
                [-6.8699697, -75.0458515],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_3e3fdd6087c9c758781225814d190eb5 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_5e057e3615a3002fbfda904ddd04bb6b = $(`&lt;div id=&quot;html_5e057e3615a3002fbfda904ddd04bb6b&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Peru&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 11&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 7&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 9&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 2&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_3e3fdd6087c9c758781225814d190eb5.setContent(html_5e057e3615a3002fbfda904ddd04bb6b);



        circle_f0dc039816ad9e2611771c01083f8701.bindPopup(popup_3e3fdd6087c9c758781225814d190eb5)
        ;




            circle_f0dc039816ad9e2611771c01083f8701.bindTooltip(
                `&lt;div&gt;
                     Peru
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_06822684b27f7a99b85fff5ff67b70b9 = L.circle(
                [8.559559, -81.1308434],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_1c08532250ba038e335cc00949cdf92a = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_6a905a12339baa58f45f79d188326bf2 = $(`&lt;div id=&quot;html_6a905a12339baa58f45f79d188326bf2&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Panama&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_1c08532250ba038e335cc00949cdf92a.setContent(html_6a905a12339baa58f45f79d188326bf2);



        circle_06822684b27f7a99b85fff5ff67b70b9.bindPopup(popup_1c08532250ba038e335cc00949cdf92a)
        ;




            circle_06822684b27f7a99b85fff5ff67b70b9.bindTooltip(
                `&lt;div&gt;
                     Panama
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_9c4af2094ce25c52ac9aed8d0309984b = L.circle(
                [0.9713095, 7.02255],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_e842df77dc786283d24eca5d2dddf1ca = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_d1a6c1a93f89a932af1cbcc9b6ff58e8 = $(`&lt;div id=&quot;html_d1a6c1a93f89a932af1cbcc9b6ff58e8&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Sao Tome and Principe&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_e842df77dc786283d24eca5d2dddf1ca.setContent(html_d1a6c1a93f89a932af1cbcc9b6ff58e8);



        circle_9c4af2094ce25c52ac9aed8d0309984b.bindPopup(popup_e842df77dc786283d24eca5d2dddf1ca)
        ;




            circle_9c4af2094ce25c52ac9aed8d0309984b.bindTooltip(
                `&lt;div&gt;
                     Sao Tome and Principe
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_2bf8c21c581fff655f0fc31245aeeb54 = L.circle(
                [10.2735633, -84.0739102],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_43ae148bfbd4ceca77fa2dc1050a4d48 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_efb7010e6e2e5c0ab260b03ee2e56aab = $(`&lt;div id=&quot;html_efb7010e6e2e5c0ab260b03ee2e56aab&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Costa Rica&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_43ae148bfbd4ceca77fa2dc1050a4d48.setContent(html_efb7010e6e2e5c0ab260b03ee2e56aab);



        circle_2bf8c21c581fff655f0fc31245aeeb54.bindPopup(popup_43ae148bfbd4ceca77fa2dc1050a4d48)
        ;




            circle_2bf8c21c581fff655f0fc31245aeeb54.bindTooltip(
                `&lt;div&gt;
                     Costa Rica
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_9e8653c30a6b3bee9d73bbfd427d635e = L.circle(
                [-24.7761086, 134.755],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_06f310743fd05836da2ed2fa929a6621 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_8db76e04642f10de52d355669820a0dc = $(`&lt;div id=&quot;html_8db76e04642f10de52d355669820a0dc&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Australia&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 5&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 4&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_06f310743fd05836da2ed2fa929a6621.setContent(html_8db76e04642f10de52d355669820a0dc);



        circle_9e8653c30a6b3bee9d73bbfd427d635e.bindPopup(popup_06f310743fd05836da2ed2fa929a6621)
        ;




            circle_9e8653c30a6b3bee9d73bbfd427d635e.bindTooltip(
                `&lt;div&gt;
                     Australia
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_7572d710513bc3b1a2598570ff72c77a = L.circle(
                [12.7503486, 122.7312101],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_9b3e022944875c24ff77362e95125885 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_8ba10250e2ba6de5f0a87c91ecb1f7e6 = $(`&lt;div id=&quot;html_8ba10250e2ba6de5f0a87c91ecb1f7e6&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Philippines&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 12&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 0&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 11&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 7&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 5&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_9b3e022944875c24ff77362e95125885.setContent(html_8ba10250e2ba6de5f0a87c91ecb1f7e6);



        circle_7572d710513bc3b1a2598570ff72c77a.bindPopup(popup_9b3e022944875c24ff77362e95125885)
        ;




            circle_7572d710513bc3b1a2598570ff72c77a.bindTooltip(
                `&lt;div&gt;
                     Philippines
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_3efe09f1bdcfd803f5f630cb45d1f766 = L.circle(
                [4.099917, -72.9088133],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_f278275f49cc89a750c2d18f712acee3 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_eda30bb52fc4fc8f8e771ba1091a81e5 = $(`&lt;div id=&quot;html_eda30bb52fc4fc8f8e771ba1091a81e5&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Colombia&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 7&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 5&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 6&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 1&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_f278275f49cc89a750c2d18f712acee3.setContent(html_eda30bb52fc4fc8f8e771ba1091a81e5);



        circle_3efe09f1bdcfd803f5f630cb45d1f766.bindPopup(popup_f278275f49cc89a750c2d18f712acee3)
        ;




            circle_3efe09f1bdcfd803f5f630cb45d1f766.bindTooltip(
                `&lt;div&gt;
                     Colombia
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_fd69a72e22f2be5d10d9592eb183990d = L.circle(
                [51.1638175, 10.4478313],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_73fc1b507d8443a30c03ef4370ae4f5e = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_1a23708ed6b5749e1320c2bb6aef9837 = $(`&lt;div id=&quot;html_1a23708ed6b5749e1320c2bb6aef9837&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Germany&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 3&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 1&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 1&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 2&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_73fc1b507d8443a30c03ef4370ae4f5e.setContent(html_1a23708ed6b5749e1320c2bb6aef9837);



        circle_fd69a72e22f2be5d10d9592eb183990d.bindPopup(popup_73fc1b507d8443a30c03ef4370ae4f5e)
        ;




            circle_fd69a72e22f2be5d10d9592eb183990d.bindTooltip(
                `&lt;div&gt;
                     Germany
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_adb4483984a72a4c2b2cc6e9bb28ea68 = L.circle(
                [31.1667049, 36.941628],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_8962cb229e2d3c730dc6d4049dafb7ae = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_9df2c0edbbd0de17bddca57d9ff8146d = $(`&lt;div id=&quot;html_9df2c0edbbd0de17bddca57d9ff8146d&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Jordan&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 9&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 4&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 0&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 9&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 0&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_8962cb229e2d3c730dc6d4049dafb7ae.setContent(html_9df2c0edbbd0de17bddca57d9ff8146d);



        circle_adb4483984a72a4c2b2cc6e9bb28ea68.bindPopup(popup_8962cb229e2d3c730dc6d4049dafb7ae)
        ;




            circle_adb4483984a72a4c2b2cc6e9bb28ea68.bindTooltip(
                `&lt;div&gt;
                     Jordan
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );


            var circle_6d7c04cfccf3ee68b356e8faee168c40 = L.circle(
                [-10.3333333, -53.2],
                {&quot;bubblingMouseEvents&quot;: true, &quot;color&quot;: &quot;#3388ff&quot;, &quot;dashArray&quot;: null, &quot;dashOffset&quot;: null, &quot;fill&quot;: true, &quot;fillColor&quot;: &quot;#3388ff&quot;, &quot;fillOpacity&quot;: 0.2, &quot;fillRule&quot;: &quot;evenodd&quot;, &quot;lineCap&quot;: &quot;round&quot;, &quot;lineJoin&quot;: &quot;round&quot;, &quot;opacity&quot;: 1.0, &quot;radius&quot;: 60000, &quot;stroke&quot;: true, &quot;weight&quot;: 3}
            ).addTo(map_1a5a9d7afe5e8792bab5cb12da30d363);


        var popup_6610819fb32d68f4d4fbbc9b05c1fc50 = L.popup({&quot;maxWidth&quot;: &quot;100%&quot;});



                var html_32c1399998fa2ffb01aa57d2eb03049c = $(`&lt;div id=&quot;html_32c1399998fa2ffb01aa57d2eb03049c&quot; style=&quot;width: 100.0%; height: 100.0%;&quot;&gt;&lt;h4&gt;Brazil&lt;/h4&gt;&lt;br&gt;                     &lt;b&gt;Count&lt;/b&gt;: 11&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Undergraduates&lt;/b&gt;: 2&lt;br&gt;                     &lt;b&gt;Master&#x27;s&lt;/b&gt;: 3&lt;br&gt;                     &lt;b&gt;Doctoral&lt;/b&gt;: 6&lt;br&gt;&lt;br&gt;                     &lt;b&gt;On OPT&lt;/b&gt;: 2&lt;br&gt;&lt;br&gt;                     &lt;b&gt;Male&lt;/b&gt;: 8&lt;br&gt;                     &lt;b&gt;Female&lt;/b&gt;: 3&lt;br&gt;                     &lt;/div&gt;`)[0];
                popup_6610819fb32d68f4d4fbbc9b05c1fc50.setContent(html_32c1399998fa2ffb01aa57d2eb03049c);



        circle_6d7c04cfccf3ee68b356e8faee168c40.bindPopup(popup_6610819fb32d68f4d4fbbc9b05c1fc50)
        ;




            circle_6d7c04cfccf3ee68b356e8faee168c40.bindTooltip(
                `&lt;div&gt;
                     Brazil
                 &lt;/div&gt;`,
                {&quot;sticky&quot;: true}
            );

&lt;/script&gt;" style="position:absolute;width:100%;height:100%;left:0;top:0;border:none !important;" allowfullscreen webkitallowfullscreen mozallowfullscreen></iframe></div></div>



### Save the file
Run the following code block and enter the file name and select the location where you would like to save your output file.


```python
# prompt user for file name and check that it is a valid file name
file_name = input("Enter file name: ")
check = True
while check:
    # check that filename does not include special characters
    if not re.match("[- _a-zA-Z0-9]*$", file_name):
        print("Please only enter letters, numbers, underscores, or hyphens.")
        file_name = input("Enter file name: ")
    # check that user actually entered a filename
    elif not file_name:
        print("Please enter a filename.")
        file_name = input("Enter file name: ")
    else:
        check = False

# prompt user for where to save the file
directory = filedialog.askdirectory()
while not directory:
    print("You must choose a location to save your map.")
    directory = filedialog.askdirectory()
# change directory to the selected directory
os.chdir(directory)

# save map to html in selected directory
m.save(file_name+".html")
```

    Enter file name: final_test


### You're done!
You can take the resulting HTML file to add to our WordPress instance. You can find instructions on how to update WordPress in the Digital Media Assistant manual in OneNote. 
