#!/bin/sh

arch="$1"
package="$2"
cmd="$3"
opt="$4"

[ "$cmd" = "" ] && cmd=ln
[ "$opt" = "" ] && opt=all

case $opt in
all)        dirs="usr/include lib usr/lib usr/share/pkgconfig";;
include)    dirs="usr/include";;
lib)        dirs="lib usr/lib";;
share)      dirs="usr/share/pkgconfig";;
esac

if [ -d "dist/$arch/packages/$package" ]; then
    saved_cwd="`pwd`"
    cd "dist/$arch/packages/$package"
    for file in `(find $dirs \( -type f -o -type l \) 2> /dev/null; true)`; do
        case "$cmd" in
        ln)
            case "$file" in
            lib/lib*.a|lib/lib*.so|usr/lib/lib*.a|usr/lib/lib*.so)
                mkdir -p "$saved_cwd/sysroot/$arch/`dirname "$file"`" || exit 1
                case "`file "$file"`" in
                *ASCII\ text)
                    cp "$file" "$saved_cwd/sysroot/$arch/$file" || exit 1;;
                *)
                    ln -s "`pwd`/$file" "$saved_cwd/sysroot/$arch/$file" || exit 1;;
                esac
                ;;
            lib/*.la|usr/lib/*.la) ;;
            usr/share/pkgconfig/*)
                mkdir -p "$saved_cwd/sysroot/$arch/usr/lib/pkgconfig" || exit 1
                ln -s "`pwd`/$file" "$saved_cwd/sysroot/$arch/usr/lib/pkgconfig/`basename "$file"`" || exit 1
                ;;
            *)
                mkdir -p "$saved_cwd/sysroot/$arch/`dirname "$file"`" || exit 1
                ln -s "`pwd`/$file" "$saved_cwd/sysroot/$arch/$file" || exit 1
                ;;
            esac
            ;;
        rm)
            case "$file" in
            usr/share/pkgconfig/*)
                rm -f "$saved_cwd/sysroot/$arch/usr/lib/pkgconfig/`basename "$file"`" || exit 1;;
            *)
                rm -f "$saved_cwd/sysroot/$arch/$file" || exit 1;;
            esac
            ;;
         esac
    done
    cd "$saved_cwd" || exit 1
    if [ -d "sysroot/$arch" ]; then
        cd "sysroot/$arch" || exit 1
        case "$cmd" in
        rm)
            for dir in `(find -depth \( -type d \) 2> /dev/null; true)`; do
                if [ "$dir" != . ]; then
                    rmdir -p "$dir" 2> /dev/null
                    true
                fi
            done
            ;;
        esac
        cd "$saved_cwd" || exit 1
    fi
fi
