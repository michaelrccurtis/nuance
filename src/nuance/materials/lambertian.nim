import material
import nuance/collisions/interaction
import nuance/la/all
import nuance/colour/all
import nuance/texture/all
import fenv

{.warning[Deprecated]: off.}

type Lambertian*[S: Scalar] = ref object of Material[S]
    albedo*: Texture[S]

method `$`*[S](mat: Lambertian[S]): string {.base.} =
    "<Lambertian>"

method scatter*[S](mat: Lambertian[S], ray: Ray[3, S], interaction: SurfaceInteraction[3, 2, S]): MaterialScatterResult[S]  {.gcsafe.} =

    let
        rand = Vec3OnUnitSphere()
    var
        scattered_d = to_vector(interaction.n) + rand

    if max_cpt(scattered_d) < epsilon(float):
        scattered_d = to_vector(interaction.n)

    return MaterialScatterResult[S](
        scattered: true,
        attenuation: mat.albedo.interaction_colour(interaction),
        scattered_ray: Ray3(interaction.p, scattered_d)
    )
