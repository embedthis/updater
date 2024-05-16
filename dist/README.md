# EmbedThis Updater

The EmbedThis Updater is a command line utility and library to download and apply device software updates published on the [EmbedThis Builder](https://admin.embedthis.com).

## Description

This source builds a stand-alone **updater** program that can be used to download software updates published by you
on the [Builder site](https://admin.embedthis.com).

## Usage

    update [options] key=value,...

Where options are:

Option | Description
-|-
--cmd script        | Script to invoke to apply the update
--device ID         | Unique device ID
--file image/path   | Path to save the downloaded update
--host host.domain  | Device cloud endpoint from the Builder cloud edit panel
--product ProductID | ProductID from the Buidler token list
--token TokenID     | CloudAPI access token from the Builder token list
--version SemVer    | Current device firmware version

The key=value pairs can provide device specific properties that can be used by the Builder software
update policy to determine which devices receive the update.

### Example:

    update -v --device "A123456789" \
        --host "https://ygp2t8ckqj.execute-api.ap-southeast-1.amazonaws.com" \
        --product "XABCDACC2T1234567890123455" \
        --token "TT488ETG5H1234567890123456" \
        --version "2.1.2" \
        --cmd ./apply.sh \
        pro=true

## Library

You can use the update.c source file and invoke the update() API from your programs.

## Files

File | Description
-|-
Makefile | Local Makefile to build update program
apply.sh | Script to customize to apply the update to the device
main.c | Main program for the updater
update.c | Update library source
update.h | Update library header
