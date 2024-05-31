
Base.length(::Sampleable{SingleParticleVariate}) = 1
Base.size(::Sampleable{SingleParticleVariate}) = ()
Base.eltype(::Type{<:Sampleable{SingleParticleVariate,Continuous}}) = SFourMomentum
