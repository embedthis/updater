#
#   updater-macosx-default.mk -- Makefile to build EmbedThis Updater for macosx
#

NAME                  := updater
VERSION               := 1.1.4
PROJECT               := updater-macosx-default
PROFILE               ?= dev
ARCH                  ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/mips.*/mips/')
CC_ARCH               ?= $(shell echo $(ARCH) | sed 's/x86/i686/;s/x64/x86_64/')
OS                    ?= macosx
CC                    ?= clang
AR                    ?= ar
BUILD                 ?= build
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
LBIN                  ?= $(BUILD)/bin
PATH                  := $(LBIN):$(PATH)

#
# Components
#
ME_COM_COMPILER       ?= 1
ME_COM_LIB            ?= 1
ME_COM_OSDEP          ?= 1
ME_COM_R              ?= 1
ME_COM_VXWORKS        ?= 0


ifeq ($(ME_COM_LIB),1)
    ME_COM_COMPILER := 1
endif

#
# Settings
#
ME_AUTHOR             ?= \"updater\"
ME_BUILD              ?= \"build\"
ME_COMPANY            ?= \"updater\"
ME_COMPATIBLE         ?= \"1.1\"
ME_COMPILER_FORTIFY   ?= 1
ME_COMPILER_HAS_ATOMIC ?= 1
ME_COMPILER_HAS_ATOMIC64 ?= 1
ME_COMPILER_HAS_DOUBLE_BRACES ?= 1
ME_COMPILER_HAS_DYN_LOAD ?= 1
ME_COMPILER_HAS_LIB_EDIT ?= 1
ME_COMPILER_HAS_LIB_RT ?= 0
ME_COMPILER_HAS_MMU   ?= 1
ME_COMPILER_HAS_MTUNE ?= 1
ME_COMPILER_HAS_PAM   ?= 1
ME_COMPILER_HAS_STACK_PROTECTOR ?= 1
ME_COMPILER_HAS_SYNC  ?= 1
ME_COMPILER_HAS_SYNC64 ?= 1
ME_COMPILER_HAS_SYNC_CAS ?= 1
ME_COMPILER_HAS_UNNAMED_UNIONS ?= 1
ME_COMPILER_NOEXECSTACK ?= 0
ME_COMPILER_WARN64TO32 ?= 1
ME_COMPILER_WARN_UNUSED ?= 1
ME_CONFIGURE          ?= \"me -d -q -platform macosx-arm64-default -configure . -gen make\"
ME_CONFIGURED         ?= 1
ME_DEBUG              ?= 1
ME_DEPTH              ?= 1
ME_DESCRIPTION        ?= \"Device firmware updater\"
ME_INTEGRATE          ?= 1
ME_MBEDTLS_COMPACT    ?= 0
ME_NAME               ?= \"updater\"
ME_PARTS              ?= \"undefined\"
ME_PREFIXES           ?= \"install-prefixes\"
ME_STATIC             ?= 1
ME_TITLE              ?= \"EmbedThis Updater\"
ME_TLS                ?= \"openssl\"
ME_TUNE               ?= \"size\"
ME_VERSION            ?= \"1.1.4\"

CFLAGS                += -Wno-unused-result -Wshorten-64-to-32 -Wall -Wno-unknown-warning-option -fstack-protector --param=ssp-buffer-size=4 -Wformat -Wformat-security -Wsign-compare -Wsign-conversion
DFLAGS                +=  $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) "-DME_COM_COMPILER=$(ME_COM_COMPILER)" "-DME_COM_LIB=$(ME_COM_LIB)" "-DME_COM_OSDEP=$(ME_COM_OSDEP)" "-DME_COM_R=$(ME_COM_R)" "-DME_COM_VXWORKS=$(ME_COM_VXWORKS)" "-DME_MBEDTLS_COMPACT=$(ME_MBEDTLS_COMPACT)" 
IFLAGS                += "-I$(BUILD)/inc"
LDFLAGS               += "-Wl,-no_warn_duplicate_libraries" "-Wl,-rpath,@executable_path/" "-Wl,-rpath,@loader_path/"
LIBPATHS              += "-L$(BUILD)/bin"
LIBS                  += "-ldl" "-lpthread" "-lm"

OPTIMIZE              ?= debug
CFLAGS-debug          ?= -g
DFLAGS-debug          ?= -DME_DEBUG=1
LDFLAGS-debug         ?= -g
DFLAGS-release        ?= 
CFLAGS-release        ?= -O2
LDFLAGS-release       ?= 
CFLAGS                += $(CFLAGS-$(OPTIMIZE))
DFLAGS                += $(DFLAGS-$(OPTIMIZE))
LDFLAGS               += $(LDFLAGS-$(OPTIMIZE))

ME_ROOT_PREFIX        ?= 
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local
ME_DATA_PREFIX        ?= $(ME_ROOT_PREFIX)/
ME_STATE_PREFIX       ?= $(ME_ROOT_PREFIX)/var
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)/lib/$(NAME)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)/$(VERSION)
ME_BIN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/bin
ME_INC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/include
ME_LIB_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/lib
ME_MAN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/share/man
ME_SBIN_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local/sbin
ME_ETC_PREFIX         ?= $(ME_ROOT_PREFIX)/etc/$(NAME)
ME_WEB_PREFIX         ?= $(ME_ROOT_PREFIX)/var/www/$(NAME)
ME_LOG_PREFIX         ?= $(ME_ROOT_PREFIX)/var/log/$(NAME)
ME_VLIB_PREFIX        ?= $(ME_ROOT_PREFIX)/var/lib/$(NAME)
ME_SPOOL_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)
ME_CACHE_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)/cache
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)$(NAME)-$(VERSION)


TARGETS               += $(BUILD)/bin/libupdater.a
TARGETS               += $(BUILD)/bin/updater


DEPEND := $(strip $(wildcard ./projects/depend.mk))
ifneq ($(DEPEND),)
include $(DEPEND)
endif

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all build compile: prep $(TARGETS)

.PHONY: prep

prep:
	@if [ "$(BUILD)" = "" ] ; then echo WARNING: BUILD not set ; exit 255 ; fi
	@if [ "$(ME_APP_PREFIX)" = "" ] ; then echo WARNING: ME_APP_PREFIX not set ; exit 255 ; fi
	@[ ! -x $(BUILD)/bin ] && mkdir -p $(BUILD)/bin; true
	@[ ! -x $(BUILD)/inc ] && mkdir -p $(BUILD)/inc; true
	@[ ! -x $(BUILD)/obj ] && mkdir -p $(BUILD)/obj; true
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/$(PROJECT)-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/$(PROJECT)-me.h >/dev/null ; then\
		cp projects/$(PROJECT)-me.h $(BUILD)/inc/me.h  ; \
	fi; true

clean:
	rm -f "$(BUILD)/obj/main.o"
	rm -f "$(BUILD)/obj/updater.o"
	rm -f "$(BUILD)/bin/libupdater.a"
	rm -f "$(BUILD)/bin/updater"

clobber: clean
	rm -fr ./$(BUILD)

#
#   me.h
#
DEPS_1 += src/me.h

$(BUILD)/inc/me.h: $(DEPS_1)
	@echo '      [Copy] $(BUILD)/inc/me.h'
	mkdir -p "$(BUILD)/inc"
	cp src/me.h $(BUILD)/inc/me.h

#
#   osdep.h
#
DEPS_2 += src/osdep/osdep.h

$(BUILD)/inc/osdep.h: $(DEPS_2)
	@echo '      [Copy] $(BUILD)/inc/osdep.h'
	mkdir -p "$(BUILD)/inc"
	cp src/osdep/osdep.h $(BUILD)/inc/osdep.h

#
#   updater.h
#
DEPS_3 += src/updater.h

$(BUILD)/inc/updater.h: $(DEPS_3)
	@echo '      [Copy] $(BUILD)/inc/updater.h'
	mkdir -p "$(BUILD)/inc"
	cp src/updater.h $(BUILD)/inc/updater.h

#
#   updater.h
#

src/updater.h: $(DEPS_4)

#
#   main.o
#
DEPS_5 += src/updater.h

$(BUILD)/obj/main.o: \
    src/main.c $(DEPS_5)
	@echo '   [Compile] $(BUILD)/obj/main.o'
	$(CC) -c -o "$(BUILD)/obj/main.o" -arch $(CC_ARCH) $(CFLAGS) $(DFLAGS) $(IFLAGS) "-Isrc" "-Isrc/osdep" "-I/opt/homebrew/include" $(INPUT) "src/main.c"

#
#   updater.o
#
DEPS_6 += src/updater.h

$(BUILD)/obj/updater.o: \
    src/updater.c $(DEPS_6)
	@echo '   [Compile] $(BUILD)/obj/updater.o'
	$(CC) -c -o "$(BUILD)/obj/updater.o" -arch $(CC_ARCH) $(CFLAGS) $(DFLAGS) $(IFLAGS) "-Isrc" "-Isrc/osdep" "-I/opt/homebrew/include" $(INPUT) "src/updater.c"

#
#   libupdater
#
DEPS_7 += $(BUILD)/inc/osdep.h
DEPS_7 += $(BUILD)/inc/me.h
DEPS_7 += $(BUILD)/inc/updater.h
DEPS_7 += $(BUILD)/obj/updater.o

$(BUILD)/bin/libupdater.a: $(DEPS_7)
	@echo '      [Link] $(BUILD)/bin/libupdater.a'
	$(AR) -cr "$(BUILD)/bin/libupdater.a" $(INPUT) "$(BUILD)/obj/updater.o"

#
#   updater
#
DEPS_8 += $(BUILD)/bin/libupdater.a
DEPS_8 += $(BUILD)/inc/osdep.h
DEPS_8 += $(BUILD)/obj/main.o

LIBS_8 += -lupdater

$(BUILD)/bin/updater: $(DEPS_8)
	@echo '      [Link] $(BUILD)/bin/updater'
	$(CC) -o "$(BUILD)/bin/updater" -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "-L/opt/homebrew/lib" $(INPUT) "$(BUILD)/obj/main.o" $(LIBPATHS_8) $(LIBS_8) $(LIBS_8) $(LIBS) "-lcrypto" "-lssl" 

#
#   installPrep
#

installPrep: $(DEPS_9)
	if [ "`id -u`" != 0 ] ; \
	then echo "Must run as root. Rerun with sudo." ; \
	exit 255 ; \
	fi

#
#   stop
#

stop: $(DEPS_10)

#
#   installBinary
#

installBinary: $(DEPS_11)

#
#   start
#

start: $(DEPS_12)

#
#   install
#
DEPS_13 += installPrep
DEPS_13 += stop
DEPS_13 += installBinary
DEPS_13 += start

install: $(DEPS_13)

#
#   uninstall
#
DEPS_14 += stop

uninstall: $(DEPS_14)

#
#   uninstallBinary
#

uninstallBinary: $(DEPS_15)


EXTRA_MAKEFILE := $(strip $(wildcard ./projects/extra.mk))
ifneq ($(EXTRA_MAKEFILE),)
include $(EXTRA_MAKEFILE)
endif
