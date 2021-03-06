#!/bin/bash
# Brief: scan current directory (NOT support sub-directories yet),
#        then generate a cmake file to allow cmake build the Qt 
#        Project accordingly

# Example:
#   $ ls
#     main.cpp dialog.ui myres.qrc myobj.h
#   $ newqtcmakeproject.sh
#   $ ls
#     main.cpp dialog.ui myres.qrc myobj.h QtProject.cmake
#   $ echo 'include (QtProject.cmake)' >> CMakeLists.txt
#  Then you can build your target with cmake

# Prerequisite:
#   To make it works, you must include the Qt Modules in CMakeLists.txt,
#   Typically, it's like:
#   	find_package (Qt4 REQUIRED)
#		include (${QT_USE_FILE})
#		add_definitions (${QT_DEFINITIONS})
#		set (QT_LIBS ${QT_LIBS} ${QT_LIBRARIES})
#		set (EXTRA_LIBS ${EXTRA_LIBS} ${QT_LIBS})

### Scanning source files into $SRCS, ridding files has counterpart header file
### containing 'Q_OBJECT' macro
###

OUTPUT="CMakeLists.txt"
test -f CMakeLists.txt || newcmakefile.sh
sed -i 's/#include (Qt4)/include (Qt4)/g' CMakeLists.txt

#for f in $(ls *.cpp); do
	#h=$(basename "$f" .cpp).h
	#test -f "$h" && res=$(grep 'Ui::' "$h") || res=""
	#[ "$res" == "" ] && SRCS="$SRCS $f"
#done

SRCS=$(ls *.cpp)
MOCS=$(ls *.h 2>/dev/null | xargs grep -l 'Q_OBJECT' | xargs)
UIS=$(ls *.ui 2>/dev/null)
QRCS=$(ls *.qrc 2>/dev/null)

# Prompts
echo >> "$OUTPUT"
echo '# Auto generated by newqtcmakeproject.sh  -- Author: LIU Yang' >> "$OUTPUT"
echo '# Contact me: JeremyRobturtle@gmail.com' >> "$OUTPUT"

# Context
echo 'include_directories (${CMAKE_CURRENT_BINARY_DIR})' >> "$OUTPUT"

if [ "$SRCS" != "" ]; then
	echo "set (SRCS "$SRCS")" >> "$OUTPUT"
fi

if [ "$MOCS" != "" ]; then
	echo "set (MOCS "$MOCS")" >> "$OUTPUT"
	echo 'QT4_WRAP_CPP (MOCS_OUT ${MOCS})' >> "$OUTPUT"
fi

if [ "$UIS"  != "" ]; then
	echo "set (UIS "$UIS")" >> "$OUTPUT"
	echo 'QT4_WRAP_UI (UIS_OUT ${UIS})' >> "$OUTPUT"
fi

if [ "$QRCS" != "" ]; then
	echo "set (QRCS "$QRCS")" >> "$OUTPUT"
	echo 'QT4_ADD_RESOURCES (QRCS_OUT ${QRCS})' >> "$OUTPUT"
fi

[ "$1" != "" ] && exe="$1" || exe="a.out"

echo 'add_executable (' "$exe" '${SRCS} ${MOCS_OUT} ${UIS_OUT} ${QRCS_OUT})'\
	>> "$OUTPUT"
echo 'target_link_libraries (' "$exe" '${QT_LIBRARIES})'\
	>> "$OUTPUT"
