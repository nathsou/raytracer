import vec3
import std/[sugar, options]
import ray
from std/math import sqrt

type Intersection* = object
  p*, normal*: Vec3
  t*: float
  frontFace*: bool

type GeometryConcept* {.explain.} = concept g
  g.intersect(Ray) is Option[Intersection]

type Geometry* = Ray -> Option[Intersection]

template toGeometry*(g: GeometryConcept): Geometry =
  (r: Ray) => g.intersect(r)

type Sphere* = object
  center*: Vec3
  radius*: float

func intersect*(s: Sphere, r: Ray): Option[Intersection] =
  let
    so = r.origin - s.center
    a = r.dir.lengthSquared
    b = so.dot(r.dir)
    c = so.lengthSquared - s.radius * s.radius
    d = b * b - a * c
  if d <= 0:
    none(Intersection)
  else:
    let
      t = (-b - sqrt(d)) / a
      p = r.at(t)
      outwardNormal = (p - s.center) / s.radius
      frontFace = r.dir.dot(outwardNormal) < 0
      normal = if frontFace: outwardNormal else: -outwardNormal
    some(Intersection(p: p, t: t, normal: normal, frontFace: frontFace))
