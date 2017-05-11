#!/bin/sh
# http://stackoverflow.com/questions/3001177/how-do-i-grep-for-all-non-ascii-characters-in-unix
find . -type f \( -name "*.py" -o -name "*.c" -o -name "*.h" \
-o -name "*.pl" -o -name "*.java" -o -name "*.cpp" \) \
-exec file {} \; \
-exec grep --color='auto' -P -n "[\x80-\xFF]" {} \;
