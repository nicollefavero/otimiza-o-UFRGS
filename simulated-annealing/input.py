import os
from structs import Instance

def get_instances(filename):
    current_dir = os.path.dirname(__file__)
    filename_abs_path = os.path.join(current_dir, "../instances/" + filename)

    with open(filename_abs_path, 'r') as file:
        first_line = file.readline()
        n, m, k, l, u = map(int, first_line.strip().split())

        second_line = file.readline()

        # Cuidar que os índices dos vértices começam em 0 aqui
        vertices_weights = list(map(int, second_line.strip().split()))

        vertices_range = range(0, n)
        edges_range = range(0, m)

        edges = [[] for x in edges_range]

        for _ in edges_range:
            i, j = map(int, file.readline().strip().split())

            # Padronizar os índices dos vértices de acordo com os índices dos arrays
            i -= 1
            j -= 1

            edges[i].append(j)
            edges[j].append(i)

        vertices_costs = [[] for x in vertices_range]

        for x in vertices_range:
            vertices_costs[x] = list(map(int, file.readline().strip().split()[1:]))

    
    with open(f"{filename_abs_path}.txt", 'w') as file:
        tam = len(vertices_costs[0])
        for x in range(tam):
            vertices_costs[x].append(vertices_costs[tam][x])
        vertices_costs[tam].append(0)

        for i, l in enumerate(vertices_costs):
            file.write(f"{i}")
            for y in l:
                file.write(f" {y}")
            file.write("\n")


        #return Instance(n, m, k, l, u, vertices_weights, edges, vertices_costs)
