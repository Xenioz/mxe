# GEOS
# http://geos.refractions.net/

PKG            := geos
$(PKG)_VERSION := 3.0.0
$(PKG)_SUBDIR  := geos-$($(PKG)_VERSION)
$(PKG)_FILE    := geos-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL     := http://geos.refractions.net/downloads/$($(PKG)_FILE)
$(PKG)_DEPS    := gcc

define $(PKG)_UPDATE
    wget -q -O- 'http://geos.refractions.net/' | \
    $(SED) -n 's,.*geos-\([0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    $(SED) 's,-lgeos,-lgeos -lstdc++,' -i '$(1)/tools/geos-config.in'
    # timezone and gettimeofday are in <time.h> since MinGW runtime 3.10
    $(SED) 's,struct timezone {,struct timezone_disabled {,' -i '$(1)/source/headers/geos/timeval.h'
    $(SED) 's,int gettimeofday,int gettimeofday_disabled,'   -i '$(1)/source/headers/geos/timeval.h'
    cd '$(1)' && ./configure \
        --host='$(TARGET)' \
        --disable-shared \
        --prefix='$(PREFIX)/$(TARGET)' \
        --disable-swig
    $(MAKE) -C '$(1)' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
endef