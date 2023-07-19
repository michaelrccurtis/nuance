import math
import nuancepkg/math/efloat
import nuancepkg/math/fp
import nuancepkg/la/vector
import nuancepkg/la/point
import nuancepkg/la/normal
import nuancepkg/la/ray
import nuancepkg/shape/shape
import nuancepkg/shape/triangle
import interaction
import shape

{.warning[Deprecated]: off.}

method get_collisions*[S](tri: Triangle[S], ray: Ray[3, S]): ShapeCollisionResult[S] =
    var
        p0 = tri.p0 - to_vector(ray.o)
        p1 = tri.p1 - to_vector(ray.o)
        p2 = tri.p2 - to_vector(ray.o)
    let
        zp = max_dim(abs(ray.d))
        xp = (zp + 1) mod 3
        yp = (xp + 1) mod 3

    var d = permute(ray.d, [xp, yp, zp])
    mut_permute(p0, [xp, yp, zp])
    mut_permute(p1, [xp, yp, zp])
    mut_permute(p2, [xp, yp, zp])

    let
        shear_x = -d.x / d.z
        shear_y = -d.y / d.z
        shear_z = S(1) / d.z

    p0.x += shear_x * p0.z
    p0.y += shear_y * p0.z
    p1.x += shear_x * p1.z
    p1.y += shear_y * p1.z
    p2.x += shear_x * p2.z
    p2.y += shear_y * p2.z

    let
        e0 = p1.x * p2.y - p1.y * p2.x
        e1 = p2.x * p0.y - p2.y * p0.x
        e2 = p0.x * p1.y - p0.y * p1.x

    if (e0 == 0.0 or e1 == 0.0 or e2 == 0.0):
        echo "EQ 0"

    if (e0 < 0 or e1 < 0 or e2 < 0) and (e0 > 0 or e1 > 0 or e2 > 0):
        return ShapeCollisionResult[S](collides: false)

    let det = e0 + e1 + e2
    if det == 0:
        return ShapeCollisionResult[S](collides: false)

    p0.z *= shear_z
    p1.z *= shear_z
    p2.z *= shear_z

    let t_scaled = e0 * p0.z + e1 * p1.z + e2 * p2.z
    if det < 0 and (t_scaled >= 0 or t_scaled < ray.t_max * det):
        return ShapeCollisionResult[S](collides: false)
    if det > 0 and (t_scaled <= 0 or t_scaled > ray.t_max * det):
        return ShapeCollisionResult[S](collides: false)

    let
        inv_det = 1 / det
        b0 = e0 * inv_det
        b1 = e1 * inv_det
        b2 = e2 * inv_det
        t = t_scaled * inv_det

        max_zt = max([abs(p0.z), abs(p1.z), abs(p2.z)])
        delta_z = fpe_term(3) * max_zt

        max_xt = max([abs(p0.x), abs(p1.x), abs(p2.x)])
        max_yt = max([abs(p0.y), abs(p1.y), abs(p2.y)])

        delta_x = fpe_term(5) * (max_xt + max_zt)
        delta_y = fpe_term(5) * (max_yt + max_zt)
        delta_e = 2 * (fpe_term(2) * max_xt * max_yt + delta_y * max_xt + delta_x * max_yt)

        max_e = max([abs(e0), abs(e1), abs(e2)])
        delta_t = 3 * (fpe_term(3) * max_e * max_zt + delta_e * max_zt + delta_z * max_e) * abs(inv_det)

    if t <= delta_t:
        return ShapeCollisionResult[S](collides: false)

    var dpdu, dpdv: Vector[3, S]
    let
        duv02 = tri.uv0 - tri.uv2
        duv12 = tri.uv1 - tri.uv2
        dp02 = tri.p0 - tri.p2
        dp12 = tri.p1 - tri.p2
        determinant = duv02[0] * duv12[1] - duv02[1] * duv12[0]
        degenerate_uv = abs(determinant) < 1.0e-8

    if not degenerate_uv:
        let invdet = 1 / determinant
        dpdu = (duv12[1] * dp02 - duv02[1] * dp12) * invdet
        dpdv = (-duv12[0] * dp02 + duv02[0] * dp12) * invdet

    if degenerate_uv or (dpdu *^ dpdv).length_squared == 0:
        let ng = (tri.p2 - tri.p0) *^ (tri.p1 - tri.p0)
        if ng.length_squared == 0:
            return ShapeCollisionResult[S](collides: false)
        let coords = coordinate_system(norm(ng))
        dpdu = coords[1]
        dpdv = coords[2]

    let
        x_abs_sum = abs(b0 * p0.x) + abs(b1 * p1.x) + abs(b2 * p2.x)
        y_abs_sum = abs(b0 * p0.y) + abs(b1 * p1.y) + abs(b2 * p2.y)
        z_abs_sum = abs(b0 * p0.z) + abs(b1 * p1.z) + abs(b2 * p2.z)

        p_hit = b0 * tri.p0 + b1 * tri.p1 + b2 * tri.p2
        uv_hit = b0 * tri.uv0 + b1 * tri.uv1 + b2 * tri.uv2

    var p_error = Vec3(x_abs_sum, y_abs_sum, z_abs_sum)
    p_error *= fpe_term(7)

    var interaction = SurfaceInteraction[3, 2, S](
        p: p_hit, p_error: p_error, uv: uv_hit, wo: (-ray.d),
        dpdu: dpdu, dpdv: dpdv, dndu: ZerosNorm[3, S](), dndv: ZerosNorm[3, S](),
        time: ray.time, shape: tri
    )

    let n = to_normal_cast(norm(dp02 *^ dp12))
    interaction.n = n

    if tri.mesh.has_normals or tri.mesh.has_tangents:
        var ns: Normal[3, S]
        if tri.mesh.has_normals:
            ns = b0 * tri.n0 + b1 * tri.n1 + b2 * tri.n2
            if ns.length_squared > 0:
                ns = norm(ns)
            else:
                ns = interaction.n

        var ss: Vector[3, S]
        if tri.mesh.has_tangents:
            ss = b0 * tri.s0 + b1 * tri.s1 + b2 * tri.s2
            if ss.length_squared > 0:
                ss = norm(ss)
            else:
                ss = norm(interaction.dpdu)
        else:
            ss = norm(interaction.dpdu)

        var ts = ss *^ to_vector(ns)
        if ts.length_squared > S(0):
            ts = norm(ts)
            ss = ts *^ to_vector(ns)
        else:
            let coords = coordinate_system(to_vector(ns))
            ss = coords[1]
            ts = coords[2]

        var dndu, dndv: Normal[3, S]

        if tri.mesh.has_normals:
            let
                duv02 = tri.uv0 - tri.uv2
                duv12 = tri.uv1 - tri.uv2
                dn1 = tri.n0 - tri.n2
                dn2 = tri.n1 - tri.n2
                determinant = duv02[0] * duv12[1] - duv02[1] * duv12[0]
                degenerate_uv = abs(determinant) < 1.0e-8
            if degenerate_uv:
                let dn = to_vector(tri.n2 - tri.n0) *^ to_vector(tri.n1 - tri.n0)
                if dn.length_squared == 0:
                    dndu = ZerosNorm[3, S]()
                    dndv = ZerosNorm[3, S]()
                else:
                    let coords = coordinate_system(dn)
                    dndu = to_normal_cast(coords[1])
                    dndv = to_normal_cast(coords[2])
            else:
                let inv_det = S(1) / determinant
                dndu = (duv12[1] * dn1 - duv02[1] * dn2) * inv_det
                dndv = (-duv12[0] * dn1 + duv02[0] * dn2) * inv_det
        else:
            dndu = ZerosNorm[3, S]()
            dndv = ZerosNorm[3, S]()

    if tri.reverse_orientation xor tri.transform_swaps_handedness:
        interaction.n = -interaction.n
    return ShapeCollisionResult[S](
      collides: true, t_hit: t, interaction: interaction
    )


method collides*[S](tri: Triangle[S], ray: Ray[3, S]): bool =
    var
        p0 = tri.p0 - to_vector(ray.o)
        p1 = tri.p1 - to_vector(ray.o)
        p2 = tri.p2 - to_vector(ray.o)
    let
        zp = max_dim(abs(ray.d))
        xp = (zp + 1) mod 3
        yp = (xp + 1) mod 3
    var d = permute(ray.d, [xp, yp, zp])
    mut_permute(p0, [xp, yp, zp])
    mut_permute(p1, [xp, yp, zp])
    mut_permute(p2, [xp, yp, zp])

    let
        shear_x = -d.x / d.z
        shear_y = -d.y / d.z
        shear_z = S(1) / d.z

    p0.x = p0.x + shear_x * p0.z
    p0.y = p0.y + shear_y * p0.z
    p1.x = p1.x + shear_x * p1.z
    p1.y = p1.y + shear_y * p1.z
    p2.x = p2.x + shear_x * p2.z
    p2.y = p2.y + shear_y * p2.z

    let
        e0 = p1.x * p2.y - p1.y * p2.x
        e1 = p2.x * p0.y - p2.y * p0.x
        e2 = p0.x * p1.y - p0.y * p1.x

    if (e0 == 0.0 or e1 == 0.0 or e2 == 0.0):
        echo "EQ 0"

    if (e0 < 0 or e1 < 0 or e2 < 0) and (e0 > 0 or e1 > 0 or e2 > 0):
        return false

    let det = e0 + e1 + e2
    if det == 0:
        return false

    p0.z = p0.z * d.z
    p1.z = p1.z * d.z
    p2.z = p2.z * d.z

    let t_scaled = e0 * p0.z + e1 * p1.z + e2 * p2.z
    if det < 0 and (t_scaled >= 0 or t_scaled < ray.t_max * det):
        return false
    if det > 0 and (t_scaled <= 0 or t_scaled > ray.t_max * det):
        return false

    let
        inv_det = 1 / det
        b0 = e0 * inv_det
        b1 = e1 * inv_det
        b2 = e2 * inv_det
        t = t_scaled * inv_det

        max_zt = max([abs(p0.z), abs(p1.z), abs(p2.z)])
        delta_z = fpe_term(3) * max_zt

        max_xt = max([abs(p0.x), abs(p1.x), abs(p2.x)])
        max_yt = max([abs(p0.y), abs(p1.y), abs(p2.y)])
        delta_x = fpe_term(5) * (max_xt + max_zt)
        delta_y = fpe_term(5) * (max_yt + max_zt)
        delta_e = 2 * (fpe_term(2) * max_xt * max_yt + delta_y * max_xt + delta_x * max_yt)

        max_e = max([abs(e0), abs(e1), abs(e2)])
        delta_t = 3 * (fpe_term(3) * max_e * max_zt + delta_e * max_zt + delta_z * max_e) * abs(inv_det)
    if t <= delta_t:
        return false
    return true
