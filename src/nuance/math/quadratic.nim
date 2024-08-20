import math
import fenv
import efloat

proc quadratic_solvable*[S](a, b, c: S): bool =
    let discrim = b^2 - 4.0*a*c
    return discrim > 0

proc quadratic*[S](a, b, c: S): array[2, S] =
    let discrim = b^2 - 4.0*a*c
    let root_discrim = sqrt(discrim)

    let q = if b < 0:
        -0.5 * (b - root_discrim)
    else:
        -0.5 * (b + root_discrim)

    let
        x0 = q / a
        x1 = c / q

    if x0 > x1: return [x1, x0]
    return [x0, x1]


proc quadratic_solvable*(a, b, c: EFloat): bool =
    let discrim = b.v^2 - 4.0*a.v*c.v
    return discrim > 0

proc quadratic*(a, b, c: EFloat): array[2, EFloat] =
    let discrim = b.v^2 - 4.0*a.v*c.v
    let root_discrim = sqrt(discrim)

    let float_root_discrim = efloat(root_discrim, epsilon(float) * root_discrim)
    let q = if b.v < 0.0:
        -0.5 * (b - float_root_discrim)
    else:
        -0.5 * (b + float_root_discrim)

    let
        x0 = q / a
        x1 = c / q

    if x0.v > x1.v: return [x1, x0]
    return [x0, x1]
