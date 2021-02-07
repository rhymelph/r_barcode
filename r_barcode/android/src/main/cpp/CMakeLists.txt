# 当期需要的最低版本的cmake
cmake_minimum_required(VERSION 3.4.1)

include_directories(libyuv/include)
add_subdirectory(libyuv ./build)
aux_source_directory(./ SRC_FILE)

# 指定文件添加到项目中
add_library( # 设置库的名字
        native-r_barcode

        # 将库设置为共享库
        SHARED

        # 提供原文件的相对路径
        ${SRC_FILE})

find_library( # 设置路径变量的名称
        log-lib

        # 指定NDK的命名空间
        # 你要定位的CMake
        log)

target_link_libraries( # 指定目标库
        native-r_barcode

        # 将目标链接到日志库，可以打印日志
        # 包含在ndk
        ${log-lib} yuv)

