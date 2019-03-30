#!/bin/sh

package="$1"
url="$2"
source_file="$3"
source_file_sha256="$4"

if [ ! -f "download/$package/$source_file" ]; then
    rm -f "download/$package/$source_file" || exit 1
    mkdir -p "download/$package" || exit 1
    wget -O "download/$package/$source_file" "$url/$source_file" || exit 1
fi

if [ "$source_file_sha256" != "" ]; then
    (printf '%s\n' "$source_file_sha256  download/$package/$source_file" | sha256sum -c) || exit 1
fi
