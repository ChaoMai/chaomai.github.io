title: C++ PImpl 和 Fast PImpl
date: 2017-04-26 13:54:34
categories:
    - c++
---

# Opaque Value 和 PImpl

* Opaque Data Type：不透明数据类型指的是，具体的数据结构并未在其接口定义的数据类型。
* Opaque Pointer：Opaque Data Type 的特例，指向未定义类型数据结构的指针。
* [PImpl](http://www.gotw.ca/gotw/024.htm)：Opaque Pointer 例子。

    ```cpp
    // in header file
    class widget {
    public:
      widget();
      ~widget();
    private:
      class impl;
      unique_ptr<impl> pimpl;
    };
     
    // in implementation file
    class widget::impl {
      // :::
    };
     
    widget::widget() : pimpl{ new impl } { }
    widget::~widget() { }                   // or =default
    ```
    
    * 类似桥接模式。
    * 稳定的 ABI，为私有数据结构（实现）增加新成员，不影响 binary compatibility。
    * 减少编译时间。


# Fast PImpl

在上面 Opaque Pointer 的代码中，如果 `new impl` 是一个代价较高的操作，或者希望使用自己的 `new`，这时可以在 `impl` 中重载 `new` 和 `delete`。

```cpp
// in header file
class widget {
public:
  widget();
  ~widget();
private:
  class impl;
  unique_ptr<impl> pimpl;
};

// in implementation file
class widget::impl {
  // :::
  void* operator new(size_t) { /*...*/ }
  void operator delete(void*) { /*...*/ }
};

widget::widget() : pimpl{ new impl{ /*...*/ } } { }
widget::~widget() { }                   // or =default
```


