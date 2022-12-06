using Statistics, LinearAlgebra, Random, Optim
using EnsembleKalmanProcesses
using EnsembleKalmanProcesses.Observations
using EnsembleKalmanProcesses.ParameterDistributions

include("./config.jl")
include("./generate_fake_pysdm_data.jl")
include("./test_reference_models.jl")
include("./test_KiD_utils.jl")
include("./test_reference_stats.jl")
include("./test_distribution_utils.jl")
include("./test_optimization_utils.jl")
include("./test_helper_funcs.jl")
include("./test_io_utils.jl")
