# AVR32 Toolchain Makefile
#
# Copyright (C) 2011 by James Snyder <jbsnyder@fanplastic.org>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

#### PRIMARY TOOLCHAIN VERSIONS #####

GCC_VERSION      = 4.4.7
BINUTILS_VERSION = 2.23.1
NEWLIB_VERSION   = gs-1.16.0
DFU_VERSION      = 0.5.4
AVR32_PATCH_REV	 = 3.4.2
ATMEL_HEADER_REV = 6.1.3.1475


#### PATHS AND ENVIRONMENT VARIABLES #####

SHELL       = /bin/bash
TARGET      = avr32

TODAY = $(shell date "+%Y%m%d")
GIT_REV	    = $(shell git rev-parse --verify HEAD --short)

ifeq ($(strip $(GIT_REV)),)
PREFIX     ?= $(HOME)/avr32-tools-$(TODAY)
else
PREFIX     ?= $(HOME)/avr32-tools-$(GIT_REV)
endif

PROCS := $(shell getconf _NPROCESSORS_ONLN || getconf NPROCESSORS_ONLN || \
                 nproc || sysctl -n hw.ncpu || echo 4)

SUPP_PREFIX = $(CURDIR)/supp
PATH       := ${PREFIX}/bin:${SUPP_PREFIX}/bin:${PATH}
AUTOCONF    = $(SUPP_PREFIX)/bin/autoconf
AUTOMAKE    = $(SUPP_PREFIX)/bin/automake
GPERF       = $(SUPP_PREFIX)/bin/gperf

BUG_URL = https://github.com/jsnyder/avr32-toolchain
PKG_VERSION = "AVR 32 bit GNU Toolchain-$(AVR_PATCH_REV)-$(GIT_REV)"


#### PRIMARY TOOLCHAIN URLS #####

GCC_ARCHIVE = gcc-$(GCC_VERSION).tar.bz2
GCC_URL = https://ftp.gnu.org/gnu/gcc/gcc-$(GCC_VERSION)/$(GCC_ARCHIVE)
GCC_MD5 = 295709feb4441b04e87dea3f1bab4281

BINUTILS_ARCHIVE = binutils-$(BINUTILS_VERSION).tar.bz2
BINUTILS_URL = https://ftp.gnu.org/gnu/binutils/$(BINUTILS_ARCHIVE)
BINUTILS_MD5 = 33adb18c3048d057ac58d07a3f1adb38

NEWLIB_URL = https://github.com/GomSpace/avr32-newlib.git

AVR32PATCHES_ARCHIVE = avr32-patches.tar.gz
# AVR32PATCHES_URL = http://distribute.atmel.no/tools/opensource/Atmel-AVR32-GNU-Toolchain/$(AVR32_PATCH_REV)/$(AVR32PATCHES_ARCHIVE)
# This link is dead.
AVR32PATCHES_MD5 = 99b2f4497d264c9200538bb1229fdef9

AVR32HEADERS_ARCHIVE = atmel-headers-$(ATMEL_HEADER_REV).zip
AVR32HEADERS_URL = https://ww1.microchip.com/downloads/en/DeviceDoc/$(AVR32HEADERS_ARCHIVE)
AVR32HEADERS_MD5 = d69e8e188470e4fea68a4650442b5750

DFU_ARCHIVE = dfu-programmer-$(DFU_VERSION).tar.gz
DFU_URL = https://surfnet.dl.sourceforge.net/project/dfu-programmer/dfu-programmer/$(DFU_VERSION)/$(DFU_ARCHIVE)
DFU_MD5 = 707dcd0f957a74e92456ea6919faa772


##### SUPPORT TOOLS VERSIONS / URLS ######
AUTOCONF_VERSION = 2.64
AUTOMAKE_VERSION = 1.11
MPC_VERSION = 0.8.1
GPERF_VERSION = 3.0.4
TEXINFO_VERSION = 4.13

AUTOCONF_ARCHIVE = autoconf-$(AUTOCONF_VERSION).tar.bz2
AUTOCONF_URL = https://ftp.gnu.org/gnu/autoconf/$(AUTOCONF_ARCHIVE)
AUTOCONF_MD5 = ef400d672005e0be21e0d20648169074

AUTOMAKE_ARCHIVE = automake-$(AUTOMAKE_VERSION).tar.bz2
AUTOMAKE_URL = https://ftp.gnu.org/gnu/automake/$(AUTOMAKE_ARCHIVE)
AUTOMAKE_MD5 = 4db4efe027e26b33930a7e151de19d0f

GPERF_ARCHIVE = gperf-$(GPERF_VERSION).tar.gz
GPERF_URL = https://ftp.gnu.org/gnu/gperf/$(GPERF_ARCHIVE)
GPERF_MD5 = c1f1db32fb6598d6a93e6e88796a8632

TEXINFO_ARCHIVE = texinfo-$(TEXINFO_VERSION)a.tar.gz
TEXINFO_URL = https://ftpmirror.gnu.org/texinfo/$(TEXINFO_ARCHIVE)
TEXINFO_MD5 = 71ba711519209b5fb583fed2b3d86fcb

.PHONY: install-tools
install-tools: stamps/install-binutils stamps/install-final-gcc stamps/install-newlib stamps/install-headers

.PHONY: install-cross
install-cross: install-tools install-note


.PHONY: sudomode
sudomode:
ifneq ($(USER),root)
	@echo Please run this target with sudo!
	@echo e.g.: sudo make targetname
	@exit 1
endif


.PHONY: tst
tst:
	@echo $(PREFIX)

.PHONY: install-note
install-note: install-tools
	@echo
	@echo ====== INSTALLATION NOTE ======
	@echo Your tools have now been installed at the following prefix:
	@echo $(PREFIX)
	@echo
	@echo Please be sure to add something similar to the following to your .bash_profile, .zshrc, etc:
	@echo export PATH=$(PREFIX)/bin:'$$PATH'




.PHONY: install-supp-tools
install-supp-tools stamps/install-supp-tools: stamps/install-autoconf stamps/install-automake stamps/install-gperf stamps/install-texinfo
	[ -d stamps ] || mkdir stamps ;
	touch stamps/install-supp-tools;


############# SUPP: AUTOCONF ############

.PHONY: download-autoconf
downloads/$(AUTOCONF_ARCHIVE) download-autoconf:
	[ -d downloads ] || mkdir downloads ;
	cd downloads && curl -LO $(AUTOCONF_URL)

.PHONY: extract-autoconf
extract-autoconf stamps/extract-autoconf: downloads/$(AUTOCONF_ARCHIVE)
	@(t1=`openssl md5 $< | cut -f 2 -d " " -` && \
	[ "$$t1" = "$(AUTOCONF_MD5)" ] || \
	( echo "Bad Checksum! Please remove the following file and retry: $<" && false ))
	tar -jxf $< ;
	[ -d stamps ] || mkdir stamps ;
	touch stamps/extract-autoconf;

.PHONY: build-autoconf
build-autoconf stamps/build-autoconf: stamps/extract-autoconf
	mkdir -p build/autoconf && cd build/autoconf && \
	../../autoconf-$(AUTOCONF_VERSION)/configure --prefix="$(SUPP_PREFIX)" && \
	$(MAKE) -j$(PROCS)
	[ -d stamps ] || mkdir stamps
	touch stamps/build-autoconf;

.PHONY: install-autoconf
install-autoconf stamps/install-autoconf:  stamps/build-autoconf
	cd build/autoconf && \
	$(MAKE) install
	[ -d stamps ] || mkdir stamps
	touch stamps/install-autoconf;



############ SUPP: AUTOMAKE ############

.PHONY: download-automake
downloads/$(AUTOMAKE_ARCHIVE) download-automake:
	[ -d downloads ] || mkdir downloads ;
	cd downloads && curl -LO $(AUTOMAKE_URL)

.PHONY: extract-automake
extract-automake stamps/extract-automake: downloads/$(AUTOMAKE_ARCHIVE)
	@(t1=`openssl md5 $< | cut -f 2 -d " " -` && \
	[ "$$t1" = "$(AUTOMAKE_MD5)" ] || \
	( echo "Bad Checksum! Please remove the following file and retry: $<" && false ))
	tar -jxf $< ;
	[ -d stamps ] || mkdir stamps ;
	touch stamps/extract-automake;

.PHONY: patch-automake
patch-automake stamps/patch-automake: stamps/extract-automake
	pushd automake-$(AUTOMAKE_VERSION) ; \
	patch -N -p1 < ../patches/automake/010-automake-port-to-Perl-5.22-and-later.patch
	[ -d stamps ] || mkdir stamps
	touch stamps/patch-automake;

.PHONY: build-automake
build-automake stamps/build-automake: stamps/patch-automake stamps/install-autoconf
	mkdir -p build/automake && cd build/automake && \
	../../automake-$(AUTOMAKE_VERSION)/configure --prefix="$(SUPP_PREFIX)" && \
	$(MAKE) -j$(PROCS)
	[ -d stamps ] || mkdir stamps
	touch stamps/build-automake;

.PHONY: install-automake
install-automake stamps/install-automake:  stamps/build-automake
	cd build/automake && \
	$(MAKE) install
	[ -d stamps ] || mkdir stamps
	touch stamps/install-automake;


############ SUPP: TEXINFO ############

.PHONY: download-texinfo
downloads/$(TEXINFO_ARCHIVE) download-texinfo:
	[ -d downloads ] || mkdir downloads ;
	cd downloads && curl -LO $(TEXINFO_URL)

.PHONY: extract-texinfo
extract-texinfo stamps/extract-texinfo: downloads/$(TEXINFO_ARCHIVE)
	@(t1=`openssl md5 $< | cut -f 2 -d " " -` && \
	[ "$$t1" = "$(TEXINFO_MD5)" ] || \
	( echo "Bad Checksum! Please remove the following file and retry: $<" && false ))
	tar -zxf $< ;
	[ -d stamps ] || mkdir stamps ;
	touch stamps/extract-texinfo;

.PHONY: build-texinfo
build-texinfo stamps/build-texinfo: stamps/extract-texinfo stamps/install-autoconf
	mkdir -p build/texinfo && cd build/texinfo && \
	../../texinfo-$(TEXINFO_VERSION)/configure --prefix="$(SUPP_PREFIX)" && \
	$(MAKE) -j$(PROCS)
	[ -d stamps ] || mkdir stamps
	touch stamps/build-texinfo;

.PHONY: install-texinfo
install-texinfo stamps/install-texinfo:  stamps/build-texinfo
	cd build/texinfo && \
	$(MAKE) install
	[ -d stamps ] || mkdir stamps
	touch stamps/install-texinfo;



############ SUPP: GPERF ############

.PHONY: download-gperf
downloads/$(GPERF_ARCHIVE) download-gperf:
	[ -d downloads ] || mkdir downloads ;
	cd downloads && curl -LO $(GPERF_URL)

.PHONY: extract-gperf
extract-gperf stamps/extract-gperf: downloads/$(GPERF_ARCHIVE)
	@(t1=`openssl md5 $< | cut -f 2 -d " " -` && \
	[ "$$t1" = "$(GPERF_MD5)" ] || \
	( echo "Bad Checksum! Please remove the following file and retry: $<" && false ))
	tar -zxf $< ;
	[ -d stamps ] || mkdir stamps ;
	touch stamps/extract-gperf;

.PHONY: build-gperf
build-gperf stamps/build-gperf: stamps/extract-gperf
	mkdir -p build/gperf && cd build/gperf && \
	../../gperf-$(GPERF_VERSION)/configure --prefix="$(SUPP_PREFIX)" && \
	$(MAKE) -j$(PROCS)
	[ -d stamps ] || mkdir stamps
	touch stamps/build-gperf;

.PHONY: install-gperf
install-gperf stamps/install-gperf:  stamps/build-gperf
	cd build/gperf && \
	$(MAKE) install
	[ -d stamps ] || mkdir stamps
	touch stamps/install-gperf;


############# AVR32 PATCHES ############

.PHONY: download-avr32patches
downloads/$(AVR32PATCHES_ARCHIVE) download-avr32patches:
	cd downloads && curl -LO $(AVR32PATCHES_URL)

.PHONY: extract-avr32patches
extract-avr32patches stamps/extract-avr32patches : downloads/$(AVR32PATCHES_ARCHIVE)
	@(t1=`openssl md5 $< | cut -f 2 -d " " -` && \
	[ "$$t1" = "$(AVR32PATCHES_MD5)" ] || \
	( echo "Bad Checksum! Please remove the following file and retry: $<" && false ))
	tar -xf $<
	[ -d stamps ] || mkdir stamps
	touch stamps/extract-avr32patches;


############# AVR32 HEADERS ############

.PHONY: download-avr32headers
downloads/$(AVR32HEADERS_ARCHIVE) download-avr32headers:
	cd downloads && curl -LO $(AVR32HEADERS_URL)

.PHONY: extract-headers
extract-headers stamps/extract-headers : downloads/$(AVR32HEADERS_ARCHIVE)
	@(t1=`openssl md5 $< | cut -f 2 -d " " -` && \
	[ "$$t1" = "$(AVR32HEADERS_MD5)" ] || \
	( echo "Bad Checksum! Please remove the following file and retry: $<" && false ))
	unzip -o $<
	mkdir -p stamps
	touch stamps/extract-headers

.PHONY: install-headers
install-headers stamps/install-headers : stamps/extract-headers stamps/install-final-gcc
	cp -r atmel-headers-$(ATMEL_HEADER_REV)/$(TARGET) $(PREFIX)/$(TARGET)/include/$(TARGET)
	mkdir -p stamps
	touch stamps/install-headers


################ NEWLIB ################

.PHONY: download-newlib
downloads/$(NEWLIB_ARCHIVE) download-newlib clone-newlib stamps/clone-newlib:
	[ -d downloads ] || mkdir downloads ;
	git clone $(NEWLIB_URL) newlib-$(NEWLIB_VERSION)
	[ -d stamps ] || mkdir stamps
	touch stamps/clone-newlib;

.PHONY: prep-newlib
prep-newlib stamps/prep-newlib: stamps/regen-newlib
	[ -d stamps ] || mkdir stamps
	touch stamps/prep-newlib;


.PHONY: regen-newlib
regen-newlib stamps/regen-newlib: stamps/clone-newlib stamps/install-supp-tools
	pushd newlib-$(NEWLIB_VERSION) ; \
	"$(SUPP_PREFIX)/bin/autoconf"; "$(SUPP_PREFIX)/bin/automake" ; \
	for dir in newlib/libc/machine/avr32 newlib/libc/machine newlib/libc/sys/avr32 newlib/libc/sys; do \
	  pushd $$dir ; \
	  "$(SUPP_PREFIX)/bin/aclocal" -I ../.. -I ../../.. -I ../../../.. ; \
	  "$(SUPP_PREFIX)/bin/autoconf"; "$(SUPP_PREFIX)/bin/automake"; \
	  popd ; \
	done; \
	popd;
	[ -d stamps ] || mkdir stamps
	touch stamps/regen-newlib;

NEWLIB_FLAGS="-ffunction-sections -fdata-sections	\
-DPREFER_SIZE_OVER_SPEED -D__OPTIMIZE_SIZE__ -g -Os	\
-fomit-frame-pointer -fno-unroll-loops -D__BUFSIZ__=128	\
-DSMALL_MEMORY"

.PHONY: cross-newlib
build-newlib stamps/build-newlib: stamps/prep-newlib stamps/install-binutils stamps/install-gcc
	mkdir -p build/newlib && cd build/newlib && \
	pushd ../../newlib-$(NEWLIB_VERSION) ; \
	make clean ; \
	popd ; \
	../../newlib-$(NEWLIB_VERSION)/configure --prefix=$(PREFIX)	\
	--with-build-time-tools=$(PREFIX) \
	--target=$(TARGET) \
	--disable-newlib-supplied-syscalls \
	--disable-libgloss \
	--disable-nls \
	--disable-shared \
	--enable-newlib-io-long-long \
	--enable-newlib-io-long-double \
	--enable-newlib-io-pos-args	\
	--enable-newlib-reent-small \
	--enable-target-optspace \
	--enable-newlib-retargetable-locking \
	&& \
	$(MAKE) -j$(PROCS) CFLAGS_FOR_TARGET=$(NEWLIB_FLAGS) CCASFLAGS=$(NEWLIB_FLAGS) && \
	[ -d stamps ] || mkdir stamps
	touch stamps/build-newlib;

.PHONY: install-newlib
install-newlib stamps/install-newlib: stamps/build-newlib
	cd build/newlib && \
	$(MAKE) install
	[ -d stamps ] || mkdir stamps
	touch stamps/install-newlib;

################ BINUTILS ################

.PHONY: download-binutils
downloads/$(BINUTILS_ARCHIVE) download-binutils:
	[ -d downloads ] || mkdir downloads ;
	cd downloads && curl -LO $(BINUTILS_URL)

.PHONY: prep-binutils
prep-binutils stamps/prep-binutils: stamps/regen-binutils
	[ -d stamps ] || mkdir stamps;
	touch stamps/prep-binutils;

.PHONY: extract-binutils
extract-binutils stamps/extract-binutils: downloads/$(BINUTILS_ARCHIVE)
	@(t1=`openssl md5 $< | cut -f 2 -d " " -` && \
	[ "$$t1" = "$(BINUTILS_MD5)" ] || \
	( echo "Bad Checksum! Please remove the following file and retry: $<" && false ))
	tar -jxf $< ;
	[ -d stamps ] || mkdir stamps ;
	touch stamps/extract-binutils;

.PHONY: patch-binutils
patch-binutils stamps/patch-binutils: stamps/extract-binutils stamps/extract-avr32patches
	pushd binutils-$(BINUTILS_VERSION) ; \
	for f in ../avr32-patches/binutils/*.patch; do \
	patch -N -p0 <$${f} ; \
	done ; \
	popd ; \
	[ -d stamps ] || mkdir stamps
	touch stamps/patch-binutils;

.PHONY: regen-binutils
regen-binutils stamps/regen-binutils: stamps/patch-binutils stamps/install-supp-tools
	pushd binutils-$(BINUTILS_VERSION) ; \
	"$(SUPP_PREFIX)/bin/aclocal" -I config ; \
	"$(SUPP_PREFIX)/bin/autoconf" ; \
	"$(SUPP_PREFIX)/bin/automake" ; \
	"$(SUPP_PREFIX)/bin/autoheader" ; \
	for dir in bfd opcodes binutils gas ld; do \
	  pushd $$dir ; \
	  "$(SUPP_PREFIX)/bin/autoconf"; \
	  "$(SUPP_PREFIX)/bin/automake"; \
	  "$(SUPP_PREFIX)/bin/autoheader"; \
	  popd ; \
	done; \
	popd; \
	[ -d stamps ] || mkdir stamps ;
	touch stamps/regen-binutils;

.PHONY: build-binutils
build-binutils stamps/build-binutils: stamps/regen-binutils stamps/install-supp-tools
	cd binutils-$(BINUTILS_VERSION) ; \
	CFLAGS="-g -O2 -fcommon" \
	./configure   --enable-maintainer-mode		\
	--prefix="$(PREFIX)" --target=$(TARGET) --disable-nls		\
	--disable-shared --disable-werror				\
	--with-sysroot="$(PREFIX)/$(TARGET)" --with-bugurl=$(BUG_URL) &&	\
	$(MAKE) all-bfd TARGET-bfd=headers; \
	rm -f bfd/Makefile; \
	make configure-bfd; \
	$(MAKE)
	[ -d stamps ] || mkdir stamps ;
	touch stamps/build-binutils;

.PHONY: install-binutils
install-binutils stamps/install-binutils: stamps/build-binutils
	cd binutils-$(BINUTILS_VERSION) && \
	$(MAKE) installdirs install-host install-target
	[ -d stamps ] || mkdir stamps ;
	touch stamps/install-binutils;

########## DFU PROGRAMMER ###########

.PHONY: download-dfu
downloads/$(DFU_ARCHIVE) download-dfu:
	[ -d downloads ] || mkdir downloads ;
	cd downloads && curl -LO $(DFU_URL)

.PHONY: extract-dfu
extract-dfu stamps/extract-dfu: downloads/$(DFU_ARCHIVE)
	@(t1=`openssl md5 $< | cut -f 2 -d " " -` && \
	[ "$$t1" = "$(DFU_MD5)" ] || \
	( echo "Bad Checksum! Please remove the following file and retry: $<" && false ))
	tar -zxf $< ;
	[ -d stamps ] || mkdir stamps ;
	touch stamps/extract-dfu;

.PHONY: build-dfu
build-dfu stamps/build-dfu: stamps/extract-dfu
	mkdir -p build/dfu-programmer && cd build/dfu-programmer && \
	../../dfu-programmer-$(DFU_VERSION)/configure --prefix="$(PREFIX)" && \
	$(MAKE) -j$(PROCS)
	[ -d stamps ] || mkdir stamps
	touch stamps/build-dfu;

.PHONY: install-dfu
install-dfu stamps/install-dfu:  stamps/build-dfu
	cd build/dfu-programmer && \
	$(MAKE) install
	[ -d stamps ] || mkdir stamps
	touch stamps/install-dfu;


################ Bootstrap GCC ################

.PHONY: download-gcc
downloads/$(GCC_ARCHIVE) download-gcc:
	[ -d downloads ] || mkdir downloads ;
	cd downloads && curl -LO $(GCC_URL)

.PHONY: prep-gcc
prep-gcc stamps/prep-gcc: stamps/patch-gcc
	[ -d stamps ] || mkdir stamps;
	touch stamps/prep-gcc;

.PHONY: extract-gcc
extract-gcc stamps/extract-gcc: downloads/$(GCC_ARCHIVE)
	@(t1=`openssl md5 $< | cut -f 2 -d " " -` && \
	[ "$$t1" = "$(GCC_MD5)" ] || \
	( echo "Bad Checksum! Please remove the following file and retry: $<" && false ))
	tar -jxf $< ;
	[ -d stamps ] || mkdir stamps ;
	touch stamps/extract-gcc;

.PHONY: patch-gcc
patch-gcc stamps/patch-gcc: stamps/extract-gcc stamps/extract-avr32patches
	pushd gcc-$(GCC_VERSION) ; \
	for f in ../avr32-patches/gcc/*.patch; do \
	patch -N -p0 <$${f} ; \
	done ; \
	patch -N -p0 <../patches/gcc/00-libstdc++-shared_ptr-without-rtti-bug-42019.patch ; \
	patch -N -p0 <../patches/gcc/01-gcc-floor_log2-error.patch ; \
	patch -N -p0 <../patches/gcc/02-libstdc++-libsupc++-with-fno-exceptions.patch ; \
	patch -N -p0 <../patches/gcc/03-libstdc++-with-fno-exceptions.patch ; \
	patch -N -p1 <../patches/gcc/04-texinfo-5.0-support.patch ; \
	patch -N -p1 <../patches/gcc/05-gperf-3.0.4.patch ; \
   patch -N -p1 <../patches/gcc/06-texi2pod.patch ; \
   patch -N -p1 <../patches/gcc/99_all_cgraph_node-gcc-9.patch ; \
	popd ;
	[ -d stamps ] || mkdir stamps
	touch stamps/patch-gcc;

CFLAGS_FOR_TARGET=-ffunction-sections -fdata-sections			\
-fomit-frame-pointer -DPREFER_SIZE_OVER_SPEED -D__OPTIMIZE_SIZE__ -g	\
-Os -fno-unroll-loops
CXXFLAGS_FOR_TARGET=$(CFLAGS_FOR_TARGET) -fno-exceptions

CFLAGS="-O2 -g -fgnu89-inline -fcommon"

.PHONY: build-gcc
build-gcc stamps/build-gcc: stamps/install-binutils stamps/prep-gcc
	mkdir -p build/gcc && cd build/gcc && \
	pushd ../../gcc-$(GCC_VERSION) ; \
	make clean ; \
	popd ; \
	CFLAGS=$(CFLAGS) ../../gcc-$(GCC_VERSION)/configure --prefix="$(PREFIX)"		\
	--target=$(TARGET) --enable-languages="c" --with-gnu-ld		\
	--with-gnu-as --with-newlib --disable-nls --disable-libssp	\
	--with-dwarf2 --enable-version-specific-runtime-libs --disable-libstdcxx-pch	\
	--disable-shared						\
	--with-build-time-tools="$(PREFIX)/$(TARGET)/bin"		\
	--enable-cxx-flags="$(CXXFLAGS_FOR_TARGET)"				\
	--with-sysroot="$(PREFIX)/$(TARGET)"				\
	--with-build-sysroot="$(PREFIX)/$(TARGET)"			\
	--with-build-time-tools="$(PREFIX)/$(TARGET)/bin"		\
	CFLAGS_FOR_TARGET="$(CFLAGS_FOR_TARGET)"				\
	LDFLAGS_FOR_TARGET="--sysroot=\"$(PREFIX)/$(TARGET)\""		\
	CPPFLAGS_FOR_TARGET="--sysroot=\"$(PREFIX)/$(TARGET)\""		\
	--with-bugurl=$(BUG_URL) \
	--with-pkgversion=$(PKG_VERSION) && \
	rm -f ../../gcc-$(GCC_VERSION)/gcc/cp/cfns.h && \
	$(MAKE) -j$(PROCS)
	[ -d stamps ] || mkdir stamps
	touch stamps/build-gcc;

.PHONY: install-gcc
install-gcc stamps/install-gcc:  stamps/build-gcc
	cd build/gcc && \
	$(MAKE) installdirs install-target && \
	$(MAKE) -C gcc install-common install-cpp install- install-driver install-headers install-man
	[ -d stamps ] || mkdir stamps
	touch stamps/install-gcc;


################ Final GCC ################

.PHONY: prep-final-gcc
prep-final-gcc stamps/prep-final-gcc: stamps/patch-gcc stamps/prep-gcc
	[ -d stamps ] || mkdir stamps;
	touch stamps/prep-final-gcc;

.PHONY: build-final-gcc
build-final-gcc stamps/build-final-gcc: stamps/install-binutils stamps/install-gcc stamps/install-newlib stamps/prep-final-gcc
	mkdir -p build/final-gcc && cd build/final-gcc && \
	pushd ../../gcc-$(GCC_VERSION) ; \
	make clean ; \
	popd ; \
	CFLAGS=$(CFLAGS) ../../gcc-$(GCC_VERSION)/configure --prefix=$(PREFIX) \
	--target=$(TARGET) $(DEPENDENCIES) --enable-languages="c,c++" --with-gnu-ld \
	--with-gnu-as --with-newlib --disable-nls --disable-libssp \
	--with-dwarf2 --enable-version-specific-runtime-libs --disable-libstdcxx-pch \
	--disable-shared --enable-__cxa_atexit \
	--with-build-time-tools=$(PREFIX)/$(TARGET)/bin \
	--enable-cxx-flags="$(CXXFLAGS_FOR_TARGET)" \
	--with-sysroot=$(PREFIX)/$(TARGET) \
	--with-build-sysroot=$(PREFIX)/$(TARGET) \
	--with-build-time-tools=$(PREFIX)/$(TARGET)/bin \
	--disable-libstdcxx-verbose \
	CFLAGS_FOR_TARGET="$(CFLAGS_FOR_TARGET)" \
	LDFLAGS_FOR_TARGET="--sysroot=$(PREFIX)/$(TARGET)" \
	CPPFLAGS_FOR_TARGET="--sysroot=$(PREFIX)/$(TARGET)" \
	--with-bugurl=$(BUG_URL) \
	--with-pkgversion=$(PKG_VERSION) && \
	$(MAKE) -j$(PROCS)
	[ -d stamps ] || mkdir stamps
	touch stamps/build-final-gcc;

.PHONY: install-final-gcc
install-final-gcc stamps/install-final-gcc: stamps/build-final-gcc
	cd build/final-gcc && \
	$(MAKE) installdirs install-target && \
	$(MAKE) -C gcc install-common install-cpp install- install-driver install-headers install-man
	[ -d stamps ] || mkdir stamps
	touch stamps/install-final-gcc;


################ NON-WORKING/NON-ADJUSTED TARGETS ################


gcc-optsize-patch: gcc-$(GCC_VERSION)-$(CS_BASE)/
	pushd gcc-$(GCC_VERSION)-$(CS_BASE) ; \
	patch -N -p1 < ../patches/gcc-optsize.patch ; \
	popd ;

gmp: gmp-$(CS_BASE)/ sudomode
	sudo -u $(SUDO_USER) mkdir -p build/gmp && cd build/gmp ; \
	pushd ../../gmp-$(CS_BASE) ; \
	make clean ; \
	popd ; \
	sudo -u $(SUDO_USER) ../../gmp-$(CS_BASE)/configure --disable-shared && \
	sudo -u $(SUDO_USER) $(MAKE) -j$(PROCS) all && \
	$(MAKE) install

mpc: mpc-$(MPC_VERSION)/ sudomode
	sudo -u $(SUDO_USER) mkdir -p build/gmp && cd build/gmp ; \
	pushd ../../mpc-$(MPC_VERSION) ; \
	make clean ; \
	popd ; \
	sudo -u $(SUDO_USER) ../../mpc-$(MPC_VERSION)/configure --disable-shared && \
	sudo -u $(SUDO_USER) $(MAKE) -j$(PROCS) all && \
	$(MAKE) install

mpc-$(MPC_VERSION) : $(LOCAL_BASE)/mpc-$(CS_VERSION).tar.bz2
ifeq ($(USER),root)
	sudo -u $(SUDO_USER) tar -jxf $<
else
	tar -jxf $<
endif

mpfr: gmp mpfr-$(CS_BASE)/ sudomode
	sudo -u $(SUDO_USER) mkdir -p build/mpfr && cd build/mpfr && \
	pushd ../../mpfr-$(CS_BASE) ; \
	make clean ; \
	popd ; \
	sudo -u $(SUDO_USER) ../../mpfr-$(CS_BASE)/configure LDFLAGS="-Wl,-search_paths_first" --disable-shared && \
	sudo -u $(SUDO_USER) $(MAKE) -j$(PROCS) all && \
	$(MAKE) install

.PHONY : clean
clean:
	rm -rf build stamps source supp
	rm -rf gcc-* binutils-* newlib-* avr32-patches atmel-headers-* dfu-programmer-*
	rm -rf autoconf-* automake-* gperf-* texinfo-*
