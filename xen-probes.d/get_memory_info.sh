#!/bin/bash

total=$(free | awk ' /^Mem/ { print $2 }')
used=$(free | awk '/buffers\/cache/ { print $3 }')
free=$(free | awk '/buffers\/cache/ { print $4 }')

echo "TOTALMEMORY=$total"
echo "USEDMEMORY=$used"
echo "FREEMEMORY=$free"

