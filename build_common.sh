#!/bin/bash

# Set variables according to real environment to make this script can run
# on Ubuntu and Mac OS X.
uname_string=`uname | sed 'y/LINUXDARWINFREEOPENPCBSD/linuxdarwinfreeopenpcbsd/'`
host_arch=`uname -m | sed 'y/XI/xi/'`
if [ "x$uname_string" == "xlinux" ] ; then
    HOST_NATIVE="$host_arch"-linux-gnu
    PACKAGE_NAME_SUFFIX=linux
    GCC_CONFIG_OPTS_LCPP="--with-host-libstdcxx=-static-libgcc -Wl,-Bstatic,-lstdc++,-Bdynamic -lm"
    JOBS=-j`grep ^processor /proc/cpuinfo|wc -l`
elif [ "x$uname_string" == "xdarwin" ] ; then
    HOST_NATIVE=x86_64-apple-darwin10
    PACKAGE_NAME_SUFFIX=mac
    GCC_CONFIG_OPTS_LCPP="--with-host-libstdcxx=-static-libgcc -Wl,-lstdc++ -lm"
    JOBS=-j4
else
    error "Unsupported build system : $uname_string"
fi

LIBICONV_VERSION=1.14
GMP_VERSION=6.1.1
MPFR_VERSION=3.1.4
MPC_VERSION=1.0.3
ISL_VERSION=0.17.1
ZLIB_VERSION=1.2.8
LIBZIP_VERSION=1.1.3
LIBELF_VERSION=0.8.13
JANSSON_VERSION=2.8
DLFCN_VERSION=1.0.0
BINUTILS_VERSION=2.27
GCC_VERSION=6.2.0

ROOTDIR=`pwd`
PATCHDIR=${ROOTDIR}/patch
DOWNLOADDIR=${ROOTDIR}/download
SRCDIR=${ROOTDIR}/src
BUILDDIR=${ROOTDIR}/build
PACKAGEDIR=${ROOTDIR}/pkg
mkdir -p ${SRCDIR} ${BUILDDIR} ${PACKAGEDIR}
SRCRELDIR=../src
INSTALLDIR=${ROOTDIR}/install
VITASDKROOT=${ROOTDIR}/vitasdk
RELEASEDATE=`date +%Y%m%d`
PACKAGE_NAME=gcc-arm-vita-eabi-6.2-${RELEASEDATE}
PACKAGE_NAME_NATIVE=${PACKAGE_NAME}-${PACKAGE_NAME_SUFFIX}


# Strip binary files as in "strip binary" form, for both native(linux/mac) and mingw.
strip_binary() {
    set +e
    if [ $# -ne 2 ] ; then
        warning "strip_binary: Missing arguments"
        return 0
    fi
    local strip="$1"
    local bin="$2"

    file $bin | grep -q  "(\bELF\b)|(\bPE\b)|(\bPE32\b)"
    if [ $? -eq 0 ]; then
        $strip $bin 2>/dev/null || true
    fi

    set -e
}
