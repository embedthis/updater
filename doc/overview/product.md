# EmbedThis Updater - Product Overview

## What It Is

The EmbedThis Updater is a standalone Over-The-Air (OTA) software update utility and library for IoT devices. It provides secure, reliable firmware update capabilities to devices in the field with minimal dependencies and a small footprint suitable for embedded environments.

## Implementations

The repo ships multiple implementations sharing the same Builder API protocol so integrators can pick the form that best fits their device:

- **C command-line utility** (`src/main.c` + `src/updater.c/h`) — primary implementation; recommended for embedded targets.
- **C library** — embed `update()` in another program via `updater.h`.
- **Node.js utility** (`src/updater.js`) — alternative for JavaScript-based devices and gateways.
- **Shell script** (`src/updater.sh`) — sample reference for environments where shell access is preferred over compiled binaries.

## Design Principles

1. **Security First** — HTTPS-only, certificate validation, and checksum verification on every download.
2. **Simplicity** — single-purpose tool with minimal dependencies (OpenSSL/LibreSSL for the C build).
3. **Portability** — Linux, macOS, Windows (via Git for Windows / WSL), FreeBSD, FreeRTOS, VxWorks.
4. **Developer Trust Model** — assumes the integrator controls and secures the host system; inputs to local APIs are deemed validated.
5. **Fail-Safe** — comprehensive validation and error handling at every step of check, download, verify, apply, report.

## Backend

The updater integrates with the [EmbedThis Builder](https://www.embedthis.com/builder/) cloud service by default. Builder handles update storage (AWS S3 + CloudFront CDN), distribution policy evaluation, rollout throttling, and analytics. The protocol is open: API endpoint paths are configurable via `--check-path` and `--report-path`, so the same client can drive a custom backend that implements the same request/response contract.

## Update Process

1. **Check** — POST device identity, product ID, and current version to the update service.
2. **Download** — fetch the update package if one is offered.
3. **Verify** — validate the SHA-256 checksum of the downloaded file.
4. **Apply** — execute the configured apply script to install the update.
5. **Report** — POST status back to the update service for analytics and auditing.

## Audience

Experienced embedded developers who:

- Embed the updater in device firmware or higher-level applications.
- Are responsible for securing the broader system and validating all inputs.
- Are responsible for a secure configuration of the host environment.

## Where to Go Next

- Architecture and protocol details: [../architecture/system.md](../architecture/system.md)
- Build and test procedures: [../operations/PROCEDURE.md](../operations/PROCEDURE.md)
- Feature history: [../features/INDEX.md](../features/INDEX.md)
- External references: [../references/REFERENCES.md](../references/REFERENCES.md)
