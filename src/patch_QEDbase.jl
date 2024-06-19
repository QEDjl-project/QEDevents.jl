
@warn "This repository contains patches for QEDbase.jl\n It is NOT ready for release!"

# See https://github.com/QEDjl-project/QEDbase.jl/issues/69
struct UnknownDirection <: QEDbase.ParticleDirection end
Broadcast.broadcastable(d::UnknownDirection) = Ref(d)

is_incoming(::UnknownDirection) = false
is_outgoing(::UnknownDirection) = false
