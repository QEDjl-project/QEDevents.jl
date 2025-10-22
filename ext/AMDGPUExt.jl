module AMDGPUExt

using QEDevents
using QEDevents.TestUtils
using AMDGPU

@inline function QEDevents.TestUtils.get_test_setup(backend::ROCBackend)
    return TestSetup(backend, (ROCVector,), (Float32, Float64))
end

end
