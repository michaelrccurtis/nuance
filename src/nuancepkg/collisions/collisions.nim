import nuancepkg/la/shared_vector
import nuancepkg/la/point

type
    CollisionResult*[D: static[int], S: Scalar] = ref object of RootObj
        collides*: bool
        t_hit*: S

proc `$`*[D, S](col: CollisionResult[D, S]): string =
    if col.collides:
        result = "<Collision at:" & $col.t_hit & ">"
    else:
        result = "<No Collision>"
