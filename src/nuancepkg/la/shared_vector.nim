import math
import nuancepkg/math/efloat

type Scalar* = SomeNumber | EFloat


# Stringify
template stringify*(vector_type: untyped): untyped =

    proc `$`*[D, S](vec: vector_type[D, S]): string =
        result = "[ "
        for idx in 0 ..< D-1:
            result &= $(vec[idx]) & ", "
        result &= $(vec[D - 1]) & " ]"


# Component wise accessors / settors
template vector_accessors_and_setters*(vector_type: untyped): untyped =

    proc x*[D, S](vec: vector_type[D, S]): var S {.inline.} =
        vec.arr[0]
    proc `x=`*[D, S](vec: vector_type[D, S], value: S) {.inline.} =
        vec.arr[0] = value
    proc y*[D, S](vec: vector_type[D, S]): var S {.inline.} =
        vec.arr[1]
    proc `y=`*[D, S](vec: vector_type[D, S], value: S) {.inline.} =
        vec.arr[1] = value
    proc z*[D, S](vec: vector_type[D, S]): var S {.inline.} =
        vec.arr[2]
    proc `z=`*[D, S](vec: vector_type[D, S], value: S) {.inline.} =
        vec.arr[2] = value

    proc `[]`*[D, S](vec: vector_type[D, S]; idx: int): S {.inline.} =
        vec.arr[idx]
    proc `[]`*[D, S](vec: var vector_type[D, S]; idx: int): var S {.inline.} =
        vec.arr[idx]
    proc `[]=`*[D, S](vec: var vector_type[D, S]; idx: int; cpt: S): void {.inline.} =
        vec.arr[idx] = cpt

    proc `==`*[D, S](vec1, vec2: vector_type[D, S]): bool {.inline.} =
        for idx in 0 ..< D:
            if vec1.arr[idx] != vec2.arr[idx]:
                return false
        return true

    proc `~=`*[D, S](vec1, vec2: vector_type[D, S], tolerance: float = 1.0e-5): bool {.inline.} =
        for idx in 0 ..< D:
            if abs(vec1[idx] - vec2[idx]) >= tolerance:
                return false
        return true

    proc abs*[D, S](vec: vector_type[D, S]): vector_type[D, S] =
        result = vector_type[D, S]()
        for idx in 0 ..< D:
            result.arr[idx] = abs(vec.arr[idx])

# Component Wise Math Operators
template componentwise_op*(vector_type: untyped, op: untyped): untyped =

    proc op*[D, S](vec1, vec2: vector_type[D, S]): vector_type[D, S] {.inline.} =
        result = vector_type[D, S]()
        for idx in 0 ..< D:
            result.arr[idx] = op(vec1.arr[idx], vec2.arr[idx])

template componentwise_opeq*(vector_type: untyped, op, opeq: untyped): untyped =

    proc opeq*[D, S](vec1: var vector_type[D, S], vec2: vector_type[D, S]) {.inline.} =
        for idx in 0 ..< D:
            vec1.arr[idx] = op(vec1.arr[idx], vec2.arr[idx])

template negation*(vector_type: untyped): untyped =

    proc `-`*[D, S](vec: vector_type[D, S]): vector_type[D, S] {.inline.} =
        `*`(S(-1), vec)

# Scalar Math Operators
template scalar_op*(vector_type: untyped, op, opeq, opDo: untyped): untyped =

    proc opDo*[D, S](scalar: Scalar, vec: vector_type[D, S]): vector_type[D, S] {.inline.} =
        result = vector_type[D, S]()
        for idx in 0 ..< D:
            result.arr[idx] = op(vec.arr[idx], scalar)

    proc op*[D, S](scalar: Scalar, vec: vector_type[D, S]): vector_type[D, S] {.inline.} =
        opDo(scalar, vec)

    proc op*[D, S](vec: vector_type[D, S], scalar: Scalar): vector_type[D, S] {.inline.} =
        opDo(scalar, vec)

    proc op*[D, S](vec: vector_type[D, S], scalar: float): vector_type[D, S] {.inline.} =
        opDo(S(scalar), vec)

    proc op*[D, S](scalar: float, vec: vector_type[D, S]): vector_type[D, S] {.inline.} =
        opDo(S(scalar), vec)

    proc op*[D, S](vec: vector_type[D, S], scalar: int): vector_type[D, S] {.inline.} =
        opDo(S(scalar), vec)

    proc op*[D, S](scalar: int, vec: vector_type[D, S]): vector_type[D, S] {.inline.} =
        opDo(S(scalar), vec)

    proc opeq*[D, S](vec: var vector_type[D, S], scalar: Scalar) {.inline.} =
        for idx in 0 ..< D:
            vec.arr[idx] = op(vec.arr[idx], scalar)

template dot_product*(vector1_type: untyped, vector2_type: untyped): untyped =
    # Dot Product
    proc dot*[D, S](vec1: vector1_type[D, S], vec2: vector2_type[D, S]): S {.inline.} =
        # take first component for case of (e.g. efloat which needs initialising)
        result = vec1[0] * vec2[0]
        for idx in 1 ..< D:
            result += vec1[idx] * vec2[idx]
    proc `*.`*[D, S](vec1: vector1_type[D, S], vec2: vector2_type[D, S]): S {.inline.} =
        dot(vec1, vec2)
    proc absdot*[D, S](vec1: vector1_type[D, S], vec2: vector2_type[D, S]): S {.inline.} =
        abs(dot(vec1, vec2))

template length*(vector_type: untyped): untyped =
    # Length & Normalisation
    proc length*(vec: vector_type): auto = sqrt(dot(vec, vec))
    proc length_squared*(vec: vector_type): auto = dot(vec, vec)
    proc norm*(vec: vector_type): auto = vec / length(vec)


template cross_product*(vector_type: untyped): untyped =
    # Cross Product
    proc cross*[S](vec1, vec2: vector_type[3, S]): vector_type[3, S] =
        result = vector_type[3, S](arr: [
          vec1[1]*vec2[2] - vec1[2]*vec2[1],
          vec1[2]*vec2[0] - vec1[0]*vec2[2],
          vec1[0]*vec2[1] - vec1[1]*vec2[0],
        ])
    proc `*^`*[S](vec1, vec2: vector_type[3, S]): vector_type[3, S] =
        cross(vec1, vec2)

    proc coordinate_system*[S](vec1: vector_type[3, S]): array[3, vector_type[3, S]] =
        var vec2: vector_type[3, S]
        if abs(vec1.x) > abs(vec1.y):
            vec2 = vector_type[3, S](arr: [-vec1.z, 0.0, vec1.x]) / sqrt(vec1.x*vec1.x + vec1.z*vec1.z)
        else:
            vec2 = vector_type[3, S](arr: [0.0, vec1.z, -vec1.y]) / sqrt(vec1.y*vec1.y + vec1.z*vec1.z)
        let vec3 = vec1*^vec2
        return [vec1, vec2, vec3]


template permute*(vector_type: untyped): untyped =

    proc permute*[D, S](vec: vector_type[D, S], perm: array[D, int]): vector_type[D, S] =
        result = vector_type[D, S]()
        for idx in 0 ..< D:
            result[idx] = vec[perm[idx]]

    proc mut_permute*[S](vec: var vector_type[3, S], perm: array[3, int]) =
        var fullCycle = true

        for idx in 0 ..< 3:
            if idx == perm[idx]:
                fullCycle = false

        if fullCycle:
            if perm[0] == 1:
                swap(vec[0], vec[1])
                swap(vec[1], vec[2])
            else:
                swap(vec[0], vec[2])
                swap(vec[1], vec[2])
        else:
            for idx in 0 ..< 3:
                if perm[idx] > idx:
                    swap(vec[idx], vec[perm[idx]])


template max_and_min*(vector_type: untyped): untyped =

    proc min*[D, S](vec1, vec2: vector_type[D, S]): vector_type[D, S] {.inline.} =
        result = vector_type[D, S]()
        for idx in 0 ..< D:
            result[idx] = min(vec1[idx], vec2[idx])

    proc max*[D, S](vec1, vec2: vector_type[D, S]): vector_type[D, S] {.inline.} =
        result = vector_type[D, S]()
        for idx in 0 ..< D:
            result[idx] = max(vec1[idx], vec2[idx])
