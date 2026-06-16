import numpy as np
import pandas as pd
import gpxpy
from matplotlib import pyplot as plt
from datetime import datetime
from garmin_fit_sdk import Decoder, Stream

def import_gpx(filename):
    
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
    
    t0 = gpx['time'][0]
    for n,i in enumerate(gpx['time']):
        gpx['time'][n] = (i-t0).total_seconds()
    
    return gpx
            
def import_fit(filename):
    fitfile = Decoder(Stream.from_file(filename)).read()[0]['record_mesgs']
    
    fit=dict()
    for key in ['timestamp', 'position_lat', 'position_long', 'enhanced_speed', 'enhanced_altitude', 'altitude', 'speed']:
        fit[key]=[]
    for i in fitfile:
        for key in ['timestamp', 'position_lat', 'position_long', 'enhanced_speed', 'enhanced_altitude', 'altitude', 'speed']:
            fit[key].append(i[key])
    
    t0 = fit['timestamp'][0]
    for n,i in enumerate(fit['timestamp']):
        fit['timestamp'][n] = (i-t0).total_seconds()
    
    return fit


# gpx_filename = 'C:/Users/morit/OneDrive/Anwendungen/Outdoor/Read Garmin Files/ActivityData/Dove Lake Tasmania/activity_22506825181.gpx'
# gpx = import_gpx(gpx_filename)

fit_filename = 'C:/Users/morit/OneDrive/Anwendungen/Outdoor/Read Garmin Files/ActivityData/Dove Lake Tasmania/22506825181/22506825181_ACTIVITY.fit'
d1 = import_fit(fit_filename) #This file has elevation data from Garmin Device (with barometric adjustment)
gpx_filename = 'C:/Users/morit/OneDrive/Anwendungen/Outdoor/Read Garmin Files/ActivityData/Dove Lake Tasmania/activity_22506825181_alternative.gpx'
d2 = import_gpx(gpx_filename) #This file has elevation data from gps dataset

#%%        
        
fig,ax = plt.subplots()

# ax.plot(fit['timestamp'],fit['altitude'],color='k')
ax.plot(d1['timestamp'],d1['enhanced_altitude'],color='k')
ax.plot(d2['time'],d2['elevation'],color='red',linestyle='-')
