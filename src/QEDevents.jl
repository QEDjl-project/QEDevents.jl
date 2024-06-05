module QEDevents

export SingleParticleDistribution

import Random: AbstractRNG
import Distributions: rand, rand!, _rand!
using Distributions: Distributions

using QEDbase
using QEDprocesses

using DocStringExtensions

include("interfaces/particle_distribution.jl")
include("interfaces/single_particle_distribution.jl")

include("patch_QEDbase.jl")

end
