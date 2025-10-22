module QEDevents


function __init__()
    deprecated_symbols = join(["ParticleSampleable", "weight", "max_weight", "SingleParticleDistribution", "MultiParticleDistribution", "ScatteringProcessDistribution"], ", ", " and ")

    return @warn(
        """
        The following symbols will not be supported in future releases: $deprecated_symbols.
        They will be replaced by similar functionality using `RejectionSamplers.jl`.
        """
    )
end

# WARN: will be deprecated and removed soon
# --
export ParticleSampleable, weight, max_weight
export SingleParticleDistribution
export MultiParticleDistribution
export ScatteringProcessDistribution
#---

# single particle distributions
export MaxwellBoltzmannParticle, temperature

# Generator
export HardScatteringDistribution

import Random: AbstractRNG
import Distributions: rand, rand!, _rand!
using Distributions: Distributions

using QEDbase
using QEDcore
using RejectionSamplers

using DocStringExtensions

# patch Distributions.jl
include("patch_Distributions.jl")
export MaxwellBoltzmann

include("utils.jl")

include("deprecated.jl")

include("sampler/single_particle_dists/maxwell_boltzmann.jl")


include("testutils/TestUtils.jl")
end
