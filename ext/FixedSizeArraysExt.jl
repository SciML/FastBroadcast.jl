module FixedSizeArraysExt

using FastBroadcast: FastBroadcast
using FixedSizeArrays: FixedSizeArrays

FastBroadcast.use_fast_broadcast(::Type{<:FixedSizeArrays.FixedSizeArrayBroadcastStyle}) = true

end
