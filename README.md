<div align="center">

# `NiTch`

<h3>
  incredibly fast system fetch written in <code>nim</code>
</h3>
<br>

![Maintenance](https://shields.io/maintenance/yes/2022?style=for-the-badge)
![License](https://shields.io/github/license/unxsh/nitch?style=for-the-badge)
![Commits](https://shields.io/github/commit-activity/m/unxsh/nitch?style=for-the-badge)

![GitHub Repo stars](https://img.shields.io/github/stars/unxsh/nitch?style=for-the-badge)
![GitHub issues](https://img.shields.io/github/issues/unxsh/nitch?style=for-the-badge)
![GitHub pull requests](https://img.shields.io/github/issues-pr/unxsh/nitch?style=for-the-badge)

![GitHub release (latest by date)](https://img.shields.io/github/v/release/unxsh/nitch?style=for-the-badge)

</div>

# Description
`nitch` is a small and incredibly fast system fetch written fully in `nim` without any dependencies, on my pc
it executes in around 1.70 miliseconds.

The source code of `nitch` is highly documented and I hope it will act as a learning resource for nim
and linux systems architecture

If anything in the source code is unclear or is lacking in its explanation, open an issue. Sometimes you get too close to something and you fail to see the "bigger picture"!


btw written in `nim`

why `nim`? because it's fast and simple

<br>

# Supported systems
### logos
`arch`, `artix`, `arcolinux`, `cachyos`, `endeavouros`, `garuda`, `manjaro`,
`debian`, `ubuntu`, `linuxmint`, `pop`, `zorin`, `fedora`, `centos`, `rhel`, `almalinux`, `rocky`,
`opensuse-*` (tumbleweed, leap, ...), `gentoo`, `slackware`, `void`, `kiss`, `nixos`, `bedrock`,
`openwrt` / `lede` (and derivatives)

Any other distro gets the default `nitch` logo.

The distro is read from `/etc/os-release` (parsed by `nitch` itself, single quotes
supported), or from `/etc/openwrt_release` on old OpenWrt releases without `os-release`.

### package managers
| package manager | distros |
|---|---|
| `pacman` | arch, artix, archcraft, manjaro, endeavouros, garuda, cachyos, arcolinux |
| `dpkg` | debian, ubuntu, linuxmint, pop, zorin |
| `rpm` | fedora, centos, rhel, almalinux, rocky |
| `portage` | gentoo |
| `xbps` | void |
| `kiss` | kiss |
| `nix` | nixos |
| `opkg` / `ipkg` | openwrt, lede (up to 24.10, and very old releases) |
| `apk` | openwrt 25.x+, alpine |

On any other distro, the package manager is auto-detected from its database
(`/var/lib/pacman/local`, `/var/lib/dpkg/status`, `/var/db/xbps`, ...).

<br>

# Installation
```sh
wget https://raw.githubusercontent.com/gildas-le-drogoff/nitch/main/setup.sh && sh setup.sh
```
`setup.sh` detects the architecture, downloads the matching static binary from the
[latest release](https://github.com/gildas-le-drogoff/nitch/releases/latest), checks its
SHA256 and installs it to `/usr/local/bin/nitch` (`/usr/bin/nitch` when there is no
`/usr/local/bin`, e.g. on OpenWrt). It works with busybox and needs `curl`, `wget` or `uclient-fetch`.

Options (environment variables):
```sh
NITCH_VERSION=0.3.0 sh setup.sh   # a given release instead of the latest one
PREFIX=$HOME/.local sh setup.sh   # install to ~/.local/bin, no sudo
```

Prebuilt binaries (static, no dependency):

| file | architecture | typical devices |
|---|---|---|
| `nitch-amd64` | x86_64 | PCs, servers |
| `nitch-arm64` | aarch64 | Raspberry Pi 3/4/5 (64-bit kernel), ARM servers |
| `nitch-armv7` | ARMv7 hard-float | Raspberry Pi 2/3 (32-bit), OpenWrt `arm_cortex-a*` |
| `nitch-mips` | MIPS32r2 big-endian, soft-float | OpenWrt `ath79` routers (`mips_24kc`) |
| `nitch-mipsel` | MIPS32r2 little-endian, soft-float | OpenWrt `ramips` routers (`mipsel_24kc`) |

The icons need a [Nerd Font](https://www.nerdfonts.com/) in your terminal; to use ASCII
icons instead, see [Configuration](#configuration). Other architectures: see [Building](#building).

# Usage
```
nitch
```

flags:
```
 -f --fetch    | return fetch about system
 -a --no-ascii | return fetch without ascii art
 -h --help     | return help message
 -v --version  | return version of program
```

# Uninstall
```sh
sudo rm /usr/local/bin/nitch   # or /usr/bin/nitch on OpenWrt
```

<br>

# OpenWrt
`nitch` runs on OpenWrt / LEDE routers, from very old releases to the current ones
(derivatives such as GL.iNet, Turris or ImmortalWrt are detected through `/etc/openwrt_release`).

In addition to the usual fields, it shows:
```
 model  | router model (/tmp/sysinfo/model, device-tree, /proc/cpuinfo, DMI)
 cpu    | SoC / cpu model and number of cores (/proc/cpuinfo)
 target | target and arch, e.g. ath79/generic (mips_24kc)
 disk   | used and total space of the writable flash (/overlay, /jffs or /)
 load   | load average (/proc/loadavg)
```
The build revision (e.g. `r23809-234f1a2efa`) is appended to the distro name.

When `$USER` / `$SHELL` are unset (common with dropbear/ash), `nitch` falls back to
`$LOGNAME` and `/etc/passwd`. Memory is computed even without `MemAvailable` (kernels < 3.14).

`sh setup.sh` works on the router itself (`nitch-armv7`, `nitch-mips` or `nitch-mipsel`).
If the router cannot download over HTTPS, copy the binary from your PC:
`scp -O nitch-mips root@192.168.1.1:/usr/bin/nitch`.
See [Building](#building) to build it yourself.

<br>

# Configuration
`nitch` has no config file: it is configured by editing
[`src/funcs/drawing.nim`](src/funcs/drawing.nim) and rebuilding (see [Building](#building)).

| what | constants in `drawing.nim` | default |
|---|---|---|
| icons | `userIcon`, `hnameIcon`, ..., `dotIcon` | Nerd Font glyphs (see below) |
| labels | `userCat`, `hnameCat`, ..., `loadCat` | `" user   │ "`, `" hname  │ "`, ... |
| colors | `color1` ... `color8`, `color0` | standard terminal colors |
| logo | `coloredLogo` | logo of the detected distro (`src/assets/logos.nim`) |
| displayed lines | the `stdout.styledWrite(...)` calls at the end of `drawInfo` | all lines |

### Icons
The default icons are [Nerd Font](https://www.nerdfonts.com/) glyphs: your terminal
needs a Nerd Font to display them. They are listed here by code point (the glyphs
themselves do not render on GitHub or on most phones). Use the ASCII alternative
if you don't use a Nerd Font.

| constant | shown for | Nerd Font glyph | code point | ASCII alternative |
|---|---|---|---|---|
| `userIcon` | user | `nf-fa-user` | `U+F007` | `\|>` |
| `hnameIcon` | hostname | `nf-dev-ghost_small` | `U+E714` | `\|>` |
| `distroIcon` | distro | `nf-md-penguin` | `U+F0EC0` | `\|>` |
| `kernelIcon` | kernel | `nf-md-laptop` | `U+F0322` | `\|>` |
| `uptimeIcon` | uptime | `nf-fa-clock_o` | `U+F017` | `\|>` |
| `shellIcon` | shell | `nf-oct-terminal` | `U+F489` | `\|>` |
| `pkgsIcon` | packages | `nf-md-package_variant` | `U+F03D6` | `\|>` |
| `ramIcon` | memory | `nf-md-memory` | `U+F035B` | `\|>` |
| `colorsIcon` | colors | `nf-md-palette` | `U+F03D8` | `->` |
| `modelIcon` | model (OpenWrt) | `nf-md-router_wireless` | `U+F0469` | `\|>` |
| `cpuIcon` | cpu (OpenWrt) | `nf-oct-cpu` | `U+F4BC` | `\|>` |
| `targetIcon` | target (OpenWrt) | `nf-md-chip` | `U+F061A` | `\|>` |
| `diskIcon` | disk (OpenWrt) | `nf-md-harddisk` | `U+F02CA` | `\|>` |
| `loadIcon` | load (OpenWrt) | `nf-md-gauge` | `U+F029A` | `\|>` |
| `dotIcon` | color dots | `nf-oct-dot_fill` | `U+F444` | `■` (`U+25A0`) |

In `drawing.nim` the icons are written with their code point (`"\u{F007} "` is the
glyph followed by a space), so the source stays readable in any editor, even without a Nerd Font.
Keep a character (a space) after each icon, otherwise the edge of the icon may be cropped.

Example, ASCII only (no Nerd Font needed):
```nim
const  # icons before categories
  userIcon   = "|> "
  hnameIcon  = "|> "
  distroIcon = "|> "
  # ...
  colorsIcon = "-> "
  dotIcon    = "\u{25A0}"  # ■
```

Example, with Nerd Font glyphs written as code points:
```nim
const
  userIcon   = "\u{F007} "   # nf-fa-user
  distroIcon = "\u{F0EC0} "  # nf-md-penguin
  ramIcon    = "\u{F035B} "  # nf-md-memory
```

### Labels
Each label is a plain string, padded so that the `│` separators line up:
```nim
const  # categories
  userCat   = " user   │ "
  kernelCat = " kernel │ "
```
If you rename a label, keep the same width for all of them (and adjust the
`╭───────────╮` / `├───────────┤` / `╰───────────╯` borders if you change the width).

### Colors
| alias | default |
|---|---|
| `color1` | `fgRed` |
| `color2` | `fgYellow` |
| `color3` | `fgGreen` |
| `color4` | `fgCyan` |
| `color5` | `fgBlue` |
| `color6` | `fgMagenta` |
| `color7` | `fgWhite` |
| `color8` | `fgBlack` |
| `color0` | `fgDefault` (reset) |

Any value of [`ForegroundColor`](https://nim-lang.org/docs/terminal.html#ForegroundColor)
from `std/terminal` can be used.

### Lines
Each line of the fetch is one `stdout.styledWrite(...)` call at the end of `drawInfo`:
delete or comment out a call to hide a line, or move it to change the order.
Lines whose value is empty (e.g. the OpenWrt fields on a desktop) are not displayed.

<br>

# Building
### 0) install [nim](https://nim-lang.org/)

### 1) clone repo
```fish
git clone https://github.com/unxsh/nitch.git
```
### 2) change dir to `nitch`
```fish
cd nitch/
```

### 3) build program with `nimble`
```fish
nimble build
```
After that you will get a ready-made binary file in the root directory of the project.

### static build
If the binary has to run on other machines (older glibc, error like
``version `GLIBC_2.34' not found``), build a fully static binary:
```fish
nimble build -d:static
```

### other architectures (arm64, ...)
`nim` compiles to C, so `nitch` works on any architecture with a C compiler:
just build it from source on the target machine (or cross compile with
`--cpu:arm64 --os:linux` and a suitable C cross compiler).

### static ARMv7 binary (OpenWrt routers, Raspberry Pi, ...)
With a musl cross toolchain (e.g. `arm-linux-musleabihf-cross` from [musl.cc](https://musl.cc/)) in your `PATH`:
```fish
nimble armv7
```
This produces a stripped, static `nitch-armv7` binary in the root directory of the project.
Use another toolchain prefix with the `CROSS` variable:
```fish
CROSS=armv7l-linux-musleabihf nimble armv7
```
Then copy it to the device, e.g. `scp -O nitch-armv7 root@192.168.1.1:/usr/bin/nitch`.

### release binaries (amd64, arm64, armv7, mips, mipsel)
With [zig](https://ziglang.org/) (cross C compiler for amd64, arm64, mips and mipsel)
and the ARMv7 musl toolchain above in your `PATH`:
```sh
nimble release
```
This builds the 5 static binaries of the [releases](https://github.com/gildas-le-drogoff/nitch/releases)
and their `SHA256SUMS` in `dist/`. The build is reproducible: the checksums match the published ones.

<br>

# File architecture
```fish
nitch
  ├── LICENSE
  ├── nitch.nimble
  ├── README.md
  ├── setup.sh
  ├── src
  │   ├── assets
  │   │   ├── assets.nim
  │   │   └── logos.nim
  │   ├── flags
  │   │   └── argParser.nim
  │   ├── funcs
  │   │   ├── drawing.nim
  │   │   ├── getDistroId.nim
  │   │   ├── osRelease.nim
  │   │   ├── packages
  │   │   │   ├── getDpkgPkgs.nim
  │   │   │   ├── getKissPkgs.nim
  │   │   │   ├── getNixPkgs.nim
  │   │   │   ├── getOpkgPkgs.nim
  │   │   │   ├── getPacmanPkgs.nim
  │   │   │   ├── getPortagePkgs.nim
  │   │   │   ├── getRpmPkgs.nim
  │   │   │   └── getXbpsPkgs.nim
  │   │   ├── passwd.nim
  │   │   └── perform.nim
  │   ├── nitches
  │   │   ├── getDistro.nim
  │   │   ├── getHostname.nim
  │   │   ├── getKernel.nim
  │   │   ├── getLogo.nim
  │   │   ├── getOpenwrt.nim
  │   │   ├── getPkgs.nim
  │   │   ├── getRam.nim
  │   │   ├── getShell.nim
  │   │   ├── getUptime.nim
  │   │   └── getUser.nim
  │   ├── nitch.nim
  │   └── nitch.nim.cfg
  ├── tools
  │   └── zigcc.sh
  └── templates
      ├── bfetch
      ├── cfgParser.nim
      ├── colorTest.nim
      ├── data.dat
      ├── echo.sh
      ├── listFiles.nim
      ├── readLine.nim
      ├── refTest.nim
      ├── rxfetch
      ├── shellCheck.nim
      ├── slice.nim
      ├── test.cfg
      ├── testCounter.nim
      ├── testFile
      ├── testProc.nim
      └── tupleTest.nim

  8 directories, 49 files
```

# Thanks for ideas & examples
- [pfetch](https://github.com/dylanaraps/pfetch/)
- [neofetch](https://github.com/dylanaraps/neofetch)
- [paleofetch](https://github.com/ss7m/paleofetch)
- [rxfetch](https://github.com/Mangeshrex/rxfetch)
- [nerdfetch](https://github.com/ThatOneCalculator/NerdFetch)
