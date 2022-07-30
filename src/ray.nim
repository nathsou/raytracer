import vec3

type Ray* = object
    origin*, dir*: Vec3

func at*(ray: Ray, t: float): Vec3 {.inline.} =
    ray.origin + t * ray.dir
