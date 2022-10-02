using JuMP
using GLPK
using Formatting

Vertex = UInt
Edge = Tuple{Vertex, Vertex}
EdgeMatrix = Array{Bool, 2}
CostMatrix  = Array{Real, 2}
WeightVector = Array{Real}
Path = Array{Vertex}
PathTree = Dict{Vertex, Path}
PathTable = Array{Path}
FlowEdges = Set{Edge}
FlowVector = Array{FlowEdges}

struct Graph
    vertex_count :: UInt
    edge_count :: UInt
    edges :: EdgeMatrix
end

struct Instance
    graph :: Graph
    subgraph_count :: UInt
    lower_limit :: Real
    upper_limit  :: Real
    weights :: WeightVector
    costs :: CostMatrix
end

struct FlowTable
    arriving :: FlowVector
    leaving :: FlowVector
end

function read_instance(path :: String) :: Instance
    function split_row(row :: String) :: Array{String}
        filter(function (s) s != "" end, split(row, " "))
    end

    open(path, "r") do file
        firstline = readline(file)
        n_string, m_string, k_string, L_string, U_string = split_row(firstline)
        vertex_count = parse(UInt, n_string)
        edge_count = parse(UInt, m_string)
        subgraph_count = parse(UInt, k_string)
        lower_limit = parse(Float64, L_string)
        upper_limit = parse(Float64, U_string)

        graph = 

        secondline = readline(file)
        ps_strings = filter(function (s) s != "" end, split_row(secondline))
        weights = map(function (s) parse(Float64, s) end, ps_strings)

        edges = falses(vertex_count, vertex_count)
        for _ in 1:edge_count
            otherline = readline(file)
            u, v = map(function (s) parse(UInt, s) end, split_row(otherline))
            edges[u, v] = true
            edges[v, u] = true
        end

        costs = zeros(Real, vertex_count, vertex_count)
        for u in 1:vertex_count
            otherline = readline(file)
            col = map(function (s) parse(Float64, s) end, split_row(otherline))
            for v in 1:vertex_count
                costs[u, v] = col[v]
            end
        end

        graph = Graph(vertex_count, edge_count, edges)
        Instance(graph, subgraph_count, lower_limit, upper_limit, weights, costs)
    end
end

function dijkstra(instance :: Instance, start :: Vertex) :: PathTree
    (; vertex_count, edges) = instance.graph

    dists = fill(typemax(UInt), vertex_count)
    prevs = fill(Vertex(0), vertex_count)

    dists[start] = 0

    frontier = Set{Vertex}([start])
    visited = Set{Vertex}()
    
    while length(frontier) > 0
        u = 0
        for v in frontier
            if u == 0 || dists[v] < dists[u]
                u = v
            end
        end
        delete!(frontier, u)
        push!(visited, u)

        for v in 1:vertex_count
            if edges[u,v] && !(v in visited)
                new_dist = dists[u] + 1
                if new_dist < dists[v]
                    dists[v] = new_dist
                    prevs[v] = u
                end
                push!(frontier, v)
            end
        end
    end

    paths = PathTree()

    for u in 1:vertex_count
        v = u
        path = []
        is_valid = false
        while v != 0
            push!(path, v)
            is_valid = v == start
            v = prevs[v]
        end
        if is_valid
            push!(path, start)
            paths[u] = path
        end
    end

    return paths
end

function mount_paths(instance :: Instance) :: PathTable
    (; vertex_count) = instance.graph

    paths = PathTable(undef, vertex_count)
    unvisited = Set{Vertex}(1:vertex_count)
    while length(unvisited) > 0
        u = pop!(unvisited)
        
        for (v, path) in dijkstra(instance, u)
            paths[v] = path
            delete!(unvisited, v)
        end
    end

    paths
end

function mount_flow(instance :: Instance, paths :: PathTable) :: FlowTable
    (; vertex_count) = instance.graph

    arriving = FlowVector(undef, vertex_count)
    leaving = FlowVector(undef, vertex_count)

    for u in 1:vertex_count
        arriving[u] = Set()
        leaving[u] = Set()
    end

    for path in paths
        u = 0
        for v in path
            if u != 0
                push!(arriving[v], (u, v))
                push!(leaving[u], (u, v))
            end
            u = v
        end
    end

    FlowTable(arriving, leaving)
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

flow = let
    local paths = mount_paths(instance)

    println("done")
    print("Creating arriving/leaving edges... ")

    mount_flow(instance, paths)
end

println("done")
print("Creating model... ")

n = instance.graph.vertex_count
k = instance.subgraph_count
c = instance.costs

N_minus = flow.arriving
N_plus = flow.leaving

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
