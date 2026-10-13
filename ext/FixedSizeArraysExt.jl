module FixedSizeArraysExt

using FastBroadcast: FastBroadcast
using FixedSizeArrays: FixedSizeArrays

# Zero-dimensional broadcasts are materialized to a scalar by Base
FastBroadcast.use_fast_broadcast(::Type{<:FixedSizeArrays.FixedSizeArrayBroadcastStyle}) = true
FastBroadcast.use_fast_broadcast(::Type{<:FixedSizeArrays.FixedSizeArrayBroadcastStyle{0}}) = false

end
