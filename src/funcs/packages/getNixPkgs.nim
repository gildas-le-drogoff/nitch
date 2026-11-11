import
  std/[os, strutils, osproc]

proc getNixPkgs*(): string =
  # count store paths required by the system and the user profile
  var count = 0
  for profile in ["/run/current-system/sw", getHomeDir() / ".nix-profile"]:
    if dirExists(profile):
      let (output, exitCode) = execCmdEx("nix-store --query --requisites " & quoteShell(profile))
      if exitCode == 0 and output.strip.len > 0:
        count += output.strip.countLines

  result = $count
