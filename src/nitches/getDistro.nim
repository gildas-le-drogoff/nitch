import
  ../funcs/osRelease

proc getDistro*(): string =
  result = getOsReleaseValue("PRETTY_NAME")
  if result == "":
    result = getOsReleaseValue("NAME")

  # old OpenWrt: DISTRIB_DESCRIPTION='OpenWrt Barrier Breaker 14.07'
  if result == "":
    result = getOpenwrtReleaseValue("DISTRIB_DESCRIPTION")
  if result == "":
    result = getOpenwrtReleaseValue("DISTRIB_ID")

  if result == "":
    result = "Linux"
