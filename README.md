# MusaUX build system

The MusaUX build system was written to build MusaUX. MusaUX is an operating system for Banana Pi which
is based on the Linux kernel and the GNU tools. This build system uses Espact to build packages.

## Building

You can build MusaUX by invoke the following command:

    espact dist

## SD card image

After building, the SD card image with MusaUX should be in the
`work/dist/armhf/sdcard-sunxi-Bananapi.img` file.

## Running on QEMU

You can run MusaUX on QEMU by invoke the following command:

    espact -m run dist

Before running, you must build the kernel for vexpress and the root image of MusaUX by invoke the
following commands:

    espact -D kernel_platform=vexpress base/linux
    espact -m build_root_img dist

## License

The MusaUX build system is licensed under the MIT license except patches.

The patches are licensed under the licenses of the packages to which the patches are applied unless
note otherwise.
