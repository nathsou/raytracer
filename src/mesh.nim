import geometry
import material

type Mesh* = object
  geometry*: Geometry
  material*: Material

proc initMesh*(geometry: GeometryConcept, material: Material): Mesh =
  Mesh(geometry: geometry.toGeometry, material: material)
