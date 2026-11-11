import
  ../funcs/osRelease

proc getDistro*(): string =
  result = getOsReleaseValue("PRETTY_NAME")
  if result == "":
    result = getOsReleaseValue("NAME")
  if result == "":
    result = "Linux"
