import
  std/[terminal, strutils],
  ../assets/logos

func getLogo*(distroId: string): (ForegroundColor, string) =
  # opensuse ids are "opensuse-tumbleweed", "opensuse-leap", ...
  if distroId.startsWith("opensuse"):
    return (fgGreen, opensuseLogo)

  # each distro maps directly to its (color, logo) pair
  case distroId:
  of "arch":        (fgBlue, archLogo)
  of "ubuntu":      (fgRed, ubuntuLogo)
  of "debian":      (fgRed, debianLogo)
  of "fedora":      (fgBlue, fedoraLogo)
  of "linuxmint":   (fgGreen, mintLogo)
  of "zorin":       (fgBlue, zorinLogo)
  of "pop":         (fgCyan, poposLogo)
  of "manjaro":     (fgGreen, manjaroLogo)
  of "slackware":   (fgBlue, slackwareLogo)
  of "centos":      (fgYellow, centosLogo)
  of "rhel":        (fgRed, redhatLogo)
  of "gentoo":      (fgMagenta, gentooLogo)
  of "endeavouros": (fgMagenta, endeavourosLogo)
  of "artix":       (fgBlue, artixLogo)
  of "arcolinux":   (fgBlue, arcoLogo)
  of "cachyos":     (fgCyan, cachyosLogo)
  of "kiss":        (fgMagenta, kissLogo)
  of "void":        (fgGreen, voidLogo)
  of "garuda":      (fgMagenta, garudaLogo)
  of "almalinux":   (fgYellow, almaLogo)
  of "rocky":       (fgGreen, rockyLogo)
  of "nixos":       (fgBlue, nixosLogo)
  of "bedrock":     (fgWhite, bedrockLogo)
  of "openwrt", "lede": (fgBlue, openwrtLogo)
  else:             (fgRed, nitchLogo)
