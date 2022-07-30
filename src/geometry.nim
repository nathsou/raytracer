import vec3
import std/options
import ray
from std/math import sqrt

type
  Intersection* = object
    p*, normal*: Vec3
    t*: float
    frontFace*: bool
  GeometryKind* = enum gkSphere
  Geometry* = object
    case kind*: GeometryKind
    of gkSphere:
      center*: Vec3
      radius*: float

func intersectSphere*(center: Vec3, radius: float, ray: Ray): Option[Intersection] =
  let
    so = ray.origin - center
    a = ray.dir.lengthSquared
    b = so.dot(ray.dir)
    c = so.lengthSquared - radius * radius
    d = b * b - a * c
  if d <= 0:
    none(Intersection)
  else:
    let
      t = (-b - sqrt(d)) / a
      p = ray.at(t)
      outwardNormal = (p - center) / radius
      frontFace = ray.dir.dot(outwardNormal) < 0
      normal = if frontFace: outwardNormal else: -outwardNormal
    some(Intersection(p: p, t: t, normal: normal, frontFace: frontFace))

func initSphere*(center: Vec3, radius: float): Geometry =
  Geometry(kind: gkSphere, center: center, radius: radius)

func intersect*(geo: Geometry, ray: Ray): Option[Intersection] =
  case geo.kind
    of gkSphere: intersectSphere(geo.center, geo.radius, ray)
