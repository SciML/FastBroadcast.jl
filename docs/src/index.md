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
[ThreadTeams.jl](https://github.com/vchuravy/ThreadTeams.jl) (disabled by default):
the last axis of the destination is split into one contiguous chunk per thread, and
the chunks run as an [OhMyThreads.jl](https://github.com/JuliaFolds2/OhMyThreads.jl)
`tforeach` on ThreadTeams' persistent worker team (`TeamScheduler`).
Start Julia with multiple threads to benefit from this, and load `ThreadTeams` to
activate the threaded code path.

```julia
using FastBroadcast, ThreadTeams

function foo_parallel!(dest, src)
    @.. thread = true dest = log(src)
end
```

The `thread` argument accepts `true`/`false` or the exported types
[`Serial`](@ref)`()`/[`Threaded`](@ref)`()`. When the threading choice is stored
in a type-parameterized struct (e.g. an algorithm configuration), using
`Serial()`/`Threaded()` enables compile-time dispatch and avoids invalidations
when ThreadTeams is loaded.

See the [API](@ref) page for the full public interface.
