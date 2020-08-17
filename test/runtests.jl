using DensityScatter
using Test

@testset "DensityScatter.jl" begin

    rows = 10000

    x = [rand() for i in range(1, length=rows)]    
    y = [rand() for i in range(1, length=rows)]

    matrix = hcat(x,y)

    @test (calc_densities(matrix) |> first |> length) == rows
    @test (smoothe(x,y) |> length) == rows
end