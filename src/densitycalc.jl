using Pipe

function calc_densities(matrix::Array{Float64,2})
    resolution = (200, 200)     

    densities = zeros(Float64, resolution...)  
    
    cartesians = performBinning(matrix, resolution)

    map(cidx -> densities[cidx] += 1, cartesians)                 

    return (cartesians, densities)
end

function replaceZeroIndexes(idxs, newval=0) 
    idxs[idxs .== 0] .= 1

    idxs
end

function performBinning(matrix, resolution, columns=[1,2])
    mins = minimum(matrix[:,columns], dims=1)
    maxs = maximum(matrix[:,columns], dims=1)

    interval = maxs - mins

    cartesians = @pipe matrix |> 
                _[:,columns] |> # get the first two columns
                _ .- mins |> # subtract min values for each column
                _ ./ interval |> # divide with interval to get relative range from 0 to 1
                _ .* hcat(resolution...)  |> # multiply with resolution to get bin number
                trunc.(Int64, _) |> # floor to get bins as integers
                replaceZeroIndexes(_, 1) |> # handle edge case for bins on position zero
                [CartesianIndex(a...) for a in eachrow(_)] # get list of indexes to facilitate broadcasting
end

my_f(x)=x+1