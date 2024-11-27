function get_save_file_path_and_createdir(params; save_folder = "save_folder/", hashname=false, extension="jld2")
    
    # Create a directory to save the results
    mkpath(save_folder)
    name = dict_to_string(params)
    if hashname
        name = string(hash(name))
    end
    return "$save_folder/$(name).$extension"
end