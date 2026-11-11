import
  std/terminal,
  ../assets/logos

func getLogo*(distroId: string): (ForegroundColor, string) =
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
  of "opensuse":    (fgGreen, opensuseLogo)
  of "slackware":   (fgBlue, slackwareLogo)
  of "centos":      (fgYellow, centosLogo)
  of "rhel":        (fgRed, redhatLogo)
  of "gentoo":      (fgMagenta, gentooLogo)
  of "endeavouros": (fgMagenta, endeavourosLogo)
  of "artix":       (fgBlue, artixLogo)
  of "arcolinux":   (fgBlue, arcoLogo)
  of "cachyos":     (fgCyan, cachyosLogo)
  else:             (fgRed, nitchLogo)
