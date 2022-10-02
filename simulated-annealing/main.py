import input
import structs
import os

current_dir = os.path.dirname(__file__)
absolute_dir = os.path.join(current_dir, "../instances/")
files = os.listdir(absolute_dir)

for file in files:
    instance = input.get_instances(file)
    solution = structs.SimulatedAnnealing(instance).first_solution()
    print(solution)