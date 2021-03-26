#!/usr/bin/python3
# Convert data from Kartverket and Posten into GeoJson

import xml.etree.ElementTree as ET
import json
import pyproj
from shapely.geometry import Point, Polygon, LineString, mapping
from shapely.ops import linemerge, transform
import csv

# Log configuration
import logging
logging.basicConfig(format='%(asctime)s - %(levelname)s : %(message)s', level=logging.INFO)


# Postcode category helpers

postcode_categories = {}

def postcode_category(postcode):

    global postcode_categories

    if len(postcode_categories) == 0:
        # need to initialize
        with open('input/register.tsv') as tsv:
            reader = csv.reader(tsv, delimiter="\t")
            for row in reader:
                postcode_categories[row[0]] = row[4]

    if postcode in postcode_categories:
        return postcode_categories[postcode]
    else:
        return "U" # unknown


# GML parsing helper functions

def ringToList(ring):
    points = []
    for poslist in ring.findall('.//gml:posList', ns):
        numbers = iter([float(j) for j in poslist.text.split()])

        points.extend(zip(numbers, numbers))

    return points

# Start conversion
kartverketfile = 'input/Basisdata_0000_Norge_25833_Postnummeromrader_GML.gml'

# Handle namespaces
logging.info("reading namespaces")
ns = dict([node for _, node in ET.iterparse(kartverketfile, events=['start-ns'])])

logging.info(json.dumps(ns, indent=4, sort_keys=True))

# Parse file
tree = ET.parse(kartverketfile)
root = tree.getroot()

# Projection
proj = pyproj.Transformer.from_proj(
    pyproj.CRS(25833), # source coordinate system
    pyproj.CRS(4326),  # destination coordinate system wsg
    always_xy=True
).transform

# The one and only map
postalcodes = {}

for feature in root.findall('.//app:Postnummerområde', ns):
    try:
        municipality = feature.find('app:kommune', ns).text
        postalcode = feature.find('.//app:postnummer', ns).text
        city = feature.find('.//app:poststed', ns).text
        date = feature.find('app:datauttaksdato', ns).text

        exterior = ringToList(feature.find('.//gml:exterior', ns))
        interiors = []

        for interior in feature.findall('.//gml:interior', ns):
            interiors.append(ringToList(interior))

        pol = Polygon(exterior, interiors)

        area = pol.area
        valid = pol.is_valid
        simple = pol.is_simple
        c1 = pol.centroid

        polwsg = transform(proj, pol)
        c2 = polwsg.centroid

        # add empty array if it doesn't exist
        if postalcode not in postalcodes:
            postalcodes[postalcode] = []
        else:
            if postalcodes[postalcode][-1]["municipality"] != municipality:
                raise ValueError("municipality is off %s vs %s" % ( postalcodes[postalcode][-1]["municipality"],municipality ))


        postalcodes[postalcode].append({
            "polygon" : polwsg,
            "area" : area,
            "city" : city,
            "municipality" : municipality,
            "holes" : len(interiors)
        })

    except Exception as e:
        logging.error("failed on %s" % postalcode)
        raise(e)

for code in postalcodes:
    data = postalcodes[code]
    geoj = {
        "type" : "FeatureCollection",
        "metadata" : {
            "municipality" : data[0]["municipality"],
            "city" : data[0]["city"],
            "num" : len(data),
            "postcode_category" : postcode_category(code)
        },
        "attribution" : [
            {
                "publisher" : "Kartverket ©",
                "source" : "https://kartkatalog.geonorge.no/metadata/462a5297-33ef-438a-82a5-07fff5799be3",
                "license" : "https://creativecommons.org/licenses/by/4.0/",
                "data" : "Entire dataset, except metadata.postcode_category"
            },
            {
                "publisher" : "Posten Norge AS",
                "source" : "https://www.bring.no/tjenester/adressetjenester/postnummer",
                "license" : "Unknown",
                "data" : "metadata.postcode_category"
            }
        ],
        "features" : [{
            'type': 'Feature',
            'properties': {
                "area" : area["area"],
                "holes" : area["holes"]
            },
            'geometry': mapping(area["polygon"])
        } for area in data
        ]
    }
    with open('output/%s.json' % (code), 'w') as outfile:
        json.dump(geoj, outfile, sort_keys=True)
