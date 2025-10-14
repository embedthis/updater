/*
    me.h -- MakeMe Configure Header for vxworks-arm-default
 */

/* Settings */
#ifndef ME_AUTHOR
    #define ME_AUTHOR "updater"
#endif
#ifndef ME_COMPANY
    #define ME_COMPANY "updater"
#endif
#ifndef ME_COMPATIBLE
    #define ME_COMPATIBLE "1.1"
#endif
#ifndef ME_COMPILER_FORTIFY
    #define ME_COMPILER_FORTIFY 1
#endif
#ifndef ME_COMPILER_HAS_ATOMIC
    #define ME_COMPILER_HAS_ATOMIC 0
#endif
#ifndef ME_COMPILER_HAS_ATOMIC64
    #define ME_COMPILER_HAS_ATOMIC64 0
#endif
#ifndef ME_COMPILER_HAS_DOUBLE_BRACES
    #define ME_COMPILER_HAS_DOUBLE_BRACES 0
#endif
#ifndef ME_COMPILER_HAS_DYN_LOAD
    #define ME_COMPILER_HAS_DYN_LOAD 1
#endif
#ifndef ME_COMPILER_HAS_LIB_EDIT
    #define ME_COMPILER_HAS_LIB_EDIT 0
#endif
#ifndef ME_COMPILER_HAS_LIB_RT
    #define ME_COMPILER_HAS_LIB_RT 0
#endif
#ifndef ME_COMPILER_HAS_MMU
    #define ME_COMPILER_HAS_MMU 1
#endif
#ifndef ME_COMPILER_HAS_MTUNE
    #define ME_COMPILER_HAS_MTUNE 0
#endif
#ifndef ME_COMPILER_HAS_PAM
    #define ME_COMPILER_HAS_PAM 0
#endif
#ifndef ME_COMPILER_HAS_STACK_PROTECTOR
    #define ME_COMPILER_HAS_STACK_PROTECTOR 1
#endif
#ifndef ME_COMPILER_HAS_SYNC
    #define ME_COMPILER_HAS_SYNC 0
#endif
#ifndef ME_COMPILER_HAS_SYNC64
    #define ME_COMPILER_HAS_SYNC64 0
#endif
#ifndef ME_COMPILER_HAS_SYNC_CAS
    #define ME_COMPILER_HAS_SYNC_CAS 0
#endif
#ifndef ME_COMPILER_HAS_UNNAMED_UNIONS
    #define ME_COMPILER_HAS_UNNAMED_UNIONS 1
#endif
#ifndef ME_COMPILER_WARN64TO32
    #define ME_COMPILER_WARN64TO32 0
#endif
#ifndef ME_COMPILER_WARN_UNUSED
    #define ME_COMPILER_WARN_UNUSED 0
#endif
#ifndef ME_DEBUG
    #define ME_DEBUG 1
#endif
#ifndef ME_DEPTH
    #define ME_DEPTH 1
#endif
#ifndef ME_DESCRIPTION
    #define ME_DESCRIPTION "Device firmware updater"
#endif
#ifndef ME_INTEGRATE
    #define ME_INTEGRATE 1
#endif
#ifndef ME_MBEDTLS_COMPACT
    #define ME_MBEDTLS_COMPACT 0
#endif
#ifndef ME_NAME
    #define ME_NAME "updater"
#endif
#ifndef ME_PARTS
    #define ME_PARTS "undefined"
#endif
#ifndef ME_PREFIXES
    #define ME_PREFIXES "install-prefixes"
#endif
#ifndef ME_STATIC
    #define ME_STATIC 1
#endif
#ifndef ME_TITLE
    #define ME_TITLE "EmbedThis Updater"
#endif
#ifndef ME_TLS
    #define ME_TLS "openssl"
#endif
#ifndef ME_TUNE
    #define ME_TUNE "size"
#endif
#ifndef ME_VERSION
    #define ME_VERSION "1.1.2"
#endif

/* Prefixes */
#ifndef ME_ROOT_PREFIX
    #define ME_ROOT_PREFIX "deploy"
#endif
#ifndef ME_BASE_PREFIX
    #define ME_BASE_PREFIX "deploy"
#endif
#ifndef ME_DATA_PREFIX
    #define ME_DATA_PREFIX "deploy"
#endif
#ifndef ME_STATE_PREFIX
    #define ME_STATE_PREFIX "deploy"
#endif
#ifndef ME_BIN_PREFIX
    #define ME_BIN_PREFIX "deploy"
#endif
#ifndef ME_INC_PREFIX
    #define ME_INC_PREFIX "deploy/inc"
#endif
#ifndef ME_LIB_PREFIX
    #define ME_LIB_PREFIX "deploy"
#endif
#ifndef ME_MAN_PREFIX
    #define ME_MAN_PREFIX "deploy"
#endif
#ifndef ME_SBIN_PREFIX
    #define ME_SBIN_PREFIX "deploy"
#endif
#ifndef ME_ETC_PREFIX
    #define ME_ETC_PREFIX "deploy"
#endif
#ifndef ME_WEB_PREFIX
    #define ME_WEB_PREFIX "deploy/web"
#endif
#ifndef ME_LOG_PREFIX
    #define ME_LOG_PREFIX "deploy"
#endif
#ifndef ME_SPOOL_PREFIX
    #define ME_SPOOL_PREFIX "deploy"
#endif
#ifndef ME_CACHE_PREFIX
    #define ME_CACHE_PREFIX "deploy"
#endif
#ifndef ME_APP_PREFIX
    #define ME_APP_PREFIX "deploy"
#endif
#ifndef ME_VAPP_PREFIX
    #define ME_VAPP_PREFIX "deploy"
#endif
#ifndef ME_SRC_PREFIX
    #define ME_SRC_PREFIX "/usr/src/updater-1.1.2"
#endif

/* Suffixes */
#ifndef ME_EXE
    #define ME_EXE ".out"
#endif
#ifndef ME_SHLIB
    #define ME_SHLIB ".out"
#endif
#ifndef ME_SHOBJ
    #define ME_SHOBJ ".out"
#endif
#ifndef ME_LIB
    #define ME_LIB ".a"
#endif
#ifndef ME_OBJ
    #define ME_OBJ ".o"
#endif

/* Profile */
#ifndef ME_CONFIG_CMD
    #define ME_CONFIG_CMD "me -d -q -platform vxworks-arm-default -configure . -gen make"
#endif
#ifndef ME_UPDATER_PRODUCT
    #define ME_UPDATER_PRODUCT 1
#endif
#ifndef ME_PROFILE
    #define ME_PROFILE "default"
#endif
#ifndef ME_TUNE_SIZE
    #define ME_TUNE_SIZE 1
#endif

/* Miscellaneous */
#ifndef ME_MAJOR_VERSION
    #define ME_MAJOR_VERSION 1
#endif
#ifndef ME_MINOR_VERSION
    #define ME_MINOR_VERSION 1
#endif
#ifndef ME_PATCH_VERSION
    #define ME_PATCH_VERSION 2
#endif
#ifndef ME_VNUM
    #define ME_VNUM 100010002
#endif

/* Components */
#ifndef ME_COM_CC
    #define ME_COM_CC 1
#endif
#ifndef ME_COM_LIB
    #define ME_COM_LIB 1
#endif
#ifndef ME_COM_LINK
    #define ME_COM_LINK 1
#endif
#ifndef ME_COM_OSDEP
    #define ME_COM_OSDEP 1
#endif
#ifndef ME_COM_R
    #define ME_COM_R 1
#endif
#ifndef ME_COM_VXWORKS
    #define ME_COM_VXWORKS 0
#endif
