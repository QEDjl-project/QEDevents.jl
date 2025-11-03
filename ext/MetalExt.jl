module MetalExt

using QEDevents
using QEDevents.TestUtils
using Metal

@inline function QEDevents.TestUtils.get_test_setup(backend::MetalBackend)
    return TestSetup(backend, (MtlVector,), (Float16, Float32))
end


end
