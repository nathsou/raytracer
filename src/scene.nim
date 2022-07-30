import lightsource
import geometry
import ray
import vec3
import camera
import mesh
import std/[options, random, strformat]
from std/math import sqrt

type Scene* = ref object
  camera*: Camera
  meshes*: seq[Mesh]
  lights*: seq[LightSource]

func add*(scene: Scene, mesh: Mesh): void =
  scene.meshes.add(mesh)

func add*(scene: Scene, light: LightSource): void =
  scene.lights.add(light)

proc castRay*(scene: Scene, ray: Ray, depth: Natural = 50): Color =
  if depth <= 0: return black

  var closestInter = Intersection(t: Inf)
  var closestIndex = -1

  for i, mesh in scene.meshes:
    let inter = mesh.geometry(ray)
    if inter.isSome:
      let ter = inter.unsafeGet
      if ter.t < closestInter.t and ter.t >= 0.001:
        closestInter = ter
        closestIndex = i

  if closestIndex == -1:
    # background
    let unitDir = ray.dir.normalize
    let t = 0.5 * (unitDir.y + 1.0)
    return (1.0 - t) * rgb(1.0, 1.0, 1.0) + t * rgb(0.5, 0.7, 1.0)

  let mesh = scene.meshes[closestIndex]
  let scatter = mesh.material.scatter(ray, closestInter)
  if scatter.isSome:
    let (scattered, attenuation) = scatter.unsafeGet
    return attenuation.hadamard(castRay(scene, scattered, depth - 1))

  black

const log = true

proc render*(scene: Scene, width, height: Natural, camera: Vec3,
    samples: Positive = 100): seq[byte] =
  result = newSeqUninitialized[byte](width * height * 3)
  var i = 0
  let invWidth = 1.0 / float(width)
  let invHeight = 1.0 / float(height)
  let invSamples = 1.0 / float(samples)

  for y in countdown(height - 1, 0):
    when log: echo fmt"{height - y} / {height}"
    for x in 0..<width:
      var averageColor = rgb(0.0, 0.0, 0.0)
      for _ in 0..<samples:
        let u = (float(x) + rand(1.0)) * invWidth
        let v = (float(y) + rand(1.0)) * invHeight
        let ray = scene.camera.rayAt(u, v)
        averageColor += scene.castRay(ray)

      # gamma correction
      result[i + 0] = byte(sqrt(averageColor.r * invSamples) * 255.0)
      result[i + 1] = byte(sqrt(averageColor.g * invSamples) * 255.0)
      result[i + 2] = byte(sqrt(averageColor.b * invSamples) * 255.0)
      i += 3
