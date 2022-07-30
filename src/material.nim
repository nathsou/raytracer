import lightsource
import std/[sugar, options]
import ray
import vec3
import geometry
from std/math import sqrt, pow
from random import rand

type Ret = tuple[scattered: Ray, attenuation: Color]

type Material* = object
  scatter*: (Ray, Intersection) -> Option[Ret]

proc randomVec3InUnitSphere(): Vec3 =
  result = vec3.random()
  if (result.lengthSquared >= 1.0):
    return randomVec3InUnitSphere()

proc randomUnitVec3(): Vec3 = randomVec3InUnitSphere().normalize

func lambertian*(color: Color): Material =
  Material(
    scatter: proc (r: Ray, inter: Intersection): auto =
    let scatterDir = inter.normal + randomUnitVec3()
    some((
      scattered: Ray(origin: inter.p, dir: scatterDir),
      attenuation: color
    ))
  )

func metal*(color: Color, fuzziness: float = 0.0): Material =
  Material(
    scatter: proc (r: Ray, inter: Intersection): auto =
    var reflected = r.dir.normalize.reflect(inter.normal)
    if fuzziness > 0.0: reflected += fuzziness * randomVec3InUnitSphere()
    if reflected.dot(inter.normal) > 0:
      some((
        scattered: Ray(origin: inter.p, dir: reflected),
        attenuation: color
      ))
    else:
      none(Ret)
  )

func dielectric*(ir: float): Material =
  func squared(x: float): float {.inline.} = x * x
  func reflectance(cosine, refIndex: float): float =
    # Use Schlick's approximation for reflectance.
    let r0 = squared((1.0 - refIndex) / (1.0 + refIndex))
    r0 + (1.0 - r0) * (1.0 - cosine).pow(5.0)

  const attenuation = rgb(1.0, 1.0, 1.0)
  Material(
    scatter: proc (r: Ray, inter: Intersection): auto =
    let refractionRatio = if inter.frontFace: 1.0 / ir else: ir
    let unitDir = r.dir.normalize
    let cosTheta = min(-unitDir.dot(inter.normal), 1.0)
    let sinTheta = sqrt(1.0 - cosTheta * cosTheta)
    let cannotRefract = refractionRatio * sinTheta > 1.0
    let direction =
      if cannotRefract or (reflectance(cosTheta, refractionRatio) > rand(1.0)):
        unitDir.reflect(inter.normal)
      else:
        unitDir.refract(inter.normal, refractionRatio, cosTheta)

    some((
      scattered: Ray(origin: inter.p, dir: direction),
      attenuation: attenuation
    ))
  )
