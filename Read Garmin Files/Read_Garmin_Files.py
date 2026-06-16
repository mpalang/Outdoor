import numpy as np
import pandas as pd
import gpxpy
from matplotlib import pyplot as plt

filename = 'C:/Users/morit/OneDrive/Anwendungen/Outdoor/Read Garmin Files/ActivityData/Dove Lake Tasmania/activity_22506825181.gpx'
with open(filename, 'r') as gpx_file:
    gpx_raw = gpxpy.parse(gpx_file)
    
points = gpx_raw.tracks[0].segments[0].points
del(gpx_raw)

gpx=dict()
keys=['time','latitude','longitude','elevation']
for key in keys:
    gpx[key]=[]
for i in points:
    for key in keys:
        gpx[key].append(getattr(i,key))

        
    
filename = 'C:/Users/morit/OneDrive/Anwendungen/Outdoor/Read Garmin Files/ActivityData/Dove Lake Tasmania/22506825181/22506825181_ACTIVITY.fit'
from garmin_fit_sdk import Decoder, Stream

fitfile = Decoder(Stream.from_file(filename)).read()[0]['record_mesgs']

fit=dict()
for key in ['timestamp', 'position_lat', 'position_long', 'enhanced_speed', 'enhanced_altitude', 'altitude', 'speed']:
    fit[key]=[]
for i in fitfile:
    for key in ['timestamp', 'position_lat', 'position_long', 'enhanced_speed', 'enhanced_altitude', 'altitude', 'speed']:
        fit[key].append(i[key])

del(i,fitfile,points,keys,key,filename,gpx_file)
#%%        
        
fig,ax = plt.subplots()

ax.plot(fit['timestamp'],fit['enhanced_altitude'])
ax.plot(gpx['time'],fit['altitude'])
