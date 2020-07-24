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

    cartesians = matrix |> 
                (m -> m[:,columns]) |> # get the first two columns
                (tc -> tc .- mins) |> # subtract min values for each column
                (tc -> tc ./ interval) |> # divide with interval to get relative range from 0 to 1
                (tc ->  tc .* hcat(resolution...))  |> # multiply with resolution to get bin number
                (tc -> trunc.(Int64, tc)) |> # floor to get bins as integers
                (tc -> replaceZeroIndexes(tc, 1)) |> # handle edge case for bins on position zero
                tc -> [CartesianIndex(a...) for a in eachrow(tc)] # get list of indexes to facilitate broadcasting
end