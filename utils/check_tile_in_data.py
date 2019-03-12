#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Checks if tile (z, x, y) contains inside regions (lua data file).
"""

import argparse
from collections import defaultdict

from pyosm.point import LatLong, zxy_to_latlong
from pyosm.polygon import Polygon


def parse_args():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("-i", "--input", type=str, required=True, help="input lua data file")
    p.add_argument("-z", type=int, required=True, help="z coord")
    p.add_argument("-x", type=int, required=True, help="x coord")
    p.add_argument("-y", type=int, required=True, help="y coord")
    return p.parse_args()


def parse_lua_data_file(filepath):
    polygons = defaultdict(list)
    section = 0
    with open(filepath, "rb") as f:
        for line in f.readlines():
            if line.strip() in ["local region = {", "return region"]:
                continue

            if line.strip() == "{":
                section += 1

            if line.strip().startswith("{lon="):
                lon = line.split(",")[0].split("=")[1]
                lat = line.split(",")[1].split("=")[1][:-1]
                polygons[section].append(LatLong(lat=float(lat), long=float(lon)))
    return polygons


def main():
    args = parse_args()

    ll = zxy_to_latlong(args.z, args.x, args.y)
    polygons = parse_lua_data_file(args.input)
    for k, points in polygons.items():
        polygon = Polygon(points)
        if ll in polygon:
            print("{key}: {point} in {polygon}".format(key=k, point=ll, polygon=polygon))


if __name__ == "__main__":
    main()
