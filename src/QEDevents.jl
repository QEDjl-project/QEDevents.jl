module QEDevents

export weight

export SingleParticleDistribution
export MultiParticleDistribution

import Random: AbstractRNG
import Distributions: rand, rand!, _rand!
using Distributions: Distributions

using QEDbase
using QEDcore

using DocStringExtensions

include("utils.jl")

include("interfaces/particle_distribution.jl")
include("interfaces/single_particle_distribution.jl")
include("interfaces/multi_particle_distribution.jl")
include("interfaces/process_distribution.jl")

include("patch_QEDbase.jl")

end
