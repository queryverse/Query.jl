using TestItemRunner
using Documenter

include("test_core.jl")
include("test_dplyr-syntax.jl")
include("test_pipesyntax.jl")
include("test_macros.jl")

@run_package_tests

# Only run doctests on 64, all the output checks get messed up with
# Int32 otherwise. Also only run on Julia 1.12 and newer, because
# a lot of output printing was changed and doctests now can't be written
# to work on multiple Julia versions.
Int==Int64 && VERSION>=v"1.12" && doctest(Query)
