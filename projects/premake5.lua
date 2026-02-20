--
--  projects/premake5.lua -- Updater Library and Utility Build
--
--  Builds libupdater.a (static library) and updater (command-line utility).
--
--  Cross-generation: uses explicit `platforms` so all platform variants
--  are generated in a single pass from any host machine.
--
--  Usage (run from the projects/ directory):
--      premake5 gmake2                    # Generate GNU Makefiles for all platforms
--      premake5 vs2022                    # Generate VS2022 projects for Windows
--      premake5 xcode4                    # Generate Xcode projects for macOS
--      make config=debug_macosx           # Build for macOS
--      make config=release_linux          # Build for Linux
--

local ROOT = ".."

-- Read version from pak.json (single source of truth)
local pakContent = io.readfile(ROOT .. "/pak.json")
local VERSION = pakContent:match('"version"%s*:%s*"([^"]+)"') or "0.0.0"
local isVS = (_ACTION == "vs2022")
local isXcode = (_ACTION == "xcode4")

---------------------------------------------------------------------
--  Options
---------------------------------------------------------------------

newoption {
    trigger     = "tls",
    value       = "PROVIDER",
    description = "TLS provider: openssl (default) or mbedtls",
    default     = "openssl",
    allowed     = {
        { "openssl", "OpenSSL (default)" },
        { "mbedtls", "MbedTLS" },
    }
}

newoption {
    trigger     = "openssl-path",
    value       = "PATH",
    description = "Path to OpenSSL installation (default: /opt/homebrew on macOS, /usr on Linux/FreeBSD)",
}

newoption {
    trigger     = "mbedtls-path",
    value       = "PATH",
    description = "Path to MbedTLS installation",
}

-- Detect target OS for platform-specific defaults
local hostOS = os.host()
local defaultOpensslPath
if isVS then
    defaultOpensslPath = "C:/Program Files/OpenSSL"
elseif hostOS == "macosx" then
    defaultOpensslPath = "/opt/homebrew"
else
    defaultOpensslPath = "/usr"
end

local opensslPath = _OPTIONS["openssl-path"] or defaultOpensslPath
local mbedtlsPath = _OPTIONS["mbedtls-path"] or "/usr"
local tlsProvider = _OPTIONS["tls"] or "openssl"

---------------------------------------------------------------------
--  Workspace
---------------------------------------------------------------------

workspace "updater"
    configurations { "debug", "release" }
    language       "C"
    staticruntime  "On"
    warnings       "Extra"
    objdir         (ROOT .. "/build/obj/%{prj.name}-%{cfg.platform}-%{cfg.buildcfg}")
    targetdir      (ROOT .. "/build/bin")

    if isVS then
        platforms { "windows" }
        location  "vs2022"
        cdialect  "C11"
        architecture "x86_64"
        characterset "MBCS"
    elseif isXcode then
        platforms { "macosx" }
        location  "xcode"
        cdialect  "gnu11"
    else
        platforms { "macosx", "linux", "freebsd" }
        location  "gmake2"
        cdialect  "gnu11"
    end

    -- Common include paths
    includedirs { ROOT .. "/src", ROOT .. "/src/osdep" }

    -- Dynamic defines (static defaults are in src/updater.h)
    defines {
        'ME_VERSION="' .. VERSION .. '"',
    }

    -- TLS include paths for OpenSSL/MbedTLS header resolution
    if tlsProvider == "openssl" then
        includedirs { opensslPath .. "/include" }
    else
        includedirs { mbedtlsPath .. "/include" }
    end

    -----------------------------------------------------------------
    --  Debug / Release
    -----------------------------------------------------------------
    filter "configurations:debug"
        symbols  "On"
        optimize "Off"
        defines  { "ME_DEBUG=1" }

    filter "configurations:release"
        symbols  "Off"
        optimize "On"

    filter {}

    if not isVS then
        filter "configurations:debug"
            linkoptions { "-g" }
        filter "configurations:release"
            linkoptions { "-s" }
        filter {}
    end

    -----------------------------------------------------------------
    --  Platform-specific flags
    -----------------------------------------------------------------
    if isVS then
        filter "platforms:windows"
            system  "windows"
            toolset "msc"
            disablewarnings {
                "4100",     -- unreferenced formal parameter
                "4127",     -- conditional expression is constant
                "4133",     -- incompatible types (char*/LPCWSTR)
                "4152",     -- function/data pointer conversion
                "4244",     -- conversion, possible loss of data
                "4389",     -- signed/unsigned mismatch
            }
        filter {}
    else
        filter "platforms:macosx"
            system  "macosx"
            toolset "clang"
            buildoptions {
                "-Wno-sign-conversion",
                "-Wno-unused-parameter",
                "-Wno-unused-result",
                "-Wshorten-64-to-32",
                "-Wall",
                "-Wno-unknown-warning-option",
                "-fstack-protector",
                "--param=ssp-buffer-size=4",
                "-Wformat", "-Wformat-security",
                "-Wsign-compare",
            }
            linkoptions {
                "-Wl,-no_warn_duplicate_libraries",
                "-Wl,-rpath,@executable_path/",
                "-Wl,-rpath,@loader_path/",
            }
            links { "dl", "pthread", "m" }

        filter "platforms:linux"
            system  "linux"
            toolset "gcc"
            buildoptions {
                "-Wno-unused-result",
                "-Wall",
                "-fstack-protector",
                "--param=ssp-buffer-size=4",
                "-Wformat", "-Wformat-security",
                "-Wsign-compare",
                "-pie", "-fPIE",
            }
            linkoptions {
                "-Wl,-z,relro,-z,now",
                "-Wl,--as-needed",
                "-Wl,--no-copy-dt-needed-entries",
                "-Wl,-z,noexecheap",
                "-Wl,--no-warn-execstack",
            }
            links { "rt", "dl", "pthread", "m" }

        filter "platforms:freebsd"
            system  "bsd"
            toolset "gcc"
            buildoptions {
                "-Wno-unused-result",
                "-Wall",
                "-fstack-protector",
                "--param=ssp-buffer-size=4",
                "-Wformat", "-Wformat-security",
                "-Wsign-compare",
            }
            links { "dl", "pthread", "m" }

        filter {}
    end


---------------------------------------------------------------------
--  libupdater (static library)
---------------------------------------------------------------------

project "updater"
    kind       "StaticLib"
    if isVS then
        targetname "libupdater"
    else
        targetname "updater"
    end

    files {
        ROOT .. "/src/updater.c",
    }


---------------------------------------------------------------------
--  updater (command-line utility)
---------------------------------------------------------------------

project "updater-exe"
    kind       "ConsoleApp"
    targetname "updater"
    links      { "updater" }
    dependson  { "updater" }
    libdirs    { ROOT .. "/build/bin" }

    files { ROOT .. "/src/main.c" }

    -- TLS libraries (per-platform)
    filter "platforms:macosx or linux or freebsd"
        if tlsProvider == "openssl" then
            libdirs { opensslPath .. "/lib" }
            links   { "ssl", "crypto" }
        else
            libdirs { mbedtlsPath .. "/lib", mbedtlsPath .. "/library" }
            links   { "mbedtls", "mbedcrypto", "mbedx509" }
        end

    filter "platforms:windows"
        links   { "ws2_32", "advapi32", "user32", "kernel32", "oldnames", "shell32" }
        if tlsProvider == "openssl" then
            libdirs {
                opensslPath .. "/lib",
                opensslPath .. "/lib/VC/x64/MTd",
                opensslPath .. "/lib/VC/x64/MT",
                opensslPath .. "/lib/VC/x64/MDd",
                opensslPath .. "/lib/VC/x64/MD",
            }
            links   { "libssl", "libcrypto" }
        else
            libdirs { mbedtlsPath .. "/lib", mbedtlsPath .. "/library" }
            links   { "mbedtls", "mbedcrypto", "mbedx509" }
        end
    filter {}
