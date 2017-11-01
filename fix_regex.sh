#!/bin/bash

file=${WK}/view/src/libxec/xec_Regexp.c 
add="#define NO_REGEXP"
sed -i $file -e "s:regexp.h:regex.h:"
sed -i "1i $add" "$file"
