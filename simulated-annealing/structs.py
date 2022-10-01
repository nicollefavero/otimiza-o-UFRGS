class Instance:
    def __init__(self, n, m, k, l, u, edges, costs):
        self.vertex_qt = n
        self.edges_qt = m
        self.subgraphs_qt = k
        self.min_weight = l
        self.max_weight = u
        self.vertex_edges = edges
        self.vertex_costs = costs 

    def __str__(self):
        graph_infos = f"""
        Informações do Grafo:
        Quantidade de Vértices (n): {self.vertex_qt}
        Quantidade de Arestas (m): {self.edges_qt}
        Arestas:
"""

        for vi, edges in enumerate(self.vertex_edges):
            for edge in edges:
                graph_infos += (f"            {vi + 1} <-> {edge + 1}\n")

        graph_infos += ("        Custos (c_ij):\n")

        diff = 2
        for vi, costs in enumerate(self.vertex_costs):
            for vj, cost in enumerate(costs):
                graph_infos += (f"            {vi + 1} <-> {vj + diff}: {cost}\n")
            diff += 1

        graph_infos += f"""
        Informações do Problema:
        Quantidade de Subgrafos (k): {self.subgraphs_qt}
        Peso Mínimo de Cada Subgrafo (L): {self.min_weight}
        Peso Máximo de Cada Subgrafo (U): {self.max_weight}
        """

        return graph_infos