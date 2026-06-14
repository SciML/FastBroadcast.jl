using PerformanceTestTools
using SafeTestsets
using SciMLTesting

run_tests(;
    core = function ()
        @safetestset "FastBroadcast" begin
            include(joinpath(@__DIR__, "core_tests.jl"))
        end
        @safetestset "DimensionMismatch" begin
            include(joinpath(@__DIR__, "dimensionmismatch_tests.jl"))
        end
        # vectorization_tests.jl must run in a child process started with
        # `--check-bounds=no` (PerformanceTestTools spawns one) so its
        # `@allocated == 0` assertions actually run; under Pkg.test's default
        # `--check-bounds=yes` the `check_bounds != 1` guard would skip them.
        return VERSION >= v"1.6" &&
            PerformanceTestTools.@include("vectorization_tests.jl")
    end,
    qa = (; env = joinpath(@__DIR__, "qa"), body = joinpath(@__DIR__, "qa", "qa.jl")),
    # Match the pre-conversion dispatcher: GROUP=All (the unset default) ran only
    # Core; QA was its own lane and never part of All.
    all = ["Core"],
)
