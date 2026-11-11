import
  std/[posix, strutils]

proc getPasswdEntry*(): seq[string] =
  # /etc/passwd line of the current uid, split on ':'
  #   name:password:uid:gid:gecos:home:shell
  # (getpwuid() is avoided on purpose: it needs NSS shared libs when glibc is
  # statically linked)
  let uid = $getuid()

  try:
    for line in lines("/etc/passwd"):
      let fields = line.split(':')
      if fields.len >= 7 and fields[2] == uid:
        return fields
  except CatchableError:
    discard
