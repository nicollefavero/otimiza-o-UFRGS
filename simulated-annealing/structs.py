import random

class Subgraph():
    def __init__(self, weight, available):
        self.subgraph = {}
        self.weight = weight
        self.available_vertices = []

    def __str__(self):
        return f"""
                Vertices: {self.subgraph}
                Total Weight: {self.weight}
                Available Vertices: {self.available}
                """


class Solution:
    def __init__(self, feasible):
        self.feasible = feasible
        self.subgraphs = []
        self.cost = None

    def __str__(self):
        s = f"""
                Solution 
                Is feasible: {self.feasible},
                Subgraphs:
                """

        for i, sg in enumerate(self.subgraphs):
            s += f"""{i}
                {sg}
                """
        
        return s


class SimulatedAnnealing():
    def __init__(self, instance):
        self.instance = instance

    def first_solution(self):
        # itera sobre os vertices da borda, e pega o primeiro cuja adição ao subgrafo nao faz o peso total nao ultrapassar U e que não esteja nos explorados
            # se todos ultrapassarem, finaliza esse subgrafo 
        # adiciona esse vertice ao subgrafo
        # retira esse vertice dos available vertices e coloca nos explorados
        # atualiza a borda com os vizinhos desse novo vertice

        # border: vizinhos do vértice i (zerado a cada iteração interna)
        # available: todos vértices que passaram por border mas não foram para explorados (zerado a cada iteração externa)
        # remaining: todos os vértices que passaram por available de todas iterações (todos vértices de todas iterações que não foram para explorados)
        # explored: todos os vértices já usados desde o inicio do loop

        remaining = []
        explored = []
        subgraphs_count = 0

        solution = Solution(True)

        while subgraphs_count < self.instance.subgraphs_qt:
            subgraph = {}

            i = random.randint(0, self.instance.vertices_qt)

            while (i in explored):
                i = random.randint(0, self.instance.vertices_qt)

            subgraph[i] = self.instance.vertices_weights[i]
            border = self.instance.vertices_edges[i]

            available = []
            explored.append(i)

            weight = 0

            while True:
                v = None
                for j in border:
                    if ((weight + self.instance.vertices_weights[j]) <= self.instance.max_weight) and (j not in explored):
                        v = j
                        break

                available = list(set(available.append(border)))                     # remove duplicatas 
                
                if v is None:
                    if weight < self.instance.min_weight:
                        solution.feasible = False
                        
                    solution.subgraphs.append(Subgraph(subgraph, weight, available))
                    subgraphs_count += 1
                    break  

                else:
                    weight_v = self.instance.vertices_weights[v]
                    weight += weight_v
                    explored.append(v)
                    available.remove(v)  
                    border = self.vertex_edges[v]                                   # atualiza border com vizinhos do vertice atual
                    subgraph[v] = weight_v

            remaining = list(set(remaining.append(available)))


        # conferir se todos os vértices foram para algum subgrafo e tratar caso esse não tenha sido o caso
        remaining_qt = len(remaining) 
        if remaining_qt > 0:
            for vr in remaining:
                vr_weight =  self.instance.vertices_weight[vr]
                for sg in solution.subgraphs:
                    if (vr in sg.available) and ((sg.weight + vr_weight) <= self.instance.max_weight):
                        sg.subgraph[vr] = vr_weight
                        sg.weight += vr_weight
                        sg.available.remove(vr)
                        remaining_qt -= 1

        if remaining_qt > 0:
            solution.feasible = False
            for vr in remaining:
                vr_weight =  self.instance.vertices_weight[vr]

                sg = 0
                for idx, vr in enumerate(remaining):
                    idx_sg = 0
                    len_sg = len(solution.subgraphs)

                    if vr in solution.subgraphs[sg].available:
                        idx_sg = sg
                
                    else:
                        for i in range(0, len_sg):
                            if vr in solution.subgraphs[i].available:
                                idx_sg = i

                    solution.subgraphs[sg].subgraph[vr] = vr_weight
                    solution.subgraphs[sg].weight += vr_weight
                    solution.subgraphs[sg].available.remove(vr)
                    sg = (sg + 1) % len_sg

        return solution

                        
class Instance:
    def __init__(self, n, m, k, l, u, weights, edges, costs):
        self.vertices_qt = n
        self.edges_qt = m
        self.subgraphs_qt = k
        self.min_weight = l
        self.max_weight = u
        self.vertices_weights = weights
        self.vertices_edges = edges
        self.vertices_costs = costs 

    def __str__(self):

        print("Enttrou em __str__")
        graph_infos = f"""
        Informações do Grafo:
        Quantidade de Vértices (n): {self.vertices_qt}
        Quantidade de Arestas (m): {self.edges_qt}
        Arestas:
"""

        for v in range(0, self.vertices_qt):
            graph_infos += (f"            {v} está conectado à {self.vertices_edges[v]}\n")

        graph_infos += ("        Custos (c_ij):\n")
        
        for v, costs in enumerate(self.vertices_costs):
            graph_infos += f"{v}: "
            for cost in costs:
                graph_infos += f"{cost} "
            graph_infos += "\n"

        graph_infos += ("\n        Pesos (p_i):\n")

        for v, p in enumerate(self.vertices_weights):
            graph_infos += f"        {v}: {p}\n"
            
        graph_infos += f"""
        Informações do Problema:
        Quantidade de Subgrafos (k): {self.subgraphs_qt}
        Peso Mínimo de Cada Subgrafo (L): {self.min_weight}
        Peso Máximo de Cada Subgrafo (U): {self.max_weight}
        """
    
        return graph_infos

    # def get_vertex_neighbors(self, v):
    #     if v < len(self.vertices_edges):
    #         return self.vertices_edges[v]
    #     else:





