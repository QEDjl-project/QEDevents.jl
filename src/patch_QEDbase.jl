
@warn "This repository contains patches for QEDbase.jl\n It is NOT ready for release!"

struct UnknownDirection <: ParticleDirection end
Broadcast.broadcastable(d::UnknownDirection) = Ref(d)

is_incoming(::UnknownDirection) = false
is_outgoing(::UnknownDirection) = false
