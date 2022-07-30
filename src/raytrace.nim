from nimBMP import saveBMP24
import vec3
import geometry
import scene
import material
import lightsource
import camera
import mesh
import std/random

randomize(1621)

const aspectRatio = 16.0 / 9.0
const width: Natural = 400
const height: Natural = (float(width) / aspectRatio).Natural

when isMainModule:
  let ground = initMesh(
    Sphere(center: vec3(0.0, -100.5, -1.0), radius: 100.0),
    lambertian(rgb(0.8, 0.8, 0.0))
  )

  let sphereCenter = initMesh(
    Sphere(center: vec3(0.0, 0.0, -1.0), radius: 0.5),
    lambertian(rgb(0.1, 0.2, 0.5))
  )

  let sphereLeft = initMesh(
    Sphere(center: vec3(-1.0, 0.0, -1.0), radius: 0.5),
    dielectric(1.5)
  )

  let sphereLeft2 = initMesh(
    Sphere(center: vec3(-1.0, 0.0, -1.0), radius: -0.45),
    dielectric(1.5)
  )

  let sphereRight = initMesh(
    Sphere(center: vec3(1.0, 0.0, -1.0), radius: 0.5),
    metal(rgb(0.8, 0.6, 0.2), fuzziness = 0.0)
  )

  let sc = Scene(
    camera: initCamera(
      lookFrom = vec3(-2, 2, 1),
      lookAt = vec3(0, 0, -1),
      up = vec3(0, 1, 0),
      vfov = 20,
      aspectRatio
    ),
    meshes: @[ground, sphereCenter, sphereLeft, sphereLeft2, sphereRight],
    lights: @[LightSource(pos: vec3(10, -10, 10), color: rgb(1.0, 1.0, 1.0))]
  )

  let pixels = sc.render(width, height, vec3(0, 0, -1), samples = 100)
  saveBMP24("out.bmp", pixels, width, height)
