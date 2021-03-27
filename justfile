init:
  pip install -r requirements.txt

clean:
  rm -f output/*.json
  rm -f tmp/*.zip tmp/*.json
  rm  -f input/*.gml input/*.tsv

release:
  ./release.sh

get:
  ./get_kartverket.sh
  ./get_posten.sh

convert:
  python3 convert.py
