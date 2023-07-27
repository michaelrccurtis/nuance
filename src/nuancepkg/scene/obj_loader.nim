import strutils
import nuancepkg/la/all
import nuancepkg/shape/all


proc parse_face_vertex(face: string): int =
    let processed = face.split("/")
    result = parse_int(processed[0]) - 1 # obj vertex lists start at 1


proc load_obj*(obj_file: string): auto =
    echo "loading: ", obj_file
    var
        vertices = newSeq[Point[3, float]]()
        faces = newSeq[array[3, int]]()

    for line in lines(obj_file):
        # Strip out comments and whitespace
        var l = line.strip()
        let comment_pos = find(l, "#")

        if comment_pos > -1:
            l = l[0 ..< comment_pos]

        let processed = l.split(" ")

        if processed[0] == "v":
            vertices.add(Pt3(parse_float(processed[1]), parse_float(processed[2]), parse_float(processed[3])))
        
        if processed[0] == "f":
            if len(processed) == 4:
                faces.add([parse_face_vertex(processed[1]), parse_face_vertex(processed[2]), parse_face_vertex(processed[3])])
            elif len(processed) == 5:
                faces.add([parse_face_vertex(processed[1]), parse_face_vertex(processed[2]), parse_face_vertex(processed[3])])
                faces.add([parse_face_vertex(processed[1]), parse_face_vertex(processed[3]), parse_face_vertex(processed[4])])
            else:
                echo "unexpected number of face vertices"

    var vertex_indices = newSeq[int]()

    for face in faces:
        for v in face:
            vertex_indices.add(v)

    let mesh = TriangleMesh[float].init(
        NoTransform[float](),
        vertex_indices,
        vertices
    )

    var triangles = newSeq[Triangle[float]](mesh.n_triangles)

    for tri in 0 ..< mesh.n_triangles:
        triangles[tri] = Triangle.make(NoTransform[float](), mesh, tri)

    return triangles