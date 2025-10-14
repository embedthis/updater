#
#   Makefile - Top-level Updater makefile
#
#	This Makefile is used for native builds and for ESP32 configuration.
#	It is a wrapper over generated makefiles under ./projects.
#
#	Use "make help" for a list of available make variable options.
#

SHELL		:= /bin/bash
PROFILE 	?= dev
OPTIMIZE	?= debug
TOP			:= $(shell realpath .)
MAKE		:= $(shell if which gmake >/dev/null 2>&1; then echo gmake ; else echo make ; fi) --no-print-directory
OS			:= $(shell uname | sed 's/CYGWIN.*/windows/;s/Darwin/macosx/' | tr '[A-Z]' '[a-z]')
ARCH		?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/mips.*/mips/;s/aarch/arm/')
LOCAL 		:= $(strip $(wildcard ./.local.mk))
PROJECT		:= projects/updater-$(OS)-default.mk

# BUILD		:= build/$(OS)-$(ARCH)-$(PROFILE)
BUILD		:= build

BIN			:= $(TOP)/$(BUILD)/bin
PATH		:= $(TOP)/bin:$(BIN):$(PATH)
CDPATH		:=

.EXPORT_ALL_VARIABLES:

.PHONY:		app build clean compile config info show

ifndef SHOW
.SILENT:
endif

all: build

build: config compile info

config:
	@mkdir -p $(BUILD)/bin

compile:
	@if [ ! -f $(PROJECT) ] ; then \
		echo "The build configuration $(PROJECT) is not supported" ; exit 255 ; \
	fi
	$(MAKE) -f $(PROJECT) OPTIMIZE=$(OPTIMIZE) PROFILE=$(PROFILE) BUILD=$(BUILD) compile 

clean:
	@echo '       [Run] $@'
	@$(MAKE) -f $(PROJECT) TOP=$(TOP) PROFILE=$(PROFILE) $@

install installBinary uninstall:
	@echo '       [Run] $@'
	@$(MAKE) -f $(PROJECT) TOP=$(TOP) PROFILE=$(PROFILE) $@

info:
	@VERSION=`json --default 1.2.3 version pak.json` ; \
	echo "      [Info] Built Updater $${VERSION} optimized for \"$(OPTIMIZE)\""
	echo "      [Info] Run via: \"sudo make run\". Run \"Updater\" manually with \"$(BUILD)/bin\" in your path."

run:
	$(BUILD)/bin/updater -v

path:
	echo $(PATH)

help:
	@echo '' >&2
	@echo 'usage: make [clean, build, run]' >&2
	@echo '' >&2
	@echo 'Other make environment variables:' >&2
	@echo '  ARCH               # CPU architecture (x86, x64, ppc, ...)' >&2
	@echo '  OS                 # Operating system (linux, macosx, ...)' >&2
	@echo '  CC                 # Compiler to use ' >&2
	@echo '  LD                 # Linker to use' >&2
	@echo '  OPTIMIZE           # Set to "debug" or "release" for a debug or release build of the agent.' >&2
	@echo '  CFLAGS             # Add compiler options. For example: -Wall' >&2
	@echo '  DFLAGS             # Add compiler defines. For example: -DCOLOR=blue' >&2
	@echo '  IFLAGS             # Add compiler include directories. For example: -I/extra/includes' >&2
	@echo '  LDFLAGS            # Add linker options' >&2
	@echo '  LIBPATHS           # Add linker library search directories. For example: -L/libraries' >&2
	@echo '  LIBS               # Add linker libraries. For example: -lpthreads' >&2
	@echo '' >&2
	@echo 'Use "SHOW=1 make" to show executed commands.' >&2
	@echo '' >&2

ifneq ($(LOCAL),)
include $(LOCAL)
endif

# vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: