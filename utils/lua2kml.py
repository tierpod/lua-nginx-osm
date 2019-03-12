#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Converts lua data file to kml file.
"""

import argparse

XML_HEADER = """<?xml version="1.0" encoding="UTF-8"?> <kml xmlns="http://earth.google.com/kml/2.0"> <Document> <Placemark> <MultiGeometry>"""
XML_FOOTER = """</MultiGeometry> <Style> <PolyStyle>  <color>#a00000ff</color> <outline>0</outline> </PolyStyle> </Style> </Placemark> </Document> </kml>"""
POLYGON_HEADER = """<Polygon> <outerBoundaryIs> <LinearRing>  <coordinates>"""
POLYGON_FOOTER = """</coordinates> </LinearRing> </outerBoundaryIs>  </Polygon>"""


def parse_args():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("-i", "--input", type=str, required=True, help="input lua data file")
    return p.parse_args()


def parse_lua_data_file(filepath):
    with open(filepath, "rb") as f:
        print(XML_HEADER)
        for line in f.readlines():

            if line.strip() in ["local region = {", "return region"]:
                continue

            if line.strip() == "{":
                print(POLYGON_HEADER)

            if line.strip() == "},":
                print(POLYGON_FOOTER)

            if line.strip().startswith("{lon="):
                lon = line.split(",")[0].split("=")[1]
                lat = line.split(",")[1].split("=")[1][:-1]
                print("%s,%s,0" % (lon, lat))

        print XML_FOOTER


def main():
    args = parse_args()
    parse_lua_data_file(args.input)


if __name__ == "__main__":
    main()
