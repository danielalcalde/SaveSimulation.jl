module SaveSimulation

using Printf
using JLD2
using OrderedCollections
using DataStructures

include("parameters.jl")
include("load.jl")
include("prepare_save_folder.jl")

export print_non_zero, load_dir, get_save_file_path_and_createdir

function print_non_zero(array::AbstractArray)
    # Create a list to store indices
    indices = Vector{Int}(undef, ndims(array))
    print_recursive(array, indices, 1)
end

function print_recursive(array::AbstractArray, indices::Vector{Int}, dim::Int)
    for i in 1:size(array, dim)
        indices[dim] = i

        if dim == ndims(array)
            value = array[indices...]
            if abs(value) > 1e-5
                formatted_indices = join([" $idx" for idx in indices], ',')[2:end]
                if real(value) < 0
                    if abs(imag(value)) < 1e-5
                        @printf "[%s] => %.5f\n" formatted_indices real(value)
                    else
                        if imag(value) < 0
                            @printf "[%s] => %.5f -%.5fim\n" formatted_indices real(value) abs(imag(value))
                        else
                            @printf "[%s] => %.5f +%.5fim\n" formatted_indices real(value) imag(value)
                        end
                    end
                else
                    if abs(imag(value)) < 1e-5
                        @printf "[%s] =>  %.5f\n" formatted_indices real(value)
                    else
                        if imag(value) < 0
                            @printf "[%s] =>  %.5f -%.5fim\n" formatted_indices real(value) abs(imag(value))
                        else
                            @printf "[%s] =>  %.5f +%.5fim\n" formatted_indices real(value) imag(value)
                        end
                    end
                end
            end
        else
            print_recursive(array, indices, dim + 1)
        end
    end
end

"""
    unravel_index(index::Int, shape::Tuple})

Unravel an index into a tuple of indices.
Example:
    unravel_index(1, (2, 3)) = (1, 1)
    unravel_index(2, (2, 3)) = (2, 1)
    unravel_index(3, (2, 3)) = (1, 2)
    unravel_index(5, (2, 3)) = (1, 3)
"""
function unravel_index(index::Int, shape::Tuple)
    @assert index <= prod(shape)
    index -= 1
    indices = Vector{Int16}(undef, length(shape))
    for (i, si) in enumerate(shape)
        indices[i] = mod(index, si)
        index = Int((index - indices[i]) / si)
    end
    @assert index == 0 "$index"
    return indices .+ 1
end

function dict_to_string(a::Dict)
    result = ""
    for (i, (key, value)) in enumerate(a)
        if i != 1
            result *= "_"
        end
        result *= "$(key)=$(value)"
    end
    return result
end


end # module QOS
