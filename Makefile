.PHONY: all

NVCC := /usr/local/cuda-12.2/bin/nvcc
CXX  := g++-12

all: gcc nvcc

nvcc:
	$(NVCC) -ccbin $(CXX) -O2 -std=c++17 -x cu -c test.cc -o test.nvcc.o
	nm -C test.nvcc.o | grep '::resource$$' | grep --color '\<\w\>\|::resource$$'

gcc:
	$(CXX) -O2 -std=c++17 -c test.cc -o test.gcc.o
	nm -C test.gcc.o | grep '::resource$$' | grep --color '\<\w\>\|::resource$$'
