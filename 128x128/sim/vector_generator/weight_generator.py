import numpy as np
import argparse

def generate_weight_matrix(n):
    np.random.seed(35)  # Use a different seed each time
    weight_matrix = np.random.randint(-128, 128, (n, n), dtype=np.int8)
    return weight_matrix

def main(n, filename="weight_matrix.txt"):
    with open(filename, "w") as f:
        for i in range(1):          # change this value to make further weight matrix
            weight_matrix = generate_weight_matrix(n)
            np.savetxt(f, weight_matrix, fmt="%d", delimiter=" ")
            # if i < 3:  # Add a separator between matrices, except after the last one
            #     f.write("\n")
            print(f"Generated Weight Matrix {i+1}:")
            print(weight_matrix)
            print()

    print(f"\n모든 가중치 행렬이 {filename} 파일에 저장되었습니다.")

# Parse command line arguments
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate four n x n weight matrices and save to a single file.")
    parser.add_argument("n", type=int, help="Size of the weight matrix (n x n)")
    args = parser.parse_args()

    main(args.n)
