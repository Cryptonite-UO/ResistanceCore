set(TOOLCHAIN_LOADED 1)

function(toolchain_after_project_common)
    include("${CMAKE_SOURCE_DIR}/cmake/DetectArch.cmake")
endfunction()

function(toolchain_exe_stuff_common)
    #-- Find libraries to be linked to.

    message(STATUS "Locating libraries to be linked to...")

    set(LIBS_LINK_LIST mariadb dl)
    foreach(LIB_NAME ${LIBS_LINK_LIST})
        find_library(LIB_${LIB_NAME}_WITH_PATH ${LIB_NAME} PATH ${lib_search_paths})
        message(STATUS "Library ${LIB_NAME}: ${LIB_${LIB_NAME}_WITH_PATH}")
    endforeach()

    #-- Validate sanitizers options and store them between the common compiler flags.

    set(ENABLED_SANITIZER false)
    # From https://clang.llvm.org/docs/ClangCommandLineReference.html
    # -static-libsan Statically link the sanitizer runtime (Not supported for ASan, TSan or UBSan on darwin)

    #string(REPLACE ";" " " CXX_FLAGS_EXTRA "${CXX_FLAGS_EXTRA}")

    if(${USE_ASAN})
        set(CXX_FLAGS_EXTRA
            ${CXX_FLAGS_EXTRA}
            # -fsanitize=safe-stack # Can't be used with asan!
            -fsanitize=address
            -fno-sanitize-recover=address
            #-fsanitize-cfi # cfi: control flow integrity
            -fsanitize-address-use-after-scope
            -fsanitize=pointer-compare
            -fsanitize=pointer-subtract
            # Flags for additional instrumentation not strictly needing asan to be enabled
            -fcf-protection=full
            -fstack-check
            -fstack-protector-all
            -fstack-clash-protection
            # Not supported by Clang, but supported by GCC
            #-fvtable-verify=preinit -fharden-control-flow-redundancy -fhardcfr-check-exceptions
            # Other
            #-fsanitize-trap=all
        )
        set(CMAKE_EXE_LINKER_FLAGS_EXTRA ${CMAKE_EXE_LINKER_FLAGS_EXTRA} -fsanitize=address)
        set(PREPROCESSOR_DEFS_EXTRA ${PREPROCESSOR_DEFS_EXTRA} ADDRESS_SANITIZER)
        set(ENABLED_SANITIZER true)
    endif()
    if(${USE_MSAN})
        message(
            WARNING
            "You have enabled MSAN. Make sure you do know what you are doing. It doesn't work out of the box. \
See comments in the toolchain and: https://github.com/google/sanitizers/wiki/MemorySanitizerLibcxxHowTo"
        )
        set(CXX_FLAGS_EXTRA ${CXX_FLAGS_EXTRA} -fsanitize=memory -fsanitize-memory-track-origins -fPIE)
        set(CMAKE_EXE_LINKER_FLAGS_EXTRA ${CMAKE_EXE_LINKER_FLAGS_EXTRA} -fsanitize=memory)
        set(PREPROCESSOR_DEFS_EXTRA ${PREPROCESSOR_DEFS_EXTRA} MEMORY_SANITIZER)
        set(ENABLED_SANITIZER true)
    endif()
    if(${USE_LSAN})
        set(CXX_FLAGS_EXTRA ${CXX_FLAGS_EXTRA} -fsanitize=leak)
        set(CMAKE_EXE_LINKER_FLAGS_EXTRA ${CMAKE_EXE_LINKER_FLAGS_EXTRA} -fsanitize=leak>)
        set(PREPROCESSOR_DEFS_EXTRA ${PREPROCESSOR_DEFS_EXTRA} LEAK_SANITIZER)
        set(ENABLED_SANITIZER true)
    endif()
    if(${USE_UBSAN})
        set(UBSAN_FLAGS
            -fsanitize=undefined,float-divide-by-zero,local-bounds
            -fno-sanitize=enum
            # Supported?
            -fsanitize=unsigned-integer-overflow #Unlike signed integer overflow, this is not undefined behavior, but it is often unintentional.
            -fsanitize=implicit-conversion
        )
        set(CXX_FLAGS_EXTRA ${CXX_FLAGS_EXTRA} ${UBSAN_FLAGS} -fsanitize=return,vptr)
        set(CMAKE_EXE_LINKER_FLAGS_EXTRA ${CMAKE_EXE_LINKER_FLAGS_EXTRA} -fsanitize=undefined)
        set(PREPROCESSOR_DEFS_EXTRA ${PREPROCESSOR_DEFS_EXTRA} UNDEFINED_BEHAVIOR_SANITIZER)
        set(ENABLED_SANITIZER true)
    endif()

    if(${ENABLED_SANITIZER})
        set(PREPROCESSOR_DEFS_EXTRA ${PREPROCESSOR_DEFS_EXTRA} _SANITIZERS)
        set(CMAKE_EXE_LINKER_FLAGS_EXTRA
            ${CMAKE_EXE_LINKER_FLAGS_EXTRA}
            $<$<BOOL:${RUNTIME_STATIC_LINK}>:-static-libsan>
        )
    endif()

    #-- Store compiler flags common to all builds.

    set(cxx_local_opts_warnings
        -Werror
        -Wall
        -Wextra
        -Wpedantic

        -Wmissing-include-dirs # Warns when an include directory provided with -I does not exist.
        -Wformat=2
        #-Wcast-qual # Warns about casts that remove a type's const or volatile qualifier.
        #-Wconversion # Temporarily disabled. Warns about implicit type conversions that might change a value, such as narrowing conversions.
        -Wdisabled-optimization
        #-Winvalid-pch
        -Wzero-as-null-pointer-constant
        -Wnull-dereference

        # Clang-only
        -Wweak-vtables
        #-Wmissing-prototypes
        #-Wmissing-variable-declarations

        # Unsupported by Clang, but supported by GCC:
        #-fno-expensive-optimizations
        #-Wtrampolines # Warns when trampolines (a technique to implement nested functions) are generated (don't want this for security reasons).
        #-Wvector-operation-performance
        #-Wsized-deallocation
        #-Wduplicated-cond
        #-Wshift-overflow=2
        #-Wno-maybe-uninitialized
        #-Wno-nonnull-compare

        # Disable errors:
        -Wno-format-nonliteral # Since -Wformat=2 is stricter, you would need to disable this warning.
        -Wno-switch
        -Wno-implicit-fallthrough
        -Wno-parentheses
        -Wno-misleading-indentation
        -Wno-unused-result
        -Wno-format-security # TODO: disable that when we'll have time to fix every printf format issue
        -Wno-nested-anon-types
    )
    set(cxx_local_opts
        -std=c++20
        -pthread
        -fexceptions
        -fnon-call-exceptions
        -pipe
        -ffast-math
        # clang -specific:
        # -fforce-emit-vtables
    )
    set(cxx_compiler_options_common ${cxx_local_opts_warnings} ${cxx_local_opts} ${CXX_FLAGS_EXTRA})
    #separate_arguments(cxx_compiler_options_common)

    # GCC flags not supported by clang:

    # MemorySanitizer: it doesn't work out of the box. It needs to be linked to an MSAN-instrumented build of libc++ and libc++abi.
    #  This means: one should build them from LLVM source...
    #  https://github.com/google/sanitizers/wiki/MemorySanitizerLibcxxHowTo
    #IF (${USE_MSAN})
    #    SET (CMAKE_CXX_FLAGS    "${CMAKE_CXX_FLAGS} -stdlib=libc++")
    #ENDIF()
    # Use "-stdlib=libstdc++" to link against GCC c/c++ libs (this is done by default)
    # To use LLVM libc++ use "-stdlib=libc++", but you need to install it separately

    #-- Apply compiler flags, only the ones specific per build type.

    # -fno-omit-frame-pointer disables a good optimization which may corrupt the debugger stack trace.
    set(COMPILE_OPTIONS_EXTRA)
    if(ENABLED_SANITIZER OR TARGET spheresvr_debug)
        set(COMPILE_OPTIONS_EXTRA -fno-omit-frame-pointer -fno-inline)
    endif()
    if(TARGET spheresvr_release)
        target_compile_options(
            spheresvr_release
            PUBLIC -O3 -flto=full -fvirtual-function-elimination ${COMPILE_OPTIONS_EXTRA}
        )
    endif()
    if(TARGET spheresvr_nightly)
        if(ENABLED_SANITIZER)
            target_compile_options(spheresvr_nightly PUBLIC -ggdb3 -Og ${COMPILE_OPTIONS_EXTRA})
        else()
            target_compile_options(
                spheresvr_nightly
                PUBLIC -O3 -flto=full -fvirtual-function-elimination ${COMPILE_OPTIONS_EXTRA}
            )
        endif()
    endif()
    if(TARGET spheresvr_debug)
        target_compile_options(spheresvr_debug PUBLIC -ggdb3 -O0 ${COMPILE_OPTIONS_EXTRA})
    endif()

    #-- Store common linker flags.

    if(${USE_MSAN})
        set(CMAKE_EXE_LINKER_FLAGS_EXTRA ${CMAKE_EXE_LINKER_FLAGS_EXTRA} -pie)
    endif()
    set(cxx_linker_options_common
        ${CMAKE_EXE_LINKER_FLAGS_EXTRA}
        -pthread
        -dynamic
        -Wl,--fatal-warnings
        $<$<BOOL:${RUNTIME_STATIC_LINK}>:
        -static-libstdc++
        -static-libgcc> # no way to safely statically link against libc
    )

    #-- Store common define macros.

    set(cxx_compiler_definitions_common
        ${PREPROCESSOR_DEFS_EXTRA}
        $<$<NOT:$<BOOL:${CMAKE_NO_GIT_REVISION}>>:_GITVERSION>
        _EXCEPTIONS_DEBUG
        # _EXCEPTIONS_DEBUG: Enable advanced exceptions catching. Consumes some more resources, but is very useful for debug
        #   on a running environment. Also it makes sphere more stable since exceptions are local.
    )

    #-- Apply define macros, only the ones specific per build type.

    if(TARGET spheresvr_release)
        target_compile_definitions(spheresvr_release PUBLIC NDEBUG)
    endif(TARGET spheresvr_release)
    if(TARGET spheresvr_nightly)
        target_compile_definitions(spheresvr_nightly PUBLIC NDEBUG THREAD_TRACK_CALLSTACK _NIGHTLYBUILD)
    endif(TARGET spheresvr_nightly)
    if(TARGET spheresvr_debug)
        target_compile_definitions(spheresvr_debug PUBLIC _DEBUG THREAD_TRACK_CALLSTACK _PACKETDUMP)
    endif(TARGET spheresvr_debug)

    #-- Now add back the common compiler options, preprocessor macros, linker targets and options.

    foreach(tgt ${TARGETS})
        target_compile_options(${tgt} PRIVATE ${cxx_compiler_options_common})
        target_compile_definitions(${tgt} PRIVATE ${cxx_compiler_definitions_common})
        target_link_options(${tgt} PRIVATE ${cxx_linker_options_common})
        target_link_libraries(${tgt} PRIVATE ${LIB_mariadb_WITH_PATH} ${LIB_dl_WITH_PATH})
    endforeach()

    #-- Set different output folders for each build type
    # (When we'll have support for multi-target builds...)
    #SET_TARGET_PROPERTIES(spheresvr PROPERTIES RUNTIME_OUTPUT_RELEASE    "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Release"    )
    #SET_TARGET_PROPERTIES(spheresvr PROPERTIES RUNTIME_OUTPUT_DEBUG        "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Debug"    )
    #SET_TARGET_PROPERTIES(spheresvr PROPERTIES RUNTIME_OUTPUT_NIGHTLY    "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Nightly"    )
endfunction()
