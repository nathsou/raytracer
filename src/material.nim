import color
import std/options
import ray
import vec3
import geometry
from std/math import sqrt, pow
from random import rand

type
  Ret = tuple[scattered: Ray, attenuation: Color]
  MaterialKind* = enum mkLambertian, mkMetal, mkDielectric
  Material* = object
    case kind*: MaterialKind
    of mkLambertian:
      albedo*: Color
    of mkMetal:
      color*: Color
      fuzziness*: float
    of mkDielectric:
      indexOfRefraction*: float

func initLambertian*(albedo: Color): Material =
  Material(kind: mkLambertian, albedo: albedo)

func initMetal*(albedo: Color, fuzziness: float = 1.0): Material =
  Material(kind: mkMetal, color: albedo, fuzziness: fuzziness)

func initDielectric*(indexOfRefraction: float): Material =
  Material(kind: mkDielectric, indexOfRefraction: indexOfRefraction)

proc randomVec3InUnitSphere(): Vec3 =
  result = vec3.random()
  if (result.lengthSquared >= 1.0):
    return randomVec3InUnitSphere()

proc randomUnitVec3(): Vec3 = randomVec3InUnitSphere().normalize

proc scatterLambertian*(color: Color, r: Ray, inter: Intersection): Option[Ret] =
  let scatterDir = inter.normal + randomUnitVec3()
  some((
    scattered: Ray(origin: inter.p, dir: scatterDir),
    attenuation: color
  ))

proc scatterMetal*(color: Color, fuzziness: float, r: Ray,
    inter: Intersection): Option[Ret] =
  var reflected = r.dir.normalize.reflect(inter.normal)
  if fuzziness > 0.0: reflected += fuzziness * randomVec3InUnitSphere()
  if reflected.dot(inter.normal) > 0:
    some((
      scattered: Ray(origin: inter.p, dir: reflected),
      attenuation: color
    ))
  else:
    none(Ret)

proc scatterDielectric*(ir: float, r: Ray, inter: Intersection): Option[Ret] =
  func squared(x: float): float {.inline.} = x * x
  func reflectance(cosine, refIndex: float): float =
    # Use Schlick's approximation for reflectance.
    let r0 = squared((1.0 - refIndex) / (1.0 + refIndex))
    r0 + (1.0 - r0) * (1.0 - cosine).pow(5.0)

  const attenuation = rgb(1.0, 1.0, 1.0)
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

proc scatter*(mat: Material, ray: Ray, inter: Intersection): Option[Ret] =
  case mat.kind
    of mkLambertian: scatterLambertian(mat.albedo, ray, inter)
    of mkMetal: scatterMetal(mat.color, mat.fuzziness, ray, inter)
    of mkDielectric: scatterDielectric(mat.indexOfRefraction, ray, inter)
