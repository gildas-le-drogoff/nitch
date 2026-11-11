import
  std/[os, strutils],
  osRelease

proc getDistroId*(): string =
  result = getOsReleaseValue("ID")

  # old OpenWrt releases have no os-release, only /etc/openwrt_release
  # (DISTRIB_ID='OpenWrt' or 'LEDE')
  if result == "":
    result = getOpenwrtReleaseValue("DISTRIB_ID").toLowerAscii

func isOpenwrtId*(distroId: string): bool =
  distroId in ["openwrt", "lede"]

proc isOpenwrt*(distroId: string): bool =
  # OpenWrt derivatives (GL.iNet, Turris, ImmortalWrt, ...) may use their own
  # ID but keep /etc/openwrt_release
  distroId.isOpenwrtId or fileExists("/etc/openwrt_release")
