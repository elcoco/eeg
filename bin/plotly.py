#!/usr/bin/python3
#import plotly.plotly as py
import plotly
#import plotly.tools as tls
#print(plotly.__version__)  # version >1.9.4 required
from plotly.graph_objs import Scatter, Layout

plotly.offline.plot({
"data": [
    Scatter(x=[1, 2, 3, 4], y=[4, 1, 3, 7])
],
"layout": Layout(
    title="hello world"
)
})
