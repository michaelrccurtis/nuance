import nuancepkg/la/shared_vector
import nuancepkg/la/bounds
import nuancepkg/la/normal
import nuancepkg/la/vector
import nuancepkg/la/point
import nuancepkg/la/transform
import shape
import triangle_mesh

{.warning[Deprecated]: off.}

type
    Triangle*[S: Scalar] = ref object of Shape[S]
        mesh*: TriangleMesh[S]
        n_triangle: int

method `$`*[S](shape: Triangle[S]): string {.base.} =
    "<Triangle>"

proc v0*[S](tri: Triangle[S]): int = tri.mesh.vertexIndices[3 * tri.n_triangle]
proc v1*[S](tri: Triangle[S]): int = tri.mesh.vertexIndices[3 * tri.n_triangle + 1]
proc v2*[S](tri: Triangle[S]): int = tri.mesh.vertexIndices[3 * tri.n_triangle + 2]

proc p0*[S](tri: Triangle[S]): Point[3, S] = tri.mesh.positions[tri.v0]
proc p1*[S](tri: Triangle[S]): Point[3, S] = tri.mesh.positions[tri.v1]
proc p2*[S](tri: Triangle[S]): Point[3, S] = tri.mesh.positions[tri.v2]

proc n0*[S](tri: Triangle[S]): Normal[3, S] = tri.mesh.normals[tri.v0]
proc n1*[S](tri: Triangle[S]): Normal[3, S] = tri.mesh.normals[tri.v1]
proc n2*[S](tri: Triangle[S]): Normal[3, S] = tri.mesh.normals[tri.v2]

proc s0*[S](tri: Triangle[S]): Vector[3, S] = tri.mesh.tangents[tri.v0]
proc s1*[S](tri: Triangle[S]): Vector[3, S] = tri.mesh.tangents[tri.v1]
proc s2*[S](tri: Triangle[S]): Vector[3, S] = tri.mesh.tangents[tri.v2]

proc uv0*[S](tri: Triangle[S]): Point[2, S] =
    if tri.mesh.has_uv: tri.mesh.uv[tri.v0] else: Pt2(S(0), S(0))
proc uv1*[S](tri: Triangle[S]): Point[2, S] =
    if tri.mesh.has_uv: tri.mesh.uv[tri.v1] else: Pt2(S(1), S(0))
proc uv2*[S](tri: Triangle[S]): Point[2, S] =
    if tri.mesh.has_uv: tri.mesh.uv[tri.v2] else: Pt2(S(1), S(1))

method object_bounds*[S](tri: Triangle[S]): Bounds[3, S] =
    return new_bounds(tri.p0, tri.p1).union(tri.p2)

proc surface_area*[S](tri: Triangle[S]): S =
    length(S(0.5) * (tri.p1 - tri.p0) *^ (tri.p2 - tri.p0))

proc make*[S](
    T: type Triangle,
    object_to_world: Transform[4, 4, S],
    mesh: TriangleMesh,
    n_triangle: int
): Triangle[S] =
    Triangle[S](
      object_to_world: object_to_world,
      world_to_object: inverse(object_to_world),
      mesh: mesh,
      n_triangle: n_triangle
    )
