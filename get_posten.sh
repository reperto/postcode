#!/bin/bash
# Download a tab-separated
# https://www.bring.no/tjenester/adressetjenester/postnummer
set -e

TEMP_FILE=tmp/register.dl
DEST_FILE=input/register.tsv

curl -o $TEMP_FILE -s https://www.bring.no/postnummerregister-ansi.txt
iconv -f WINDOWS-1252 -t UTF-8 -o $DEST_FILE $TEMP_FILE
rm $TEMP_FILE
