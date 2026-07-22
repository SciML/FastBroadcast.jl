using SciMLTesting, FastBroadcast, Test

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
const EI_KWARGS = (;
    all_explicit_imports_are_public = (;
        ignore = (
            :Broadcasted, :materialize, :materialize!,
            :flatten_tuples, :indices_do_not_alias, :Fix1,
        ),
    ),
    all_qualified_accesses_are_public = (;
        ignore = (
            Symbol("@propagate_inbounds"),
            :AbstractArrayStyle, :Broadcasted, :DefaultArrayStyle,
            :Experimental, :RefValue, :Slice, :broadcasted,
            :check_broadcast_shape, :combine_eltypes, :front,
            :get_extension, :maybeview, :register_error_hint, :tail,
        ),
    ),
)

@testset "Aqua + ExplicitImports" begin
    run_qa(
        FastBroadcast;
        explicit_imports = true,
        ei_kwargs = EI_KWARGS,
    )
end
