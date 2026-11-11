import
  std/[os, parsecfg, strutils]

proc readFirstLine(path: string): string =
  # empty or unreadable files must not crash nitch (EOFError)
  try:
    result = readFile(path).strip.splitLines()[0].strip
  except CatchableError, IndexDefect:
    result = ""

proc getHostname*(): string =
  const
    hostname = "/etc/hostname"
    hostnameOpenrc = "/etc/conf.d/hostname"
    hostnameKernel = "/proc/sys/kernel/hostname"

  if hostname.fileExists():
    result = readFirstLine(hostname)

  if result == "" and hostnameOpenrc.fileExists():
    try:
      result = hostnameOpenrc.loadConfig.getSectionValue("", "hostname")
    except CatchableError:
      result = ""

  if result == "" and hostnameKernel.fileExists():
    result = readFirstLine(hostnameKernel)
