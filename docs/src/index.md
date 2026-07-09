# FastBroadcast.jl

FastBroadcast.jl exports [`@..`](@ref) that compiles broadcast expressions into
loops that are easier for the compiler to optimize.

```julia
using FastBroadcast

function fast_foo9(a, b, c, d, e, f, g, h, i)
    @.. a = b + 0.1 * (0.2c + 0.3d + 0.4e + 0.5f + 0.6g + 0.6h + 0.6i)
    nothing
end
```

It is important to note that FastBroadcast does not speed up "dynamic broadcast",
i.e. when the arguments are not equal-axised or scalars. For example, dynamic
broadcast happens when the expansion of singleton dimensions occurs.

## Threading

The macro [`@..`](@ref) accepts a keyword argument `thread` to control whether the
broadcast should use multithreading via
[Polyester.jl](https://github.com/JuliaSIMD/Polyester.jl) (disabled by default).
Start Julia with multiple threads to benefit from this, and load `Polyester` to
activate the threaded code path.

```julia
using FastBroadcast, Polyester

function foo_parallel!(dest, src)
    @.. thread = true dest = log(src)
end
```

The `thread` argument accepts `true`/`false` or the exported types
[`Serial`](@ref)`()`/[`Threaded`](@ref)`()`. When the threading choice is stored
in a type-parameterized struct (e.g. an algorithm configuration), using
`Serial()`/`Threaded()` enables compile-time dispatch and avoids invalidations
when Polyester is loaded.

See the [API](@ref) page for the full public interface.
