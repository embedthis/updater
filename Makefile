#
#	Updater Makefile
#

all: compile

compile build:
	@make -C src

clean:
	@make -C src clean

cache: clean
	@me cache

format:
	uncrustify -q -c .uncrustify --replace --no-backup src/*.{c,h}


LOCAL_MAKEFILE := $(strip $(wildcard ./.local.mk))

ifneq ($(LOCAL_MAKEFILE),)
include	$(LOCAL_MAKEFILE)
endif
