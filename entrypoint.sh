#!/bin/bash
export XDG_CACHE_HOME="$(mktemp -d)"
/usr/local/bin/pandoc --data-dir=/pandoc "$@"