#
#   updater.sh - Sample updates using shell
#
#
#   Get values for PRODUCT, TOKEN and ENDPOINT from your Builder Token list and 
#   Cloud Edit panel. Set your VERSION and DEVICE here.
#

VERSION="1.2.3"
DEVICE="YOUR_DEVID"

PRODUCT="ProductID from the Buidler sevice token list"
TOKEN="CloudAPI from the Builder cloud token list"
ENDPOINT="Cloud API endpoint from Builder Cloud Panel"

# Securely create a temporary directory for our files
TMPDIR=$(mktemp -d)
if [[ ! "$TMPDIR" || ! -d "$TMPDIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi
# Make sure it's cleaned up on exit
trap "rm -rf '$TMPDIR'" EXIT

DATA="$TMPDIR/data.tmp"
OUTPUT="$TMPDIR/output.tmp"
UPDATE="$TMPDIR/update.bin"

#
#   Update request. Can add custom device properties to use in the distribution policy
#
cat >"$DATA" <<!EOF
{
    "id":"${DEVICE}",
    "product":"${PRODUCT}",
    "version":"${VERSION}",
}
!EOF

#
#   Check for an update
#
curl -s -X POST \
    -H "Authorization:${TOKEN}" \
    -H "Content-Type:application/json" \
    -d "@${DATA}" "${ENDPOINT}/tok/provision/update" >"$OUTPUT"
if [ $? -ne 0 ] ; then
    echo "Failed to update: " `cat "$OUTPUT"` >&2 
    exit 2
fi

#
#   Parse output and extract the URL
#
URL=$(cat "$OUTPUT" | jq -r .url)

if [ "${URL}" != "" ] ; then
    #
    #   Fetch the update
    #
    curl -s "${URL}" >"$UPDATE"

    #
    #   Validate the checksum
    #
    SUM=$(openssl dgst -sha256 "$UPDATE" | awk '{print $2}')
    CHECKSUM=$(cat "$OUTPUT" | jq -r .checksum)
    if [ "${SUM}" != "${CHECKSUM}" ] ; then
        echo "Checksum does not match"
    else
        echo "Checksum matches, apply update $UPDATE"
    fi
    #
    #   Customize to apply update here and set success to true/false
    #
    success=true

    #
    #   Post update status
    #
    UPDATEID=$(cat "$OUTPUT" | jq -r .update)
    cat >"$DATA" <<!EOF2
{
    "success":${success},
    "id":"${DEVICE}",
    "update":"${UPDATEID}",
}
!EOF2
    curl -s -X POST \
        -H "Authorization:${TOKEN}" \
        -H "Content-Type:application/json" \
        -d "@${DATA}" "${ENDPOINT}/tok/provision/updateReport"

else
    echo No update required
fi