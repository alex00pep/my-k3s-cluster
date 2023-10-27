#!/usr/bin/env python

import sys
from configparser import ConfigParser

config = ConfigParser()
config.read_file(sys.stdin)

for sec in config.sections():
    print("declare -A %s" % sec)
    all_k_v = []
    for key, val in config.items(sec):
        k_v_str = '[%s]="%s"' % (key, val)
        all_k_v.append(k_v_str)
    arr = "{}=( {} )".format(sec, " ".join(all_k_v))
    print(arr)