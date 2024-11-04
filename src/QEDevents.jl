module QEDevents

export ParticleSampleable, weight, max_weight

export SingleParticleDistribution
export MultiParticleDistribution
export ScatteringProcessDistribution

# single particle distributions
export MaxwellBoltzmannParticle, temperature

import Random: AbstractRNG
import Distributions: rand, rand!, _rand!
using Distributions: Distributions

using QEDbase
using QEDcore

using DocStringExtensions

# patch Distributions.jl
include("patch_Distributions.jl")
export MaxwellBoltzmann

include("utils.jl")

include("interfaces/particle_distribution.jl")
include("interfaces/single_particle_distribution.jl")
include("interfaces/multi_particle_distribution.jl")
include("interfaces/process_distribution.jl")

include("sampler/single_particle_dists/maxwell_boltzmann.jl")
end
