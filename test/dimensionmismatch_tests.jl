using FastBroadcast
using Test

A = rand(4, 2)
v = rand(8)
@test_throws Base.DimensionMismatch @.. A = v
