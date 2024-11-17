import numpy as np

# Load matrices from txt files
original_matrix = np.loadtxt("original_matrix.txt", dtype=int, delimiter=" ")
weight_matrix = np.loadtxt("weight_matrix.txt", dtype=int, delimiter=" ")

# Perform matrix multiplication
result_matrix = np.dot(original_matrix, weight_matrix)

# Print matrices to console
print("Original Matrix (from original_matrix.txt):")
print(original_matrix)
print("\nWeight Matrix (from weight_matrix.txt):")
print(weight_matrix)
print("\nResult Matrix (Original x Weight):")
print(result_matrix)

# Save the result matrix to a txt file
np.savetxt("result_matrix.txt", result_matrix, fmt="%d", delimiter=" ")
print("\nResult matrix has been saved as 'result_matrix.txt'.")
