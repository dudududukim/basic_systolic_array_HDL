# configuration
# matrix size
n=64
convert_files=("setup_result.txt" "weight_matrix.txt" "original_matrix.txt")

# 1st : make two Matrix (Weight / Data)
python3 data_setup.py $n
python3 weight_generator.py $n

# 2nd : Weight * Matrix (loding txt and make results)
python3 matrix_mul.py

# 3rd : make decimal matrix file to hex
for file in "${convert_files[@]}"; do
    output_file="${file%.txt}_hex.txt"  # 변환된 파일 이름: 원본 파일 이름 + "_hex.txt"
    python3 dec_to_hex.py "$file" "$output_file"
done

python3 dec_to_hex_results.py "result_matrix.txt" "./hex/result_matrix_hex.txt"         # output bitwidth에 맞춰서 따로 해줘야함


# 4th : Convert Weight matrix to fit into 64B FIFO Data in
python3 converter_weight_fifo.py ./hex/weight_matrix_hex.txt ./hex/weight_matrix_concat.txt 64