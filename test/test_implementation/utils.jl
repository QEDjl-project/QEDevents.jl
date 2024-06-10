"""
replace i-th entry of t with val
"""
function tuple_setindex(t::Tuple, i, val)
    return ntuple(j -> j == i ? val : t[j], length(t))
end
