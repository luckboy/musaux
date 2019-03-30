#!/bin/sh

package_collection_dir="$1"
arch="$2"
kernel_platform="$3"
kernel_package="$4"
shift 4
packages="$*"

mkdir -p "dist/$arch/root/$kernel_platform" || exit 1

saved_cwd="`pwd`"
cd "dist/$arch/root/$kernel_platform" || exit 1
for dir in \
    bin \
    boot \
    dev \
    etc \
    home \
    lib \
    media \
    mnt \
    opt \
    proc \
    root \
    run \
    sbin \
    srv \
    sys \
    tmp \
    usr/bin \
    usr/games \
    usr/include \
    usr/lib \
    usr/local/bin \
    usr/local/etc \
    usr/local/games \
    usr/local/include \
    usr/local/lib \
    usr/local/sbin \
    usr/local/share/man \
    usr/local/share/misc \
    usr/local/src \
    usr/sbin \
    usr/share/man \
    usr/share/misc \
    var/cache \
    var/cache/man \
    var/lib/hwclock \
    var/lib/misc \
    var/lib/ntp \
    var/lib/polkit-1 \
    var/local \
    var/mail \
    var/log \
    var/opt \
    var/spool/lpd \
    var/spool/news \
    var/spool/uucp \
    var/www \
    var/tmp; do
    printf "Making directory /%s ...\n" "$dir"
    mkdir -p "$dir"
done
echo "Making symbolic link /var/run ..."
ln -s ../run var/run || exit 1
echo "Making symbolic link /var/lock ..."
ln -s ../run/lock var/lock || exit 1
cd "$saved_cwd" || exit 1

printf "Copying kernel package %s ...\n" "$kernel_package"
cp -PRp "dist/$arch/packages/$kernel_package/$kernel_platform/"* "dist/$arch/root/$kernel_platform" || exit 1

for package in $packages; do
    if [ ! -L "dist/$arch/packages/$package" ]; then
        printf "Copying package %s ...\n" "$package"
        cp -PRp "dist/$arch/packages/$package/"* "dist/$arch/root/$kernel_platform" || exit 1
    fi
done

saved_cwd="`pwd`"
cd "dist/$arch/root/$kernel_platform" || exit 1
if [ "`which ginstall-info`" != "" ]; then
    install_info=ginstall-info
else
    install_info=install-info
fi
for file in usr/share/info/*.info.gz; do
    if [ -f "$file" ]; then
        printf "Installing info file /%s ...\n" "$file"
        "$install_info" --dir-file=usr/share/info/dir "$file" || exit 1
    fi
done
cd "$saved_cwd" || exit 1

echo "Compiling schemas in directory /usr/share/glib-2.0/schemas ..."
glib-compile-schemas "dist/$arch/root/$kernel_platform/usr/share/glib-2.0/schemas" || exit 1

if [ -d "$package_collection_dir/etc" ]; then
    mkdir -p "dist/$arch/root/$kernel_platform/etc" || exit 1
    echo "Copying directory /etc ..."
    cp -PRp "$package_collection_dir/etc/"* "dist/$arch/root/$kernel_platform/etc" || exit 1
fi

saved_cwd="`pwd`"
cd "dist/$arch/root/$kernel_platform" || exit 1
echo "Making symbolic link /usr/bin/pager ..."
ln -s less usr/bin/pager || exit 1
echo "Making symbolic link /etc/mtab ..."
ln -s ../proc/mounts etc/mtab || exit 1
echo "Making directory /etc/runit/runsvdir ..."
mkdir -p etc/runit/runsvdir || exit 1
echo "Making directory /etc/runit/runsvdir/default ..."
mkdir -p etc/runit/runsvdir/default || exit 1
for service in \
    agetty-tty1 \
    agetty-tty2 \
    agetty-tty3 \
    agetty-tty4 \
    agetty-tty5 \
    agetty-tty6 \
    agetty-tty7 \
    dhclient \
    ntpd \
    sshd \
    syslogd; do
    printf "Making symbolic link /etc/runit/runsvdir/default/%s ...\n" "$service"
    ln -s "/etc/sv/$service" "etc/runit/runsvdir/default/$service" || exit 1
done
echo "Making directory /etc/runit/runsvdir/static ..."
mkdir -p etc/runit/runsvdir/static || exit 1
for service in \
    agetty-tty1 \
    agetty-tty2 \
    agetty-tty3 \
    agetty-tty4 \
    agetty-tty5 \
    agetty-tty6 \
    agetty-tty7 \
    ntpd \
    sshd \
    syslogd; do
    printf "Making symbolic link /etc/runit/runsvdir/static/%s ...\n" "$service"
    ln -s "/etc/sv/$service" "etc/runit/runsvdir/static/$service" || exit 1
done
echo "Making symbolic link /etc/runit/runsvdir/current ..."
ln -s default etc/runit/runsvdir/current || exit 1
echo "Making symbolic link /service ..."
ln -s etc/runit/runsvdir/current service || exit 1
cd "$saved_cwd" || exit 1

echo "Generating file /etc/trusted-key.key ..."
mkdir -p "tmp/$arch/root/$kernel_platform" || exit 1
cd "tmp/$arch/root/$kernel_platform" || exit 1
rm -fr * || exit 1
unbound-anchor -v -a root.key || unbound-anchor -v -a root.key
unbound-host -v -f root.key -t DNSKEY . | sed 's/ (secure)//;t;d' | sed 's/ has / IN /' | sed 's/ record / /' > trusted-key.key
cd "$saved_cwd"
cp "tmp/$arch/root/$kernel_platform/trusted-key.key" "dist/$arch/root/$kernel_platform/etc/trusted-key.key" || exit 1

echo "Changing file modes ..."
chmod -R go-w "dist/$arch/root/$kernel_platform" || exit 1
