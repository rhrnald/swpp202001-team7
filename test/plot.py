import os, sys, pathlib

try:
    import numpy as np
    import matplotlib as mpl
    import matplotlib.pyplot as plt
except:
    print('No module named numpy or matplotlib')
    exit()

LOG_ORIGINAL = os.path.join(str(pathlib.Path(__file__).parent.absolute()), 'original.log')
LOG_CONVERTED = os.path.join(str(pathlib.Path(__file__).parent.absolute()), 'converted.log')

f_original = open(LOG_ORIGINAL, 'r')
f_converted = open(LOG_CONVERTED, 'r')

conv = lambda xyz : [xyz[0], float(xyz[1]), int(xyz[2])]

s_original = [conv(x.split()) for x in f_original.read().strip().split('\n')]
s_converted = [conv(x.split()) for x in f_converted.read().strip().split('\n')]

colors = plt.cm.jet(np.linspace(0, 1, 100))

xy_max = 0

for original, converted in zip(s_original, s_converted):
    o_name, o_cost, o_heap = original
    c_name, c_cost, c_heap = converted

    ratio = int(50 + 99.9 / np.pi * np.arctan(5 * (1.0 - o_cost / c_cost)))
    xy_max = max(xy_max, max(o_cost, c_cost))

    plt.scatter(o_cost, c_cost, marker='o', color=colors[ratio], alpha=1)

plt.plot([0, xy_max], [0, xy_max], color='black', linewidth=0.1)

plt.xscale('log')
plt.yscale('log')
plt.xlabel('Original Cost')
plt.ylabel('Converted Cost')
plt.show()

f_original.close()
f_converted.close()
