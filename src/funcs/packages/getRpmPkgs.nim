import
  std/[strutils, osproc]

proc getRpmPkgs*(): string =
  # strip the trailing newline from wc, otherwise an empty line is printed
  result = osproc.execCmdEx("rpm -qa | wc --lines")[0].strip
