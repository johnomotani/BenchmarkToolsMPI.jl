BenchmarkToolsMPI.jl is a very thin wrapper around BenchmarkTools.jl, which replaces a
couple of internal functions to make benchmarking compatible with MPI programs.

In particular, in places where BenchmarkTools.jl uses timing, BenchmarkToolsMPI.jl
broadcasts the timing from rank-0 to all processes, to ensure consistent execution (e.g.
number of samples) on all ranks.

Usage
-----

See documentation for BenchmarkTools.jl. The only difference is to replace `using
BenchmarkTools` with
```
using BenchmarkToolsMPI
```

When importing BenchmarkToolsMPI for the first time, you may get several warnings like
`WARNING: Method definition ... overwritten in module BenchmarkToolsMPI at ...`.
Hopefully these warnings do not indicate a real problem...
