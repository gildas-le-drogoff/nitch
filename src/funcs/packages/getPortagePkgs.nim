import
  std/[os, strutils]

proc getPortagePkgs*(): string =
  # every installed package is a /var/db/pkg/<category>/<package> directory
  var count = 0
  for catKind, category in walkDir("/var/db/pkg"):
    if catKind != pcDir:
      continue
    for pkgKind, pkg in walkDir(category, relative = true):
      if pkgKind == pcDir and not pkg.startsWith("-MERGING-"):
        inc count

  result = $count
