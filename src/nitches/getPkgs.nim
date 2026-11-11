import
  std/os,
  ../funcs/packages/[getPacmanPkgs, getRpmPkgs,
                     getPortagePkgs, getXbpsPkgs,
                     getDpkgPkgs, getKissPkgs,
                     getNixPkgs, getOpkgPkgs]

# guess the package manager from its database when the distro id is unknown
proc detectPkgs(): string =
  if dirExists("/var/lib/pacman/local"):
    result = getPacmanPkgs()
  elif fileExists("/var/lib/dpkg/status"):
    result = getDpkgPkgs()
  elif dirExists("/var/db/xbps"):
    result = getXbpsPkgs()
  elif dirExists("/var/db/kiss/installed"):
    result = getKissPkgs()
  elif dirExists("/var/db/pkg"):
    result = getPortagePkgs()
  elif dirExists("/var/lib/rpm") or dirExists("/usr/lib/sysimage/rpm"):
    result = getRpmPkgs()
  elif dirExists("/run/current-system/sw"):
    result = getNixPkgs()
  elif fileExists("/etc/openwrt_release"):
    result = getOpenwrtPkgs()
  elif fileExists("/lib/apk/db/installed"):
    result = getApkPkgs()
  elif fileExists("/usr/lib/opkg/status") or fileExists("/usr/lib/ipkg/status"):
    result = getOpkgPkgs()
  else:
    result = ">3"

proc getPkgs*(distroId: string): string =
  case distroId:
  of "arch", "artix", "archcraft", "manjaro", "endeavouros",
     "garuda", "cachyos", "arcolinux":
    result = getPacmanPkgs()

  of "fedora", "centos", "rhel", "almalinux", "rocky":
    result = getRpmPkgs()

  of "gentoo":
    result = getPortagePkgs()

  of "void":
    result = getXbpsPkgs()

  of "kiss":
    result = getKissPkgs()

  of "nixos":
    result = getNixPkgs()

  of "ubuntu", "debian", "linuxmint", "pop", "zorin":
    result = getDpkgPkgs()

  of "openwrt", "lede":
    result = getOpenwrtPkgs()

  of "alpine":
    result = getApkPkgs()

  else:
    result = detectPkgs()
