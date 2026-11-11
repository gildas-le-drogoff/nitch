import
  osRelease

proc getDistroId*(): string =
  result = getOsReleaseValue("ID")
