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
