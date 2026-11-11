#!/bin/sh
# `zig cc` wrapper used as a C cross compiler by `nimble release`.
#   ZIG_TARGET=aarch64-linux-musl tools/zigcc.sh ...
# zig rejects `-flto=auto` (set in src/nitch.nim.cfg): it is replaced by `-flto`.

: "${ZIG_TARGET:?ZIG_TARGET is not set (e.g. aarch64-linux-musl)}"

for arg in "$@"; do
  shift
  [ "$arg" = "-flto=auto" ] && arg="-flto"
  set -- "$@" "$arg"
done

exec zig cc -target "$ZIG_TARGET" "$@"
