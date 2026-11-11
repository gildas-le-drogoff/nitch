import
  std/[os, strutils]

proc countStatusFile(statusFile: string): int =
  # opkg/ipkg status file is dpkg-like:
  #   Status: install ok installed
  #   Status: install user installed
  #   Status: deinstall hold not-installed
  try:
    for line in lines(statusFile):
      if line.startsWith("Status:") and line.endsWith(" installed"):
        inc result
  except CatchableError:
    result = 0

proc getOpkgPkgs*(): string =
  # opkg: OpenWrt / LEDE up to 24.10
  # ipkg: very old OpenWrt (White Russian, Kamikaze 7.x)
  var count = 0

  for statusFile in ["/usr/lib/opkg/status", "/usr/lib/ipkg/status"]:
    if fileExists(statusFile):
      count = countStatusFile(statusFile)
      if count > 0:
        break

  # fallback: one <pkg>.control file per installed package
  if count == 0:
    for infoDir in ["/usr/lib/opkg/info", "/usr/lib/ipkg/info"]:
      for kind, path in walkDir(infoDir):
        if kind in {pcFile, pcLinkToFile} and path.endsWith(".control"):
          inc count
      if count > 0:
        break

  result = $count

proc getApkPkgs*(): string =
  # apk: OpenWrt 25.x and later, Alpine. Each package entry has a "P:" line
  const installed = "/lib/apk/db/installed"
  var count = 0

  if fileExists(installed):
    try:
      for line in lines(installed):
        if line.startsWith("P:"):
          inc count
    except CatchableError:
      count = 0

  result = $count

proc getOpenwrtPkgs*(): string =
  # newer OpenWrt switched from opkg to apk
  if fileExists("/lib/apk/db/installed"):
    result = getApkPkgs()
  else:
    result = getOpkgPkgs()
