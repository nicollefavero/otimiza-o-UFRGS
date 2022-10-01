using JuMP
using GLPK
using Formatting

struct Instance
    n :: UInt
    m :: UInt
    k :: UInt
    L :: Float64
    U :: Float64
    ps :: Array{Float64}
    E :: Array{Bool, 2}
    cs :: Array{Float64, 2}
end

function read_instance(path :: String) :: Instance
    function split_row(row :: String) :: Array{String}
        filter(function (s) s != "" end, split(row, " "))
    end

    open(path, "r") do file
        firstline = readline(file)
        n_string, m_string, k_string, L_string, U_string = split_row(firstline)
        n = parse(UInt, n_string)
        m = parse(UInt, m_string)
        k = parse(UInt, k_string)
        L = parse(Float64, L_string)
        U = parse(Float64, U_string)

        secondline = readline(file)
        ps_strings = filter(function (s) s != "" end, split_row(secondline))
        ps = map(function (s) parse(Float64, s) end, ps_strings)

        E = zeros(Bool, n, n)

        cs = zeros(Float64, n, n)

        for _ in 1:m
            otherline = readline(file)
            i, j = map(function (s) parse(UInt, s) end, split_row(otherline))
            E[i, j] = true
            E[j, i] = true
        end


        for i in 1:n
            otherline = readline(file)
            cijs = map(function (s) parse(Float64, s) end, split_row(otherline))
            for j in 1:n
                cs[i, j] = cijs[j]
            end
        end

        Instance(n, m, k, L, U, ps, E, cs)
    end
end

if length(ARGS) != 1
    println(stderr, "This program accepts and requires exactly one argument.")
    println(stderr, "Usage:")
    println(stderr, "    julia model-solver.jl PATH")
    exit(-1)
end

instance = read_instance(ARGS[1])

m = Model();
set_optimizer(m, GLPK.Optimizer);

V_idx = collect(1:instance.n)

k_idx = collect(1:instance.k)

@variable(m, y[i in V_idx, j in V_idx], Bin)
@variable(m, z[u in V_idx, v in V_idx, l in k_idx], Bin)
@variable(m, f[u in V_idx, v in V_idx, l in k_idx, i in V_idx, j in V_idx], Bin)

@objective(m, Min, sum(instance.cs[i,j] * y[i,j] for i in V_idx for j in V_idx))
