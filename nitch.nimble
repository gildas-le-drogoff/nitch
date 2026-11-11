# Package

version       = "0.3.0"
author        = "sfome"
description   = "System fetch in nim lang"
license       = "MIT"

srcDir        = "src"
bin           = @["nitch"]


# Dependencies

requires "nim >= 1.6.6"


# Tasks

# static ARMv7 (armhf) binary with a musl cross toolchain, e.g. from musl.cc:
#   nimble armv7                         -> ./nitch-armv7
#   CROSS=arm-linux-musleabihf nimble armv7
task armv7, "Build a static ARMv7 (armhf, musl) binary":
  let cross = getEnv("CROSS", "arm-linux-musleabihf")
  exec "nim c --cpu:arm --os:linux" &
    " --arm.linux.gcc.exe:" & cross & "-gcc" &
    " --arm.linux.gcc.linkerexe:" & cross & "-gcc" &
    " --passC:\"-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard\"" &
    " -d:static --passL:\"-static -s\"" &
    " -o:nitch-armv7 src/nitch.nim"

# static release binaries for amd64, arm64, armv7, mips and mipsel, in ./dist
# (+ SHA256SUMS). Needs `zig` (amd64, arm64, mips, mipsel) and the musl cross
# toolchain of the armv7 task (CROSS, default arm-linux-musleabihf):
#   nimble release
task release, "Build static release binaries in ./dist":
  let
    cross = getEnv("CROSS", "arm-linux-musleabihf") & "-gcc"
    zigcc = thisDir() & "/tools/zigcc.sh"
    # name, nim cpu, zig target ("" = use the armv7 cross toolchain), extra C flags
    targets = [
      ("amd64",  "amd64",  "x86_64-linux-musl",     ""),
      ("arm64",  "arm64",  "aarch64-linux-musl",    ""),
      ("armv7",  "arm",    "",                      "-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard"),
      ("mips",   "mips",   "mips-linux-musleabi",   "-mcpu=mips32r2"),  # OpenWrt ath79 (mips_24kc)
      ("mipsel", "mipsel", "mipsel-linux-musleabi", "-mcpu=mips32r2"),  # OpenWrt ramips (mipsel_24kc)
    ]
  rmDir "dist"
  mkDir "dist"
  for (name, cpu, zigTarget, passC) in targets:
    var cc = cross
    if zigTarget != "":
      putEnv("ZIG_TARGET", zigTarget)
      cc = zigcc
    echo "==> nitch-" & name
    # both --<cpu>.linux.gcc.exe (overrides nim's default cross compiler, e.g.
    # arm-linux-gnueabihf-gcc) and --gcc.exe (the only one used for the host cpu)
    exec "nim c --hints:off --cpu:" & cpu & " --os:linux" &
      " --gcc.exe:" & cc & " --gcc.linkerexe:" & cc &
      " --" & cpu & ".linux.gcc.exe:" & cc & " --" & cpu & ".linux.gcc.linkerexe:" & cc &
      (if passC != "": " --passC:\"" & passC & "\"" else: "") &
      " -d:static --passL:\"-static -s\"" &
      " --nimcache:dist/.nimcache/" & name &
      " -o:dist/nitch-" & name & " src/nitch.nim"
  rmDir "dist/.nimcache"
  exec "cd dist && sha256sum nitch-* > SHA256SUMS"
