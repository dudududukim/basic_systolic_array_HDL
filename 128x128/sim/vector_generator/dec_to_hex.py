import sys
import os

def convert_to_64bit_hex(input_file, output_file):
    # Ensure the output directory exists
    output_dir = os.path.dirname(output_file)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)

    with open(input_file, "r") as infile, open(output_file, "w") as outfile:
        for line in infile:
            # 각 행의 10진수 값을 8비트 정수로 변환 후, 2자리 16진수로 변환
            values = list(map(int, line.split()))
            if len(values) != 128:
                raise ValueError("Each line must contain exactly 8 values.")

            # 각 값이 8비트로 제한되도록 & 0xFF 마스크 적용 후, 2자리 16진수로 변환
            hex_str = ''.join(f"{(val & 0xFF):02X}" for val in values)

            # 64비트(16자리 16진수)로 구성된 한 줄을 파일에 저장
            outfile.write(hex_str + "\n")

# Main entry point to handle command-line arguments
if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python convert_to_hex.py <input_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = os.path.join("hex", sys.argv[2])  # hex 폴더에 저장되도록 설정
    convert_to_64bit_hex(input_file, output_file)
    print(f"Converted {input_file} to {output_file} in hex format.")
