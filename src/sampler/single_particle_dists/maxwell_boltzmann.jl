struct MaxwellBoltzmannDistribution{D,P,T,DIST} <: SingleParticleDistribution
    dir::D
    part::P
    temperature::T
    std_dev::T
    comp_dist::DIST

    function MaxwellBoltzmannDistribution(
        dir::D, particle::P, temperature::T
    ) where {D<:ParticleDirection,P<:AbstractParticleType,T<:Real}
        std_dev = sqrt(mass(particle) * temperature)
        comp_dist = Distributions.Normal(0.0, std_dev)
        return new{D,P,T,Distributions.Normal{T}}(
            dir, particle, temperature, std_dev, comp_dist
        )
    end
end

_particle(d::MaxwellBoltzmannDistribution) = d.part
_particle_direction(d::MaxwellBoltzmannDistribution) = d.dir
temperature(d::MaxwellBoltzmannDistribution) = d.temperature

function QEDevents._weight(d::MaxwellBoltzmannDistribution, ps::ParticleStateful)
    mom = momentum(ps)

    #if !isonshell(mom,mass(particle_species(ps)))
    #    return 0.0
    #end

    comp_dist = d.comp_dist
    # normalized on the maximum (=1/scale)
    scale = sqrt((2 * pi)^3) * d.std_dev^3
    return Distributions.pdf(comp_dist, getX(mom)) *
           Distributions.pdf(comp_dist, getY(mom)) *
           Distributions.pdf(comp_dist, getZ(mom)) *
           scale
end

function max_weight(d::MaxwellBoltzmannDistribution{D,P,T}) where {D,P,T}
    return one(T)
end

function _randmom(rng::AbstractRNG, d::MaxwellBoltzmannDistribution)
    px, py, pz = rand(rng, d.comp_dist, 3)
    E = sqrt(mass(d.part)^2 + px^2 + py^2 + pz^2)
    return SFourMomentum(E, px, py, pz)
end

# consider writing this function for all single particle dists generically,
# and implement _rand! accordingly. This could increase speed if a more
# performant implementation for several samples exists.
function _randmom(rng::AbstractRNG, d::MaxwellBoltzmannDistribution, n::Dims) end
