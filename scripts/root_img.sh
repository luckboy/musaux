#!/bin/sh

package_collection_dir="$1"
arch="$2"
kernel_platform="$3"
root_img_size="$4"
root_img_bytes_per_inode="$5"
shift 5
packages="$*"

root_uid="`awk -F : '/^root:/ { print($3); }' "$package_collection_dir/etc/passwd"`"
root_gid="`awk -F : '/^root:/ { print($3); }' "$package_collection_dir/etc/group"`"
lp_uid="`awk -F : '/^lp:/ { print($3); }' "$package_collection_dir/etc/passwd"`"
lp_gid="`awk -F : '/^lp:/ { print($3); }' "$package_collection_dir/etc/group"`"
mail_uid="`awk -F : '/^mail:/ { print($3); }' "$package_collection_dir/etc/passwd"`"
mail_gid="`awk -F : '/^mail:/ { print($3); }' "$package_collection_dir/etc/group"`"
news_uid="`awk -F : '/^news:/ { print($3); }' "$package_collection_dir/etc/passwd"`"
news_gid="`awk -F : '/^news:/ { print($3); }' "$package_collection_dir/etc/group"`"
news_uid="`awk -F : '/^news:/ { print($3); }' "$package_collection_dir/etc/passwd"`"
uucp_gid="`awk -F : '/^uucp:/ { print($3); }' "$package_collection_dir/etc/group"`"
uucp_uid="`awk -F : '/^uucp:/ { print($3); }' "$package_collection_dir/etc/passwd"`"
ntp_uid="`awk -F : '/^ntp:/ { print($3); }' "$package_collection_dir/etc/passwd"`"
ntp_gid="`awk -F : '/^ntp:/ { print($3); }' "$package_collection_dir/etc/group"`"

export PATH="$PATH:/sbin:/usr/sbin"

cat > "dist/$arch/device_table-$kernel_platform.txt" <<EOF
/etc/gshadow        f   0600    0           0           -   -   -   -   -
/etc/shadow         f   0600    0           0           -   -   -   -   -
/proc               d   0444    0           0           -   -   -   -   -
/root               d   0700    $root_uid   $root_gid   -   -   -   -   -
/sys                d   0444    0           0           -   -   -   -   -
/tmp                d   1777    0           0           -   -   -   -   -
/var/lib/ntp        d   2775    0           $ntp_gid    -   -   -   -   -
/var/lib/polkit-1   d   0700    0           0           -   -   -   -   -
/var/mail           d   2775    0           $mail_gid   -   -   -   -   -
/var/spool/lpd      d   2775    0           $lp_gid     -   -   -   -   -
/var/spool/news     d   2775    0           $news_gid   -   -   -   -   -
/var/tmp            d   1777    0           0           -   -   -   -   -
EOF
for package in $packages; do
    if [ -f "dist/$arch/packages/$package.suid_files" ]; then
        for file in `cat "dist/$arch/packages/$package.suid_files"`; do
            printf '/%s\tf\t4755\t0\t0\t-\t-\t-\t-\t-\n' "$file" >> "dist/$arch/device_table-$kernel_platform.txt" || exit 1
        done
    fi
done

genext2fs \
    -d "dist/$arch/root/$kernel_platform" \
    -D "dist/$arch/device_table-$kernel_platform.txt" \
    -b "$root_img_size" -i "$root_img_bytes_per_inode" -U \
    "dist/$arch/root-$kernel_platform.img" || exit 1
    
tune2fs -O dir_index,extents,has_journal,uninit_bg "dist/$arch/root-$kernel_platform.img" || exit 1
e2fsck -fp "dist/$arch/root-$kernel_platform.img"
true
