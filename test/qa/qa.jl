using FastBroadcast
using Aqua, ExplicitImports, JET, Test
using SciMLTesting: run_qa

# ExplicitImports ignore-lists (per-check, keyed by check short name). Every entry is
# a non-public name of a dependency that FastBroadcast must use and that has no public
# alias, so it cannot be FIXed:
#   * Base.Broadcast `Broadcasted`/`materialize`/`materialize!`/`broadcasted`/
#     `AbstractArrayStyle`/`DefaultArrayStyle`/`check_broadcast_shape`/`combine_eltypes`
#     are the broadcast machinery FastBroadcast specializes on; none is public.
#   * Base `RefValue`/`Slice`/`maybeview`/`Experimental` and `Base.Experimental.register_error_hint`
#     are Base internals used by the `@..` lowering and the load-time MethodError hint.
#   * ArrayInterface `indices_do_not_alias`/`flatten_tuples` are non-public in ArrayInterface
#     (confirmed: not exported, not `public`-declared) with no public replacement.
const EI_KWARGS = (;
    all_explicit_imports_are_public = (;
        ignore = (
            :Broadcasted, :materialize, :materialize!,
            :flatten_tuples, :indices_do_not_alias,
        ),
    ),
    all_qualified_accesses_are_public = (;
        ignore = (
            :AbstractArrayStyle, :Broadcasted, :DefaultArrayStyle,
            :Experimental, :RefValue, :Slice, :broadcasted,
            :check_broadcast_shape, :combine_eltypes, :maybeview,
            :register_error_hint,
        ),
    ),
)

@testset "Aqua + ExplicitImports" begin
    # deps_compat currently fails: no [compat] entry for the stdlib dep
    # LinearAlgebra (deps) nor for the test extra Pkg (extras).
    # Tracked in https://github.com/SciML/FastBroadcast.jl/issues/101
    run_qa(
        FastBroadcast;
        Aqua = Aqua,
        aqua_kwargs = (; deps_compat = false),
        ExplicitImports = ExplicitImports,
        explicit_imports = true,
        ei_kwargs = EI_KWARGS,
    )
    @test_broken false  # Aqua deps_compat: missing [compat] for LinearAlgebra (deps) and Pkg (extras) — tracked in https://github.com/SciML/FastBroadcast.jl/issues/101
end

@testset "JET" begin
    # JET.test_package reports the threaded fast_materialize paths (from the
    # FastBroadcastPolyesterExt extension) as missing methods because the
    # weakdep extension is not loaded during report_package.
    # Tracked in https://github.com/SciML/FastBroadcast.jl/issues/101
    @test_broken false  # JET: 2 errors — fast_materialize_threaded!/fast_materialize_threaded missing (extension) — tracked in https://github.com/SciML/FastBroadcast.jl/issues/101
end
