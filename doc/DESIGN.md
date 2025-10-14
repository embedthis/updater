# EmbedThis Updater - Design Document

## Overview

The EmbedThis Updater provides secure Over-The-Air (OTA) software update capabilities for IoT devices. This document describes the architecture, design decisions, and implementation details across three language implementations: C, JavaScript (Node.js/Bun), and Shell.

The updater client integrates with the [EmbedThis Builder](https://www.embedthis.com/builder/) cloud service, which manages software update distribution, version control, and deployment policies. The Builder service stores updates on AWS S3 and distributes them globally via AWS CloudFront CDN.

## Builder Service Integration

### Service Architecture

The Builder cloud service provides:

1. **Update Storage & Distribution**
   - Updates hosted on AWS S3 with global CDN delivery
   - HTTPS-only secure downloads
   - Automatic geographic distribution for low latency

2. **Distribution Policy Engine**
   - JavaScript-like expression language for policy evaluation
   - SemVer 2.0 version comparison
   - Device property-based targeting
   - Opt-in update mechanism (devices request, not pushed)

3. **Rollout Controls**
   - Gradual deployment with percentage-based limits
   - Maximum updates per time period throttling
   - Update rate control to prevent service overload
   - Ability to pause or rollback updates

4. **Analytics & Monitoring**
   - Real-time update metrics
   - Success/failure tracking per device
   - Deferred update reporting
   - Historical update data

### Update Check-In Protocol

Devices periodically check for updates by sending a POST request to the Builder API:

**Request:**
```json
{
  "id": "device-unique-id",
  "product": "product-id-from-builder",
  "version": "1.2.3",
  "custom-property": "value"
}
```

**Response (update available):**
```json
{
  "url": "https://cdn.example.com/update.bin",
  "checksum": "sha256-hex-string",
  "update": "update-id",
  "version": "1.3.0"
}
```

**Response (no update):**
```json
{}
```

The Builder service evaluates the distribution policy for the device and returns an update URL only if:
- A newer version is available
- The device matches the distribution policy criteria
- Rollout limits have not been exceeded
- The update has not been deferred for this device

### Distribution Policy Examples

Builder supports flexible targeting policies:

**Version-based update:**
```javascript
device.version < update.version
```

**Property-based targeting:**
```javascript
device.version < update.version && device.pro == true
```

**Complex conditional:**
```javascript
device.version < update.version &&
(device.region == 'us-west' || device.tier == 'premium')
```

### Supported Device Agents

The Builder service supports multiple device agent types:
- **Ioto Device Agent** - Full-featured IoT device agent with integrated updater
- **Appweb/GoAhead** - Embedded web servers with updater integration
- **Standalone Updater** - This repository's implementations for custom devices

## Architecture

### High-Level Flow

All implementations follow the same core workflow:

```
1. Check for Updates
   ├─> POST to Builder API with device metadata
   ├─> Receive update response (URL, checksum, version)
   └─> Validate response completeness

2. Download Update (if available)
   ├─> Validate HTTPS URL
   ├─> Download with size/time limits
   └─> Save to local filesystem

3. Verify Update
   ├─> Calculate SHA-256 checksum
   └─> Compare with expected checksum

4. Apply Update
   ├─> Execute user-provided script
   └─> Capture exit status

5. Report Status
   └─> POST result back to Builder API
```

### Security Model

The updater operates under the following security assumptions:

1. **Developer Trust**: The developer embedding the updater is trusted to:
   - Provide valid, secure endpoints
   - Protect API tokens and credentials
   - Implement secure update application scripts
   - Validate inputs to the updater

2. **Network Security**: All communication uses HTTPS with:
   - TLS 1.2+ (C implementation enforces minimum)
   - Certificate validation against system CA bundle
   - Hostname verification

3. **Update Integrity**: Updates are validated via:
   - SHA-256 cryptographic checksums
   - Strict URL validation (HTTPS-only)
   - Content-Length validation and enforcement

4. **File System Security**: Downloaded files are:
   - Created with exclusive flags (prevents race conditions)
   - Set with restrictive permissions (0600)
   - Validated as regular files (not symlinks/devices)

## Implementation Comparison

### C Implementation (`updater.c`)

**Purpose**: Production-ready library and command-line utility for resource-constrained embedded devices.

**Key Features**:
- Single-file library design (updater.c + updater.h)
- Minimal dependencies (OpenSSL/LibreSSL only)
- Safe Runtime types (ssize instead of size_t)
- Null-tolerant functions
- Explicit error handling
- TLS 1.2+ enforcement
- Quiet mode for suppressing stdout while preserving stderr
- Cross-platform (Linux, macOS, BSD, Windows/WSL)

**Design Decisions**:

1. **Memory Management**
   - Manual memory management with explicit free() calls
   - Early exits with cleanup on errors
   - No global allocation handler (returns NULL on failure)

2. **Network Layer**
   - Minimal HTTP client using OpenSSL directly
   - No external HTTP library dependencies
   - Manual HTTP request/response parsing
   - Supports only required HTTP features (POST, GET)

3. **Type System**
   - Uses `ssize` (64-bit signed) instead of `size_t` for consistency
   - Uses `cchar` for const char* (readability)
   - Explicit casts minimized

4. **Error Handling**
   - Returns -1 on error, 0 on success
   - Errors printed to stderr
   - No exceptions (C has none)

**Implementation Details**:

```c
// Core structures
typedef struct Fetch {
    SSL_CTX *ctx;          // TLS context
    SSL     *ssl;          // TLS connection
    int     fd;            // Socket descriptor
    ssize   contentLength; // Response size
    ssize   bodyLength;    // Already-read body bytes
    char    *body;         // Body fragment
    int     status;        // HTTP status code
} Fetch;

// Main API
int update(cchar *host, cchar *product, cchar *token,
           cchar *device, cchar *version, cchar *properties,
           cchar *path, cchar *script, int verbose, int quiet);
```

**Security Features**:
- Certificate validation with system CA bundle
- SNI (Server Name Indication) support
- Hostname verification via X509_VERIFY_PARAM
- Buffer overflow protection (bounds checking on all operations)
- Integer overflow protection (validates Content-Length)
- TOCTOU mitigation (exclusive file creation)
- No shell execution (uses fork/execvp)

**Trade-offs**:
- ✅ Minimal memory footprint (~10KB code)
- ✅ No dynamic library dependencies beyond OpenSSL
- ✅ Suitable for embedded Linux, RTOS
- ❌ More verbose than high-level languages
- ❌ Manual memory management complexity

### JavaScript Implementation (`updater.js`)

**Purpose**: Modern alternative for devices running Node.js or Bun with equivalent security.

**Key Features**:
- Built-in fetch API (no dependencies)
- Native crypto for checksums
- Promise-based async/await flow
- Single file implementation
- ES6 modules
- Quiet mode for suppressing stdout while preserving stderr

**Design Decisions**:

1. **Async Model**
   - Promise-based async/await for clean code
   - No callbacks (uses modern async patterns)
   - Sequential execution (no parallelism needed)

2. **Network Layer**
   - Uses native `fetch()` API (Node 18+, Bun)
   - Automatic redirect handling
   - Built-in HTTPS with certificate validation
   - Streaming downloads with pipe()

3. **Type System**
   - JavaScript dynamic typing
   - No TypeScript (keeps it simple)
   - Runtime validation of all inputs

4. **Error Handling**
   - try/catch blocks around all I/O
   - Throws errors with descriptive messages
   - Early returns on validation failures

**Implementation Details**:

```javascript
// Constants
const MAX_CONTENT_LENGTH = 100 * 1024 * 1024  // 100 MB
const DOWNLOAD_TIMEOUT = 10 * 60 * 1000       // 10 minutes
const SCRIPT_TIMEOUT = 5 * 60 * 1000          // 5 minutes
const MAX_PROPERTIES = 50
const FILE_MODE = 0o600

// Main flow
async function main() {
    parseArgs()
    let response = await fetch(url, { method: 'POST', ... })
    let data = await response.text()
    data = JSON.parse(data)
    await download(data.url, file)
    let sum = await getChecksum(file)
    if (!timingSafeEqual(Buffer.from(sum), Buffer.from(checksum))) {
        throw new Error('Checksum mismatch')
    }
    let success = await applyUpdate(cmd, file)
    await fetch(reportUrl, { method: 'POST', ... })
}
```

**Security Features**:
- Timing-safe checksum comparison (`timingSafeEqual`)
- Script executable verification (`fs.accessSync`)
- Timeout on script execution (`execFile` with timeout option)
- Timeout on download (stream timeout)
- Content-Length validation (NaN, Infinity checks)
- Properties count limit (prevents DoS)
- Input validation (key=value parsing)

**Trade-offs**:
- ✅ Cleaner, more readable code
- ✅ Native async/await simplifies flow
- ✅ Built-in HTTPS with modern crypto
- ✅ Easier to maintain and extend
- ❌ Requires Node.js 18+ or Bun runtime (~50MB+)
- ❌ Larger memory footprint than C
- ❌ Not suitable for minimal embedded systems

### Shell Script Implementation (`updater.sh`)

**Purpose**: Documentation and reference only - demonstrates the API protocol.

**Key Features**:
- Plain bash/POSIX shell
- Command-line arguments (not environment variables)
- Uses curl for HTTP
- Uses jq for JSON parsing
- Uses openssl for checksums
- Quiet mode for suppressing stdout while preserving stderr
- Minimal error handling

**Design Decisions**:

1. **External Dependencies**
   - curl: HTTP client with HTTPS support
   - jq: JSON parsing (safer than shell string manipulation)
   - openssl: Cryptographic operations

2. **Security**
   - Temporary directory with trap cleanup
   - curl safety flags: `-f`, `--max-filesize`, `--max-time`
   - HTTPS validation via regex
   - JSON validation before parsing

3. **Error Handling**
   - Exit codes: 0 (success), 2 (error)
   - Early exit on errors
   - Validation of jq outputs ("null" checks)

**Implementation Details**:

```bash
# Request update
curl -f -s --max-time 30 -X POST \
    -H "Authorization:${TOKEN}" \
    -H "Content-Type:application/json" \
    -d "@${DATA}" "${ENDPOINT}/tok/provision/update" >"$OUTPUT"

# Parse response
URL=$(cat "$OUTPUT" | jq -r .url)
CHECKSUM=$(cat "$OUTPUT" | jq -r .checksum)

# Validate HTTPS
if [[ ! "$URL" =~ ^https:// ]] ; then
    echo "Insecure download URL (HTTPS required)"
    exit 2
fi

# Download with limits
curl -f -s --max-filesize 104857600 --max-time 600 "$URL" >"$UPDATE"

# Verify checksum
SUM=$(openssl dgst -sha256 "$UPDATE" | awk '{print $2}')
if [ "$SUM" != "$CHECKSUM" ] ; then
    exit 2
fi
```

**Limitations (By Design)**:
- No retry logic
- Limited input validation
- Basic error messages
- Not suitable for production
- Requires external tools (curl, jq, openssl)

**Trade-offs**:
- ✅ Easy to understand and customize
- ✅ Good for testing/development
- ✅ Portable across Unix-like systems
- ❌ Requires multiple external tools
- ❌ Less robust error handling
- ❌ Not production-ready

## Common Design Patterns

### 1. Input Validation

All implementations validate:
- Required parameters (host, product, token, device, version, file)
- URL format (must start with "https://")
- Response completeness (url, checksum, update, version fields)
- Content-Length (must be 0-100MB)
- Checksum format (hex string, correct length)

### 2. Error Handling Strategy

**C**: Return codes with stderr messages
```c
if (error) {
    fprintf(stderr, "Error message\n");
    return -1;
}
```

**JavaScript**: Exceptions with try/catch
```javascript
try {
    operation()
} catch (error) {
    console.error('Operation failed:', error.message)
    throw new Error('Failed')
}
```

**Shell**: Exit codes with stderr
```bash
if [ $? -ne 0 ] ; then
    echo "Error message" >&2
    exit 2
fi
```

### 3. Resource Cleanup

**C**: Manual cleanup with explicit free()
```c
if (error) {
    free(buffer);
    close(fd);
    return -1;
}
```

**JavaScript**: Automatic garbage collection + explicit stream cleanup
```javascript
stream.on('error', (error) => {
    stream.destroy()
    fs.unlinkSync(path)  // Remove partial file
    reject(error)
})
```

**Shell**: trap for cleanup
```bash
trap "rm -rf '$TMPDIR'" EXIT
```

### 4. Checksum Verification

All implementations use SHA-256:

**C**:
```c
EVP_MD_CTX *mdctx = EVP_MD_CTX_new();
EVP_DigestInit_ex(mdctx, EVP_sha256(), NULL);
while ((bytes = fread(buf, 1, sizeof(buf), file)) > 0) {
    EVP_DigestUpdate(mdctx, buf, bytes);
}
EVP_DigestFinal_ex(mdctx, hash, &len);
```

**JavaScript**:
```javascript
const hash = crypto.createHash('sha256')
const stream = fs.createReadStream(path)
stream.on('data', (chunk) => hash.update(chunk))
stream.on('end', () => {
    const sha256 = hash.digest('hex')
    resolve(sha256)
})
```

**Shell**:
```bash
SUM=$(openssl dgst -sha256 "$UPDATE" | awk '{print $2}')
```

## Protocol Details

### Builder Service Configuration

Before using the updater, you need to configure your Builder account:

1. **Create a Product** in the Builder portal
2. **Upload Update Images** with version numbers (SemVer 2.0 format)
3. **Configure Distribution Policy** to control which devices receive updates
4. **Set Rollout Limits** (optional) to control update pace
5. **Obtain API Credentials**:
   - Product ID from the Builder token list
   - CloudAPI token from the Builder token list
   - Cloud endpoint URL from the Builder cloud edit panel

### API Endpoints

1. **Check for Update**: `POST /tok/provision/update`
   - Headers: `Authorization: <token>`, `Content-Type: application/json`
   - Body: `{"id": "<device>", "product": "<product>", "version": "<version>", ...}`
   - Custom properties can be included for policy evaluation
   - Response (update available): `{"url": "<https://...>", "checksum": "<sha256>", "update": "<id>", "version": "<new>"}`
   - Response (no update): `{}`

2. **Report Update Status**: `POST /tok/provision/updateReport`
   - Headers: `Authorization: <token>`, `Content-Type: application/json`
   - Body: `{"success": true/false, "id": "<device>", "update": "<id>"}`
   - Response: Ignored (fire-and-forget, best-effort reporting)

### Distribution Policy Evaluation

The Builder service evaluates the distribution policy when a device checks for updates:

1. **Device properties** sent in the check-in request become available as `device.*` variables
2. **Update properties** configured in Builder are available as `update.*` variables
3. **Policy expression** is evaluated (JavaScript-like syntax)
4. **Rollout limits** are checked (max percentage, max updates per period)
5. **Update URL** is returned only if all conditions are met

**Version Comparison:**
- Uses SemVer 2.0 semantic versioning
- Supports standard comparison operators: `<`, `<=`, `>`, `>=`, `==`, `!=`
- Example: `device.version < update.version` ensures only newer versions are offered

### Update Package Download

- Must use HTTPS (no HTTP allowed)
- Content-Length header required
- Maximum size: 100 MB
- Timeout: 10 minutes
- Streamed to disk (not buffered in memory)

### Checksum Format

- Algorithm: SHA-256
- Format: Lowercase hexadecimal string (64 characters)
- Example: `a3b5c7d9e1f2a3b5c7d9e1f2a3b5c7d9e1f2a3b5c7d9e1f2a3b5c7d9e1f2a3b5`

## Testing Considerations

### Security Testing

All implementations should be tested for:

1. **HTTPS Enforcement**
   - Reject HTTP URLs
   - Validate certificates
   - Verify hostnames

2. **Checksum Validation**
   - Reject mismatched checksums
   - Handle empty files
   - Handle truncated downloads

3. **Size Limits**
   - Reject Content-Length > 100MB
   - Handle Content-Length = 0
   - Handle missing Content-Length

4. **Input Validation**
   - Missing required parameters
   - Invalid URL formats
   - Incomplete API responses
   - Malformed JSON

5. **File Security**
   - File creation race conditions
   - Symlink attacks
   - Permission checks

### Functional Testing

Test scenarios:

1. **No Update Available** - Server returns empty or null URL
2. **Update Available** - Full download and apply cycle
3. **Checksum Mismatch** - Reject corrupted download
4. **Network Failure** - Timeout, connection refused, DNS failure
5. **Script Failure** - Update script returns non-zero
6. **Partial Download** - Connection drops mid-download

## Future Enhancements

Potential improvements (not currently implemented):

1. **Retry Logic** - Exponential backoff on transient failures
2. **Resume Downloads** - HTTP Range requests for large files
3. **Delta Updates** - Binary diff patches
4. **Signature Verification** - Digital signatures in addition to checksums
5. **Progress Reporting** - Download progress callbacks
6. **Background Updates** - Daemon mode
7. **Update Scheduling** - Time-based update windows
8. **Rollback Support** - Automatic rollback on failed updates

## Conclusion

The three implementations provide flexibility for different deployment scenarios:

- **C**: Production embedded devices with minimal resources
- **JavaScript**: Modern devices with Node.js/Bun runtime
- **Shell**: Development, testing, and reference

All share the same security model and protocol, ensuring consistent behavior regardless of implementation choice. The design prioritizes security, simplicity, and correctness over features and performance.
