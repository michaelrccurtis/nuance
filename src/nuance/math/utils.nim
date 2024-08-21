proc linear_interp*[S](t, f1, f2: S): S =
    return (1 - t) * f1 + t * f2
