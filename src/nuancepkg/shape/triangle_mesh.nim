import nuancepkg/la/shared_vector
import nuancepkg/la/normal
import nuancepkg/la/vector
import nuancepkg/la/point
import nuancepkg/la/transform

type
    TriangleMesh*[S: Scalar] = ref object
        n_triangles*: int
        n_vertices*: int
        vertex_indices*: seq[int]
        positions*: seq[Point[3, S]]

        has_normals*, has_tangents*, has_uv*: bool
        normals*: seq[Normal[3, S]]
        tangents*: seq[Vector[3, S]]
        uv*: seq[Point[2, S]]

proc `$`*[S](shape: TriangleMesh[S]): string =
    "<TriangleMesh>"
    
proc init*[S](T: typedesc[TriangleMesh[S]],
  object_to_world: Transform[4, 4, S],
  vertex_indices: openArray[int],
  positions: openArray[Point[3, S]],
  #Todo: support for normals, tangents, uv here
): auto =

    let
        n_triangles = int(len(vertex_indices) / 3)
        n_vertices = len(positions)

    var pos = newSeq[Point[3, S]](n_vertices)

    for idx in 0 ..< n_vertices:
        pos[idx] = object_to_world(positions[idx])

    result = T(
      n_triangles: n_triangles,
      n_vertices: n_vertices,
      vertex_indices: @(vertex_indices),
      positions: pos,
      has_normals: false,
      has_tangents: false,
      has_uv: false
    )