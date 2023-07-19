import material
import nuancepkg/collisions/interaction
import nuancepkg/la/all
import nuancepkg/colour/all

{.warning[Deprecated]: off.}

type Glass*[S: Scalar] = ref object of Material[S]
    index_of_refraction*: float

method `$`*[S](mat: Glass[S]): string {.base.} =
    "<Glass>"

method scatter*[S](mat: Glass[S], ray: Ray[3, S], interaction: SurfaceInteraction[3, 2, S]) : MaterialScatterResult[S] =

    let
        outside = dot(ray.d, interaction.n) < 0.0
        refraction_ratio = (if outside : 1.0/mat.index_of_refraction else: mat.index_of_refraction)
        adjust_normal = (if outside: 1.0 else: -1.0)
        refracted_d = refract(norm(ray.d), to_vector(norm(adjust_normal*interaction.n)), refraction_ratio)

    return MaterialScatterResult[S](
        scattered: true,
        attenuation: White(),
        scattered_ray: Ray3(interaction.p, refracted_d)
    )