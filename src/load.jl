using OrderedCollections
using DataStructures

# Load a directory of files


function load2(file::String)
    d = load(file)
    d["file_name"] = file
    return d
end


"""    
load_dir(dir; parameter=nothing, parameter_list=false, sort_parameter=true, parameter_type_func=x->x)

Load a directory of files. If parameter is specified, the files are sorted according to the parameter. If parameter_list is true, the files are grouped according to the parameter. If sort_parameter is true, the parameter is sorted. If parameter_type_func is specified, the parameter is converted using the function before sorting.
"""
function load_dir(dir; parameter=nothing, parameter_list=false, sort_parameter=true, parameter_type_func=x->x)
    files = readdir(dir)
    if parameter isa Vector
        return load_dir_vector(dir; parameter, parameter_list, sort_parameter, parameter_type_func)
        
    elseif parameter !== nothing
        return load_dir_parameter(dir; parameter, parameter_list, sort_parameter, parameter_type_func)

    else
        return Dict(file[1:end-5] => load2("$dir/$file") for file in files if file[end-4:end]==".jld2")

    end
end

"""
load_dir_vector(dir; parameter::Vector=[], parameter_list=false, sort_parameter=true, parameter_type_func=x->x)

Load a directory of files. The files are sorted according to the parameter. If parameter_list is true, the files are grouped according to the parameter. If sort_parameter is true, the parameter is sorted. If parameter_type_func is specified, the parameter is converted using the function before sorting.
"""
function load_dir_vector(dir; parameter::Vector=[], parameter_list=false, sort_parameter=true, parameter_type_func=x->x)
    files = readdir(dir)
    
    if  !(parameter_type_func isa Vector)
        parameter_type_func = [parameter_type_func for _ in 1:length(parameter)]
    end
    
    d = Dict()
    if parameter_list
        dd = DefaultDict(Vector)
        for file in files
            if length(file) > 5 && file[end-4:end]==".jld2"
                local data
                try
                    data = load2("$dir/$file")
                catch
                    @warn "Error loading $file"
                    continue
                end
                params = []
                for (parameter_type_func_, para) in zip(parameter_type_func, parameter)
                    if para in keys(data["params"])
                        push!(params, parameter_type_func_(data["params"][para]))
                    else
                        push!(params, NaN)
                    end
                end

                push!(dd[params], data)
            end
        end
        d = dd
    
    else
        for file in files
            if length(file) > 5 && file[end-4:end]==".jld2"
                local data
                try
                    data = load2("$dir/$file")
                    if !("params" in keys(data))
                        @warn "No params in $file"
                        continue
                    end
                catch
                    @warn "Error loading $file"
                    continue
                end
                params = []
                for (parameter_type_func_, para) in zip(parameter_type_func, parameter)
                    if para in keys(data["params"])
                        push!(params, parameter_type_func_(data["params"][para]))
                    else
                        push!(params, NaN)
                    end
                end
                #params = [parameter_type_func_(data["params"][para]) for (parameter_type_func_, para) in zip(parameter_type_func, parameter)]
                d[params] = data
            end
        end
    end
    
    parameter_set = [Set() for _ in 1:length(parameter)]
    for key in keys(d)
        for i in 1:length(parameter)
            parameter_set[i] = push!(parameter_set[i], key[i])
        end
    end
    
    if sort_parameter
        paramter_vec = Any[]
        for s in parameter_set
            s = collect(s)
            try
                sort!(s)
            catch
            end
            push!(paramter_vec, collect(s))
        end

        dn = OrderedDict{Any, Any}()
        # Iterate over all possible combinations of parameters and add them to the OrderedDict
        for param in Iterators.product(paramter_vec...)
            param = collect(param)
            if param in keys(d)
                dn[param] = d[param]
            end
        end
        d = dn
    else
        paramter_vec = [collect(s) for s in parameter_set]
    end

    dout = OrderedDict{Any, Any}()
    for (key, value) in d
        key = Parameters(key, String.(parameter))
        dout[key] = value
    end

    return paramter_vec, dout
end

function load_dir_parameter(dir; parameter=nothing, parameter_list=false, sort_parameter=true, parameter_type_func=x->x)
    files = readdir(dir)
    d = Dict{String, Any}()
    for file in files
        if file[end-4:end]==".jld2"
            try
                d[file[1:end-5]] = load2("$dir/$file")
            catch
                @warn "Error loading $file"
                continue
            end
        end
    end
    if parameter_list
        dd = DefaultDict(Vector)
        for (key, value) in d
            parameter_value = parameter_type_func(value["params"][parameter])
            push!(dd[parameter_value], value)
        end
        d = dd
    else
        d = Dict(parameter_type_func(value["params"][parameter]) => value for (file, value) in d)
    end
    params = collect(keys(d))

    if sort_parameter
        try
            sort!(params)
        catch
        end
        # Define an OrderedDict with the same order as params
        dn = OrderedDict{Any, Any}()
        for param in params
            println(param)
            dn[param] = d[param]
        end
        d = dn
    end
    return params, d
end