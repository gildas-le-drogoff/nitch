<div align="center">

# `NiTch`

<h3>
  incredibly fast system fetch written in <code>nim👑</code>
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

# Description 📖

`nitch` is a small and incredibly fast system fetch written fully in `nim👑` without any dependencies, on my pc
it executes in around 1.70 miliseconds.

The source code of `nitch` is highly documented and I hope it will act as a learning resource for nim
and linux systems architecture

If anything in the source code is unclear or is lacking in its explanation, open an issue. Sometimes you get too close to something and you fail to see the "bigger picture"!


btw written in `nim👑`

why `nim👑`? because it's fast and simple

<br>

# Supported systems 🐧
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

# Installation ☁️
```fish
wget https://raw.githubusercontent.com/unxsh/nitch/main/setup.sh && sh setup.sh
```

# Usage 🪨
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

# Uninstall 🗑️
```fish
sudo rm /usr/local/bin/nitch
```

<br>

# OpenWrt 📡
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

See [Building](#building-) to build a static ARMv7 binary for your router.

<br>

# Configuration ⚙️
### `nitch` is configured by changing the source code
### `src/funcs/drawing.nim` - config file
```nim
import
  std/terminal,     # import standard terminal lib
  std/strutils,
  getDistroId,      # import to get distro id through /etc/os-release
  ../assets/logos,  # uncomment if you use your own logo
  ../nitches/[getUser, getHostname,
                  getDistro, getKernel,
                  getUptime, getShell,
                  getPkgs, getRam, getLogo,
                  getOpenwrt]  # import nitches to get info about user system

# the main function for drawing fetch
proc drawInfo*(asciiArt: bool) =
  let  # distro id (arch, manjaro, debian)
    distroId = getDistroId()
    openwrt = isOpenwrt(distroId)  # OpenWrt, LEDE or a derivative

  let  # logo and it color
    coloredLogo = getLogo(if openwrt: "openwrt" else: distroId)  # color + logo tuple
    # (fgRed, nitchLogo)

  const  # icons before cotegores
    userIcon   = " "  # recomended: " " or "|>"
    hnameIcon  = " "  # recomended: " " or "|>"
    distroIcon = "󰻀 "  # recomended: "󰻀 " or "|>"
    kernelIcon = "󰌢 "  # recomended: "󰌢 " or "|>"
    uptimeIcon = " "  # recomended: " " or "|>"
    shellIcon  = " "  # recomended: " " or "|>"
    pkgsIcon   = "󰏖 "  # recomended: "󰏖 " or "|>"
    ramIcon    = "󰍛 "  # recomended: "󰍛 " or "|>"
    colorsIcon = "󰏘 "  # recomended: "󰏘 " or "->"
    # OpenWrt only
    modelIcon  = "\u{F0469} "  # 󰑩 router   recomended: "\u{F0469} " or "|>"
    cpuIcon    = "\u{F4BC} "   #  cpu      recomended: "\u{F4BC} " or "|>"
    targetIcon = "\u{F061A} "  # 󰘚 chip     recomended: "\u{F061A} " or "|>"
    diskIcon   = "\u{F02CA} "  # 󰋊 harddisk recomended: "\u{F02CA} " or "|>"
    loadIcon   = "\u{F029A} "  # 󰊚 gauge    recomended: "\u{F029A} " or "|>"
    # please insert any char after the icon
    # to avoid the bug with cropping the edge of the icon

    dotIcon = ""  # recomended: "" or "■"
    # icon for demonstrate colors

  const  # categories
    userCat   = " user   │ "  # recomended: " user   │ "
    hnameCat  = " hname  │ "  # recomended: " hname  │ "
    distroCat = " distro │ "  # recomended: " distro │ "
    kernelCat = " kernel │ "  # recomended: " kernel │ "-
    uptimeCat = " uptime │ "  # recomended: " uptime │ "
    shellCat  = " shell  │ "  # recomended: " shell  │ "
    pkgsCat   = " pkgs   │ "  # recomended: " pkgs   │ "
    ramCat    = " memory │ "  # recomended: " memory │ "
    colorsCat = " colors │ "  # recomended: " colors │ "
    # OpenWrt only
    modelCat  = " model  │ "
    cpuCat    = " cpu    │ "
    targetCat = " target │ "
    diskCat   = " disk   │ "
    loadCat   = " load   │ "

  var  # all info about system
    userInfo     = getUser()          # get user through $USER env variable
    hostnameInfo = getHostname()      # get Hostname hostname through /etc/hostname
    distroInfo   = getDistro()        # get distro through /etc/os-release (or /etc/openwrt_release)
    kernelInfo   = getKernel()        # get kernel through /proc/version
    uptimeInfo   = getUptime()        # get Uptime through /proc/uptime file
    shellInfo    = getShell()         # get shell through $SHELL env variable
    pkgsInfo     = getPkgs(distroId)  # get amount of packages in distro
    ramInfo      = getRam()           # get ram through /proc/meminfo

  var  # OpenWrt only, empty values are not displayed
    modelInfo, cpuInfo, targetInfo, diskInfo, loadInfo: string

  if openwrt:
    modelInfo  = getModel()    # /tmp/sysinfo/model, device-tree, /proc/cpuinfo
    cpuInfo    = getCpu()      # /proc/cpuinfo (system type, Hardware, model name)
    targetInfo = getTarget()   # DISTRIB_TARGET + DISTRIB_ARCH
    diskInfo   = getStorage()  # free space on /overlay (writable flash)
    loadInfo   = getLoad()     # /proc/loadavg

    let revision = getRevision()  # r23809-234f1a2efa
    if revision != "" and revision notin distroInfo:
      distroInfo &= " " & revision

  const  # aliases for colors
    color1 = fgRed
    color2 = fgYellow
    color3 = fgGreen
    color4 = fgCyan
    color5 = fgBlue
    color6 = fgMagenta
    color7 = fgWhite
    color8 = fgBlack
    color0 = fgDefault

  # ascii art
  if not asciiArt:
    discard
  else:
    stdout.styledWrite(styleBright, coloredLogo[0], coloredLogo[1], color0)

  # colored out
  stdout.styledWrite("\n", styleBright, "  ╭───────────╮\n")
  stdout.styledWrite("  │ ", color2, userIcon, color0, userCat, color1, userInfo, color0, "\n",)
  if not isEmptyOrWhitespace(hostnameInfo):
    stdout.styledWrite("  │ ", color2, hnameIcon, color0, hnameCat, color2, hostnameInfo, color0, "\n")
  stdout.styledWrite("  │ ", color3, distroIcon, color0, distroCat, color3, distroInfo, color0, "\n")
  stdout.styledWrite("  │ ", color4, kernelIcon, color0, kernelCat, color4, kernelInfo, color0, "\n")
  stdout.styledWrite("  │ ", color5, uptimeIcon, color0, uptimeCat, color5, uptimeInfo, color0, "\n")
  stdout.styledWrite("  │ ", color6, shellIcon, color0, shellCat, color6, shellInfo, color0, "\n")
  stdout.styledWrite("  │ ", color1, pkgsIcon, color0, pkgsCat, color1, pkgsInfo, color0, "\n")
  stdout.styledWrite("  │ ", color2, ramIcon, color0, ramCat, fgYellow, ramInfo, color0, "\n")

  # OpenWrt only
  if modelInfo != "":
    stdout.styledWrite("  │ ", color3, modelIcon, color0, modelCat, color3, modelInfo, color0, "\n")
  if cpuInfo != "":
    stdout.styledWrite("  │ ", color4, cpuIcon, color0, cpuCat, color4, cpuInfo, color0, "\n")
  if targetInfo != "":
    stdout.styledWrite("  │ ", color5, targetIcon, color0, targetCat, color5, targetInfo, color0, "\n")
  if diskInfo != "":
    stdout.styledWrite("  │ ", color6, diskIcon, color0, diskCat, color6, diskInfo, color0, "\n")
  if loadInfo != "":
    stdout.styledWrite("  │ ", color1, loadIcon, color0, loadCat, color1, loadInfo, color0, "\n")
  stdout.styledWrite("  ├───────────┤\n")
  stdout.styledWrite("  │ ", color7, colorsIcon, color0, colorsCat, color7, dotIcon, " ", color1, dotIcon, " ", color2, dotIcon, " ", color3, dotIcon, " ", color4, dotIcon, " ", color5, dotIcon, " ", color6, dotIcon, " ", color8, dotIcon, color0, "\n")
  stdout.styledWrite("  ╰───────────╯\n\n")
```

# Building 📦
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

<br>

# File architecture 📁
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

  7 directories, 48 files
```

# Thanks for ideas & examples 💬
- [pfetch](https://github.com/dylanaraps/pfetch/)
- [neofetch](https://github.com/dylanaraps/neofetch)
- [paleofetch](https://github.com/ss7m/paleofetch)
- [rxfetch](https://github.com/Mangeshrex/rxfetch)
- [nerdfetch](https://github.com/ThatOneCalculator/NerdFetch)
