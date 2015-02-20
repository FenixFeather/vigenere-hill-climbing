#!/usr/bin/env julia

function population_variance(text::String)
    text_dict = frequency_dict(text)
    total = sum(collect(values(text_dict)))
    return var([value/total * 100 for value in values(text_dict)])
end

function frequency_dict(text::String)
    text_dict = Dict{Char, Int64}()
    [text_dict[character] = get(text_dict, character, 1) + 1 for character in text]
    return text_dict
end

function vigenere_encode(text::String, key::String, decode::Bool=false)
    if key != ""
        text_array = [character - 'a' for character in text]
        key_array = vcat([[character - 'a' for character in key] for arr in 1:ceil(length(text_array)/length(key))]...)
        return join([char(character % 26 + 'a') for character in (decode ? (-) : (+))(text_array, key_array[1:length(text_array) ])], "")
    end
    return text
end

function average_variance(text::String, key::String, assumed_length=0)
    key_length = assumed_length == 0 ? length(key) : assumed_length
    return mean([population_variance(vigenere_encode(text, key)[ii:key_length:end]) for ii in 1:key_length])
end

function crack_key(text::String, key_length::Int64, places=Int64[])
    if isempty(places)
        places = [1 for ii in 1:key_length]
    end

    result = Char[]
    
    for key_index in 1:key_length
        slice = text[key_index:key_length:end]
        frequencies = frequency_dict(slice)
        rankings = sort(collect(keys(frequencies)), rev=true, by=key->frequencies[key])
        most_popular = rankings[places[key_index]]
        push!(result, (most_popular - 'e' + 52) % 26 + 'a')
    end
    return join(result, "")
end
        
