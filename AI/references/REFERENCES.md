# EmbedThis Updater - References

## Overview

This document contains useful references to external sites, documentation, code, and other resources for the EmbedThis Updater project.

---

## Official Documentation

### EmbedThis Resources

- **EmbedThis Website**: https://www.embedthis.com
- **Builder Service**: https://admin.embedthis.com
- **Builder Documentation**: https://www.embedthis.com/doc/builder/
- **Software Update Guide**: https://www.embedthis.com/blog/builder/software-update.html
- **General Documentation**: https://www.embedthis.com/doc/
- **Builder API**: https://www.embedthis.com/doc/ioto/ref/

### Project Resources

- **GitHub Repository**: https://github.com/embedthis/updater
- **Project README**: [../../README.md](../../README.md)
- **Design Document**: [../../doc/DESIGN.md](../../doc/DESIGN.md)
- **Claude Guidance**: [../../CLAUDE.md](../../CLAUDE.md)

---

## Related Projects

### Device Agents and Web Servers

- **Ioto Device Agent**: https://www.embedthis.com/ioto/
  - Full-featured IoT device agent with integrated updater

- **Appweb Embedded Web Server**: https://www.embedthis.com/appweb/
  - Includes updater under `src/updater/`

- **GoAhead Embedded Web Server**: https://www.embedthis.com/goahead/
  - Includes updater under `src/updater/`

---

## Technical Standards and Specifications

### Semantic Versioning

- **SemVer 2.0**: https://semver.org/
  - Version numbering standard used by Builder service

### Cryptography Standards

- **SHA-256**: https://en.wikipedia.org/wiki/SHA-2
  - Cryptographic hash function for checksum verification

- **TLS 1.2**: https://tools.ietf.org/html/rfc5246
  - Minimum TLS version supported

- **TLS 1.3**: https://tools.ietf.org/html/rfc8446
  - Latest TLS version supported

### HTTP Standards

- **HTTP/1.1**: https://tools.ietf.org/html/rfc2616
  - Protocol used for API and download communication

- **HTTPS**: https://tools.ietf.org/html/rfc2818
  - Secure HTTP over TLS (enforced)

---

## Development Tools and Libraries

### Cryptography Libraries

- **OpenSSL**: https://www.openssl.org/
  - Primary TLS/crypto library (recommended)
  - Documentation: https://www.openssl.org/docs/

- **LibreSSL**: https://www.libressl.org/
  - Alternative TLS/crypto library (compatible)

### Build Tools

- **GNU Make**: https://www.gnu.org/software/make/
  - Build system documentation

- **Uncrustify**: https://github.com/uncrustify/uncrustify
  - Code formatting tool

### Testing Tools

- **TestMe**: https://www.embedthis.com/testme/
  - Unit testing framework
  - Man page: `~/.local/share/man/man1/tm.1`

---

## Language and Runtime References

### C Programming

- **C Standard Library**: https://en.cppreference.com/w/c
  - Reference for standard C functions

- **POSIX Standards**: https://pubs.opengroup.org/onlinepubs/9699919799/
  - POSIX system call reference

### JavaScript/Node.js

- **Node.js Documentation**: https://nodejs.org/docs/
  - Official Node.js API reference

- **Node.js Fetch API**: https://nodejs.org/docs/latest/api/globals.html#fetch
  - Native fetch implementation (Node 18+)

- **Bun Runtime**: https://bun.sh/
  - Alternative JavaScript runtime

---

## Security Resources

### Security Best Practices

- **OWASP Top Ten**: https://owasp.org/www-project-top-ten/
  - Common web security vulnerabilities

- **CWE (Common Weakness Enumeration)**: https://cwe.mitre.org/
  - Software security weakness catalog

### Secure Coding Guidelines

- **CERT C Coding Standard**: https://wiki.sei.cmu.edu/confluence/display/c/
  - Secure C programming practices

- **OWASP Secure Coding Practices**: https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/
  - Quick reference for secure development

### Certificate and TLS Resources

- **Let's Encrypt**: https://letsencrypt.org/
  - Free TLS certificates

- **AWS Certificate Manager**: https://aws.amazon.com/certificate-manager/
  - Certificate management for Builder service

---

## Cloud and Infrastructure

### AWS Services (Used by Builder)

- **AWS S3**: https://aws.amazon.com/s3/
  - Update file storage

- **AWS CloudFront**: https://aws.amazon.com/cloudfront/
  - Global CDN for update distribution

- **AWS Lambda**: https://aws.amazon.com/lambda/
  - Serverless API backend

- **AWS API Gateway**: https://aws.amazon.com/api-gateway/
  - API endpoint management

---

## Development Environment

### Package Managers

- **Homebrew (macOS)**: https://brew.sh/
  - Package manager for macOS
  - Used for OpenSSL installation

- **APT (Debian/Ubuntu)**: https://wiki.debian.org/Apt
  - Package manager for Linux
  - Used for build dependencies

### Version Control

- **Git**: https://git-scm.com/
  - Version control system
  - Documentation: https://git-scm.com/doc

- **GitHub**: https://github.com/
  - Repository hosting and collaboration

---

## IoT and Embedded Systems

### Embedded Linux

- **Yocto Project**: https://www.yoctoproject.org/
  - Embedded Linux build system

- **Buildroot**: https://buildroot.org/
  - Embedded Linux build tool

### RTOS Platforms

- **FreeRTOS**: https://www.freertos.org/
  - Real-time operating system

- **ESP32**: https://www.espressif.com/en/products/socs/esp32
  - Popular IoT microcontroller platform

---

## Testing and Quality Assurance

### Testing Methodologies

- **Unit Testing**: https://en.wikipedia.org/wiki/Unit_testing
  - Testing individual components

- **Integration Testing**: https://en.wikipedia.org/wiki/Integration_testing
  - Testing component interactions

### Memory Debugging

- **Valgrind**: https://valgrind.org/
  - Memory leak and error detection
  - Documentation: https://valgrind.org/docs/

---

## Community and Support

### Communication Channels

- **GitHub Issues**: https://github.com/embedthis/updater/issues
  - Bug reports and feature requests

- **EmbedThis Support**: https://www.embedthis.com/support/
  - Commercial support options

### Security Reporting

- **Security Contact**: security@embedthis.com
  - Private security vulnerability reporting

---

## Code Examples and Tutorials

### C Programming

- **Beej's Guide to Network Programming**: https://beej.us/guide/bgnet/
  - Socket programming reference

- **OpenSSL Examples**: https://wiki.openssl.org/index.php/Main_Page
  - TLS/crypto implementation examples

### JavaScript/Node.js

- **Node.js Best Practices**: https://github.com/goldbergyoni/nodebestpractices
  - Production-ready Node.js patterns

---

## Standards Organizations

- **IETF (Internet Engineering Task Force)**: https://www.ietf.org/
  - Internet protocol standards (HTTP, TLS)

- **ISO/IEC**: https://www.iso.org/
  - International standards organization

- **NIST (National Institute of Standards and Technology)**: https://www.nist.gov/
  - Cryptographic standards and guidance

---

## Learning Resources

### C Programming

- **The C Programming Language (K&R)**: Classic C programming reference
- **Expert C Programming**: Deep Secrets

### Security

- **The Art of Software Security Assessment**: Vulnerability analysis
- **Applied Cryptography (Schneier)**: Cryptographic principles

### Embedded Systems

- **Making Embedded Systems**: Embedded design patterns
- **The Firmware Handbook**: Firmware development guide

---

## Related Technologies

### Message Protocols

- **MQTT**: https://mqtt.org/
  - IoT messaging protocol (used by Ioto)

- **WebSockets**: https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API
  - Real-time communication

### Data Formats

- **JSON**: https://www.json.org/
  - Data interchange format

- **JSON5**: https://json5.org/
  - Extended JSON format (used in test configs)

---

## Maintenance Notes

When adding new references:
1. Organize by category
2. Include brief description
3. Verify links are active
4. Note if resource is commercial or requires registration
5. Add date if time-sensitive

When archiving old references:
1. Move to `.agent/archive/references/`
2. Note reason for archival
3. Keep for historical context

---

## Quick Reference

### Most Frequently Used

1. **Builder Portal**: https://admin.embedthis.com
2. **OpenSSL Docs**: https://www.openssl.org/docs/
3. **Node.js API**: https://nodejs.org/docs/
4. **GitHub Repo**: https://github.com/embedthis/updater
5. **EmbedThis Docs**: https://www.embedthis.com/doc/

### Emergency Contacts

- **Security Issues**: security@embedthis.com
- **Support**: https://www.embedthis.com/support/

---

Last Updated: 2025-01-14
