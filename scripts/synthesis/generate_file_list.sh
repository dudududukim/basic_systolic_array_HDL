# Vivado TCL 파일 목록 생성
echo "# Auto-generated list of Verilog files" > file_list.tcl
for file in ../../src/basic_modules/*.v ../../src/counter/*.v ../../src/MEM/*.v ../../src/SysArr/*.v; do
    echo "add_files -norecurse $file" >> file_list.tcl
done


# ../../src/controller/*.v 는 일단 제외 아직 완성안됨