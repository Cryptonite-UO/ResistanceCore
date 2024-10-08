message(STATUS "Toolchain not specified. Detecting the one to use.")
if(MSVC)
    include("cmake/toolchains/Windows-MSVC.cmake")
else()
    if(APPLE)
        message(STATUS "Defaulting to AArch64 (ARM) arch.")
        include("cmake/toolchains/OSX-AppleClang-AArch64.cmake")
    elseif(UNIX)
        if("${ARCH}" STREQUAL "x86_64")
            include("cmake/toolchains/Linux-GNU-x86_64.cmake")
        elseif("${ARCH}" STREQUAL "x86")
            include("cmake/toolchains/Linux-GNU-x86.cmake")
        elseif("${ARCH}" STREQUAL "arm64")
            include("cmake/toolchains/Linux-Clang-AArch64.cmake")
        else()
            message(STATUS "Unsupported architecture, defaulting to native.")
            include("cmake/toolchains/Linux-GNU-native.cmake")
        endif()
    else()
        if("${ARCH}" STREQUAL "x86_64")
            include("cmake/toolchains/Windows-GNU-x86_64.cmake")
        elseif("${ARCH}" STREQUAL "x86")
            include("cmake/toolchains/Windows-GNU-x86.cmake")
        else()
            message(STATUS "Unsupported architecture, defaulting to native.")
            include("cmake/toolchains/Windows-GNU-native.cmake")
        endif()
    endif()
endif()
