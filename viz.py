import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sbrn
import pandas as pd
from matplotlib.colors import LogNorm
import sys
import os
sbrn.set_context('paper')

_fontsize = 13

#sbrn.set_style("ticks", {"xtick.major.size": 12, "ytick.major.size": 12})
custom = {"axes.edgecolor": "black","grid.linestyle": "dashed", "grid.color": "gray"}
sbrn.set_style("whitegrid", rc = custom)

dataSet = pd.read_table(sys.argv[1], skiprows = 0, header=0, delimiter=",")
print(dataSet.head())

ax = sbrn.barplot(data=dataSet, x="threading", y="t(sec)",hue="phase")

#ax.set_xscale("log")
ax.set_yscale("log")
ax.set_xlabel('Threading Model',fontsize=_fontsize);
ax.set_ylabel('t(sec)',fontsize=_fontsize);

ax.legend(fontsize=_fontsize)
#ax.set_title(os.path.splitext(sys.argv[1])[0],fontsize=_fontsize)

plt.xticks(fontsize=_fontsize)
plt.tight_layout()
plt.savefig("./PNG/"+sys.argv[1]+".png", dpi=300)
plt.savefig("./SVG/"+sys.argv[1]+".svg", dpi=300)
