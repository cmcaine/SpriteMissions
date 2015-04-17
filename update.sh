#!/bin/bash

echo -e "\n\n"

releasedir=~/release
installdir=~/install
mkdir -p $releasedir

major=0
major=`cat version-number.txt`
minor=`cat build-number.txt`
patch=`cat patch-number.txt`
mod=SpriteMissions

files="Gamedata/ContractPacks/Spacetux/SharedAssets Gamedata/ContractPacks/Spacetux/SpriteMissions"
cd $installdir

echo "zip -9r ${releasedir}/${mod}-${major}.${minor}.${patch}.zip  $files"
zip -9r ${releasedir}/${mod}-${major}.${minor}.${patch}.zip  $files
