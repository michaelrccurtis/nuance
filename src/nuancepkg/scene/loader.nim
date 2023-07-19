import toml_serialization
import std/tables
import primitive
import scene
import nuancepkg/la/all
import nuancepkg/shape/all
import nuancepkg/materials/all
import nuancepkg/texture/all
import nuancepkg/colour/all
import nimPNG


# Toml utilities
proc tom_array_tables(toml: TomlTableRef, field: string): seq[TomlTableRef] =
    if toml.hasKey(field):
        if toml[field].kind == TomlKind.Tables:
            return toml[field].tablesVal
    result = newSeq[TomlTableRef]()

proc tom_array_tables(toml: TomlValueRef, field: string): seq[TomlTableRef] =
    doassert toml.kind == TomlKind.Table
    if toml.tableVal.hasKey(field):
        if toml.tableVal[field].kind == TomlKind.Tables:
            return toml.tableVal[field].tablesVal
    result = newSeq[TomlTableRef]()

proc tom_table(toml: TomlTableRef, field: string): TomlTableRef =
    if toml.hasKey(field):
        if toml[field].kind == TomlKind.Table:
            return toml[field].tableVal

proc toml_vec3(toml: TomlValueRef): Vector[3, float] =
    let vec = toml.arrayVal
    result = Vec3(vec[0].floatVal, vec[1].floatVal, vec[2].floatVal)

proc toml_int_seq(toml: TomlValueRef): seq[int] =
    result = newSeq[int]()
    for val in toml.arrayVal:
        result.add(int(val.intVal))

proc toml_pt3_seq(toml: TomlValueRef): seq[Point[3, float]] =
    result = newSeq[Point[3, float]]()
    for toml_pt in toml.arrayVal:
        result.add(Pt3(
            toml_pt.arrayVal[0].floatVal,
            toml_pt.arrayVal[1].floatVal,
            toml_pt.arrayVal[2].floatVal
        ))


proc toml_colour(toml: TomlValueRef): Colour =
    let vec = toml.arrayVal
    result = Colour.make(vec[0].floatVal, vec[1].floatVal, vec[2].floatVal)


proc getOrDefault(toml: TomlTableRef, key: string, default: float): float =
    try:
        result = toml[key].floatVal
    except KeyError:
        result = default

type MeshesTable = Table[string, TriangleMesh[float]]

# Building the scene
proc build_transform(parsed_transform: TomlTableRef): Transform[4, 4, float] =
    let transform_type = parsed_transform["type"].stringVal
    if transform_type == "translate":
        return Translate(toml_vec3(parsed_transform["vector"]))
    elif transform_type == "rotate":
        return Rotate(parsed_transform["angle"].floatVal, toml_vec3(parsed_transform["axis"]))

    echo "Unimplemented transform type ", transform_type

    return NoTransform[float]()

proc build_transforms(parsed_transforms: seq[TomlTableRef]): Transform[4, 4, float] =
    result = NoTransform[float]()
    for transform in parsed_transforms:
        result = result * build_transform(transform)


proc build_shape(parsed: TomlTableRef, meshes: MeshesTable): Shape[float] =
    echo "building shape: ", parsed
    let shape_type = parsed["type"].stringVal

    if shape_type == "sphere":
        return Sphere.make(
            getOrDefault(parsed, "radius", 1.0),
            build_transforms(tom_array_tables(parsed, "transforms"))
        )

    if shape_type == "triangle":
        return Triangle.make(
            build_transforms(tom_array_tables(parsed, "transforms")),
            meshes[parsed["mesh"].stringVal],
            int(parsed["triangle_index"].intVal)
        )

    echo "Unimplemented shape type ", shape_type


proc build_texture(parsed: TomlTableRef): Texture[float] =
    let texture_type = parsed["type"].stringVal

    if texture_type == "image":
        let png = loadPNG32(parsed["image"].stringVal)
        return ImageTexture[float](image: Image.make(png))
    if texture_type == "constant":
        return ConstantTexture[float](colour: toml_colour(parsed["colour"]))

    return ConstantTexture[float](colour: Colour.make(0.0, 0.0, 0.0))

proc build_material(parsed: TomlTableRef): Material[float] =
    echo "bulding material: ", parsed
    let material_type = parsed["type"].stringVal

    if material_type == "glass":
        return Glass[float](index_of_refraction: parsed["index_of_refraction"].floatVal)
    elif material_type == "lambertian":
        return Lambertian[float](
          albedo: build_texture(parsed["albedo"].tableVal)
        )
    elif material_type == "metal":
        return Metal[float](
            albedo: build_texture(parsed["albedo"].tableVal)
        )

    return Lambertian[float](albedo: ConstantTexture[float](colour: Colour.make(0.0, 0.0, 0.0)))


proc build_pimitive(parsed: TomlTableRef, meshes: MeshesTable): GeometricPrimitive[float] =
    result = GeometricPrimitive[float](
        shape: build_shape(tom_table(parsed, "shape"), meshes),
        material: build_material(tom_table(parsed, "material"))
    )

proc build_mesh(parsed: TomlTableRef): TriangleMesh[float] =
    result = TriangleMesh[float].init(
        build_transforms(tom_array_tables(parsed, "transforms")),
        toml_int_seq(parsed["vertex_indices"]),
        toml_pt3_seq(parsed["positions"])
        )

proc build_scene(parsed: TomlValueRef): Scene[float] =

    var meshes = initTable[string, TriangleMesh[float]]()

    for mesh in tom_array_tables(parsed, "meshes"):
        meshes[mesh["name"].stringVal] = build_mesh(mesh)

    var primitives = newSeq[GeometricPrimitive[float]]()

    for parsed_primitive in tom_array_tables(parsed, "primitives"):
        primitives.add(build_pimitive(parsed_primitive, meshes))

    return Scene[float](
        primative_group: new_group(primitives)
    )


proc load_scene*(path: string): Scene[float] =
    try:
        let loaded_scene = Toml.loadFile(path, TomlValueRef)
        result = build_scene(loaded_scene)
    except TomlFieldReadingError as err:
        echo formatMsg(err, path)
