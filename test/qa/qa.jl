using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using FastBroadcast
using Aqua, JET, Test

@testset "Aqua" begin
    Aqua.test_all(FastBroadcast)
end

@testset "JET" begin
    JET.test_package(FastBroadcast; target_defined_modules = true)
end
