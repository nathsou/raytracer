from nimBMP import saveBMP24
import vec3
import geometry
import scene
import material
import color
import camera
import mesh
import std/random

const aspectRatio = 3.0 / 2.0
const width = 400
const height = (float(width) / aspectRatio).Natural
const samples = 100
const samplesPerThread = 1

proc randomScene(r: var Rand): seq[Mesh] =
  let ground = initMesh(
    initSphere(vec3(0, -1000, 0), 1000.0),
    initLambertian(rgb(0.5, 0.5, 0.5))
  )

  result = @[ground]

  for a in -11..<11:
    for b in -11..<11:
      let center = vec3(float(a) + 0.9 * r.rand(1.0), 0.2, float(b) + 0.9 *
          r.rand(1.0))
      if center.dist(vec3(4.0, 0.2, 0.0)) > 0.9:
        let mat = case rand(100)
          of 0..80: # diffuse
            let albedo = color.random(r).hadamard(color.random(r))
            initLambertian(albedo)
          of 81..95: # metal
            let albedo = color.random(r, 0.5, 1.0)
            let fuzz = rand(0.5)
            initMetal(albedo, fuzz)
          else: # glass
            initDielectric(1.5)

        result.add(initMesh(initSphere(center, 0.2), mat))

    result.add(initMesh(
      initSphere(vec3(0, 1, 0), 1.0),
      initDielectric(1.5)
    ))

    result.add(initMesh(
      initSphere(vec3(-4, 1, 0), 1.0),
      initLambertian(rgb(0.4, 0.2, 0.1))
    ))

    result.add(initMesh(
      initSphere(vec3(4, 1, 0), 1.0),
      initMetal(rgb(0.7, 0.6, 0.5), 0.0)
    ))

proc defaultScene2(r: var Rand): seq[Mesh] =
  result = newSeq[Mesh]()

  result.add initMesh(
    initSphere(vec3(0.0, -100.5, -1.0), 100.0),
    initLambertian(rgb(0.8, 0.8, 0.0))
  )

  result.add initMesh(
    initSphere(vec3(0.0, 0.0, -1.0), 0.5),
    initLambertian(rgb(0.1, 0.2, 0.5))
  )

  result.add initMesh(
    initSphere(vec3(-1.0, 0.0, -1.0), 0.5),
    initDielectric(1.5)
  )

  result.add initMesh(
    initSphere(vec3(-1.0, 0.0, -1.0), -0.45),
    initDielectric(1.5)
  )

  result.add initMesh(
    initSphere(vec3(1.0, 0.0, -1.0), 0.5),
    initMetal(rgb(0.8, 0.6, 0.2), fuzziness = 0.0)
  )

when isMainModule:
  var prng = initRand(11101998)
  let sc = Scene(
    camera: initCamera(
      lookFrom = vec3(13, 2, 3),
      lookAt = vec3(0, 0, 0),
      up = vec3(0, 1, 0),
      vfov = 20,
      aspectRatio
    ),
    meshes: randomScene(prng)
  )

  var pixels = newSeqUninitialized[byte](width * height * 3)
  let draw = proc (x, y: Natural, r, g, b: float): void =
    let i = ((height - y - 1) * width + x) * 3
    pixels[i + 0] = byte(r * 255)
    pixels[i + 1] = byte(g * 255)
    pixels[i + 2] = byte(b * 255)

  sc.render(width, height, draw, samples, prng, samplesPerThread)
  saveBMP24("out.bmp", pixels, width, height)
