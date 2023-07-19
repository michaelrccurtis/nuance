# import math
import shared_vector
import vector
import point
import normal

{.experimental: "callOperator".}

type Matrix*[R, C: static[int], S: Scalar] = ref object
    arr*: array[R, array[C, S]]

proc `$`*[R, C, S](mat: Matrix[R, C, S]): string =
    result = "[ "
    for row in 0 ..< R:
        for col in 0 ..< C:
            result &= $mat.arr[row][col] & " "
        if row < R-1:
            result &= "\n  "
    result &= "]"

proc `[]`*[R, C, S](mat: Matrix[R, C, S]; idx: int): array[C, S] {.inline.} =
    mat.arr[idx]
proc `[]`*[R, C, S](mat: var Matrix[R, C, S]; idx: int): var array[C, S] {.inline.} =
    mat.arr[idx]

proc `==`*[R, C, S](mat1, mat2: Matrix[R, C, S]): bool {.inline.} =
    for row in 0 ..< R:
        for col in 0 ..< C:
            if mat1[row][col] != mat2[row][col]:
                return false
    return true

proc `~=`*[R, C, S](mat1, mat2: Matrix[R, C, S], tolerance: float = 1.0e-5): bool =
    for row in 0 ..< R:
        for col in 0 ..< C:
            if abs(mat1[row][col] - mat2[row][col]) >= tolerance:
                return false
    return true

proc Identity*[R, C, S](): Matrix[R, C, S] =
    result = Matrix[R, C, S]()
    for row in 0 ..< R:
        for col in 0 ..< C:
            result[row][col] = if row == col: S(1) else: S(0)

proc transpose*[R, C, S](mat: Matrix[R, C, S]): Matrix[R, C, S] =
    result = Matrix[R, C, S]()
    for row in 0 ..< R:
        for col in 0 ..< C:
            result[row][col] = mat[col][row]

# absolute value, useful for calculating errors
proc abs*[R, C, S](mat: Matrix[R, C, S]): Matrix[R, C, S] =
    result = Matrix[R, C, S]()
    for row in 0 ..< R:
        for col in 0 ..< C:
            result[row][col] = abs(mat[row][col])

proc `*`*[I, J, K, S](mat1: Matrix[I, J, S], mat2: Matrix[J, K, S]): Matrix[I, K, S] =
    result = Matrix[I, K, S]()
    for i in 0 ..< I:
        for k in 0 ..< K:
            result[i][k] = 0
            for j in 0 ..< J:
                result[i][k] += mat1[i][j] * mat2[j][k]

template matrix_mat*(vectorType: untyped): untyped =
    proc `*`*[R, C, S](mat: Matrix[R, C, S], pt: vectorType[C, S]): vectorType[R, S] =
        result = vectorType[R, S]()
        for row in 0 ..< R:
            result[row] = 0
            for col in 0 ..< C:
                result[row] += mat[row][col] * pt[col]

proc inverse*[D, C, S](mat: Matrix[D, C, S]): Matrix[D, C, S] =
    var aug = Matrix[D, C*2, S]()

    # Create the augmented matrix
    # Identity matrix alongside original
    for i in 0 ..< D:
        for j in 0 ..< D:
            aug[i][j] = mat[i][j]
            if i == j:
                aug[i][j+D] = S(1)

    # Interchange rows of matrix, starting from last row
    for i in countdown(D-1, 1):
        if aug[i-1][0] < aug[i][0]:
            # Swap the rows
            for j in 0 ..< 2*D:
                let temp = aug[i][j]
                aug[i][j] = aug[i-1][j]
                aug[i-1][j] = temp

    # Replace row by sum of itself and multiple of other row
    for i in 0 ..< D:
        for j in 0 ..< D:
            if i != j:
                # factor to reducty aug[j][i] -> 0
                let temp = aug[j][i] / aug[i][i]
                # row op on row j
                for k in 0 ..< 2*D:
                    aug[j][k] -= aug[i][k] * temp

    # Divide row elt by diagonal element
    for i in 0 ..< D:
        let temp = aug[i][i]
        for j in 0 ..< 2*D:
            aug[i][j] /= temp

    result = Matrix[D, D, S]()
    for i in 0 ..< D:
        for j in 0 ..< D:
            result[i][j] = aug[i][j+D]


matrix_mat(Point)
matrix_mat(Vector)
matrix_mat(Normal)
