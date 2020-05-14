#python3 log_checker.py (test case name) (original output) (optimized output) (original log) (optimized log)
import os, sys

RED = '\33[31m'
BLUE = '\33[34m'
GREEN = '\33[32m'
ORIG = '\33[0m'

if len(sys.argv) == 1:
    print('========================================')
    print('We wrote test outputs as the below form:')
    print('>> [original cost]([original heap usage]) --> [optimized cost]([optimized heap usage])')
    print()
    print('And the following labels:')
    print('>> ' + GREEN + '[AC]' + ORIG + ' to represent \'ACcepted output!')
    print('>> ' + BLUE + '[RE]' + ORIG + ' to represent \'Runtime Error! (different return values)')
    print('>> ' + RED + '[WA]' + ORIG + ' to represent \'Wrong Answer! (different outputs)')
    print('========================================')
    exit(0)

if len(sys.argv) != 6:
    sys.stderr.write('please add 5 arguments!')
    sys.stderr.write('python3 log_checker.py (test case name) (original output) (optimized output) (original log) (optimized log)')
    exit(1)


def read_output(arg):
    f = open(arg, 'r')
    s = f.read()
    f.close()
    return s

def read_log(arg):
    f = open(arg, 'r')
    splits = f.read().strip().split('\n')
    return_value = int(splits[0][splits[0].find(':')+1:].strip())
    cost = float(splits[1][splits[1].find(':')+1:].strip())
    heap_usage = int(splits[2][splits[2].find(':')+1:].strip())
    f.close()
    return (return_value, cost, heap_usage)


test_case = sys.argv[1]
o1 = read_output(sys.argv[2])
o2 = read_output(sys.argv[3])
r1, c1, h1 = read_log(sys.argv[4])
r2, c2, h2 = read_log(sys.argv[5])

if o1 == o2:
    if r1 == r2:
        print('>> Testing ' + test_case + GREEN + ' [AC] ' + ORIG + '\t' \
                + str(c1) + '(' + str(h1) + ')\t' + ' --> ' \
                + str(c2) + '(' + str(h2) + ')')
    else:
        print('>> Testing ' + test_case + BLUE + ' [RE] ' + ORIG \
                + ' Return values are not same!')
else:
    print('>> Testing ' + test_case + RED + ' [WA] ' + ORIG \
            + ': ' + RED + 'Output values are not same!' + ORIG)
