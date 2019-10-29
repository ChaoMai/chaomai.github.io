# C++模板与泛型编程

模板到特定函数或者类的转化发生在**编译时**。

# 定义模板

## 函数模板

在模板定义中，模板参数列表包含第一个或多个模板参数，且列表不能为空。模板参数列表表示在类或函数定义中用到的**类型或值**。

使用模板时，**隐式或显式地**定义**模板实参**，将其绑定到模板参数上。

当使用一个函数模板时，编译器通常用函数实参了来推断模板实参，编译器用推断出的模板参数来为**实例化**一个特定版本的函数。实例化时，编译器使用**实际的模板实参**代替对应的模板参数来创建一个新*实例*。

```cpp
template <typename T>
int compare(const T &v1, const T &v2) {
  if (v1 < v2) {
    return -1;
  }

  if (v1 > v2) {
    return 1;
  }

  return 0;
}

// 实例化为int compare(const int&, const int&)
compare(1, 0);
```

### 模板类型参数

模板类型参数前必须使用class或typename。在模板参数列表中，这两个关键字的**含义相同**，可以**互换使用**和在同一个模板参数列表中**同时使用**。

```cpp
template <typename T>
int compare(const T &v1, const T &v2) // ...
```

compare有一个模板类型参数T，一般来说，可以将类型参数看作类型说明符，类似内置类型或类类型说明符。

类型参数可用于，

* 指定返回类型或函数的参数类型
* 函数体内的变量声明或类型转换

### 非模板类型参数

非模板类型参数表示一个**值**，使用一个**特定的类型名**来指定非类型参数。

当一个模板被实例化时，非类型参数被一个用户提供或编译器推断出的值所代替，这个值必须是**常量表达式**，因为编译器在编译时需要实例化模板，此时必须知道值是多少。

```cpp
template <typename T, size_t N>
T *arr_begin(T(&arr)[N]) {
  return static_cast<T *>(arr);
}
```

一个非类型参数可以是，

* 一个整型
* 一个指向对象或函数类型的指针
* 左值引用

关于绑定到非类型参数的实参，要注意，

* **必须是一个常量表达式**
* 绑定到指针或非类型参数的实参必须有**静态的生存期**，**不能**用一个普通的局部变量或动态对象作为指针或引用非类型模板参数的实参
* 指针参数可用nullptr或值为0的常量表达式来实例化

由于模板非类型参数是一个常量值，在**需要常量表达式的地方**，可以使用非类型参数。

```cpp
template <typename T, size_t N>
constexpr size_t constexpr_arr_size(T(&arr)[N]) {
  return N;
}

constexpr int size = constexpr_arr_size(arr);
```

### 模板编译

编译器遇到模板定义时，**并不生成代码**。只有当实例化出一个特定版本时，编译器才会生成代码。

不同于调用函数（只需要函数声明）和使用类对象（只需要类定义，但成员函数的定义不必出现），为了生成一个实例，编译器**必须知道**函数模板或类模板成员函数的定义，也就是说，模板的头文件通常**既包括声明也包括定义**。

模板包含两种名字，

* 不依赖于模板参数的名字
    * 在使用模板时，不依赖于模板参数的名字**必须是**可见的。同时必须保证，实例化时，模板的定义，包括类模板的成员的定义，都必须是可见的
* 依赖于模板参数的名字

## 类模板

编译器**不能**为类模板**推断模板参数类型**。

### 定义

类似函数模板。

### 实例化类模板

当使用类模板是，必须提供**显式模板实参**列表。

一个模板类的**每个实例**都形成一个**独立的类**，每个实例化出的类与任何其他实例化出的类**都没有关联**，也不会对任何其他类型的成员有特殊访问权限。

### 在模板作用域中引用模板类型

类模板的名字**不是**一个类型名。一个类模板中如果使用了另一个模板，通常**不将实际类型（或值）**的名字用作其模板实参，而是用模板自己的参数。

### 类模板的成员函数

* 定义在**类模板内**的成员函数被**隐式**声明为**内联函数**
* 类模板的成员函数具有和类模板**相同的模板参数**
* 类模板的每个实例都有**自己版本**的成员函数

从一个类模板生成的类的名字中必须**包含其模板实参**。在类外定义一个成员函数时，模板实参与模板形参相同。

```cpp
template <typename T>
void Blob<T>::check(size_type i, const std::string& msg) const {
  if (i >= data_->size()) {
    throw std::out_of_range(msg);
  }
}
```

### 类模板成员函数的实例化

默认情况下，一个类模板的成员函数**只有当程序用到它**的时候才进行实例化。

即使某种类型**不能完全符合模板操作的要求**，仍可以用该类型实例化类。如：容器的关系运算符，即使元素类型不支持关系运算符，但仍可以用这个元素类型实例化容器，只是无法对这个容器对象用关系运算符（在比较容器对象的时候会报错）。

### 在类代码内简化模板类名的使用

当处于类模板的作用域中时，可以**直接使用模板名**而不必指定模板实参。在类模板外时（如：类模板外定义成员时），**直到遇到类名**才表示进入类的作用域，其他情况（如：返回值）都需要指定模板实参。

```cpp
template <typename T>
class BlobPtr {
 public:
  // ...
  BlobPtr& operator++();
  BlobPtr& operator--();
  // ...
}
```

### 类模板和友元

#### 一对一友元关系

下面的代码中，友元关系被**限定**在用**相同类型实例化的Blob与BlobPtr，以及Blob与相等运算符之间。

```cpp
template <typename T>
class BlobPtr;

template <typename T>
class Blob;

template <typename T>
bool operator==(const Blob<T>&, const Blob<T>&);

template <typename T>
class Blob {
  friend class BlobPtr<T>;
  friend bool operator==<T>(const Blob<T>&, const Blob<T>&);
  // ...
}
```

#### 通用和特定的模板友元关系

* 将模板的每个实例声明为自己的友元

  ```cpp
  template <typename T> class Pal;
  class C {
    // 用类C实例化的Pal是C的一个友元
    friend class Pal<C>;

    // Pal2的所有实例都是C的友元，这里无需前置声明
    template <typename T> friend class Pal2;

    // Pal3是C所有实例的友元，不需要前置声明
    friend class Pal3;
  }
  ```

  为了让**所有实例成为友元**，友元声明中必须使用与类模板本身**不同的模板参数**。

* 令模板自己的类型参数成为友元

  ```cpp
  template <typename T> class Bar {
    friend T;
  }
  ```

  可以使用**内置类型**来实例化Bar。

### 模板类型别名

由于模板不是类型，不能定义typedef引用一个模板。

```cpp
template <typename T> using twin = pair<T, T>;
twing<string> authors;

template <typename T> using partNo = pair<T, unsigned int>;
// 可以固定一个或多个模板参数
partNo<string> books;
```

### 类模板的static成员

每个Foo实例都有自己的static成员实例，所有Foo<X>类型的对象**共享相同的**ctr对象和count函数。

```cpp
template <typename T>
class Foo {
 public:
  static size_t count() { return ++ctr; }

  static size_t ctr;
};

template <typename T>
size_t Foo<T>::ctr = 0;

Foo<int> f1, f2, f3;
f1.count();
f2.count();
f3.count();
cout << f1.ctr << endl; // 3

Foo<string> s1, s2;
s1.count();
s2.count();
cout << s1.ctr << endl; //2

cout << Foo<double>::count() << endl; // 1
```

上面的代码中，模板类（实例化得到的）static数据成员**必须有且仅有**一个定义，但类模板的每个实例有一个独有的static对象，因此static数据成员也定义为模板`template <typename T> size_t Foo<T>::ctr = 0;`。

### 模板参数

#### 模板参数与作用域

一个模板名的可用范围是在**其声明之后，至模板声明或定义结束之前**。在模板内**不能重用模板参数名**。

```cpp
typedef double A;
template <typename A, typename B> void f(A a, B b) {
  A tmp = a;
  double B; // 错误
}
```