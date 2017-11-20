#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re
import string

res = []
for line in sys.stdin:
    m = re.match('(-)?\d+\.\d+,(-)?\d+\.\d+', line)
    if m:
        res.append(m.group().translate(string.maketrans(',', ' ')))

print len(res)

# KML files from geofabrik has clockwise points order. CGAL need counterclockwise points order.
for i in xrange(len(res)-1, 0, -1):
    print res[i]

# for line in res:
#    print line
