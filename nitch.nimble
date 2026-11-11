# Package

version       = "0.2.2"
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
