import
  std/[os, strutils]

proc getOsReleaseValue*(key: string): string =
  # read a KEY=value pair from os-release (shell-like format, values may be
  # unquoted, "double quoted" or 'single quoted')
  for path in ["/etc/os-release", "/usr/lib/os-release"]:
    if not path.fileExists:
      continue

    for line in lines(path):
      let sep = line.find('=')
      if sep < 1 or line[0 ..< sep].strip != key:
        continue

      result = line[sep + 1 .. ^1].strip
      if result.len >= 2 and result[0] in {'"', '\''} and result[^1] == result[0]:
        result = result[1 .. ^2]
      return

    return
