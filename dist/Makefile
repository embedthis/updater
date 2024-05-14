#
#	Update Makefile
#
OS := $(shell uname | sed 's/CYGWIN.*/windows/;s/Darwin/macosx/' | tr '[A-Z]' '[a-z]')

ifeq ($(OS),macosx)
	IFLAGS	:= -I /opt/homebrew/include
	LFLAGS	:= -L /opt/homebrew/lib
endif

#
#	For test
#
VERSION		:= "2.1.2"
DEVICE   	:= "A123456789"
PRODUCT		:= "01HXRACC2TX46KCAAKW996CZHH"
TOKEN		:= "01HX8ETG5HQK6W21ZXAR3EGYJB"
HOST		:= "https://ygp2t8ckqj.execute-api.ap-southeast-1.amazonaws.com"

all: compile

compile build: update

update.o: update.c
	clang $(IFLAGS) -c update.c

update: update.o 
	clang $(IFLAGS) $(LFLAGS) -o update main.c update.o -lssl -lcrypto

clean:
	rm -f update.o main.o update

cache: clean
	cp README* apply.sh main.c update.h update.c Makefile dist
	cache

run:
	./update --device $(DEVICE) --host $(HOST) --product $(PRODUCT) --token $(TOKEN) --version $(VERSION) --cmd ./apply.sh pro=true
