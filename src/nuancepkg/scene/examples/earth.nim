# Deprecated in favour of nuance scene files
#import nuancepkg/la/all
#import nuancepkg/shape/all
#import nuancepkg/scene/scene
#import nuancepkg/scene/primitive
#import nuancepkg/materials/all
#import nuancepkg/texture/all
#import nuancepkg/colour/all
#import nimPNG

#proc earth*(): Scene[float] =
#  let png = loadPNG32("textures/earth.png")

#  let
#      globe = GeometricPrimitive[float](
#        shape: Sphere.make(1.0, Rotate(270.0, Vec3(0.0, 0.0, 1.0))),
#        material: Lambertian[float](
#          albedo:ImageTexture[float](image: Image.make(png)),
#        )
#      )

#      material_ground = Metal[float](albedo:ConstantTexture[float](colour:Colour.make(0.8, 0.8, 0.8)))

#      mesh = TriangleMesh[float].init(
#        Translate(Vec3(0.0, 0.0, -1.0)),
#        2, [0, 1, 2, 0, 2, 3],
#        4, [Pt3(-20.0, -20.0, 0.0), Pt3(20.0, -20.0, 0.0), Pt3(20.0, 20.0, 0.0), Pt3(-20.0, 20.0, 0.0)]
#      )

#      tri0 = GeometricPrimitive.make(
#        Triangle[float].init(
#          Translate(Vec3(0.0, 0.0, 0.0)),
#          inverse(Translate(Vec3(0.0, 0.0, 0.0))),
#          mesh, 0
#        ),
#        material_ground
#      )

#      tri1 = GeometricPrimitive.make(
#        Triangle[float].init(
#          Translate(Vec3(0.0, 0.0, 0.0)),
#          inverse(Translate(Vec3(0.0, 0.0, 0.0))),
#          mesh, 1
#        ),
#        material_ground
#      )


#  return Scene[float](primative_group:new_group(@[
#    globe,
#    tri0,
#    tri1
#  ]))