import
  std/os

proc getDpkgPkgs*(): string =
  # count only really installed packages ("dpkg -l" also lists headers
  # and removed packages whose config files are still present)
  const statusFile = "/var/lib/dpkg/status"
  var count = 0

  if fileExists(statusFile):
    for line in lines(statusFile):
      if line == "Status: install ok installed":
        inc count

  result = $count
