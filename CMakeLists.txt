# Licensed to the Apache Software Foundation (ASF) under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  The ASF licenses this
# file to you under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License.  You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.
project(PlasmaStore)
cmake_minimum_required(VERSION 3.10)
find_package(Arrow)
find_package(gflags)
add_custom_target(plasma-all)
add_custom_target(plasma)
add_custom_target(plasma-benchmarks)
add_custom_target(plasma-tests)
add_dependencies(plasma-all plasma plasma-tests plasma-benchmarks)

# For the moment, Plasma is versioned like Arrow
set(ARROW_VERSION "1.0")
set(PLASMA_VERSION "${ARROW_VERSION}")
set(ARROW_CUDA ON)
find_package(Threads)

# The SO version is also the ABI version
set(PLASMA_SO_VERSION "${PLASMA_VERSION}")
set(PLASMA_FULL_SO_VERSION "${PLASMA_VERSION}")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-conversion")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")

set(PLASMA_SRCS
    src/client/client.cc
    src/client/common.cc
    src/client/fling.cc
    src/client/io.cc
    src/client/malloc.cc
    src/client/plasma.cc
    src/client/protocol.cc)

set(PLASMA_STORE_SRCS
    src/server/dlmalloc.cc
    src/server/events.cc
    src/server/eviction_policy.cc
    src/server/quota_aware_policy.cc
    src/server/plasma_allocator.cc
    src/server/store.cc
    thirdparty/ae/include/ae/ae.c)

# set(PLASMA_LINK_LIBS arrow_shared)
# set(PLASMA_STATIC_LINK_LIBS arrow)

# find_library(ARROW_CUDA_LIB_PATH NAMES libarrow_cuda.a arrow_cuda)
# find_library(ARROW_LIB_PATH NAMES libarrow.a arrow)
# find_library(ARROW_DEP_LIB_PATH NAMES libarrow_bundled_dependencies.a
# arrow_bundled_dependencies)

# list(INSERT PLASMA_STATIC_LINK_LIBS 0 ${ARROW_CUDA_LIB_PATH})
add_definitions(-DPLASMA_CUDA)

add_library(plasma_client SHARED ${PLASMA_SRCS})
target_include_directories(plasma_client PRIVATE "include")
target_include_directories(plasma_client
                           PRIVATE "thirdparty/flatbuffers/include")
target_include_directories(plasma_client PRIVATE "thirdparty/xxhash/include")
message(STATUS "ARROW CUDA: ${ARROW_CUDA_LIB_PATH}")
set_target_properties(plasma_client PROPERTIES LINK_FLAGS "-Wl,-rpath,./")
target_link_libraries(plasma_client arrow_shared arrow_cuda)

foreach(LIB_TARGET ${PLASMA_LIBRARIES})
  target_compile_definitions(${LIB_TARGET} PRIVATE ARROW_EXPORTING)
endforeach()

# The optimization flag -O3 is suggested by dlmalloc.c, which is #included in
# malloc.cc; we set it here regardless of whether we do a debug or release
# build.
set_source_files_properties(dlmalloc.cc PROPERTIES COMPILE_FLAGS "-O3")

list(APPEND PLASMA_EXTERNAL_STORE_SOURCES "src/server/external_store.cc"
     "src/server/hash_table_store.cc")

# We use static libraries for the plasma-store-server executable so that it can
# be copied around and used in different locations.
add_executable(plasma-store-server ${PLASMA_EXTERNAL_STORE_SOURCES}
                                   ${PLASMA_STORE_SRCS})

target_include_directories(plasma-store-server PRIVATE "include")
target_include_directories(plasma-store-server
                           PRIVATE "thirdparty/flatbuffers/include")
target_include_directories(plasma-store-server
                           PRIVATE "thirdparty/dlmalloc/include")
target_include_directories(plasma-store-server PRIVATE "thirdparty/ae/include")
target_link_libraries(plasma-store-server ${GFLAGS_LIBRARIES})
target_link_libraries(plasma-store-server plasma_client)

set_target_properties(plasma-store-server PROPERTIES LINK_FLAGS "-Wl,-rpath,./")
add_dependencies(plasma plasma-store-server)

#
# Unit tests
#

# Adding unit tests part of the "arrow" portion of the test suite
# function(ADD_PLASMA_TEST REL_TEST_NAME) set(options) set(one_value_args)
# set(multi_value_args) cmake_parse_arguments(ARG "${options}"
# "${one_value_args}" "${multi_value_args}" ${ARGN})
# add_test_case(${REL_TEST_NAME} PREFIX "plasma" LABELS "plasma-tests"
# ${ARG_UNPARSED_ARGUMENTS}) endfunction()

# if(ARROW_BUILD_SHARED) set(PLASMA_TEST_LIBS plasma_shared ${PLASMA_LINK_LIBS})
# else() set(PLASMA_TEST_LIBS plasma_static ${PLASMA_STATIC_LINK_LIBS}) endif()

# add_plasma_test(test/serialization_tests EXTRA_LINK_LIBS ${PLASMA_TEST_LIBS})
# add_plasma_test(test/client_tests EXTRA_LINK_LIBS ${PLASMA_TEST_LIBS}
# EXTRA_DEPENDENCIES plasma-store-server)
# add_plasma_test(test/external_store_tests EXTRA_LINK_LIBS ${PLASMA_TEST_LIBS}
# EXTRA_DEPENDENCIES plasma-store-server)
