import vec3
import ray
from math import degToRad, tan

type Camera* = ref object
  origin, horizontal, vertical, lowerLeftCorner: Vec3

func initCamera*(lookFrom, lookAt, up: Vec3, vfov, aspectRatio: float): Camera =
  let
    theta = vfov.degToRad
    h = tan(theta / 2.0)
    viewportHeight = h * 2.0
    viewportWidth = aspectRatio * viewportHeight
    w = (lookFrom - lookAt).normalize
    u = up.cross(w).normalize
    v = w.cross(u)
    origin = lookfrom
    horizontal = viewportWidth * u
    vertical = viewportHeight * v
    lowerLeftCorner = origin - horizontal / 2.0 - vertical / 2.0 - w
  Camera(
    origin: origin,
    horizontal: horizontal,
    vertical: vertical,
    lowerLeftCorner: lowerLeftCorner
  )

func rayAt*(camera: Camera, u, v: float): Ray =
  let dir = camera.lowerLeftCorner + u * camera.horizontal + v *
      camera.vertical - camera.origin
  Ray(origin: camera.origin, dir: dir)
