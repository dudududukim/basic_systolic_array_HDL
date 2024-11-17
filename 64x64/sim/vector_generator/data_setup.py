import numpy as np
import argparse

def setup_matrix(matrix):
    n = matrix.shape[0]
    setup_matrix = np.zeros((2 * n - 1, n), dtype=int)

    # Fill the setup matrix based on the specified pattern
    for i in range(2 * n - 1):
        for j in range(n):
            row = i - j
            if 0 <= row < n:
                setup_matrix[i][j] = matrix[row, j]

    return setup_matrix

# Main function
def main(n):
    np.random.seed(0)  # Set seed for reproducibility

    # Generate a random n x n matrix with 8-bit signed integers
    original_matrix = np.random.randint(-128, 128, (n, n), dtype=np.int8)

    # Apply the setup transformation
    setup_result = setup_matrix(original_matrix)

    # Print matrices to console
    print("Original n x n Matrix:")
    print(original_matrix)
    print("\nSetup Matrix:")
    print(setup_result)

    # Save matrices to txt files
    np.savetxt("original_matrix.txt", original_matrix, fmt="%d", delimiter=" ")
    np.savetxt("setup_result.txt", setup_result, fmt="%d", delimiter=" ")

    print("\nOriginal matrix and setup result have been saved as 'original_matrix.txt' and 'setup_result.txt'.")

# Parse command line arguments
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate and transform an n x n matrix.")
    parser.add_argument("n", type=int, help="Size of the matrix (n x n)")
    args = parser.parse_args()

    main(args.n)
