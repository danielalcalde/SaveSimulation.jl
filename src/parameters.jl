struct Parameters
    values::Vector{Any}
    keys::OrderedDict{String, Int}
    function Parameters(values::Vector, keys::Vector{String})
        @assert length(keys) == length(values)
        d = OrderedDict(key => i for (i, key) in enumerate(keys))
        return new(values, d)
    end
end
Base.getindex(p::Parameters, i::Int) = p.values[i]
Base.getindex(p::Parameters, i::String) = p.values[p.keys[i]]
Base.lastindex(p::Parameters) = lastindex(p.values)
function Base.show(io::IO, p::Parameters)
    print(io, "Parameters(")
    first = true
    for (key, idx) in p.keys
        if !first
            print(io, ", ")
        else
            first = false
        end
        print(io, key, " => ", p.values[idx])
    end
    print(io, ")")
end