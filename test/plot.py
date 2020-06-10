import os, sys, pathlib

try:
    import numpy as np
    import matplotlib as mpl
    import matplotlib.pyplot as plt
except:
    print('No module named numpy or matplotlib')
    exit(1)

def selection_log():
    wholelist = os.listdir(str(pathlib.Path(__file__).parent.absolute()))
    filelist = []
    for name in wholelist:
        if name[-4:] == '.log':
            filelist.append(name)
    filelist.sort()
    return filelist

def get_selection(helperstr=''):
    filelist = selection_log()
    print('==========================')
    print(helperstr)
    print('==========================')
    for i, name in enumerate(filelist):
        print(str(i+1) + ')', name)
    print('==========================')
    inp = input()
    return filelist[int(inp) - 1]

log_original = get_selection('Which one do you want to use as the original log?')
log_converted = get_selection('Which one do you want to use as the converted log?')

LOG_ORIGINAL = os.path.join(str(pathlib.Path(__file__).parent.absolute()), log_original)
LOG_CONVERTED = os.path.join(str(pathlib.Path(__file__).parent.absolute()), log_converted)
#PLOT_SETS = ['benchmarks', 'ours']
PLOT_SETS = ['benchmarks']

def simplified_name(name):
    # ex. matmul4.2: 2nd data of matmul4
    sp = name.split('/')
    return sp[3] + '.' + sp[5][5]

def get_set(name):
    return name.split('/')[2]

f_original = open(LOG_ORIGINAL, 'r')
f_converted = open(LOG_CONVERTED, 'r')

#conv = lambda xyz : [xyz[0], float(xyz[1]), int(xyz[2])]

name_original = set([])
name_converted = set([])

data_original = {}
data_converted = {}

for xyz in f_original.read().strip().split('\n'):
    x, y, z = xyz.split()
    name_original.add(x)
    data_original[x] = (float(y), int(z))

for xyz in f_converted.read().strip().split('\n'):
    x, y, z = xyz.split()
    name_converted.add(x)
    data_converted[x] = (float(y), int(z))

colors = plt.cm.jet(np.linspace(0, 1, 100))

o_total = 0
c_total = 0

#for original, converted in zip(s_original, s_converted):
for name in (name_original & name_converted):
    o_cost, o_heap = data_original[name]
    c_cost, c_heap = data_converted[name]
    o_cost += o_heap
    c_cost += c_heap

    o_total += o_cost
    c_total += c_cost

    if get_set(name) not in PLOT_SETS:
        continue

    ratio = int(50 + 99.9 / np.pi * np.arctan(5 * (1.0 - o_cost / c_cost)))
    plt.scatter(o_cost, c_cost / o_cost, marker='o', color=colors[ratio], alpha=1)
    plt.text(o_cost*1.05, (c_cost / o_cost) + 0.01, simplified_name(name), fontsize=7, alpha=0.5)

plt.axhline(1, color='black', linewidth=.5)

for i in range(1, 5):
    plt.axhline(0.2 * i, color='black', linewidth=.1)

print('Original Cost Sum:', o_total)
print('Converted Cost Sum:', c_total)
print('Optimization Rate:', str(round(100 * (o_total - c_total) / o_total, 2)) + '%')

plt.xscale('log')
plt.xlabel('Original Cost')
plt.ylabel('Cost Ratio   ([Converted Cost] / [Original Cost])')
plt.show()

f_original.close()
f_converted.close()
