import numpy as np
import pandas as pd
import gpxpy
from matplotlib import pyplot as plt
from datetime import datetime
from garmin_fit_sdk import Decoder, Stream
from pathlib import Path
from fitparse import FitFile


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
    stream = Stream.from_file(filename)
    decoder = Decoder(stream)
    message, error = decoder.read()
    
    # fit=dict()
    # for key in ['timestamp', 'position_lat', 'position_long', 'enhanced_speed', 'enhanced_altitude', 'altitude', 'speed']:
    #     fit[key]=[]
    # for i in fitfile:
    #     for key in ['timestamp', 'position_lat', 'position_long', 'enhanced_speed', 'enhanced_altitude', 'altitude', 'speed']:
    #         fit[key].append(i[key])
    
    # t0 = fit['timestamp'][0]
    # for n,i in enumerate(fit['timestamp']):
    #     fit['timestamp'][n] = (i-t0).total_seconds()
    
    return message,error


# gpx_filename = 'C:/Users/morit/OneDrive/Anwendungen/Outdoor/Read Garmin Files/ActivityData/Dove Lake Tasmania/activity_22506825181.gpx'
# gpx = import_gpx(gpx_filename)
base = Path(__file__).parent/'ActivityData'
fit_filename = base/'Test Hughenden/2026-07-27 17.05.35.fit'
msg,error = import_fit(fit_filename) 

f = FitFile(str(fit_filename))
last = list(f.get_messages('record'))[-1]
for d in last:
    print(d.name, d.value, d.units)

#%%        
        
fig,ax = plt.subplots()

# ax.plot(fit['timestamp'],fit['altitude'],color='k')
ax.plot(d1['timestamp'],d1['enhanced_altitude'],color='k')
ax.plot(d2['time'],d2['elevation'],color='red',linestyle='-')
