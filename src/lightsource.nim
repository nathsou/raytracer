import vec3

type Color* {.borrow: `.`.} = distinct Vec3

type LightSource* = object
  pos*: Vec3
  color*: Color

template rgb*(r, g, b: float): Color = Vec3(x: r, y: g, z: b).Color
const black* = rgb(0.0, 0.0, 0.0)
const white* = rgb(1.0, 1.0, 1.0)
template r*(c: Color): float = c.x
template g*(c: Color): float = c.y
template b*(c: Color): float = c.z

func `+`*(a, b: Color): Color {.borrow.}
proc `+=`*(a: var Color, b: Color): void {.borrow.}
func `*`*(c: Color, x: float): Color {.borrow.}
func `*`*(x: float, c: Color): Color {.borrow.}
func `hadamard`*(a: Color, b: Color): Color {.borrow.}

proc `/=`*(c: var Color, x: float): void =
  c.x /= x
  c.y /= x
  c.z /= x
