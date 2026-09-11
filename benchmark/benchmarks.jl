using FastBroadcast, BenchmarkTools
using StableRNGs, Polyester

const SUITE = BenchmarkGroup()
const rng = StableRNG(123)

x = rand(rng, 10_000)
y = rand(rng, 10_000)
out = similar(x)

# =============================================================================
# @.. broadcasted assignments
# =============================================================================

fb_simple!(out, x, y) = (@.. out = x + y; out)
fb_complex!(out, x, y) = (@.. out = x * y + sin(x); out)
fb_threaded!(out, x, y) = (@.. thread = true out = x * y + sin(x); out)
fb_serial!(out, x, y) = (@.. broadcast = false out = x * y + sin(x); out)
fb_acc!(out, x, y) = (@.. out += x * y; out)

SUITE["broadcast"] = BenchmarkGroup()

SUITE["broadcast"]["simple"] = @benchmarkable fb_simple!($out, $x, $y)
SUITE["broadcast"]["complex"] = @benchmarkable fb_complex!($out, $x, $y)
SUITE["broadcast"]["threaded"] = @benchmarkable fb_threaded!($out, $x, $y)
SUITE["broadcast"]["serial_nobroadcast"] = @benchmarkable fb_serial!($out, $x, $y)
SUITE["broadcast"]["accumulate"] = @benchmarkable fb_acc!($out, $x, $y)

# =============================================================================
# Baseline (plain broadcast)
# =============================================================================

SUITE["baseline"] = BenchmarkGroup()

SUITE["baseline"]["plain"] = @benchmarkable $out .= $x .+ $y
SUITE["baseline"]["plain_complex"] = @benchmarkable $out .= $x .* $y .+ sin.($x)
