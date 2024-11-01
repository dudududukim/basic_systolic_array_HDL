# TPU Systolic Array Design on Xilinx FPGA

## Introduction

이 프로젝트는 **TPU v1 아키텍처**를 참고하여 **Xilinx FPGA** 상에서 Systolic Array 구조를 구현하는 것을 목표로 합니다. TPU는 행렬 연산에 특화된 하드웨어 구조로, 인공지능 연산에 최적화된 고속 병렬 처리 장치입니다. 본 설계는 Verilog를 사용하여 TPU의 핵심 기능을 구현하고, Xilinx Vivado 툴을 통해 합성과 FPGA 배치를 수행합니다.

### 주요 목표
- **Systolic Array 설계**: TPU v1 아키텍처를 참고하여 Systolic Array 기반의 행렬 연산 구조 구현
- **FPGA 최적화**: Xilinx FPGA 상에서 동작할 수 있도록 최적화된 설계
- **행렬 곱 연산 효율화**: 병렬 처리를 통한 고속 행렬 곱 연산 수행

### 프로젝트 구성 요소
- **Verilog 모듈 설계**: SRAM, Processing Element(PE), Systolic Array 등 TPU 구성 요소를 모듈화
- **시뮬레이션 및 검증**: Icarus Verilog와 GTKWave를 활용한 기능 검증 및 파형 분석
- **Python 기반 데이터 생성**: 행렬 데이터 및 가중치 벡터 자동 생성 스크립트 제공

이 프로젝트는 **종합설계 과목**의 일환으로, Xilinx FPGA에서의 구현과 성능 최적화를 목적으로 합니다.
