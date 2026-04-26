# OSDEP Module
Operating system abstraction layer providing platform detection, standard types, and compiler abstractions.

## Description

Foundation module consumed by all EmbedThis modules. Provides a single header (`osdep.h`) with platform detection, standardized integer types, compiler abstractions, and endianness support. Enables consistent cross-platform behavior across Linux, macOS, FreeBSD, Windows, VxWorks, QNX, ESP32/FreeRTOS, and more. Has no dependencies.

## When to Use

This module is automatically included by all other Ioto modules. Include `osdep.h` directly when writing platform-portable code that needs standard types (`ssize`, `int32`, etc.) or platform detection macros without pulling in the full R runtime.

## API Reference

See `osdep.h` for complete type and macro documentation.

## Key APIs

OSDEP primarily provides types and macros rather than functions.

### Platform Detection

```c
ME_OS          // OS name string: "linux", "macosx", "windows", "freertos", ...
ME_OS_TYPE     // Numeric OS constant: ME_OS_LINUX, ME_OS_MACOSX, ME_OS_WINDOWS, ...
ME_CPU         // CPU name string: "arm64", "x64", "xtensa", ...
ME_CPU_ARCH    // Numeric CPU constant: ME_CPU_ARM64, ME_CPU_X64, ME_CPU_XTENSA, ...
ME_ENDIAN      // ME_LITTLE_ENDIAN, ME_BIG_ENDIAN
```

### Standardized Types

```c
ssize          // Signed size type (always 64 bits on all platforms)
int8, uint8, int16, uint16, int32, uint32, int64, uint64
bool, true, false   // Consistent across C and C++
cchar          // const char
cvoid          // const void
Ticks          // Relative time in milliseconds (duration)
Time           // Absolute time in milliseconds (epoch)
Offset         // File offset
Socket         // OS socket handle
```

## Patterns

```c
// Platform-specific code
#if ME_OS_TYPE == ME_OS_LINUX
    // Linux-specific
#elif ME_OS_TYPE == ME_OS_WINDOWS
    // Windows-specific
#endif

// Architecture-specific optimizations
#if ME_CPU_ARCH == ME_CPU_ARM64
    // ARM64 path
#endif
```

## Configuration

```bash
# Cross-compilation
OS=linux ARCH=arm64 make        # ARM64 Linux build
OS=esp32 ARCH=xtensa make       # ESP32 build
```

## Important Notes

- **All modules MUST include osdep.h first** before any other includes.
- Use `ssize` instead of standard C `ssize_t` or `size_t` for cross-platform consistency.
- `ssize` is always 64 bits on all systems.

## References

- [doc/architecture/system.md](doc/architecture/system.md) - Architecture and design
- [doc/MAP.md](doc/MAP.md) - Project navigation map
- [doc/api/](doc/api/) - API documentation (`make doc`)
