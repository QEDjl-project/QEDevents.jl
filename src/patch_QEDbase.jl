struct UnknownDirection <: ParticleDirection end
is_incoming(::UnknownDirection) = false
is_outgoing(::UnknownDirection) = false
