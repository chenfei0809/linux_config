#!/bin/bash
# Run the ctest command
#   $1 is the build folder of CMake.
#   The script will try on "build" "Debug" "Release" folder if $1
#   is no given.
test -e CMakeLists.txt || echo "Error: CMakeLists.txt not found at " $(pwd)
test -e CMakeLists.txt || exit 1

if [[ "$1" == "" ]]; then
    for pathname in "build" "Debug" "Release"; do
        test -d "$pathname" && path="$pathname" && break
    done
    if [[ "$path" == "" ]]; then
        echo "Error: Can't find a build directory. Try to call cmakecreate.sh first."
        exit 2
    fi
else
    path="$1"
    test -d "$path" || cmakecreate.sh "$path"
fi

cd "$path"
ctest --verbose
