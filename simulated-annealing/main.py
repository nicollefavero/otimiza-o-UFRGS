import input
import structs
import os

current_dir = os.path.dirname(__file__)
absolute_dir = os.path.join(current_dir, "../instances/")
files = os.listdir(absolute_dir)

for file in files:
    instance = input.get_instances(file)
#     solution = structs.SimulatedAnnealing(instance).first_solution()
    
#     if solution is not None:
#         #print(solution)
#         print(solution.objective())


# instance = input.get_instances("instance_5_5.dat")
# solution = structs.SimulatedAnnealing(instance).first_solution()

# if solution is not None:
#     #print(solution)
#     print(solution.objective())
# else: 
#     print("solution is none")