module BenchmarkToolsMPI
"""
Make BenchmarkTools MPI-aware

Overrides a few functions from BenchmarkTools to avoid hanging when running with MPI.
"""

using Reexport
@reexport using BenchmarkTools
using MPI

import BenchmarkTools
using BenchmarkTools: Benchmark, gcscrub, Parameters, RESOLUTION, Trial

function __init__()
    MPI.Init()
end

function BenchmarkTools._lineartrial(b::Benchmark, p::Parameters = b.params;
                                     maxevals = RESOLUTION, kwargs...)
    params = Parameters(p; kwargs...)
    estimates = zeros(maxevals)
    completed = 0
    params.gctrial && gcscrub()
    start_time = time()
    for evals in eachindex(estimates)
        params.gcsample && gcscrub()
        params.evals = evals
        estimates[evals] = first(b.samplefunc(params))
        completed += 1
        run_time = MPI.bcast(time() - start_time, 0, MPI.COMM_WORLD)
        (run_time > params.seconds) && break
    end
    return estimates[1:completed]
end

function BenchmarkTools._run(b::Benchmark, p::Parameters;
                             verbose = false, pad = "", kwargs...)
    params = Parameters(p; kwargs...)
    @assert params.seconds > 0.0 "time limit must be greater than 0.0"
    params.gctrial && gcscrub()
    start_time = Base.time()
    trial = Trial(params)
    params.gcsample && gcscrub()
    s = b.samplefunc(params)
    push!(trial, s[1:end-1]...)
    return_val = s[end]
    iters = 2
    run_time = start_time
    while (run_time - start_time) < params.seconds && iters ≤ params.samples
        params.gcsample && gcscrub()
        push!(trial, b.samplefunc(params)[1:end-1]...)
        iters += 1
        run_time = MPI.bcast(time() - start_time, 0, MPI.COMM_WORLD)
    end
    return trial, return_val
end

end # BenchmarkToolsMPI
