using SciMLTesting, FastBroadcast, Test

# ExplicitImports only sees an extension module once its trigger package is loaded, so
# load every weakdep here to bring FastBroadcastStaticExt and FastBroadcastThreadTeamsExt
# into the set of scanned submodules.
using Static, ThreadTeams

# ExplicitImports ignore-lists (per-check, keyed by check short name). Every entry is
# a non-public name of a dependency that FastBroadcast must use and that has no public
# alias, so it cannot be FIXed:
#   * Base.Broadcast `Broadcasted`/`materialize`/`materialize!`/`broadcasted`/
#     `AbstractArrayStyle`/`DefaultArrayStyle`/`check_broadcast_shape`/`combine_eltypes`
#     are the broadcast machinery FastBroadcast specializes on; none is public.
#   * Base `Fix1`/`RefValue`/`Slice`/`maybeview`/`Experimental`/`tail`/`front`/
#     `get_extension`/`@propagate_inbounds` and `Base.Experimental.register_error_hint`
#     are Base internals used by the `@..` lowering, the tuple recursion, the extension
#     lookup, and the load-time MethodError hint (none is `public`-declared on the
#     supported Julia versions).
#   * ArrayInterface `indices_do_not_alias`/`flatten_tuples` are non-public in ArrayInterface
#     (confirmed: not exported, not `public`-declared) with no public replacement.
#   * ThreadTeams `nchunks` is documented API (the number of chunks a loop gets right now,
#     used to split the last axis) but ThreadTeams declares nothing `public`.
#   * FastBroadcast's own `fast_materialize`/`fast_materialize!`/`fast_materialize_threaded`/
#     `fast_materialize_threaded!`/`_view`/`_check_fast_materialize`/
#     `_fast_materialize_block!` are the internal hooks and kernels its extensions exist
#     to add methods to and to run. An extension has no public spelling for the parent's
#     dispatch points, so these stay ignored rather than being promoted to public API.
const EI_KWARGS = (;
    all_explicit_imports_are_public = (;
        ignore = (
            :Broadcasted, :DefaultArrayStyle, :materialize, :materialize!,
            :flatten_tuples, :indices_do_not_alias, :Fix1,
            :_view, :fast_materialize, :fast_materialize!,
            :_check_fast_materialize, :_fast_materialize_block!,
        ),
    ),
    all_qualified_accesses_are_public = (;
        ignore = (
            Symbol("@propagate_inbounds"),
            :AbstractArrayStyle, :Broadcasted, :DefaultArrayStyle,
            :Experimental, :RefValue, :Slice, :broadcasted,
            :check_broadcast_shape, :combine_eltypes, :front,
            :get_extension, :maybeview, :register_error_hint, :tail,
            :nchunks, :fast_materialize_threaded, :fast_materialize_threaded!,
        ),
    ),
)

# ExplicitImports silently skips an extension that fails to load, so assert the
# extension modules actually exist rather than trusting a green run_qa.
@testset "Extensions loaded" begin
    for ext in (:FastBroadcastStaticExt, :FastBroadcastThreadTeamsExt)
        @test Base.get_extension(FastBroadcast, ext) !== nothing
    end
end

@testset "Aqua + ExplicitImports" begin
    run_qa(
        FastBroadcast;
        explicit_imports = true,
        ei_kwargs = EI_KWARGS,
    )
end
