from std/math import sqrt
import std/[sugar, random]

type Vec3* = object
  x*, y*, z*: float

func vec3*(x, y, z: float): Vec3 {.inline.} =
  Vec3(x: x, y: y, z: z)

func vec3*(x, y, z: int): Vec3 =
  Vec3(x: float(x), y: float(y), z: float(z))

type Num = float | int

template vec3*(n: Num): Vec3 = vec3(n, n, n)

const zero* = vec3(0, 0, 0)
const one* = vec3(1, 1, 1)

template map*(u: Vec3, f: float -> float): Vec3 =
  Vec3(x: f(u.x), y: f(u.y), z: f(u.z))

template map*(u, v: Vec3, f: (float, float) -> float): Vec3 =
  Vec3(x: f(u.x, v.x), y: f(u.y, v.y), z: f(u.z, v.z))

func toVec*(u: (Num, Num, Num)): Vec3 =
  let (x, y, z) = u
  vec3(x, y, z)

func `+`*(u, v: Vec3): Vec3 = map(u, v, `+`)

func `-`*(u, v: Vec3): Vec3 = map(u, v, `-`)

func `-`*(v: Vec3): Vec3 = v.map(`-`)

func `*`*(u: Vec3, k: float): Vec3 =
  Vec3(x: u.x * k, y: u.y * k, z: u.z * k)

func `*`*(k: float, u: Vec3): Vec3 = u * k

func `/`*(u: Vec3, k: float): Vec3 =
  Vec3(x: u.x / k, y: u.y / k, z: u.z / k)

func `'/'`*(k: float, u: Vec3): Vec3 = u / k

proc `+=`*(u: var Vec3, v: Vec3): void =
  u.x += v.x
  u.y += v.y
  u.z += v.z

proc `-=`*(u: var Vec3, v: Vec3): void =
  u.x -= v.x
  u.y -= v.y
  u.z -= v.z

proc `*=`*(u: var Vec3, v: Vec3): void =
  u.x *= v.x
  u.y *= v.y
  u.z *= v.z

proc `/=`*(u: var Vec3, v: Vec3): void =
  u.x /= v.x
  u.y /= v.y
  u.z /= v.z

func hadamard*(u, v: Vec3): Vec3 = map(u, v, `*`)

func dot*(u, v: Vec3): float =
  u.x * v.x + u.y * v.y + u.z * v.z

func length*(u: Vec3): float = sqrt(u.dot(u))

func lengthSquared*(u: Vec3): float = u.dot(u)

func dist*(u, v: Vec3): float = (u - v).length

func normalize*(u: Vec3): Vec3 = u / u.length

func reflect*(u, n: Vec3): Vec3 =
  (u - (2.0 * n * u.dot(n))).normalize

func refract*(dir, normal: Vec3, refractionRatio: float, cosTheta = min(
    -dir.dot(normal), 1.0)): Vec3 =
  let rOutPerp = refractionRatio * (dir + cosTheta * normal)
  let routParallel = -sqrt(abs(1.0 - rOutPerp.lengthSquared)) * normal
  rOutPerp + routParallel

func limit*(u: Vec3, maxX, maxY, maxZ: float): Vec3 =
  Vec3(x: min(u.x, maxX), y: min(u.y, maxY), z: min(u.z, maxZ))

func cross*(u, v: Vec3): Vec3 =
  vec3(
    u.y * v.z - u.z * v.y,
    u.z * v.x - u.x * v.z,
    u.x * v.y - u.y * v.x
  )

proc random*(max: float = 1.0): Vec3 =
  vec3(rand(max) * 2.0 - 1.0, rand(max) * 2.0 - 1.0, rand(max) * 2.0 - 1.0)
