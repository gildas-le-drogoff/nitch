import
  std/strutils

proc readMeminfo(): tuple[total, available: uint64] =
  # parse /proc/meminfo by key instead of by line number: kernels older than
  # 3.14 (old OpenWrt, 2.6.x / 3.x) have no "MemAvailable" line
  var
    memFree, buffers, cached, sReclaimable: uint64
    hasAvailable = false

  try:
    for line in lines("/proc/meminfo"):
      let fields = line.splitWhitespace
      if fields.len < 2:
        continue

      let value = try: fields[1].parseBiggestUInt.uint64 except ValueError: 0'u64
      case fields[0]:
      of "MemTotal:":     result.total = value
      of "MemAvailable:": result.available = value; hasAvailable = true
      of "MemFree:":      memFree = value
      of "Buffers:":      buffers = value
      of "Cached:":       cached = value
      of "SReclaimable:": sReclaimable = value
      else: discard
  except CatchableError:
    discard

  if not hasAvailable:
    result.available = memFree + buffers + cached + sReclaimable

  if result.available > result.total:
    result.available = result.total

proc formatRam(divisor: uint64, unit: string): string =
  let
    mem = readMeminfo()
    total = mem.total div divisor
    used = (mem.total - mem.available) div divisor

  result = $used & " | " & $total & " " & unit

proc getRam*(): string =
  result = formatRam(1024, "MiB")

proc getRam_MB*(): string =
  result = formatRam(1000, "MB")
