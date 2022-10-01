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
        vextex_weights = map(int, second_line.strip().split())

        vertex_range = range(0, m)

        edges = [[] for x in vertex_range]

        for _ in vertex_range:
            i, j = map(int, file.readline().strip().split())

            # Padronizar os índices dos vértices de acordo com os índices dos arrays
            i -= 1
            j -= 1

            edges[i].append(j)

        costs = [[] for x in vertex_range]

        # Guardamos os custos em uma lista de listas cada vez menores
        for x in range(0, m):
            if (x + 1) < m:
                costs[x] = map(int, file.readline().strip().split()[x + 2:])

        return Instance(n, m, k, l, u, edges, costs)