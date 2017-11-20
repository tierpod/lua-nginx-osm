#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys

XML_HEADER = """<?xml version="1.0" encoding="UTF-8"?> <kml xmlns="http://earth.google.com/kml/2.0"> <Document> <Placemark> <MultiGeometry>"""
XML_FOOTER = """</MultiGeometry> <Style> <PolyStyle>  <color>#a00000ff</color> <outline>0</outline> </PolyStyle> </Style> </Placemark> </Document> </kml>"""
POLYGON_HEADER = """<Polygon> <outerBoundaryIs> <LinearRing>  <coordinates>"""
POLYGON_FOOTER = """</coordinates> </LinearRing> </outerBoundaryIs>  </Polygon>"""

print XML_HEADER
for line in sys.stdin:

    if line.strip() == "local region = {":
        continue
    if line.strip() == "return region":
        continue

    if line.strip() == "{":
        print POLYGON_HEADER
    if line.strip() == "},":
        print POLYGON_FOOTER

    if line.strip().startswith("{lon="):
        lon = line.split(",")[0].split("=")[1]
        lat = line.split(",")[1].split("=")[1][:-1]
        print "%s,%s,0" % (lon, lat)

print XML_FOOTER
