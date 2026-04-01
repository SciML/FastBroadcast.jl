module FastBroadcastPolyesterExt

using FastBroadcast: FastBroadcast, Serial, fast_materialize!, _view
using Base.Broadcast: Broadcasted, materialize
using Polyester

@inline function _batch_broadcast_fn(tup, start, stop)
    (dest, ldstaxes, bcobj, VN) = tup
    r = @inbounds ldstaxes[start:stop]
    fast_materialize!(Serial(), _view(dest, r, VN), _view(bcobj, r, VN))
    return nothing
end

Base.@propagate_inbounds function FastBroadcast.fast_materialize_threaded(
        bc::Broadcasted{S}
    ) where {S}
    if S === Base.Broadcast.DefaultArrayStyle{0}
        return only(bc)
    elseif S <: Base.Broadcast.DefaultArrayStyle
        FastBroadcast.fast_materialize_threaded!(
            similar(bc, Base.Broadcast.combine_eltypes(bc.f, bc.args)),
            bc
        )
    else
        materialize(bc)
    end
end

function FastBroadcast.fast_materialize_threaded!(dst, bc::Broadcasted)
    dstaxes = axes(dst)
    last_dstaxes = dstaxes[end]
    Polyester.batch(
        _batch_broadcast_fn,
        (length(last_dstaxes), Threads.nthreads()),
        dst,
        last_dstaxes,
        bc,
        Val(length(dstaxes))
    )
    return dst
end

end
