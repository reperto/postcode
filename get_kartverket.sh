#!/bin/bash
# Get data from
# https://kartkatalog.geonorge.no/metadata/462a5297-33ef-438a-82a5-07fff5799be3
set -e

METADATAUUID="462a5297-33ef-438a-82a5-07fff5799be3"

# Use the following to inspect the capabilities and codelists
# curl -s https://nedlasting.geonorge.no/api/capabilities/$METADATAUUID | jq
# curl -s https://nedlasting.geonorge.no/api/codelists/projection/$METADATAUUID | jq
# curl -s https://nedlasting.geonorge.no/api/codelists/format/$METADATAUUID | jq
# curl -s https://nedlasting.geonorge.no/api/codelists/area/$METADATAUUID | jq


RESPONSE=tmp/response.json

if [ ! -f $RESPONSE ]; then
  echo Placing order
  # why not api/v2? Getting error "Message": "The HTTP resource that matches the request URI 'http://nedlasting.geonorge.no/api/v2/order' does not support the API version '3.0'."
  curl -s -H "Content-Type: application/json" --data @kartverket_order.json https://nedlasting.geonorge.no/api/order -o $RESPONSE
else
  echo Skipping order, reponse exists
fi

DOWNLOADURL=$(jq -r '.files[0].downloadUrl' tmp/response.json)
ARCHIVE=tmp/kartverket.zip
GML=input/Basisdata_0000_Norge_25833_Postnummeromrader_GML.gml

if [ ! -f $GML ]; then

  echo Getting archive
  wget -O $ARCHIVE $DOWNLOADURL

  echo Unzipping archive
  unzip $ARCHIVE -d ./input

else
  echo Skipping download, gml exists
fi

exit 0
