import
  std/os

proc getKissPkgs*(): string =
  var count = 0
  for kind, _ in walkDir("/var/db/kiss/installed"):
    if kind in {pcDir, pcLinkToDir}:
      inc count

  result = $count
