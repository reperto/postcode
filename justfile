init:
  pip install -r requirements.txt

get:
  ./get_kartverket.sh
  ./get_posten.sh

convert:
  python3 convert.py
