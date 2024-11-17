import argparse

def concat_weights(input_file, output_file, n):
    with open(input_file, "r") as infile, open(output_file, "w") as outfile:
        lines = infile.readlines()
        for i in range(0, len(lines), n):
            concat_line = ''.join(line.strip() for line in lines[i:i+n])
            outfile.write(concat_line + "\n")
            # print(f"Concatenated {n * 64}-bit Line: {concat_line}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Concatenate lines from input file into n-line chunks.")
    parser.add_argument("input_file", type=str, help="Input file with hex values")
    parser.add_argument("output_file", type=str, help="Output file to save concatenated lines")
    parser.add_argument("n", type=int, help="Number of lines to concatenate")
    args = parser.parse_args()
    concat_weights(args.input_file, args.output_file, args.n)
