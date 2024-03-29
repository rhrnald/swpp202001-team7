#python3 log_checker.py (test case name) (original output) (optimized output) (original log) (optimized log)
import os, sys, pathlib
import subprocess

TC_LEN = 15
TC_LONG_LEN = 40
COST_LEN = 20

RED = '\33[31m'
BLUE = '\33[34m'
GREEN = '\33[32m'
ORIG = '\33[0m'

LOG_ORIGINAL = os.path.join(str(pathlib.Path(__file__).parent.absolute()), 'original.log')
LOG_CONVERTED = os.path.join(str(pathlib.Path(__file__).parent.absolute()), 'converted.log')

if len(sys.argv) == 1:
    print('========================================')
    print('We wrote test outputs as the below form:')
    print('>> [original cost]([original heap usage]) --> [optimized cost]([optimized heap usage])')
    print('>>   +-total difference[cost difference(heap usage difference)]')
    print()
    print('And the following labels:')
    print('>> ' + GREEN + '[AC]' + ORIG + ' to represent \'ACcepted output!\'')
    print('>> ' + BLUE + '[RE]' + ORIG +  ' to represent \'Runtime Error!\'  (different return values)')
    print('>> ' + RED + '[WA]' + ORIG +   ' to represent \'Wrong Answer!\'   (different outputs)')
    print('========================================')
    exit(0)

if len(sys.argv) != 6 and len(sys.argv) != 7:
    sys.stderr.write('please add 5 arguments!')
    sys.stderr.write('python3 log_checker.py (test case name) (original output) (optimized output) (original log) (optimized log)')
    exit(1)

silence = len(sys.argv) == 7

def bash(command):
    s = subprocess.check_output(command, shell=True)
    return str(s)

def colored(text, color):
    return color + text + ORIG

def fix_width(text, width):
    return text + ' ' * (width - len(text))

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

def stat(c, h):
    #return str(c + h) + '(' + str(c) + ',' + str(h) + ')'
    return str(c) + '(' + str(h) + ')'

def delta(c1, h1, c2, h2):
    dt = round(c2 + h2 - c1 - h1, 2)
    dc = round(c2 - c1, 2)
    dh = round(h2 - h1, 2)
    ret = ''

    if dt > 0:
        ret = ret + colored('+' + str(dt), RED)
    elif dt < 0:
        ret = ret + colored(str(dt), BLUE)
    else:
        ret = ret + colored(str(dt), GREEN)

    ret = ret + '['
    if dc > 0:
        ret = ret + colored('+' + str(dc), RED)
    elif dc < 0:
        ret = ret + colored(str(dc), BLUE)
    else:
        ret = ret + colored(str(dc), GREEN)

    ret = ret + '('
    if dh > 0:
        ret = ret + colored('+' + str(dh), RED)
    elif dh < 0:
        ret = ret + colored(str(dh), BLUE)
    else:
        ret = ret + colored(str(dh), GREEN)
    ret = ret + ')'
    ret = ret + ']'
    return ret



test_case = sys.argv[1].split('/')[-1]
full_test_case = '/'.join(sys.argv[1].split('/')[2:])
o1 = read_output(sys.argv[2])
o2 = read_output(sys.argv[3])
r1, c1, h1 = read_log(sys.argv[4])
r2, c2, h2 = read_log(sys.argv[5])

if o1 == o2:
    if r1 == r2:
        if silence:
            print('>> Testing ' + fix_width(full_test_case, TC_LONG_LEN) + colored(' [AC] ', GREEN))
        else:
            print('>> Testing ' + fix_width(test_case, TC_LEN) + colored(' [AC] ', GREEN) + '   ' \
                    + fix_width(stat(c1, h1), COST_LEN) + ' --> ' \
                    + fix_width(stat(c2, h2), COST_LEN) + '  ' \
                    + delta(c1, h1, c2, h2))
            bash('echo ' + sys.argv[1] + ' ' + str(c1) + ' ' + str(h1) + ' >> ' + LOG_ORIGINAL)
            bash('echo ' + sys.argv[1] + ' ' + str(c2) + ' ' + str(h2) + ' >> ' + LOG_CONVERTED)
    else:
        if silence:
            print('>> Testing ' + fix_width(full_test_case, TC_LONG_LEN) + colored(' [RE] ', BLUE))
        else:
            print('>> Testing ' + fix_width(test_case, TC_LEN) + colored(' [RE] ', BLUE) \
                    + ' Return values are not same!')
else:
    if silence:
        print('>> Testing ' + fix_width(full_test_case, TC_LONG_LEN) + colored(' [WA] ', RED))
    else:
        print('>> Testing ' + fix_width(test_case, TC_LEN) + colored(' [WA] ', RED) \
                + ': ' + colored('Output values are not same!', RED))
