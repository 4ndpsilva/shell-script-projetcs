#!/bin/bash

X=$(for i in $@; do :; done; echo "$i")
#X=${!#}
X=$0
echo "Last argument: $X"