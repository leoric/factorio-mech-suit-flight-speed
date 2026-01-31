#!/usr/bin/env bash

VERSION="$(grep -oP '"version"\s*:\s*"\K[^"]+' mech-flight/info.json)"
DIRNAME="mech-flight_${VERSION}"
ZIPNAME="${DIRNAME}.zip"
mkdir -p "tmp/${DIRNAME}"
cp -r mech-flight/* "tmp/${DIRNAME}"
zip -r "tmp/${ZIPNAME}" "tmp/${DIRNAME}"
rm -rf "tmp/${DIRNAME}"
echo "Package created: ${ZIPNAME}"
