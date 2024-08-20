import primitive

type Scene*[S] = ref object of RootObj
    primative_group*: PrimitiveGroup[S]
