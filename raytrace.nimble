# Package

version       = "0.1.0"
author        = "nathsou"
description   = "A simple raytracer"
license       = "MIT"
srcDir        = "src"
bin           = @["raytrace"]
backend       = "c"


# Dependencies

requires "nim >= 1.6.6"
requires "nimbmp >= 0.1.8"
