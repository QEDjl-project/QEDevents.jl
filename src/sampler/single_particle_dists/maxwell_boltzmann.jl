"""
MaxwellBoltzmannParticle(
    dir::ParticleDirection,
    part::AbstractParticleType,
    temperature::Real
)

The Maxwell-Boltzmann particle distribution is a single-particle distribution, where the
spatial components of the four-momentum are normally distributed with localion ``\\mu = 0``
and variance ``\\sigma = m k_B T`` (``m`` is the particle's mass, ``k_B`` is the Boltzmann constant,
and ``T`` is the temperature). The three-magnitude ``\\varrho = \\sqrt{p_x^2 + p_y^2 + p_z^2}`` of the generated
particle-statefuls is [`MaxwellBoltzmann`](@ref) distributed.

External links

* [Maxwell-Boltzmann distributed four-momenta on Wikipedia](https://en.wikipedia.org/wiki/Maxwell–Boltzmann_distribution#Distribution_for_the_momentum_vector)

"""
struct MaxwellBoltzmannParticle{D,P,T,DIST} <: SingleParticleDistribution
    dir::D
    part::P
    temperature::T
    rho_dist::DIST

    function MaxwellBoltzmannParticle(
        dir::D, particle::P, temperature::T
    ) where {D<:ParticleDirection,P<:AbstractParticleType,T<:Real}
        a = sqrt(mass(particle) * temperature)
        return new{D,P,T,MaxwellBoltzmann{T}}(
            dir, particle, temperature, MaxwellBoltzmann(a)
        )
    end
end

_particle(d::MaxwellBoltzmannParticle) = d.part
_particle_direction(d::MaxwellBoltzmannParticle) = d.dir
temperature(d::MaxwellBoltzmannParticle) = d.temperature

"""

    _weight(
        d::MaxwellBoltzmannParticle{D,P,T}, ps::ParticleStateful{D,P}
    ) where {D,P,T}

Unsafe weight-function for [`MaxwellBoltzmannParticle`](@ref), which is given by

```math

w(p) = \\begin{cases}
\\frac{1}{4\\pi}\\sqrt{\\frac{2}{\\pi}}\\frac{\\varrho^2}{a^3}\\exp\\left(\\frac{-\\varrho^2}{2a^2}\\right)\\quad &\\text{,for } p^2=m^2\\\\
0 &\\mathrm{elsewhere}.
\\end{cases}

```

with ``\\varrho^2 = p_x^2 + p_y^2 + p_z^2`` and ``a = \\sqrt{m k_B T}`` (``m`` is the particle's mass, ``k_B`` is the Boltzmann constant,
and ``T`` is the temperature).
"""
function _weight(
    d::MaxwellBoltzmannParticle{D,P,T}, ps::ParticleStateful{D,P}
) where {D,P,T}
    mom = momentum(ps)

    mag = getMag(mom)
    E = getE(mom)
    m = mass(_particle(d))

    if abs(E^2 - m^2 - mag^2) <= 1e-5
        return Distributions.pdf(d.rho_dist, mag) / (4 * pi)
    else
        return zero(T)
    end
end

function max_weight(d::MaxwellBoltzmannParticle)
    return Distributions.pdf(d.rho_dist, sqrt(2) * d.rho_dist.a) / (4 * pi)
end

function QEDevents._randmom(rng::AbstractRNG, d::MaxwellBoltzmannParticle)
    rho = rand(rng, d.rho_dist)
    cth = rand(rng) * 2 - 1
    sth = sqrt(1 - cth^2)
    phi = rand(rng) * 2 * pi
    sphi, cphi = sincos(phi)

    E = sqrt(rho^2 + mass(d.part)^2)
    px = rho * sth * cphi
    py = rho * sth * sphi
    pz = rho * cth
    return SFourMomentum(E, px, py, pz)
end

# consider writing this function for all single particle dists generically,
# and implement _rand! accordingly. This could increase speed if a more
# performant implementation for several samples exists.
function _randmom(rng::AbstractRNG, d::MaxwellBoltzmannParticle, n::Dims) end
