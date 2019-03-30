#!/bin/sh

arch="$1"
package="$2"
name="$3"
source_dir="$4"
doc_dir="$5"
kernel_platform="$6"
shift 6
doc_files="$*"

if [ -d "dist/$arch/packages/$package/$kernel_platform" ]; then
    saved_cwd="`pwd`"
    cd "build/$arch/$package/$source_dir/$doc_dir" || exit 1
    if [ "$doc_files" != "" ]; then
        for doc_file in $doc_files; do
            if [ -f "$doc_file" ]; then
                mkdir -p "$saved_cwd/dist/$arch/packages/$package/$kernel_platform/usr/share/doc/$name" || exit 1
                gzip -9c "$doc_file" > "$saved_cwd/dist/$arch/packages/$package/$kernel_platform/usr/share/doc/$name/$doc_file.gz" || exit 1
            fi
        done
    fi
    cd "$saved_cwd" || exit 1
fi
