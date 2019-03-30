#!/bin/sh

arch="$1"
package="$2"
name="$3"
source_dir="$4"
doc_dir="$5"
shift 5
doc_files="$*"

if [ -d "dist/$arch/packages/$package" ]; then
    saved_cwd="`pwd`"
    cd "build/$arch/$package/$source_dir/$doc_dir" || exit 1
    if [ "$doc_files" != "" ]; then
        for doc_file in $doc_files; do
            if [ -f "$doc_file" ]; then
                mkdir -p "$saved_cwd/dist/$arch/packages/$package/usr/share/doc/$name" || exit 1
                gzip -9c "$doc_file" > "$saved_cwd/dist/$arch/packages/$package/usr/share/doc/$name/$doc_file.gz" || exit 1
            fi
        done
    fi
    cd "$saved_cwd" || exit 1

    cd "dist/$arch/packages/$package" || exit 1
    rm -f usr/share/info/dir || exit 1
    for file in \
        usr/share/info/* \
        usr/share/man/man?/* \
        usr/share/man/*/man?/*; do
        is_file=0
        case "$file" in
        usr/share/info/*.info|usr/share/info/*.info-*)
            is_file=1;;
        usr/share/man/man[0-9ln]/*.[0-9ln]*.gz|usr/share/man/*/man[0-9ln]/*.[0-9ln]*.gz) ;;
        usr/share/man/man[0-9ln]/*.[0-9ln]*|usr/share/man/*/man[0-9ln]/*.[0-9ln]*)
            is_file=1;;
        esac
        if [ "$is_file" = 1 ]; then
            if [ -L "$file" ]; then
                new_file="`readlink "$file"`" || exit 1
                rm -f "$file" || exit 1
                ln -s "$new_file.gz" "$file.gz" || exit 1
            elif [ -f "$file" ]; then
                gzip -9 "$file" || exit 1
            fi
        fi
    done
    cd "$saved_cwd" || exit 1
fi
