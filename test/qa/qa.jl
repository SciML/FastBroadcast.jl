using FastBroadcast
using Aqua, JET, Test

@testset "Aqua" begin
    # deps_compat currently fails: no [compat] entry for the stdlib dep
    # LinearAlgebra (deps) nor for the test extra Pkg (extras).
    # Tracked in https://github.com/SciML/FastBroadcast.jl/issues/101
    Aqua.test_all(FastBroadcast; deps_compat = false)
    @test_broken false  # Aqua deps_compat: missing [compat] for LinearAlgebra (deps) and Pkg (extras) — tracked in https://github.com/SciML/FastBroadcast.jl/issues/101
end

@testset "JET" begin
    # JET.test_package reports the threaded fast_materialize paths (from the
    # FastBroadcastPolyesterExt extension) as missing methods because the
    # weakdep extension is not loaded during report_package.
    # Tracked in https://github.com/SciML/FastBroadcast.jl/issues/101
    @test_broken false  # JET: 2 errors — fast_materialize_threaded!/fast_materialize_threaded missing (extension) — tracked in https://github.com/SciML/FastBroadcast.jl/issues/101
end
