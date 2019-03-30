#!/bin/sh

arch="$1"
kernel_platform="$2"
boot_platform="$3"
kernel_dtb="$4"
boot_img_size="$5"
kernel_addr="$6"
kernel_dtb_addr="$7"

export PATH="$PATH:/sbin:/usr/sbin"

cat > "dist/$arch/boot-$kernel_platform-$boot_platform.cmd" << EOF
setenv bootargs console=ttyS0,115200 console=tty1 earlyprintk root=/dev/mmcblk0p2 rootfstype=ext4 rootwait panic=0 devtmpfs.mount=1 logo.nologo
load mmc 0:1 $kernel_addr zImage
load mmc 0:1 $kernel_dtb_addr $kernel_dtb
bootz $kernel_addr - $kernel_dtb_addr
EOF

if [ "$arch" = armhf ]; then
    kernel_arch=arm
else
    kernel_arch="$arch"
fi

"./dist/$arch/boot/$boot_platform/tools/mkimage" \
    -A "$kernel_arch" \
    -C none \
    -T script \
    -d "dist/$arch/boot-$kernel_platform-$boot_platform.cmd" \
    "dist/$arch/boot-$kernel_platform-$boot_platform.scr" || exit 1

dd if=/dev/zero of="dist/$arch/boot-$kernel_platform-$boot_platform.img" bs=1024 count="$boot_img_size" || exit 1
mkfs.vfat "dist/$arch/boot-$kernel_platform-$boot_platform.img" || exit 1

mcopy -i "dist/$arch/boot-$kernel_platform-$boot_platform.img" "dist/$arch/kernel/$kernel_platform/zImage" ::zImage || exit 1
mcopy -i "dist/$arch/boot-$kernel_platform-$boot_platform.img" "dist/$arch/kernel/$kernel_platform/$kernel_dtb" "::$kernel_dtb" || exit 1
mcopy -i "dist/$arch/boot-$kernel_platform-$boot_platform.img" "dist/$arch/boot-$kernel_platform-$boot_platform.cmd" ::boot.cmd || exit 1
mcopy -i "dist/$arch/boot-$kernel_platform-$boot_platform.img" "dist/$arch/boot-$kernel_platform-$boot_platform.scr" ::boot.scr || exit 1
