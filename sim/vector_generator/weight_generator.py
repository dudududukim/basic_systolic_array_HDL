import numpy as np
import argparse

def generate_weight_matrix(n, filename="weight_matrix.txt"):
    np.random.seed(12)  # Set seed for reproducibility, but differ from data_setup
    weight_matrix = np.random.randint(-128, 128, (n, n), dtype=np.int8)

    # Save the matrix to a .txt file
    np.savetxt(filename, weight_matrix, fmt="%d", delimiter=" ")

    print(f"{filename}에 {n}x{n} 가중치 행렬이 저장되었습니다.")
    return weight_matrix

def main(n):
    # Generate and save the weight matrix
    weight_matrix = generate_weight_matrix(n)
    print("Generated Weight Matrix:")
    print(weight_matrix)

# Parse command line arguments
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate an n x n weight matrix and save to file.")
    parser.add_argument("n", type=int, help="Size of the weight matrix (n x n)")
    args = parser.parse_args()

    main(args.n)
