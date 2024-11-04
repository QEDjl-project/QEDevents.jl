### Maxwell Boltzmann distribution
# https://en.wikipedia.org/wiki/Maxwell–Boltzmann_distribution

const SQRT_TWO_OVER_PI = sqrt(2 / pi)
const _CHI3 = Distributions.Chi(3; check_args=false)

"""
    MaxwellBoltzmann(scale::Real)


The *Maxwell-Boltzmann distribution* with scale parameter `a` has the probability density function

```math
f(x,a) = \\sqrt{\\frac{2}{\\pi}}\\frac{x^2}{a^3}\\exp\\left(\\frac{-x^2}{2a^2}\\right)
```

The Maxwell-Boltzmann distribution is related to the `Chi` distribution via the property
``X\\sim \\operatorname{MaxwellBoltzmann}(a=1)``, then ``X\\sim\\chi(\\mathrm{dof}=3)``.


External links

* [Maxwell-Boltzmann distribution on Wikipedia](https://en.wikipedia.org/wiki/Maxwell–Boltzmann_distribution)
* [Maxwell-Boltzmann distribution on Wolfram MathWorld](https://mathworld.wolfram.com/MaxwellDistribution.html)
* [Maxwell-Boltzmann distribution implementation in Scipy](https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.maxwell.html)
"""
struct MaxwellBoltzmann{T<:Real} <: Distributions.ContinuousUnivariateDistribution
    a::T # scale
    MaxwellBoltzmann{T}(a::T) where {T} = new{T}(a)
end

function MaxwellBoltzmann(a::T; check_args::Bool=true) where {T<:Real}
    Distributions.@check_args MaxwellBoltzmann (a, a > zero(a))
    return MaxwellBoltzmann{T}(a)
end

function MaxwellBoltzmann(a::Integer; check_args::Bool=true)
    return MaxwellBoltzmann(float(a); check_args=check_args)
end
MaxwellBoltzmann() = MaxwellBoltzmann(1.0)

Distributions.@distr_support MaxwellBoltzmann 0.0 Inf

### Conversions
convert(::Type{MaxwellBoltzmann{T}}, a::S) where {T<:Real,S<:Real} = MaxwellBoltzmann(T(a))
function Base.convert(::Type{MaxwellBoltzmann{T}}, d::MaxwellBoltzmann) where {T<:Real}
    return MaxwellBoltzmann(T(d.a))
end
Base.convert(::Type{MaxwellBoltzmann{T}}, d::MaxwellBoltzmann{T}) where {T<:Real} = d

### Parameters
Distributions.scale(d::MaxwellBoltzmann) = d.a
Distributions.params(d::MaxwellBoltzmann) = (d.a,)
Distributions.partype(d::MaxwellBoltzmann{T}) where {T} = T

### Statistics
Distributions.mean(d::MaxwellBoltzmann) = 2 * SQRT_TWO_OVER_PI * d.a
Distributions.median(d::MaxwellBoltzmann{T}) where {T<:Real} = d.a * T(1.5381722544550522) # a * sqrt(2 Q^(-1)(3/2, 1/2))
Distributions.mode(::MaxwellBoltzmann{T}) where {T<:Real} = sqrt(2) * d.a

Distributions.var(d::MaxwellBoltzmann) = d.θ^2 * (3 * pi - 8) / pi
function Distributions.skewness(::MaxwellBoltzmann{T}) where {T}
    return T(2 * sqrt(2) * (16 - 5 * pi) / (3 * pi - 8)^(3 / 2))
end
function Distributions.kurtosis(::MaxwellBoltzmann{T}) where {T}
    return T(4 * (-96 + 40 * pi - 3 * pi^2) / ((3 * pi - 8)^2))
end

function Distributions.entropy(d::MaxwellBoltzmann{T}) where {T}
    # 0.5772156649 is the Euler-Machgeroni constant
    return T(log(d.a * sqrt(2 * pi) + 0.5772156649 - 1 / 2))
end

#function kldivergence(p::MaxwellBoltzmann, q::MaxwellBoltzmann)
#   # TODO:Implement this!
#end

### pdf, cdf, ...
# derived from Chi(3)

for func in (
    :pdf,
    :logpdf,
    :cdf,
    :ccdf,
    :logcdf,
    :logccdf,
    :quantile,
    :cquantile,
    :invlogcdf,
    :invlogccdf,
)
    eval(
        quote
            function ($Distributions.$func)(d::MaxwellBoltzmann, x::Real)
                return (a = d.a; $Distributions.$func($_CHI3, x / a) / a)
            end
        end,
    )
end

### sampling
rand(rng::AbstractRNG, d::MaxwellBoltzmann) = rand(rng, _CHI3) * d.a
