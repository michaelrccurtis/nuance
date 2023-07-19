import math
import fp

type
    EFloat*[S] = ref object of RootObj
        v*: S
        v_low*, v_high*: S

proc efloat*[S](v: S, err: S = S(0)): EFloat[S] =
    if err == S(0):
        return EFloat[S](v: v, v_low: v, v_high: v)
    return EFloat[S](v: v, v_low: next_float_down(v - err), v_high: next_float_up(v + err))

proc from_pair*[S](v: S, err: S = S(0)): EFloat[S] =
    return efloat[S](v, err)

proc `$`*[S](efloat: EFloat[S]): string =
    $efloat.v & " (" & $efloat.v_low & "<x<" & $efloat.v_high & ")"

proc to_float*[S](efloat: EFloat[S]): S =
    efloat.v

proc absolute_error*[S](efloat: EFloat[S]): S =
    efloat.v_high - efloat.v_low

proc `==`*[S](f1, f2: EFloat[S]): bool =
    f1.v == f2.v

proc `+`*[S](f1, f2: EFloat[S]): EFloat[S] =
    result = EFloat[S]()
    result.v = f1.v + f2.v;
    result.v_low = next_float_down(f1.v_low + f2.v_low)
    result.v_high = next_float_down(f1.v_high + f2.v_high)
proc `+`*[S](f1: EFloat[S], f2: S): EFloat[S] =
    f1 + efloat(f2)
proc `+`*[S](f1: S, f2: EFloat[S]): EFloat[S] =
    efloat(f1) + f2
proc `+=`*[S](f1: var EFloat[S], f2: EFloat[S]) =
    f1.v = f1.v + f2.v;
    f1.v_low = next_float_down(f1.v_low + f2.v_low)
    f1.v_high = next_float_down(f1.v_high + f2.v_high)
proc `+=`*[S](f1: var EFloat[S], f2: S) =
    f1 += efloat(f2)

proc `-`*[S](f1, f2: EFloat[S]): EFloat[S] =
    result = EFloat[S]()
    result.v = f1.v - f2.v;
    result.v_low = next_float_down(f1.v_low - f2.v_low)
    result.v_high = next_float_down(f1.v_high - f2.v_high)
proc `-`*[S](f1: EFloat[S], f2: S): EFloat[S] =
    f1 - efloat(f2)
proc `-`*[S](f1: S, f2: EFloat[S]): EFloat[S] =
    efloat(f1) - f2

proc `*`*[S](f1, f2: EFloat[S]): EFloat[S] =
    result = EFloat[S]()
    result.v = f1.v * f2.v;

    let perms = [
      f1.v_low * f2.v_low, f1.v_high * f2.v_low,
      f1.v_low * f2.v_high, f1.v_high * f2.v_high
    ]
    result.v_low = next_float_down(min(perms))
    result.v_high = next_float_down(max(perms))
proc `*`*[S](f1: EFloat[S], f2: S): EFloat[S] =
    f1 * efloat(f2)
proc `*`*[S](f1: S, f2: EFloat[S]): EFloat[S] =
    efloat(f1) * f2
proc `*`*[S](f1: EFloat[S], f2: int | float): EFloat[S] =
    f1 * efloat(S(f2))
proc `*`*[S](f1: int | float, f2: EFloat[S]): EFloat[S] =
    efloat(S(f1)) * f2

proc `/`*[S](f1, f2: EFloat[S]): EFloat[S] =
    result = EFloat[S]()
    result.v = f1.v / f2.v;

    if f2.v_low < 0 and f2.v_high > 0:
        result.v_low = -1.0 / 0.0
        result.v_high = 1.0 / 0.0
        return
    let perms = [
      f1.v_low / f2.v_low, f1.v_high / f2.v_low,
      f1.v_low / f2.v_high, f1.v_high / f2.v_high
    ]
    result.v_low = next_float_down(min(perms))
    result.v_high = next_float_down(max(perms))
proc `/`*[S](f1: EFloat[S], f2: S): EFloat[S] =
    f1 / efloat(f2)
proc `/`*[S](f1: S, f2: EFloat[S]): EFloat[S] =
    efloat(f1) / f2

proc `-`*[S](efloat: EFloat[S]): Efloat =
    result = EFloat[S]()
    result.v = -efloat.v
    result.v_low = -efloat.v_high
    result.v_high = -efloat.v_low

proc abs*[S](efloat: EFloat[S]): EFloat[S] =
    if efloat.v_low >= 0:
        # definitely above 0
        return efloat
    if efloat.v_high <= 0:
        # definitely below 0
        result = EFloat[S]()
        result.v = -efloat.v
        result.v_low = -efloat.v_high
        result.v_high = -efloat.v_low

    # straddles 0
    result = EFloat[S]()
    result.v = abs(efloat.v)
    result.v_low = 0
    result.v_high = max(-efloat.v_low, efloat.v_high)

proc sqrt*[S](efloat: EFloat[S]): EFloat[S] =
    result = EFloat[S]()
    result.v = sqrt(efloat.v)
    result.v_low = next_float_down(sqrt(efloat.v_low))
    result.v_high = next_float_up(sqrt(efloat.v_high))
