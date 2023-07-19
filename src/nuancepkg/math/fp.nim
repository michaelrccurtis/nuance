import fenv
import math

proc fpe_term*(n: int): float =
    (float(n) * epsilon(float)) / (1.0 - float(n) * epsilon(float))

proc float_to_bits*(f: float): int64 =
    var bits: int64
    move_mem(unsafeAddr bits, unsafeAddr f, sizeof(float));
    return bits

proc bits_to_float*(bits: int64): float =
    var f: float
    move_mem(unsafeAddr f, unsafeAddr bits, sizeof(float));
    return f

proc next_float_down*(v: float): float =
    let fc = classify(v)
    if fc == fcNegInf: return v
    var val = v
    if fc == fcZero:
        val = -0.0
    var bits = float_to_bits(val)
    if val > 0:
        bits -= 1
    else:
        bits += 1
    return bits_to_float(bits)

proc next_float_up*(v: float): float =
    let fc = classify(v)
    if fc == fcInf: return v
    var val = v
    if fc == fcNegZero:
        val = 0.0
    var bits = float_to_bits(val)
    if val >= 0:
        bits += 1
    else:
        bits -= 1
    return bits_to_float(bits)
