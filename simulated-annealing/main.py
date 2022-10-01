import input
import structs

instance = input.get_instances("instance_5_5.dat")
solution = structs.SimulatedAnnealing(instance).first_solution()
print(solution)