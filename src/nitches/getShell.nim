import
  std/[strutils, os],
  ../funcs/passwd

proc getShell*(): string =
  var shell = getEnv("SHELL")

  # $SHELL may be unset on OpenWrt: use the login shell from /etc/passwd
  if shell == "":
    let entry = getPasswdEntry()
    if entry.len > 0:
      shell = entry[6]

  result = shell.split("/")[^1]

  if result == "":
    result = "sh"
