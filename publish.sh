#!/bin/bash
# Publish to Backblaze B2
tag=$(git describe --tags $(git rev-list --tags --max-count=1))
version=${tag:1}

# Confirm, please
read -p "About to publish $tag? Are you sure [Y|n]" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Ok, then it wont happen"
    exit 0
fi

# Temp dir
tmp_dir="./tmp/publish/$tag"
mkdir -p $tmp_dir
rm -rf $tmp_dir/*

# Unzip
unzip -q ./tmp/reperto-postcode-$version.zip  -d $tmp_dir

# Upload
echo Starting upload

rclone --config ./rclone.conf \
  --b2-key $B2_APPLICATION_KEY \
  --b2-account $B2_APPLICATION_KEY_ID \
  --progress \
  copy $tmp_dir remote:reperto-open-data/postcode/$tag

echo Done
