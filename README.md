This repository contains a reproducer for NVIDIA bug 4216808.
The problem is fixed in an upcoming CUDA 12.4 version.

## Description

When `nvcc` compiles a C++ file, in some corner cases it produces a _host_ binary with the wrong symbol type, `b` (a BSS local symbol) instead of `u` (a unique global symbol).

For example, compiling this file with `gcc`
```c++
#include <type_traits>

// user defined type used as template argument
class Type {};

// the SFINAE condition is a possible cause of the problem
template <typename T1,
          typename T2,
          typename = std::enable_if_t<std::is_class_v<T1> and std::is_class_v<T2>>>
class Resource {
public:
  explicit Resource(int value) : value_{value} {}

  int value_;
};

// initialise the function-static variable on the first call
template <typename T>
inline Resource<Type, T>& getResource() {
  static Resource<Type, T> resource(42);
  return resource;
}

// explicit call to instantiate the templates
void call() {
  getResource<Type>();
}
```

generates unique global symbols for the `resource` static variable:
```bash
$ g++-12 -O2 -std=c++17 -c test.cc -o test.gcc.o
$ nm -C test.gcc.o | grep '::resource$'
0000000000000000 u guard variable for getResource<Type>()::resource
0000000000000000 u getResource<Type>()::resource
```

Compiling the same file with `nvcc` generates a BSS local symbol:
```bash
$ /usr/local/cuda-12.2/bin/nvcc -ccbin g++-12 -O2 -std=c++17 -x cu -c test.cc -o test.nvcc.o
$ nm -C test.nvcc.o | grep '::resource$'
0000000000000000 b guard variable for getResource<Type>()::resource
0000000000000008 b getResource<Type>()::resource
```

Minor changes to the test (for example, removing the SFINAE condition on the the `Resource` class template) do not trigger the problem any more, resulting in unique global symbols also when compiling with `nvcc`.


## Details

Tested on Ubuntu 22.04 and RHEL 8.7, with CUDA 11.5, 11.8, 12.1, 12.2 and 12.3, with GCC 11.x and 12.x (where supported).
