import os, sys, pathlib

try:
    import numpy as np
    import matplotlib as mpl
    import matplotlib.pyplot as plt
except:
    print('No module named numpy or matplotlib')
    exit(1)

LOG_ORIGINAL = os.path.join(str(pathlib.Path(__file__).parent.absolute()), 'original.log')
LOG_CONVERTED = os.path.join(str(pathlib.Path(__file__).parent.absolute()), 'converted.log')
PLOT_SETS = ['benchmarks', 'ours']
#PLOT_SETS = ['benchmarks']

def simplified_name(name):
    # ex. matmul4.2: 2nd data of matmul4
    sp = name.split('/')
    return sp[3] + '.' + sp[5][5]

def get_set(name):
    return name.split('/')[2]

f_original = open(LOG_ORIGINAL, 'r')
f_converted = open(LOG_CONVERTED, 'r')

conv = lambda xyz : [xyz[0], float(xyz[1]), int(xyz[2])]

s_original = [conv(x.split()) for x in f_original.read().strip().split('\n')]
s_converted = [conv(x.split()) for x in f_converted.read().strip().split('\n')]

colors = plt.cm.jet(np.linspace(0, 1, 100))

for original, converted in zip(s_original, s_converted):
    o_name, o_cost, o_heap = original
    c_name, c_cost, c_heap = converted

    if get_set(o_name) not in PLOT_SETS:
        continue

    ratio = int(50 + 99.9 / np.pi * np.arctan(5 * (1.0 - o_cost / c_cost)))
    plt.scatter(o_cost, c_cost / o_cost, marker='o', color=colors[ratio], alpha=1)
    plt.text(o_cost*1.05, (c_cost / o_cost) + 0.01, simplified_name(o_name), fontsize=7, alpha=0.5)

plt.axhline(1, color='black', linewidth=.5)

plt.xscale('log')
plt.xlabel('Original Cost')
plt.ylabel('Cost Ratio   ([Converted Cost] / [Original Cost])')
plt.show()

f_original.close()
f_converted.close()
