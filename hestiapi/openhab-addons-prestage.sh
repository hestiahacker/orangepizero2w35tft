#!/bin/bash
# Pre-extract the bundled openHAB add-ons KAR into Karaf's local Maven repo.
#
# On a fresh install Karaf creates the KAR's storage directory as soon as it
# begins unpacking the 600MB add-ons archive. openHAB's add-on installer only
# checks that the directory exists, so it can run while the Maven repository
# inside is still empty. It then tries to download the add-ons from
# openhab.jfrog.io and, on an offline machine, never recovers.
#
# Extracting the repository here means the first boot sees a complete local
# repository, so no download is attempted and no boot-time retry is needed.

set -eu

KAR_DIR=/usr/share/openhab/addons
DATA_KAR_DIR=/var/lib/openhab/tmp/kar

kar_file=$(find "$KAR_DIR" -maxdepth 1 -name 'openhab-addons-*.kar' -printf '%f\n' | sort -V | tail -1)
if [ -z "$kar_file" ]; then
	echo "No openhab-addons KAR found in $KAR_DIR" >&2
	exit 1
fi

kar_name=${kar_file%.kar}
version=${kar_name#openhab-addons-}
dest="$DATA_KAR_DIR/$kar_name"
features_xml="$dest/org/openhab/distro/openhab-addons/$version/openhab-addons-$version-features.xml"

if [ -f "$dest/features.cfg" ] && [ -f "$features_xml" ]; then
	exit 0
fi

install -d -o openhab -g openhab -m 755 "$DATA_KAR_DIR"
rm -rf "$dest"
install -d -o openhab -g openhab -m 755 "$dest"

# Karaf strips the KAR's leading "repository/" when it populates this
# directory, so do the same here.
tmp_dir=$(mktemp -d "$DATA_KAR_DIR/.prestage.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT
unzip -q "$KAR_DIR/$kar_file" 'repository/*' -d "$tmp_dir"
cp -a "$tmp_dir/repository/." "$dest/"
printf 'mvn:org.openhab.distro/openhab-addons/%s/xml/features\n' "$version" > "$dest/features.cfg"
chown -R openhab:openhab "$dest"
