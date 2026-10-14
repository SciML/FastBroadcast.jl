module FastBroadcastThreadTeamsExt

using FastBroadcast: FastBroadcast, Serial, fast_materialize!, _view
using Base.Broadcast: Broadcasted, materialize
using ThreadTeams: ThreadTeams, TeamScheduler, tforeach, index_chunks

# The last axis of `dst` is split into one contiguous chunk per thread (fewer when the
# axis is short, one when called from inside another ThreadTeams loop or with a single
# thread), and every chunk is materialized serially by `fast_materialize!(Serial(), ...)`
# on views. The chunks run on ThreadTeams' persistent worker team with the
# `TeamScheduler`: chunk 1 on the calling task, the others on the sticky worker tasks.
struct ChunkBroadcast{D, A, B, N}
    dst::D
    ldstaxes::A
    bc::B
    VN::Val{N}
end
@inline function (cb::ChunkBroadcast)(idx)
    r = @inbounds cb.ldstaxes[idx]
    fast_materialize!(Serial(), _view(cb.dst, r, cb.VN), _view(cb.bc, r, cb.VN))
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
    n = ThreadTeams.nchunks(last_dstaxes, TeamScheduler())
    tforeach(
        ChunkBroadcast(dst, last_dstaxes, bc, Val(length(dstaxes))),
        index_chunks(last_dstaxes; n);
        scheduler = TeamScheduler()
    )
    return dst
end

end
