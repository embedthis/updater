#
#   updater.sh - Shell-based Over-The-Air (OTA) software update client
#
#   This is a sample shell script implementation of the EmbedThis Updater demonstrating the
#   complete OTA update workflow. It is provided as a reference implementation and starting point.
#
#   Features:
#   - Uses standard Unix tools (curl, jq, openssl)
#   - Secure HTTPS communication with the Builder service
#   - SHA-256 checksum verification
#   - Secure temporary file handling
#   - Comprehensive error checking
#   - Safety limits on download size and timeout
#
#   Security:
#   - Creates secure temporary directory with mktemp
#   - Automatic cleanup on exit via trap
#   - HTTPS-only downloads with fail-fast on errors
#   - Validates JSON responses
#   - Enforces maximum file size and timeout limits
#   - Checksum verification before applying updates
#
#   Configuration:
#   Set these variables with values from your Builder account:
#   - PRODUCT: Product ID from the Builder token list
#   - TOKEN: CloudAPI access token from the Builder token list
#   - ENDPOINT: Cloud API endpoint URL from the Builder Cloud Edit panel
#   - VERSION: Current device firmware version
#   - DEVICE: Unique device identifier
#
#   Dependencies: curl, jq, openssl
#
#   Copyright (c) EmbedThis Software. All Rights Reserved.
#

: ${VERSION="1.2.3"} # Current device firmware version
: ${DEVICE="YOUR_DEVID"} # Unique device identifier
: ${PRODUCT="ProductID from the Builder service token list"} # Product ID from Builder
: ${TOKEN="CloudAPI from the Builder cloud token list"} # CloudAPI access token
: ${ENDPOINT="Cloud API endpoint from Builder Cloud Panel"} # Builder API endpoint URL


#
#   Create a secure temporary directory and configure automatic cleanup
#
TMPDIR=$(mktemp -d)
if [[ ! "$TMPDIR" || ! -d "$TMPDIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

# Ensure temporary directory is cleaned up on exit (success or failure)
trap "rm -rf '$TMPDIR'" EXIT

# Define paths for temporary files
DATA="$TMPDIR/data.tmp" # Request/response data
OUTPUT="$TMPDIR/output.tmp" # API responses
UPDATE="$TMPDIR/update.bin" # Downloaded update image

#
#   Update request. Can add custom device properties to use in the distribution policy
#
cat >"$DATA" <<!EOF
{
    "id":"${DEVICE}",
    "product":"${PRODUCT}",
    "version":"${VERSION}"
}
!EOF

#
#   Check for an update. Silent and fail on non-200 status.
#
curl -f -s --max-time 30 -X POST \
    -H "Authorization:${TOKEN}" \
    -H "Content-Type:application/json" \
    -d "@${DATA}" "${ENDPOINT}/tok/provision/update" >"$OUTPUT"
if [ $? -ne 0 ] ; then
    echo "Failed to check for update" >&2
    exit 2
fi

cat "$OUTPUT" | jq empty >/dev/null 2>&1
if [ $? -ne 0 ] ; then
    # Response did not parse
    cat "$OUTPUT" ; echo
    exit 2
fi
if [ `cat "$OUTPUT"` = "{}" ] ; then
    echo "No update required"
    exit 0
fi

#
#   Parse output and extract fields
#
URL=$(cat "$OUTPUT" | jq -r .url)
CHECKSUM=$(cat "$OUTPUT" | jq -r .checksum)
UPDATEID=$(cat "$OUTPUT" | jq -r .update)
VERSION_NEW=$(cat "$OUTPUT" | jq -r .version)

if [ "$URL" = "null" -o "$URL" = "" ] ; then
    echo "No update available"
    exit 0
fi

#
#   Validate required fields
#
if [ "$CHECKSUM" = "null" -o "$UPDATEID" = "null" -o "$VERSION_NEW" = "null" ] ; then
    echo "Incomplete update response"
    exit 2
fi

#
#   Validate HTTPS
#
if [[ ! "$URL" =~ ^https:// ]] ; then
    echo "Insecure download URL (HTTPS required)"
    exit 2
fi

echo "Update $VERSION_NEW available"

#
#   Fetch the update with safety checks
#
curl -f -s --max-filesize 104857600 --max-time 600 "$URL" >"$UPDATE"
if [ $? -ne 0 ] ; then
    echo "Failed to download update"
    exit 2
fi

#
#   Validate the checksum
#
SUM=$(openssl dgst -sha256 "$UPDATE" | awk '{print $2}')
if [ "$SUM" != "$CHECKSUM" ] ; then
    echo "Checksum does not match"
    echo "$SUM vs"
    echo "$CHECKSUM"
    exit 2
fi
echo "Checksum matches, apply update"

#
#   Customize to apply update here and set success to true/false
#
./apply.sh "$UPDATE"
if [ $? -ne 0 ] ; then
    echo "Apply update failed"
    exit 2
fi
success=true

#
#   Post update status
#
cat >"$DATA" <<!EOF2
{
    "success":"${success}",
    "id":"${DEVICE}",
    "update":"${UPDATEID}"
}
!EOF2
curl -f -s --max-time 30 -X POST \
    -H "Authorization:${TOKEN}" \
    -H "Content-Type:application/json" \
    -d "@${DATA}" "${ENDPOINT}/tok/provision/updateReport"
if [ $? -ne 0 ] ; then
    echo "Failed to post update report" >&2
fi