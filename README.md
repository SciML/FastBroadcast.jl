# FastBroadcast

[![Build Status](https://github.com/SciML/FastBroadcast.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/SciML/FastBroadcast.jl/actions?query=workflow%3ACI)
[![Coverage](https://codecov.io/gh/SciML/FastBroadcast.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/SciML/FastBroadcast.jl)

FastBroadcast.jl exports `@..` that compiles broadcast expressions into loops
that are easier for the compiler to optimize.

```julia
julia> using FastBroadcast

julia> function fast_foo9(a, b, c, d, e, f, g, h, i)
           @.. a = b + 0.1 * (0.2c + 0.3d + 0.4e + 0.5f + 0.6g + 0.6h + 0.6i)
           nothing
       end
fast_foo9 (generic function with 1 method)

julia> function foo9(a, b, c, d, e, f, g, h, i)
           @. a = b + 0.1 * (0.2c + 0.3d + 0.4e + 0.5f + 0.6g + 0.6h + 0.6i)
           nothing
       end
foo9 (generic function with 1 method)

julia> a, b, c, d, e, f, g, h, i = [rand(100, 100, 2) for i in 1:9];

julia> using BenchmarkTools

julia> @btime fast_foo9($a, $b, $c, $d, $e, $f, $g, $h, $i);
  19.902 μs (0 allocations: 0 bytes)

julia> @btime foo9($a, $b, $c, $d, $e, $f, $g, $h, $i);
  81.457 μs (0 allocations: 0 bytes)
```

It's important to note that FastBroadcast doesn't speed up "dynamic broadcast",
i.e. when the arguments are not equal-axised or scalars. For example, dynamic
broadcast happens when the expansion of singleton dimensions occurs:

```julia
julia> b = [1.0];

julia> @btime foo9($a, $b, $c, $d, $e, $f, $g, $h, $i);
  70.634 μs (0 allocations: 0 bytes)

julia> @btime fast_foo9($a, $b, $c, $d, $e, $f, $g, $h, $i);
  131.470 μs (0 allocations: 0 bytes)
```

## Threading

The macro `@..` accepts a keyword argument `thread` to control whether the
broadcast should use multithreading via [Polyester.jl](https://github.com/JuliaSIMD/Polyester.jl)
(disabled by default). Start Julia with multiple threads to benefit from this.

```julia
julia> using FastBroadcast, Polyester

julia> function foo_serial!(dest, src)
           @.. thread=false dest = log(src)
       end
foo_serial! (generic function with 1 method)

julia> function foo_parallel!(dest, src)
           @.. thread=true dest = log(src)
       end
foo_parallel! (generic function with 1 method)

julia> src = rand(10^4); dest = similar(src);

julia> @btime foo_serial!($dest, $src);
  50.860 μs (0 allocations: 0 bytes)

julia> @btime foo_parallel!($dest, $src);
  17.245 μs (1 allocation: 48 bytes)
```

The `thread` argument accepts `true`/`false` or the exported types
`Serial()`/`Threaded()`. When the threading choice is stored in a
type-parameterized struct (e.g. an algorithm configuration), using
`Serial()`/`Threaded()` enables compile-time dispatch and avoids
invalidations when Polyester is loaded:

```julia
julia> function foo_maybe_parallel!(dest, src, thread)
           @.. thread=thread dest = log(src)
       end
foo_maybe_parallel! (generic function with 1 method)

julia> @btime foo_maybe_parallel!($dest, $src, $(Serial()));
  51.682 μs (0 allocations: 0 bytes)

julia> @btime foo_maybe_parallel!($dest, $src, $(Threaded()));
  17.360 μs (1 allocation: 48 bytes)
```
