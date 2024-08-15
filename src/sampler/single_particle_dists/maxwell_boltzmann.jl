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

function QEDevents._weight(
    d::MaxwellBoltzmannParticle{D,P,T}, ps::ParticleStateful
) where {D,P,T}
    mom = momentum(ps)

    mag = getMag(mom)
    E = getE(mom)
    m = mass(_particle(d))

    if abs(E^2 - m^2 - mag^2) <= 1e-5
        return Distributions.pdf(d.rho_dist, mag) / (4 * pi)
    else
        return zero(typeof(mag))
    end
end

function max_weight(d::MaxwellBoltzmannParticle{D,P,T}) where {D,P,T}
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
