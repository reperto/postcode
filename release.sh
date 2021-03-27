#!/bin/bash
set -e

# Check and register bump
if [[ $# -lt 1 ]]; then
  echo Missing bump argument.
  exit 1
fi

bump=$1
echo Bumping with $bump

# Fail if not logged in
gh auth status

# Fail if missing git credentials
if ! git push &> /dev/null; then
  echo Git credentials missing
  exit 1
fi

# Start
current_tag=$(git describe --tags $(git rev-list --tags --max-count=1))
current_version=${current_tag:1}
echo Current tag is $current_tag and version is $current_version

new_version=$(semver bump $bump $current_version)
new_tag="v${new_version}"
echo New tag is $new_tag and version is $new_version

# Get data
./get_kartverket.sh
./get_posten.sh

# Convert
./convert.py

# Package
archive="tmp/reperto-postcode-${new_version}.zip"

rm -f $archive
echo Zipping release
zip $archive --quiet --junk-paths output/*.json release/*
echo Release zipped

# Confirm, please
read -p "About to release $archive? Are you sure [Y|n]" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Ok, then it wont happen"
    exit 0
fi

git tag $new_tag
git push origin $new_tag
gh release create $new_tag $archive
echo Done
