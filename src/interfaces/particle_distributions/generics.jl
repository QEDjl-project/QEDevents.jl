
# multiple samples
function Distributions.rand(
    rng::AbstractRNG, s::Sampleable{SingleParticleVariate}, dims::Dims
)
    out = Array{eltype(s)}(undef, dims)
    return @inbounds rand!(rng, sampler(s), out)
end

function Distributions._rand!(
    rng::AbstractRNG, d::SingleParticleDistribution, A::AbstractArray{<:SFourMomentum}
)
    @inbounds for i in eachindex(A)
        A[i] = Distributions.rand(rng, d)
    end
    return A
end
