# Deprecated in favour of nuance scene files
#import nuance/la/all
#import nuance/shape/all
#import nuance/scene/scene
#import nuance/scene/primitive
#import nuance/materials/all
#import nuance/colour/all

#proc simple_scene*(): Scene[float] =

#  let
#      material_ground = Lambertian[float](albedo:Colour.make(0.8, 0.8, 0.0))
#      material_cyl = Lambertian[float](albedo:Colour.make(0.7, 0.3, 0.3))

#      sph1 = GeometricPrimitive.make(
#        Sphere.make(1.0, Translate(Vec3(0.0, 2.0, 0.0))),
#        Glass[float](index_of_refraction:1.5),
#      )

#      sph2 = GeometricPrimitive.make(
#        Sphere.make(1.0, Translate(Vec3(0.0, 0.0, 0.0))),
#        Metal[float](albedo:Colour.make(0.8, 0.8, 0.8)),
#      )

#      cyl = GeometricPrimitive.make(
#        Cylinder.make(1.5, -1.0, 0.5, Translate(Vec3(0.0, -2.0, 0.0))),
#        material_cyl
#      )

#      dsc = GeometricPrimitive.make(
#        Disc.make(1.5, 0.0, Translate(Vec3(0.0, -2.0, 0.5))),
#        material_cyl
#      )

#      mesh = TriangleMesh[float].init(
#        Translate(Vec3(0.0, 0.0, -1.0)),
#        [0, 1, 2, 0, 2, 3],
#        [Pt3(-20.0, -20.0, 0.0), Pt3(20.0, -20.0, 0.0), Pt3(20.0, 20.0, 0.0), Pt3(-20.0, 20.0, 0.0)]
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
#    sph1, sph2, dsc, cyl, tri0, tri1
#  ]))