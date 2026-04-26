# OSDEP References

## EmbedThis Documentation

- Full documentation: https://www.embedthis.com/doc/
- API reference: Generated via `make doc` in project root

## Platform References

### Compiler Detection Symbols
- GCC predefined macros: https://gcc.gnu.org/onlinedocs/cpp/Common-Predefined-Macros.html
- MSVC predefined macros: https://learn.microsoft.com/en-us/cpp/preprocessor/predefined-macros
- Clang language extensions: https://clang.llvm.org/docs/LanguageExtensions.html

### Operating Systems
- POSIX specification: https://pubs.opengroup.org/onlinepubs/9699919799/
- VxWorks documentation: https://www.windriver.com/products/vxworks
- ESP-IDF (ESP32): https://docs.espressif.com/projects/esp-idf/
- FreeRTOS: https://www.freertos.org/Documentation/

### CPU Architectures
- ARM Architecture Reference: https://developer.arm.com/documentation
- RISC-V specifications: https://riscv.org/technical/specifications/
- Xtensa (Tensilica): https://www.cadence.com/en_US/home/tools/ip/tensilica-ip.html

## Related EmbedThis Modules

- **r** (Safe Runtime) -- First consumer of osdep, provides memory management and utilities
- **crypt** -- Cryptographic functions, depends on osdep types
- **web** -- Embedded web server, uses osdep platform detection
- **mqtt** -- MQTT client, uses osdep socket abstractions

## Build System

- MakeMe: https://www.embedthis.com/makeme/
- pak package manager: https://www.embedthis.com/pak/
