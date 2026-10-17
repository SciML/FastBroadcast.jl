module FastBroadcastThreadTeamsExt

using FastBroadcast: FastBroadcast, Serial, fast_materialize!, _view,
    _check_fast_materialize, _fast_materialize_block!
using Base.Broadcast: Broadcasted, DefaultArrayStyle, materialize
using ThreadTeams: ThreadTeams, TeamScheduler, tforeach, index_chunks

# The last axis of `dst` is split into one contiguous chunk per thread (fewer when the
# axis is short, one when called from inside another ThreadTeams loop or with a single
# thread). The chunks run on ThreadTeams' persistent worker team with the `TeamScheduler`:
# chunk 1 on the calling task, the others on the sticky worker tasks.
#
# On FastBroadcast's fast path (`DefaultArrayStyle`), a chunk is materialized by the serial
# kernel over the block's indices into the original arrays (`_fast_materialize_block!`).
# Other broadcast styles are materialized by `Base` on views of the chunk.
struct BlockBroadcast{D, A, B}
    dst::D
    ldstaxes::A
    bc::B
end
@inline function (cb::BlockBroadcast)(idx)
    r = @inbounds cb.ldstaxes[idx]
    _fast_materialize_block!(cb.dst, cb.bc, r)
    return nothing
end

struct ViewBroadcast{D, A, B, N}
    dst::D
    ldstaxes::A
    bc::B
    VN::Val{N}
end
@inline function (cb::ViewBroadcast)(idx)
    r = @inbounds cb.ldstaxes[idx]
    fast_materialize!(Serial(), _view(cb.dst, r, cb.VN), _view(cb.bc, r, cb.VN))
    return nothing
end

Base.@propagate_inbounds function FastBroadcast.fast_materialize_threaded(
        bc::Broadcasted{S}
    ) where {S}
    if S === DefaultArrayStyle{0}
        return only(bc)
    elseif S <: DefaultArrayStyle
        FastBroadcast.fast_materialize_threaded!(
            similar(bc, Base.Broadcast.combine_eltypes(bc.f, bc.args)),
            bc
        )
    else
        materialize(bc)
    end
end

function FastBroadcast.fast_materialize_threaded!(dst, bc::Broadcasted{S}) where {S}
    dstaxes = axes(dst)
    if S === DefaultArrayStyle{0} || length(dstaxes) == 0
        return fast_materialize!(Serial(), dst, bc)
    end
    last_dstaxes = dstaxes[end]
    n = ThreadTeams.nchunks(last_dstaxes, TeamScheduler())
    if S <: DefaultArrayStyle
        _check_fast_materialize(dst, bc)
        tforeach(
            BlockBroadcast(dst, last_dstaxes, bc), index_chunks(last_dstaxes; n);
            scheduler = TeamScheduler()
        )
    else
        tforeach(
            ViewBroadcast(dst, last_dstaxes, bc, Val(length(dstaxes))),
            index_chunks(last_dstaxes; n);
            scheduler = TeamScheduler()
        )
    end
    return dst
end

end
