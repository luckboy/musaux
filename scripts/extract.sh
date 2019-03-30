#!/bin/sh

package_collection_dir="$1"
arch="$2"
package="$3"
source_file="$4"
source_dir="$5"
version="$6"

mkdir -p "build/$arch/$package" || exit 1
case "download/$package/$source_file" in
*.tar)
    (cat "download/$package/$source_file" | tar xf - -C "build/$arch/$package") || exit 1;; 
*.tar.gz|*.tgz)
    (gzip -cd "download/$package/$source_file" | tar xf - -C "build/$arch/$package") || exit 1;;
*.tar.bz2|*.tbz2)
    (bzip2 -cd "download/$package/$source_file" | tar xf - -C "build/$arch/$package") || exit 1;;
*.tar.xz)
    (xz -cd "download/$package/$source_file" | tar -xf - -C "build/$arch/$package") || exit 1;;
*.tar.lzma)
    (lzma -cd "download/$package/$source_file" | tar -xf - -C "build/$arch/$package") || exit 1;;
*.zip)
    (unzip -d "build/$arch/$package" "download/$package/$source_file") || exit 1;;
*)
    echo 'Unsupported file extession' >&2; exit 1;;
esac

if [ "$version" != "" ]; then
    if [ -d "$package_collection_dir/patches/$package/$version" ]; then
        for patch in `ls "$package_collection_dir/patches/$package/$version" | sort`; do
            case "$patch" in
            *.gz)
                (cat "$package_collection_dir/patches/$package/$version/$patch" | patch -p1 -d "build/$arch/$package/$source_dir" -E -g0) || exit 1;;
            *.bz2)
                (bzip2 -cd "$package_collection_dir/patches/$package/$version/$patch" | patch -p1 -d "build/$arch/$package/$source_dir" -E -g0) || exit 1;;
            *.xz)
                (xz -cd "$package_collection_dir/patches/$package/$version/$patch" | patch -p1 -d "build/$arch/$package/$source_dir" -E -g0) || exit 1;;
            *.lzma)
                (lzma -cd "$package_collection_dir/patches/$package/$version/$patch" | patch -p1 -d "build/$arch/$package/$source_dir" -E -g0) || exit 1;;
            *.zip)
                (unzip -p "$package_collection_dir/patches/$package/$version/$patch" | patch -p1 -d "build/$arch/$package/$source_dir" -E -g0) || exit 1;;
            *)
                (cat "$package_collection_dir/patches/$package/$version/$patch" | patch -p1 -d "build/$arch/$package/$source_dir" -E -g0) || exit 1;;
            esac
        done
    fi
fi
