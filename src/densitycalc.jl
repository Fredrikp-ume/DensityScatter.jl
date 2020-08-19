using Pipe
using LinearAlgebra

function calc_densities(matrix::Array{Float64,2})

    resolution = (200, 200)     

    densities = zeros(Float64, resolution...)  
    
    cartesians = performBinning(matrix, resolution)

    map(cidx -> densities[cidx] += 1, cartesians)                 

    return (cartesians, densities)
end

function logtransform(matrix)
    @pipe matrix |> _ .+ 1 |> log10.(_)
end 

# utility broadcasting function
function replaceZeroIndexes(idxs, newval=0) 
    idxs[idxs .== 0] .= 1

    idxs
end

# make binning
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
                tc -> [CartesianIndex(a[i,:]...) for i in 1:size(a,1)] # get list of indexes to facilitate broadcasting
end

# run smoothing for one dimension
function smooth1D(Y, lambda)

    m, n = size(Y)

    E = Matrix{Int}(I, m, m)
    D1 = diff(E, dims=1)
    D2 = diff(D1, dims=1)
    P = lambda.^2 .* D2' * D2 + lambda .* 2 .* D1' * D1;

    Z = (E + P) \ Y

end

function getDensity(densities, cartesians)
    [densities[gd] for gd in cartesians]
end

"""
Create a density scatter2D plot with smoothing 
http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.105.459&rep=rep1&type=pdf

...
# Arguments
- `x:: Array{Float64,1}` : x axis values
- `y:: Array{Float64,1}` : y axis values
- `lambda:: Int64=20` : input for the smoothing function
...
"""
function smoothe(x::Array{Float64,1}, y::Array{Float64,1}, lambda=20)::Array{Float64,1}

    cartesians, densities = calc_densities(hcat(x, y))

    nbins = size(densities)

    zvalues = @pipe densities |> 
        logtransform(_) |>
        smooth1D(_, nbins[2] / lambda) |>
        _' |>
        smooth1D(_, nbins[1] / lambda) |>
        _' |>
        getDensity(_, cartesians)

    return zvalues

end