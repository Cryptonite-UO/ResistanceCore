##
## Author: Hank Anderson <hank@statease.com>
## Description: Ported from the OpenBLAS/c_check perl script.
##              This is triggered by prebuild.cmake and runs before any of the code is built.
##              Creates config.h and Makefile.conf.

# Convert CMake vars into the format that OpenBLAS expects (modified for SphereServer)

# If i'm not overriding it, use mine (host machine).
if(NOT CMAKE_SYSTEM_PROCESSOR)
    set(CMAKE_SYSTEM_PROCESSOR "${CMAKE_HOST_SYSTEM_PROCESSOR}" CACHE INTERNAL "" FORCE)
endif()

string(TOUPPER "${CMAKE_SYSTEM_NAME}" HOST_OS)
if("${HOST_OS}" STREQUAL "WINDOWS")
    set(HOST_OS WINNT CACHE INTERNAL "")
endif()

if("${HOST_OS}" STREQUAL "LINUX")
    # check if we're building natively on Android (TERMUX)
    execute_process(COMMAND uname -o COMMAND tr -d '\n' OUTPUT_VARIABLE OPERATING_SYSTEM)
    if("${OPERATING_SYSTEM}" MATCHES "Android")
        set(HOST_OS ANDROID CACHE INTERNAL "")
    endif()
endif()

message(STATUS "Host machine: [OS] ${HOST_OS} [Arch] ${CMAKE_HOST_SYSTEM_PROCESSOR}")

if(MINGW)
    execute_process(
        COMMAND ${CMAKE_C_COMPILER} -dumpmachine
        OUTPUT_VARIABLE MINGW_TARGET_MACHINE
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if("${MINGW_TARGET_MACHINE}" MATCHES "amd64|x86_64|AMD64")
        set(MINGW64 1)
    endif()
endif()

# Pretty thorough determination of arch. Add more if needed
if(CMAKE_CL_64 OR MINGW64)
    if("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "^(aarch64.*|AARCH64.*|arm64.*|ARM64.*)")
        set(ARM64 1)
    else()
        set(X86_64 1)
    endif()
elseif(MINGW OR (MSVC AND NOT CMAKE_CROSSCOMPILING))
    set(X86 1)
elseif(
    "${CMAKE_SYSTEM_PROCESSOR}" MATCHES "ppc.*|power.*|Power.*"
    OR ("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin" AND "${CMAKE_OSX_ARCHITECTURES}" MATCHES "ppc.*")
)
    set(POWER 1)
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "mips64.*")
    set(MIPS64 1)
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "loongarch64.*")
    set(LOONGARCH64 1)
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "riscv64.*")
    set(RISCV64 1)
elseif(
    "${CMAKE_SYSTEM_PROCESSOR}" MATCHES "amd64.*|x86_64.*|AMD64.*"
    OR ("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin" AND "${CMAKE_SYSTEM_PROCESSOR}" MATCHES "i686.*|i386.*|x86.*")
)
    #if (${ARCH_BITS} EQUAL 64)
    set(X86_64 1)
    #else ()
    #     set(X86 1)
    #endif()
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "i686.*|i386.*|x86.*")
    #if (${ARCH_BITS} EQUAL 64)
    #  set(X86_64 1)
    #else ()
    set(X86 1)
    #endif()
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "^(aarch64.*|AARCH64.*|arm64.*|ARM64.*|armv8.*)")
    #if (${ARCH_BITS} EQUAL 64)
    set(ARM64 1)
    #else()
    #  set(ARM 1)
    #endif()
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "^(arm.*|ARM.*)")
    set(ARM 1)
elseif(CMAKE_CROSSCOMPILING)
    if("${TARGET}" STREQUAL "CORE2")
        if(NOT ARCH_BITS)
            set(X86 1)
        elseif(${ARCH_BITS} EQUAL 64)
            set(X86_64 1)
        else()
            set(X86 1)
        endif()
    elseif("${TARGET}" STREQUAL "P5600" OR "${TARGET}" MATCHES "MIPS.*")
        set(MIPS32 1)
    elseif("${TARGET}" STREQUAL "ARMV7")
        set(ARM 1)
    else()
        set(ARM64 1)
    endif()
else()
    message(WARNING "Target ARCH could not be determined, got \"${CMAKE_SYSTEM_PROCESSOR}\"")
endif()

if(NOT ARCH)
    if(X86_64)
        set(ARCH "x86_64" CACHE INTERNAL "")
        set(ARCH_BASE "x86" CACHE INTERNAL "")
    elseif(X86)
        set(ARCH "x86" CACHE INTERNAL "")
        set(ARCH_BASE "x86" CACHE INTERNAL "")
    elseif(POWER)
        set(ARCH "power" CACHE INTERNAL "")
        set(ARCH_BASE "power" CACHE INTERNAL "")
    elseif(MIPS32)
        set(ARCH "mips" CACHE INTERNAL "")
        set(ARCH_BASE "mips" CACHE INTERNAL "")
    elseif(MIPS64)
        set(ARCH "mips64" CACHE INTERNAL "")
        set(ARCH_BASE "mips" CACHE INTERNAL "")
    elseif(ARM)
        set(ARCH "arm" CACHE INTERNAL "")
        set(ARCH_BASE "arm" CACHE INTERNAL "")
    elseif(ARM64)
        set(ARCH "arm64" CACHE INTERNAL "")
        set(ARCH_BASE "arm" CACHE INTERNAL "")
    else()
        set(ARCH ${CMAKE_SYSTEM_PROCESSOR} CACHE INTERNAL "Target Architecture")
    endif()
endif()

if(NOT ARCH_BITS)
    if(
        X86_64
        OR ARM64
        OR MIPS64
        OR LOONGARCH64
        OR RISCV64
        OR (POWER AND NOT (CMAKE_OSX_ARCHITECTURES STREQUAL "ppc"))
    )
        set(ARCH_BITS 64 CACHE INTERNAL "")
    else()
        set(ARCH_BITS 32 CACHE INTERNAL "")
    endif()
endif()

if(ARCH_BITS EQUAL 64)
    set(ARCH_BITS64 1 CACHE INTERNAL "")
else()
    set(ARCH_BITS32 1 CACHE INTERNAL "")
endif()

message(STATUS "Target Arch: ${ARCH}")
