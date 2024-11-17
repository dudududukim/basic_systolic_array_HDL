# result_matrix.txt 파일에서 10진수로 된 숫자들을 19비트 hex로 변환하는 스크립트

def decimal_to_hex_19bit(decimal_value):
    # 19비트에 맞추어 음수와 양수 값을 처리
    if decimal_value < 0:
        decimal_value = (1 << 20) + decimal_value  # 19비트 2의 보수로 변환
    hex_value = f"{decimal_value:05X}"  # 5자리 16진수 형식으로 변환
    return hex_value

def convert_file_to_hex(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()
    
    hex_matrix = []
    for line in lines:
        decimal_values = map(int, line.split())  # 10진수로 변환
        hex_values = [decimal_to_hex_19bit(value) for value in decimal_values]
        hex_matrix.append("".join(hex_values))
    
    # 변환된 16진수를 새로운 파일에 저장
    with open("result_matrix_hex.txt", 'w') as file:
        file.write("\n".join(hex_matrix))
    
    print("Conversion completed. Check 'result_matrix_hex.txt' for the output.")

# 실행
convert_file_to_hex("result_matrix.txt")
