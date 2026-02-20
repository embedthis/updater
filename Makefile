#
#   Makefile -- Updater Top-level Makefile
#
#   Uses pre-generated project files from projects/gmake2/.
#   Auto-detects platform. No premake5 required for building.
#
#   Use "make help" for available targets and options.
#

NAME        := updater
OPTIMIZE    ?= debug
TOP         := $(shell realpath .)
BUILD       := build
BIN         := $(TOP)/$(BUILD)/bin
LOCAL       := $(strip $(wildcard ./.local.mk))

#
#   Detect make command (prefer gmake)
#
MAKE        := $(shell if which gmake >/dev/null 2>&1; then echo gmake ; else echo make ; fi) --no-print-directory

#
#   Auto-detect platform from host OS
#
UNAME       := $(shell uname -s)
ifeq ($(UNAME),Darwin)
    PLATFORM := macosx
else ifeq ($(UNAME),Linux)
    PLATFORM := linux
else ifeq ($(UNAME),FreeBSD)
    PLATFORM := freebsd
else
    $(error Unsupported platform: $(UNAME). Use premake5 to regenerate for your OS.)
endif

CONFIG      := $(OPTIMIZE)_$(PLATFORM)
PATH        := $(BIN):$(PATH)
CDPATH      :=

.EXPORT_ALL_VARIABLES:

.PHONY: all build clean doc format help package projects test

ifndef SHOW
.SILENT:
endif

all: build

build:
	@if [ ! -f projects/gmake2/Makefile ] ; then \
		echo "      [Error] projects/gmake2/Makefile not found. Run: cd projects && premake5 gmake2" ; exit 255 ; \
	fi
	$(MAKE) -C projects/gmake2 config=$(CONFIG) verbose=$(SHOW)
	@echo "      [Info] Updater $(OPTIMIZE) [$(PLATFORM)]"

clean:
	@echo "       [Run] clean"
	rm -fr $(BUILD)

test:
	@bin/test-prep.sh
	tm test

doc:
	cp paks/*/doc/api/* doc/api
	bun ~/bin/make-doc doc/updater.dox src/updater.h Updater doc/api paks/*/doc/api/*.tags

format:
	uncrustify -q -c .uncrustify --replace --no-backup src/*.{c,h}

package:
	bash bin/buildLib.sh
	cp CLAUDE.md dist/CLAUDE.md
	cp src/updater.h dist/updater.h

cache: build doc package
	cache

#
#   Regenerate all premake project files (developer only -- requires premake5)
#
projects:
	cd projects && premake5 gmake2 && premake5 vs2022 && premake5 xcode4

help:
	@echo '' >&2
	@echo 'usage: make [clean, build, test]' >&2
	@echo '' >&2
	@echo 'Targets:' >&2
	@echo '  build               Build libupdater and updater utility (default)' >&2
	@echo '  clean               Remove build artifacts' >&2
	@echo '  test                Run unit tests' >&2
	@echo '  doc                 Generate API documentation' >&2
	@echo '  format              Format source code' >&2
	@echo '  package             Build dist/updaterLib.c amalgamated source' >&2
	@echo '  cache               Build, package and cache' >&2
	@echo '  projects            Regenerate premake makefiles (developer only)' >&2
	@echo '' >&2
	@echo 'Make variables:' >&2
	@echo '  OPTIMIZE=debug|release    Optimization level (default: debug)' >&2
	@echo '  SHOW=1                    Show build commands' >&2
	@echo '' >&2

ifneq ($(LOCAL),)
include $(LOCAL)
endif
