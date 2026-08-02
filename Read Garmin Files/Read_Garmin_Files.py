import numpy as np
import pandas as pd
import gpxpy
from matplotlib import pyplot as plt
from datetime import datetime
from garmin_fit_sdk import Decoder, Stream
from pathlib import Path
from fitparse import FitFile


# gpx_filename = 'C:/Users/morit/OneDrive/Anwendungen/Outdoor/Read Garmin Files/ActivityData/Dove Lake Tasmania/activity_22506825181.gpx'
# gpx = import_gpx(gpx_filename)
# base = Path(__file__).parent/'ActivityData'
# fit_filename = base/'Test Hughenden/2026-07-27 17.05.35.fit'
base = Path.home()/'OneDrive'/'Desktop'
# fit_filename = base / '2026-08-02 15.11.42.fit'#
file_paths={}
file_paths['WORKING'] = base / '2026-08-02 15.59.25.fit'
file_paths['tc'] = base / '2026-08-02 16.19.58.fit'
file_paths['tc_compass'] = base / '2026-08-02 16.20.21.fit'#
file_paths['tc_altimeter'] = base / '2026-08-02 16.20.51.fit'
file_paths['tc_map'] = base / '2026-08-02 16.21.34.fit'
file_paths['dontknow'] = base / '2026-08-02 16.22.09.fit'
file_paths['ONLYTC'] = base / '2026-08-02 16.22.09.fit'

activity={}
for name,path in file_paths.items():
    messages, errors = Decoder(Stream.from_file(path)).read()    
    print('\n'+name)
    print(messages.keys())
    activity[name] = pd.DataFrame(messages['record_mesgs'])
    
#%%
a = activity['WORKING']
t = a.timestamp
d1 = np.array([a.developer_fields[n][0] for n in range(len(a.developer_fields))])
d2 = np.array([a.developer_fields[n][5] for n in range(len(a.developer_fields))])
d3 = np.array([a.developer_fields[n][6] for n in range(len(a.developer_fields))])
d4 = np.array([a.developer_fields[n][7] for n in range(len(a.developer_fields))])
ea = a.enhanced_altitude


fig,ax1 = plt.subplots()
ax2 = ax1.twinx()
# ax.plot(t,d1)
# ax1.plot(t,d2)
ax1.plot(t,d3)
ax1.plot(t,d4-870)
ax2.plot(t,ea,':')

# ax1.set_ylim((101850,101900))

    

