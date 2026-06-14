using FastBroadcast
using Polyester  # loads FastBroadcastPolyesterExt
using SparseArrays
using PerformanceTestTools, Test
using SafeTestsets

const GROUP = get(ENV, "GROUP", "All")

function activate_downstream_env()
    Pkg.activate("downstream")
    Pkg.develop(PackageSpec(path = dirname(@__DIR__)))
    return Pkg.instantiate()
end

if GROUP == "All" || GROUP == "Core"
    @safetestset "FastBroadcast" begin
        include("core_tests.jl")
    end
    @safetestset "DimensionMismatch" begin
        include("dimensionmismatch_tests.jl")
    end
    VERSION >= v"1.6" && PerformanceTestTools.@include("vectorization_tests.jl")
end

if GROUP == "Downstream"
    activate_downstream_env()
end

if GROUP == "QA"
    include(joinpath(@__DIR__, "qa", "qa.jl"))
end
