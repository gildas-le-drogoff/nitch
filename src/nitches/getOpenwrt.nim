# extra information shown on OpenWrt / LEDE (old and new releases)

import
  std/[posix, strutils],
  ../funcs/osRelease

proc readTrimmed(path: string): string =
  # device-tree strings end with '\0'
  try:
    result = readFile(path).strip(chars = Whitespace + {'\0'})
  except CatchableError:
    result = ""

proc cpuinfoValue(key: string): string =
  # first "key<tabs>: value" line of /proc/cpuinfo
  try:
    for line in lines("/proc/cpuinfo"):
      let sep = line.find(':')
      if sep > 0 and line[0 ..< sep].strip == key:
        return line[sep + 1 .. ^1].strip
  except CatchableError:
    discard

proc cpuCount(): int =
  try:
    for line in lines("/proc/cpuinfo"):
      if line.startsWith("processor") and ':' in line:
        inc result
  except CatchableError:
    discard

proc getModel*(): string =
  # 1. written at boot by OpenWrt board detection (most targets, old and new)
  result = readTrimmed("/tmp/sysinfo/model")

  # 2. device-tree targets (ath79, ramips, mvebu, ipq40xx, bcm27xx, ...)
  if result == "":
    result = readTrimmed("/proc/device-tree/model")

  # 3. old MIPS kernels (ar71xx, brcm47xx, ...): "machine : TP-LINK TL-WR841N/ND v8"
  if result == "":
    result = cpuinfoValue("machine")

  # 4. x86 / virtual machines
  if result == "":
    let
      vendor = readTrimmed("/sys/class/dmi/id/sys_vendor")
      product = readTrimmed("/sys/class/dmi/id/product_name")
    result = (vendor & " " & product).strip

proc getCpu*(): string =
  # MIPS: "system type : MediaTek MT7621 ver:1 eco:3" + "cpu model : MIPS 1004Kc V2.15"
  # ARM:  "Hardware : Qualcomm ..." (old kernels) or "model name : ARMv7 Processor rev 5 (v7l)"
  # x86:  "model name : Intel(R) Celeron(R) ..."
  let
    systemType = cpuinfoValue("system type")
    cpuModel = cpuinfoValue("cpu model")

  if systemType != "":
    result = systemType
    if cpuModel != "":
      result &= " (" & cpuModel & ")"
  else:
    result = cpuinfoValue("Hardware")
    if result == "":
      result = cpuinfoValue("model name")
    if result == "":
      result = cpuinfoValue("Processor")
    if result == "":
      result = cpuModel

  let cores = cpuCount()
  if result != "" and cores > 1:
    result &= " x" & $cores

proc getTarget*(): string =
  # DISTRIB_TARGET='ath79/generic'  DISTRIB_ARCH='mips_24kc' (since 15.05)
  # os-release: OPENWRT_BOARD="ath79/generic"  OPENWRT_ARCH="mips_24kc"
  var
    target = getOpenwrtReleaseValue("DISTRIB_TARGET")
    arch = getOpenwrtReleaseValue("DISTRIB_ARCH")

  if target == "":
    target = getOsReleaseValue("OPENWRT_BOARD")
  if arch == "":
    arch = getOsReleaseValue("OPENWRT_ARCH")

  result = target
  if arch != "":
    result = if result == "": arch else: result & " (" & arch & ")"

proc getRevision*(): string =
  # DISTRIB_REVISION='r23809-234f1a2efa' (or 'r42625' on old releases)
  result = getOpenwrtReleaseValue("DISTRIB_REVISION")
  if result == "":
    result = getOsReleaseValue("BUILD_ID")

proc isMounted(mountPoint: string): bool =
  try:
    for line in lines("/proc/mounts"):
      let fields = line.splitWhitespace
      if fields.len >= 2 and fields[1] == mountPoint:
        return true
  except CatchableError:
    discard

proc formatMiB(bytes: uint64): string =
  let mib = bytes.float / (1024 * 1024)
  result = if mib < 100: mib.formatFloat(ffDecimal, 1) else: $(bytes div (1024 * 1024))

proc getStorage*(): string =
  # writable flash: /overlay (squashfs + jffs2/ubifs, since Backfire),
  # /jffs on very old releases, otherwise the root filesystem (ext4 images)
  var mountPoint = "/"
  for candidate in ["/overlay", "/jffs"]:
    if isMounted(candidate):
      mountPoint = candidate
      break

  var st: Statvfs
  if statvfs(mountPoint.cstring, st) != 0:
    return ""

  let
    blockSize = (if st.f_frsize > 0: st.f_frsize.uint64 else: st.f_bsize.uint64)
    total = st.f_blocks.uint64 * blockSize
    free = st.f_bfree.uint64 * blockSize

  if total == 0:
    return ""

  result = formatMiB(total - free) & " | " & formatMiB(total) & " MiB (" & mountPoint & ")"

proc getLoad*(): string =
  try:
    let fields = readFile("/proc/loadavg").splitWhitespace
    if fields.len >= 3:
      result = fields[0] & " " & fields[1] & " " & fields[2]
  except CatchableError:
    result = ""
