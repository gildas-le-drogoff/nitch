#!/bin/sh
# nitch installer: downloads the static binary matching this machine from the
# GitHub releases and installs it as `nitch`. POSIX sh, works with busybox (OpenWrt).
#
#   sh setup.sh                       latest release
#   NITCH_VERSION=0.3.0 sh setup.sh   a given release
#   PREFIX=$HOME/.local sh setup.sh   install to $PREFIX/bin

set -eu

repo="gildas-le-drogoff/nitch"
version="${NITCH_VERSION:-latest}"
if [ "$version" = "latest" ]; then
  baseUrl="https://github.com/$repo/releases/latest/download"
else
  baseUrl="https://github.com/$repo/releases/download/$version"
fi

die() { echo "error: $*" >&2; exit 1; }

# 1 = little endian, 2 = big endian (EI_DATA byte of the ELF header);
# `uname -m` says "mips" for both mips and mipsel
endianness() {
  dd if=/bin/sh bs=1 skip=5 count=1 2>/dev/null | od -An -tu1 | tr -d ' \n'
}

case "$(uname -m)" in
  x86_64 | amd64)          arch="amd64" ;;
  aarch64 | arm64)         arch="arm64" ;;
  armv7* | armv8l)         arch="armv7" ;;
  mips)
    case "$(endianness)" in
      1) arch="mipsel" ;;
      2) arch="mips" ;;
      *) die "cannot detect the endianness of this mips system" ;;
    esac ;;
  *) die "no prebuilt binary for '$(uname -m)', build nitch from source (see README)" ;;
esac

# install dir: $PREFIX/bin, else /usr/local/bin, else /usr/bin (OpenWrt has no /usr/local)
if [ -n "${PREFIX:-}" ]; then
  binDir="$PREFIX/bin"
elif [ -d /usr/local/bin ]; then
  binDir="/usr/local/bin"
else
  binDir="/usr/bin"
fi

# run as root when the install dir is not writable
sudo=""
mkdir -p "$binDir" 2>/dev/null || true
if [ ! -w "$binDir" ]; then
  command -v sudo >/dev/null 2>&1 || die "$binDir is not writable and sudo is missing, run as root"
  sudo="sudo"
fi

# download $1 to $2 with curl, wget or uclient-fetch (OpenWrt)
fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$2" "$1"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$2" "$1"
  elif command -v uclient-fetch >/dev/null 2>&1; then
    uclient-fetch -q -O "$2" "$1"
  else
    die "curl, wget or uclient-fetch is needed"
  fi
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT INT TERM

echo "Downloading nitch-$arch ($version)..."
fetch "$baseUrl/nitch-$arch" "$tmp/nitch-$arch" || die "download failed: $baseUrl/nitch-$arch"

# verify the checksum when possible
if command -v sha256sum >/dev/null 2>&1 && fetch "$baseUrl/SHA256SUMS" "$tmp/SHA256SUMS" 2>/dev/null; then
  (cd "$tmp" && grep " nitch-$arch\$" SHA256SUMS | sha256sum -c >/dev/null) \
    || die "checksum mismatch for nitch-$arch"
  echo "Checksum OK"
fi

chmod +x "$tmp/nitch-$arch"
$sudo mv -f "$tmp/nitch-$arch" "$binDir/nitch"
ver="$("$binDir/nitch" -v 2>/dev/null)" \
  || die "$binDir/nitch was installed but does not run on this machine, build it from source (see README)"
echo "Installed $binDir/nitch ($ver)"
echo "The icons need a Nerd Font in your terminal: https://www.nerdfonts.com/"
