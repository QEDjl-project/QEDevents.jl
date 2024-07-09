module TestImpl

using QEDbase
using QEDcore
using QEDevents
using Distributions
import Random: AbstractRNG

include("groundtruths/single_particle.jl")
include("groundtruths/multi_particle.jl")
include("groundtruths/process.jl")

include("test_particles.jl")
include("test_model.jl")
include("test_process.jl")
include("single_particle_dist.jl")
include("multi_particle_dist.jl")
include("process_dist.jl")
include("utils.jl")

end
