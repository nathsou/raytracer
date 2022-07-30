import geometry
import material

type Mesh* = object
  geometry*: Geometry
  material*: Material

proc initMesh*(geometry: Geometry, material: Material): Mesh =
  Mesh(geometry: geometry, material: material)
