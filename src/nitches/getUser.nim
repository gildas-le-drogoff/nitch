import
  std/os,
  ../funcs/passwd

proc getUser*(): string =
  result = getEnv("USER")
  if result == "":
    result = getEnv("LOGNAME")

  # $USER is often unset on OpenWrt (serial console, procd services, ...)
  if result == "":
    let entry = getPasswdEntry()
    if entry.len > 0:
      result = entry[0]

  if result == "":
    result = "unknown"
