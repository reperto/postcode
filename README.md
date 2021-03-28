# postcode

Norwegian postcodes in a web-friendly format

## Overview

This repository contains scripts used to get Norwegian postcode data from open sources and combine and transform them into a web-friendly format (GeoJSON).

The data is then made available as Github releases.

## Data sources and data licenses

### Norwegian Mapping Authority

The data released in this repository, except the metadata attribute `category_code`, is from [© Kartverket](https://kartkatalog.geonorge.no/metadata/462a5297-33ef-438a-82a5-07fff5799be3).

The data is licensed under [Creative Commons Attribution 4.0 International](release/LICENSE).
This means the name of the Norwegian Mapping Authority must appear in all contexts, where the products or extracts of these are used, be it applications, web solutions, printed products, illustrations or others in the following way: _© Kartverket_. It should also be linked to [their website](https://www.kartverket.no) where this is possible and the [license](https://creativecommons.org/licenses/by/4.0/).

### Posten Norge

The metadata attribute `category_code` is from [© Posten Norge AS](https://www.bring.no/tjenester/adressetjenester/postnummer). The data is not released under a specific licence, but attribution should be given to _© Posten Norge AS_.

## Getting the data

This repository only contains the scripts to download, massage, release and publish data. The data itself is released as zip archive assets to [GitHub Releases](https://github.com/reperto/postcode/releases).

The data can also be accessed, free of charge, from https://data.reperto.no. To do that, use the following url pattern:

`https://data.reperto.no/file/reperto-open-data/postcode/[release_version]/[postcode].json`

Example: https://data.reperto.no/file/reperto-open-data/postcode/v0.1.1/0010.json

data.reperto.no is hosted on Backblaze B2 with Cloudflare CDN for caching in front.

## Release versioning

The data is released with [semver](https://semver.org/)-like tags/releases. I'm trying to use the following definition for _major_, _minor_ and _patch_

* **major** - breaking changes to the json structure
* **minor** - non-breaking changes to the json structure, like adding new properties
* **patch** - changes to the data itself, e.g. due to updates in source

## Requirements

The scripts are made in bash and python3.

### Bash

Bash scripts require the following packages/tools installed.

* jq
* iconv
* curl
* wget
* zip
* unzip
* rclone

Python scripts also need the following packages to be installed

* proj

### Python3

See [requirements.txt](requirements.txt). Install requirements (in a virtualenv) using `pip install requrements.txt`.

## Source code licence

The source code used to get, extract, massage and publish that content is licensed under the [MIT license](LICENCE.md).
For license information about the data, see sections above.
