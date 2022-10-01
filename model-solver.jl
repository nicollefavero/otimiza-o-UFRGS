using JuMP
using GLPK
using Formatting

struct Instance
    n :: UInt
    m :: UInt
    k :: UInt
    L :: Real
    U :: Real
    p :: Array{Real}
    E :: Array{Bool, 2}
    c :: Array{Real, 2}
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
        p = map(function (s) parse(Float64, s) end, ps_strings)

        E = zeros(Bool, n, n)
        for _ in 1:m
            otherline = readline(file)
            i, j = map(function (s) parse(UInt, s) end, split_row(otherline))
            E[i, j] = true
            E[j, i] = true
        end

        c = zeros(Real, n, n)
        for i in 1:n
            otherline = readline(file)
            col = map(function (s) parse(Float64, s) end, split_row(otherline))
            for j in 1:n
                c[i, j] = col[j]
            end
        end

        Instance(n, m, k, L, U, p, E, c)
    end
end

function dijkstra(instance :: Instance, start :: UInt) :: Dict{UInt, Array{UInt}}
    (; n, E) = instance

    dists = fill(typemax(UInt), n)
    prevs = fill(UInt(0), n)

    dists[start] = 0

    frontier = Set{UInt}([start])
    visited = Set{UInt}()
    
    while length(frontier) > 0
        u = 0
        for v in frontier
            if u == 0 || dists[v] < dists[u]
                u = v
            end
        end
        delete!(frontier, u)
        push!(visited, u)

        for v in 1:n
            if E[u,v] && !(v in visited)
                new_dist = dists[u] + 1
                if new_dist < dists[v]
                    dists[v] = new_dist
                    prevs[v] = u
                end
                push!(frontier, v)
            end
        end
    end

    paths = Dict{UInt, Array{UInt}}()

    for u in 1:n
        v = u
        path = []
        while v != start && v != 0
            push!(path, v)
            v = prevs[v]
        end
        if v == start
            push!(path, start)
            paths[u] = path
        end
    end

    return paths
end

function mount_paths(instance :: Instance) :: Dict{Tuple{UInt, UInt}, Array{UInt}}
    (; n) = instance

    paths = Dict{Tuple{UInt, UInt}, Array{UInt}}()
    for j in 1:n
        partial_paths = dijkstra(instance, j)
        for (i, path) in partial_paths
            paths[i, j] = path
        end
    end

    paths
end

if length(ARGS) != 1
    println(stderr, "This program accepts and requires exactly one argument.")
    println(stderr, "Usage:")
    println(stderr, "    julia model-solver.jl PATH")
    exit(-1)
end

instance_path = ARGS[1]
print("Reading instance at path ", instance_path, "... ")

instance = read_instance(instance_path)

println("done")
print("Mounting paths... ")

paths = mount_paths(instance)

println("done")
print("Creating model... ")

(; n, k, c) = instance
m = Model();
set_optimizer(m, GLPK.Optimizer);

V_idx = collect(1:n)
k_idx = collect(1:k)

@variable(m, y[i in V_idx, j in V_idx], Bin)
@variable(m, z[u in V_idx, v in V_idx, l in k_idx], Bin)
@variable(m, f[u in V_idx, v in V_idx, l in k_idx, i in V_idx, j in V_idx], Bin)

@objective(m, Min, sum(c[i,j] * y[i,j] for i in V_idx for j in V_idx))

@constraint(m, [i in V_idx], sum(y[i, j] for j in V_idx) == 1)
@constraint(m, sum(y[i, i] for i in V_idx) == k)

println("done")
