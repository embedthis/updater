#
#   updater-vxworks-default.mk -- Makefile to build EmbedThis Updater for vxworks
#

NAME                  := updater
VERSION               := 1.1.2
PROJECT               := updater-vxworks-default
PROFILE               ?= dev
ARCH                  ?= $(shell echo $(WIND_HOST_TYPE) | sed 's/-.*$(ME_ROOT_PREFIX)/')
CPU                   ?= $(subst X86,PENTIUM,$(shell echo $(ARCH) | tr a-z A-Z))
OS                    ?= vxworks
CC                    ?= cc$(subst x86,pentium,$(ARCH))
LD                    ?= ldundefined
AR                    ?= arundefined
BUILD                 ?= build
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
LBIN                  ?= $(BUILD)/bin
PATH                  := $(LBIN):$(PATH)

#
# Components
#
ME_COM_COMPILER       ?= 1
ME_COM_LIB            ?= 1
ME_COM_LINK           ?= 1
ME_COM_OSDEP          ?= 1
ME_COM_R              ?= 1
ME_COM_VXWORKS        ?= 0


ifeq ($(ME_COM_LIB),1)
    ME_COM_COMPILER := 1
endif
ifeq ($(ME_COM_LINK),1)
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
ME_COMPILER_HAS_ATOMIC ?= 0
ME_COMPILER_HAS_ATOMIC64 ?= 0
ME_COMPILER_HAS_DOUBLE_BRACES ?= 0
ME_COMPILER_HAS_DYN_LOAD ?= 1
ME_COMPILER_HAS_LIB_EDIT ?= 0
ME_COMPILER_HAS_LIB_RT ?= 0
ME_COMPILER_HAS_MMU   ?= 1
ME_COMPILER_HAS_MTUNE ?= 0
ME_COMPILER_HAS_PAM   ?= 0
ME_COMPILER_HAS_STACK_PROTECTOR ?= 1
ME_COMPILER_HAS_SYNC  ?= 0
ME_COMPILER_HAS_SYNC64 ?= 0
ME_COMPILER_HAS_SYNC_CAS ?= 0
ME_COMPILER_HAS_UNNAMED_UNIONS ?= 1
ME_COMPILER_WARN64TO32 ?= 0
ME_COMPILER_WARN_UNUSED ?= 0
ME_CONFIGURE          ?= \"me -d -q -platform vxworks-arm-default -configure . -gen make\"
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
ME_VERSION            ?= \"1.1.2\"

export PATH           := $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin:$(PATH)
CFLAGS                += -fomit-frame-pointer -fno-builtin -fno-defer-pop -fvolatile
DFLAGS                += -DCPU=ARMARCH7 -DRW_MULTI_THREAD -DTOOL=gnu -DTOOL_FAMILY=gnu -DVXWORKS -D_GNU_TOOL -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h" -D_WRS_KERNEL_ $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) "-DME_COM_COMPILER=$(ME_COM_COMPILER)" "-DME_COM_LIB=$(ME_COM_LIB)" "-DME_COM_LINK=$(ME_COM_LINK)" "-DME_COM_OSDEP=$(ME_COM_OSDEP)" "-DME_COM_R=$(ME_COM_R)" "-DME_COM_VXWORKS=$(ME_COM_VXWORKS)" "-DME_MBEDTLS_COMPACT=$(ME_MBEDTLS_COMPACT)" 
IFLAGS                += "-I$(BUILD)/inc"
LDFLAGS               += "-Wl,-r"
LIBPATHS              += "-L$(BUILD)/bin"
LIBS                  += "-lgcc"

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

ME_ROOT_PREFIX        ?= deploy
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)
ME_DATA_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_STATE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_BIN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_INC_PREFIX         ?= $(ME_VAPP_PREFIX)/inc
ME_LIB_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_MAN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SBIN_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_ETC_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_WEB_PREFIX         ?= $(ME_VAPP_PREFIX)/web
ME_LOG_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SPOOL_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_CACHE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/src/$(NAME)-$(VERSION)


TARGETS               += $(BUILD)/bin/libupdater.a
TARGETS               += $(BUILD)/bin/updater.out


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
	@if [ "$(WIND_BASE)" = "" ] ; then echo WARNING: WIND_BASE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_HOST_TYPE)" = "" ] ; then echo WARNING: WIND_HOST_TYPE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_GNU_PATH)" = "" ] ; then echo WARNING: WIND_GNU_PATH not set. Run wrenv.sh. ; exit 255 ; fi
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
	rm -f "$(BUILD)/bin/updater.out"

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
	$(CC) -c -o "$(BUILD)/obj/main.o" $(CFLAGS) $(DFLAGS) "-DME_DEBUG=1" "-DVXWORKS" "-DRW_MULTI_THREAD" "-DCPU=ARMARCH7" "-DTOOL_FAMILY=gnu" "-DTOOL=gnu" "-D_GNU_TOOL" "-D_WRS_KERNEL_" "-D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\"" $(IFLAGS) "-Isrc" "-Isrc/osdep" $(INPUT) "src/main.c"

#
#   updater.o
#
DEPS_6 += src/updater.h

$(BUILD)/obj/updater.o: \
    src/updater.c $(DEPS_6)
	@echo '   [Compile] $(BUILD)/obj/updater.o'
	$(CC) -c -o "$(BUILD)/obj/updater.o" $(CFLAGS) $(DFLAGS) "-DME_DEBUG=1" "-DVXWORKS" "-DRW_MULTI_THREAD" "-DCPU=ARMARCH7" "-DTOOL_FAMILY=gnu" "-DTOOL=gnu" "-D_GNU_TOOL" "-D_WRS_KERNEL_" "-D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\"" $(IFLAGS) "-Isrc" "-Isrc/osdep" $(INPUT) "src/updater.c"

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

$(BUILD)/bin/updater.out: $(DEPS_8)
	@echo '      [Link] $(BUILD)/bin/updater.out'
	$(CC) -o "$(BUILD)/bin/updater.out" $(LDFLAGS) $(LIBPATHS) $(INPUT) "$(BUILD)/obj/main.o" $(LIBPATHS_8) $(LIBS_8) $(LIBS_8) $(LIBS) "-lcrypto" "-lssl" $(LDFLAGS) 

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
