using Test, YaoBlocks, YaoArrayRegister

function heisenberg(n::Int; periodic::Bool=true)
    Sx(i) = put(n, i=>X)
    Sy(i) = put(n, i=>Y)
    Sz(i) = put(n, i=>Z)

    return sum(1:(periodic ? n : n-1)) do i
        j = mod1(i, n)
        Sx(i) * Sx(j) + Sy(i) * Sy(j) + Sz(i) * Sz(j)
    end
end

const hm = heisenberg(4)

@testset "test time evolution" begin
    te = TimeEvolution(hm, 0.2)

    r = rand_state(4)
    r1 = copy(r) |> te
    @test exp(Matrix(mat(hm)) * 0.2) * r.state ≈ r1.state
    @test applymatrix(adjoint(te)) ≈ applymatrix(te)'

    @test applymatrix(te) ≈ mat(te)
    @test isunitary(te)
    cte = copy(te)
    @test cte == te
end

@testset "test imaginary time evolution" begin
    tei = TimeEvolution(hm, 0.2im)
    r = rand_state(4)
    r1 = copy(r) |> tei
    @test exp(Matrix(mat(hm)) * 0.2im) * r.state ≈ r1.state

    @test applymatrix(tei) ≈ mat(tei)
    @test applymatrix(adjoint(tei)) ≈ applymatrix(tei)'
    @test !isunitary(tei)
end
