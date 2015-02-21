#!/usr/bin/env julia

function main()
end

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
        return join([char((character + 26) % 26 + 'a') for character in (decode ? (-) : (+))(text_array, key_array[1:length(text_array) ])], "")
    end
    return text
end

function average_variance(text::String, key::String, assumed_length=0)
    key_length = assumed_length == 0 ? length(key) : assumed_length
    return mean([population_variance(vigenere_encode(text, key)[ii:key_length:end]) for ii in 1:key_length])
end

function guess_key(text::String, key_length::Int64, places=Int64[])
    if isempty(places)
        places = [1 for ii in 1:key_length]
    end
 
    result = Char[]
    
    for key_index in 1:key_length
        slice = text[key_index:key_length:end]
        frequencies = frequency_dict(slice)
        rankings = sort(collect(keys(frequencies)), rev=true, by=key->frequencies[key])
        ## println(length(places))
        ## println(key_index)
        ## println(rankings)
        ## println(places[key_index])
        most_popular = rankings[min(length(rankings), places[key_index])]
        push!(result, (most_popular - 'e' + 52) % 26 + 'a')
    end
    return join(result, "")
end

function display_cracked_texts(ciphertext::String, vkeys::Array{String})
    for key in vkeys
        println(vigenere_encode(ciphertext, key, true))
    end
end

function crack_key(ciphertext::String, max_key_length::Int64, epsilon::Float64, epochs::Int64, cycles::Int64, decay::Float64)
    key_length = find_key_length(ciphertext, 1:max_key_length)
    learned_places = learn_key(ciphertext, key_length, epsilon, epochs, cycles, decay)
    vkeys = String[]
    for learned_place in learned_places
        current_key = guess_key(ciphertext, key_length, learned_place)
        push!(vkeys, current_key)
        println("$current_key | $(frequency_difference(frequency_dict(vigenere_encode(ciphertext, current_key, true))))")
    end
    return vkeys
end

function find_key_length(ciphertext::String, key_range::UnitRange{Int64})
    variances = [average_variance(ciphertext, "", key_length) for key_length in key_range]
    key_length = findfirst(variances, maximum(variances))
    println("Found key length: $key_length")
    return key_length
end

function learn_key(ciphertext::String, key_length::Int64, epsilon::Float64, epochs::Int64, cycles::Int64, decay::Float64)
    vkeys = Set()
    
    for epoch in 1:epochs
        println("Epoch $epoch\n=======")
        places = [1 for ii in 1:key_length] ## ones(key_length)
        for cycle in 1:cycles
            current_epsilon = epsilon
            slices = shuffle([ii for ii in 1:key_length])
            for pizza in slices
                choices = collect(Set(places[pizza], min(places[pizza] + 1, 25), max(places[pizza] - 1, 1)))
                if rand() < epsilon
                    places[pizza] = choices[rand(1:end)]
                else
                    scores = Float64[]
                    for choice in choices
                        places[pizza] = choice
                        guess = guess_key(ciphertext, key_length, places)
                        push!(scores, frequency_difference(frequency_dict(vigenere_encode(ciphertext, guess, true))))
                    end
                    places[pizza] = choices[findfirst(scores, minimum(scores))]
                end
            end
            current_epsilon *= decay
            println("\t$places")
        end                             # end for cycles
        vkeys = union(vkeys, Set(Array[places]))
    end
    return collect(vkeys)
end

function preprocess_text(text::String)
    return lowercase(replace(text, " ", ""))
end
                        
function frequency_difference(text_dict::Dict{Char, Int64})
    english_dict = [
                    'a'=>.08167,
                    'b'=>.01492,
                    'c'=>.02782,
                    'd'=>.04253,
                    'e'=>.12702,
                    'f'=>.02228,
                    'g'=>.02015,
                    'h'=>.06094,
                    'i'=>.06996,
                    'j'=>.00513,
                    'k'=>.00772,
                    'l'=>.04025,
                    'm'=>.02406,
                    'n'=>.06749,
                    'o'=>.07507,
                    'p'=>.01929,
                    'q'=>.00095,
                    'r'=>.05987,
                    's'=>.06327,
                    't'=>.09056,
                    'u'=>.02758,
                    'v'=>.00978,
                    'w'=>.02360,
                    'x'=>.00150,
                    'y'=>.01974,
                    'z'=>.00774,
                    ]
    total = sum(collect(values(text_dict)))
    letters = collect(keys(english_dict))
    english_percentages = [english_dict[letter] for letter in letters]
    text_percentages = [get(text_dict, letter, 0)/total for letter in letters]
    return sum([(percent_difference)^2 for percent_difference in english_percentages - text_percentages])
end
