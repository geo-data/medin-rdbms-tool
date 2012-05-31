#!/usr/bin/env python

# This example script is designed to be passed to the `medin-metadata` tool
# using the `--external-srs-identifier` argument e.g.:
#
#   medin-metadata output fgdc --external-srs-identifier external-srs-identifier.py fgdc-metadata.xml
#

import sys, json

# get the FGDC XML from standard input
spref = sys.stdin.read()

# Do some naive string matching to determine some EPSG
# identifiers. Alternatively the logic here could parse out the XML
# and do some more comprehensive analysis with some relevant domain
# knowledge.
output = {}
if 'OSGB' in spref or ('0.999601' in spref and '49.000000' in spref):
    output['id'] = 'urn:ogc:def:crs:EPSG::27700'
elif 'WGS_1984' in spref or 'World_Geodetic_System_of_1984' in spref:
    output['id'] = 'urn:ogc:def:crs:EPSG::4326'
else:
    # handle all other unknown FGDC input
    output['unknown'] = 'Unknown spatial reference system'

# send the value back to the main program
print json.dumps(output)
