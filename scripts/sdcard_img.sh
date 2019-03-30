#!/bin/sh

arch="$1"
kernel_platform="$2"
boot_platform="$3"

boot_img_size_in_bytes="`stat -c '%s' "dist/$arch/boot-$kernel_platform-$boot_platform.img"`"
boot_img_size="`expr \( "$boot_img_size_in_bytes" + 1023 \) / 1024`"
root_img_size_in_bytes="`stat -c '%s' "dist/$arch/root-$kernel_platform.img"`"
root_img_size="`expr \( "$root_img_size_in_bytes" + 1023 \) / 1024`"
sdcard_img_size_in_secs="`expr \( \( \( "$boot_img_size" + "$root_img_size" \) \* 2 + 2048 + 64259 \) / 64260 \) \* 64260`"

echo "boot_img_size = $boot_img_size"
echo "root_img_size = $root_img_size"
echo "sdcard_img_size_in_secs = $sdcard_img_size_in_secs"

export PATH="$PATH:/sbin:/usr/sbin"

dd if=/dev/zero of="dist/$arch/sdcard-$kernel_platform-$boot_platform.img" bs=512 count="$sdcard_img_size_in_secs" || exit 1
fdisk "dist/$arch/sdcard-$kernel_platform-$boot_platform.img" <<EOF
n
p
1

+${boot_img_size}K
n
p
2

+${root_img_size}K
t
1
6
t
2
83
w
EOF

boot_img_offset="`
fdisk -l "dist/$arch/sdcard-$kernel_platform-$boot_platform.img" | \
grep "dist/$arch/sdcard-$kernel_platform-$boot_platform.img1" | \
awk '{ print($2); }'
`"
root_img_offset="`
fdisk -l "dist/$arch/sdcard-$kernel_platform-$boot_platform.img" | \
grep "dist/$arch/sdcard-$kernel_platform-$boot_platform.img2" | \
awk '{ print($2); }'
`"

echo "boot_img_offset = $boot_img_offset"
echo "root_img_offset = $root_img_offset"

dd if="dist/$arch/boot-$kernel_platform-$boot_platform.img" of="dist/$arch/sdcard-$kernel_platform-$boot_platform.img" bs=512 conv=notrunc seek="$boot_img_offset" || exit 1
dd if="dist/$arch/root-$kernel_platform.img" of="dist/$arch/sdcard-$kernel_platform-$boot_platform.img" bs=512 conv=notrunc seek="$root_img_offset" || exit 1
dd if="dist/$arch/boot/$boot_platform/u-boot.bin" of="dist/$arch/sdcard-$kernel_platform-$boot_platform.img" bs=1024 conv=notrunc seek=8 || exit 1
