import
  std/[os, strutils]

proc getShellVar*(path, key: string): string =
  # read a KEY=value pair from a shell-like file (os-release, openwrt_release):
  # values may be unquoted, "double quoted" or 'single quoted'
  if not path.fileExists:
    return

  try:
    for line in lines(path):
      let sep = line.find('=')
      if sep < 1 or line[0 ..< sep].strip != key:
        continue

      result = line[sep + 1 .. ^1].strip
      if result.len >= 2 and result[0] in {'"', '\''} and result[^1] == result[0]:
        result = result[1 .. ^2]
      return
  except CatchableError:
    result = ""

proc getOsReleaseValue*(key: string): string =
  for path in ["/etc/os-release", "/usr/lib/os-release"]:
    if path.fileExists:
      return getShellVar(path, key)

proc getOpenwrtReleaseValue*(key: string): string =
  # /etc/openwrt_release exists on every OpenWrt/LEDE release, including
  # old ones (Kamikaze, Backfire, Attitude Adjustment, Barrier Breaker,
  # Chaos Calmer) that don't ship an os-release file
  result = getShellVar("/etc/openwrt_release", key)
