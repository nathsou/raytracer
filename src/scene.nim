import color
import geometry
import ray
import vec3
import camera
import material
import mesh
import std/[options, sugar, random, strformat, threadpool]
from std/math import sqrt, ceilDiv

type Scene* = ref object
  camera*: Camera
  meshes*: seq[Mesh]

func add*(scene: Scene, mesh: Mesh): void =
  scene.meshes.add(mesh)

proc castRay*(scene: Scene, ray: Ray, depth: Natural = 50): Color =
  if depth <= 0: return black

  var closestInter = Intersection(t: Inf)
  var closestIndex = -1

  for i, mesh in scene.meshes:
    let inter = mesh.geometry.intersect(ray)
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

proc renderInThread(scene: Scene, width, height: Natural, seed: int64,
    pixels: ptr seq[float], samples: Positive, id: Positive): void {.gcsafe.} =
  var prng = initRand(seed)
  let invWidth = 1.0 / float(width)
  let invHeight = 1.0 / float(height)
  var i = 0

  for x in 0..<width:
    for y in 0..<height:
      var averageColor = rgb(0.0, 0.0, 0.0)
      for _ in 0..<samples:
        let u = (float(x) + prng.rand(1.0)) * invWidth
        let v = (float(y) + prng.rand(1.0)) * invHeight
        let ray = scene.camera.rayAt(u, v)
        averageColor += scene.castRay(ray)

      pixels[i + 0] += averageColor.r
      pixels[i + 1] += averageColor.g
      pixels[i + 2] += averageColor.b
      i += 3

  when log: echo fmt"run {id} finished"

proc render*(scene: Scene, width, height: Natural, draw: (
    x: Natural, y: Natural, r: float, g: float, b: float) -> void,
        samples: Positive = 100, prng: var Rand,
            samplesPerThread: Positive = 1): void =
  let runs = samples.ceilDiv(samplesPerThread)
  let invTotalRuns = 1.0 / float(runs * samplesPerThread)
  var pixels = newSeq[float](width * height * 3)

  when log: echo fmt"Launching {runs} runs"

  for id in 1..runs:
    spawn scene.renderInThread(width, height, prng.rand(high(int64)),
        pixels.addr, samplesPerThread, id)

  sync()

  var i = 0

  for x in 0..<width:
    for y in 0..<height:
      # gamma correction
      let r = sqrt(pixels[i + 0] * invTotalRuns)
      let g = sqrt(pixels[i + 1] * invTotalRuns)
      let b = sqrt(pixels[i + 2] * invTotalRuns)

      draw(x, y, r, g, b)
      i += 3

