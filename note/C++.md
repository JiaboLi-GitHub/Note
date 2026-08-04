# 1 基础语法

## 1.1 类型转换

C++类型转换有四种：

**static_cast**：用于基础类型转换和继承体系中的上行/下行转换。在编译时做检查。

**dynamic_cast**：用于继承体系中的安全下行转换。类中必须定义虚函数，运行时检查。

**const_cast**：用于修改表达式中的const属性。若对原来const的对象写入，会导致未定义行为。

**reinterpret_cast**：用于任意指针类型的转换。属于强制转换。

## 1.2 const

```c++
const T* ptr;	// 数据不可修改
T* const ptr;	// 指针不可改
```

## 1.3 指定初始化

C++20支持指定初始化。

```c++
// 结构体指定初始化
struct Point {
    int x;
    int y;
};
Point p{.x = 10, .y = 20};

// 数组指定初始化
int arr[5] = {
        [0] = 10,
        [3] = 40
    };
```

## 1.4 结构体内存对齐

64位操作系统只能从8的倍数的地址读取数据，并且一次读取8个字节。内存对齐可以在某些情况下**避免多次读取，提高内存访问效率**。

三个对齐规则：

1、结构体内成员按声明顺序存储，第一个成员在与结构体偏移量为0的地址

2、其他成员变量的地址是对齐数的整数倍处，对齐数=min(默认对齐数8，自身字节数)。

3、结构体总大小为最大最齐数的整数倍。

## 1.5 指针和引用的区别

指针是一个变量，存储其他变量的地址。引用是变量的“别名”，使用起来类似于常量指针。

- 指针的定义和初始化可以分离；引用定义时必须初始化；
- 指针可以为空；引用不能为空。
- 指针可以是多级的；引用只有一级；
- 指针初始化后可以修改指向；引用初始化后不可修改指向。
- sizeof指针得到指针本身的大小；sizeof引用得到引用指向变量的大小。

简单的局部引用会被编译器优化为直接的内存访问，不占用额外内存。

引用作为类成员变量时，占用一个指针大小的内存。

## 1.6 C++内存分区

![img](C++.assets/wps1.jpg)

## 1.7 协程

一个函数的返回值类型如果符合协程的规则，那么这个函数就是一个协程。

协程的三个关键字：

co_await：调用等待体，由等待体决定是否挂起。

co_yield：调用yield_value函数，并由该函数的返回值决定是否挂起。

co_return：协程返回，会对应调用return_void或return_value。

```c++
#define __cpp_lib_coroutine

#include <iostream>
#include <coroutine>
#include <future>
#include <chrono>
#include <thread>

using namespace std::chrono_literals;

// 定义 Result 结构，包含 promise_type
struct Result 
{
    struct promise_type 
    {
        // 协程的初始挂起状态
        std::suspend_never initial_suspend()
        {
            std::cout << "步骤二" << std::endl; // 协程开始时输出
            return {}; // 不挂起
        }

        // 协程的最终挂起状态
        std::suspend_never final_suspend() noexcept
        {
            std::cout << "步骤九" << std::endl; // 协程结束时输出
            return {}; // 不挂起
        }

        // 获取协程的返回对象
        Result get_return_object()
        {
            std::cout << "步骤一" << std::endl; // 返回对象创建时输出
            return {}; // 返回一个 Result 对象
        }

        // 协程正常返回时调用
        void return_void()
        {
            std::cout << "步骤八" << std::endl; // 协程返回时输出
        }

        // 处理未处理的异常
        void unhandled_exception()
        {
         
        }

        // 处理 co_yield 的值并挂起协程
        auto yield_value(int value) 
        {
            std::cout << value << std::endl;
            return std::suspend_never{}; // 不挂起协程
        }
    };
};

// 定义 Awaiter 结构，用于协程的等待
struct Awaiter 
{
    int value; // 等待的值

    // 判断是否准备好继续执行
    bool await_ready()
    {
        std::cout << "步骤四" << std::endl;
        return false;
    }

    // 挂起协程并调度恢复
    void await_suspend(std::coroutine_handle<> coroutine_handle)
    {
        std::cout << "步骤五" << std::endl;
        coroutine_handle.resume(); // 恢复协程执行
        std::cout << "步骤十" << std::endl;
    }

    // 返回等待的结果
    int await_resume()
    {
        std::cout << "步骤六" << std::endl;
        return value; // 返回值
    }
};

// 定义协程函数
Result Coroutine()
{
    co_yield 6;
    std::cout << "步骤三" << std::endl; // 协程开始执行时输出
    std::cout << co_await Awaiter{ .value = 1000 } << std::endl; // 等待并输出结果
    std::cout << "步骤七" << std::endl; // 等待后输出
    co_return; // 正常结束协程
};

int main() 
{
    Coroutine(); // 调用协程
    return 0;
}
```

## 1.8 C++代码编译过程

### 1.8.1 预处理阶段

预处理器会依据代码里的预处理指令，对源代码进行一序列文本替换操作。输出.i文件。

- 宏展开
- 头文件插入
- 条件编译处理

### 1.8.2 编译阶段

编译阶段由编译器（g++、clang++）负责，会将预处理的代码转换为汇编代码，生成.s文件。该阶段还会进行编译优化。编译器优化贯穿编译的三个主要阶段：

前端优化：针对抽象语法树进行优化。

中间优化：对中间表示（如LLVM IR）进行与平台无关的优化。

后端优化：针对目标机器架构生成高效的机器码指令。

**前端优化**

1. 常量折叠：将编译期可计算的表达式直接计算为常量。
2. 常量传播：将已知的常量值传播到使用它的地方。
3. 死代码消除：移除永远不会执行的代码。
4. 模板元编程

**中间优化**

1. 循环优化：循环展开、循环不变量外提。
2. 函数内联

**后端优化**

1. 指令级并行：利用处理器流水线并行执行无依赖的指令。
2. 向量化：利用SIMD指令同时处理多个数据。
3. 寄存器分配优化：将频繁使用的变量分配到CPU寄存器中，减少内存访问开销。

**优化的代价**

- 编译时间增加
- 调试难度提升
- 代码尺寸增大

### 1.8.3 汇编阶段

汇编阶段由汇编器将汇编代码转为机器码，生成.o（.obj）文件。

### 1.8.4 链接阶段

链接阶段由链接器将多个目标文件以及所需的库文件链接在一起，最终生成可执行文件。

链接器主要完成以下工作：

1. 符号解析：识别代码中使用的外部符号（函数、变量等），并将期与定义这些符号的库文件关联。
2. 重定位：调整代码和数据的地址，使其在最终程序中有正确的内存位置。
3. 链接库文件：静态链接、多态链接。

编译器提供不同的优化级别：

- -o0：不优化（用于调试）
- -o1：基础优化（如常量传播、死代码消除）
- -o2：更高级的优化（如循环展开、指令调度）
- -o3：最高级优化（如自动向量化）

## 1.11 性能优化思路

算法优化
1.视锥体过滤
2.面剔除
3.遮挡剔除

4.减少状态切换（opengl）

并行优化
1.多线程技术
2.线程块大小设计（CUDA）

空间换时间优化
1.延迟着色法
2.空间索引（构建BVH树）

内存布局优化
1.合并访问（CUDA 全局内存读取是以32字节为单位）
2.内存对齐

## 1.12 大小端

**定义**

小端字节序：数据的最低字节存储在最低的内存地址。

大端字节序：数据的最高字节存储在最低的内存地址。

**应用场景**

小端字节序：计算机处理器。

大端字节序：网络传输。

**优势**

小端字节序：便于某些计算，比如加法。

大端字节序：可读性高。























































# 2 面向对象编程

C++面向对象编程（OOP）可以**提高代码的复用性和可扩展性，并且降低代码的耦合度**。面向对象有三大特性，分别是**封装、继承、多态**。

封装是将属性和方法定义到类内，并设置对应的访问权限。访问权限分为公开、保护和私有。封装的好处是隐藏实现细节，保护数据，减低耦合度。

继承是为子类指定父类，子类可以继承父类的部分功能。继承方式有三种，分别为**公开继承**、**保护继承**和**私有继承**。另外C++还支持**多继承**，不过多继承可能会引发棱形继承，这时候就需要采用**虚继承**的方式避免重复基类。继承的好处是实现代码复用和功能扩展。

以下内容介绍多态：

## 2.1 多态

**一、什么是多态？**

多态分为编译时多态和运行时多态。

编译时多态是使用重载函数或使用模板实现。

运行时多态是使用虚函数实现。

虚函数的表现是：父类中有一个虚函数，子类中也有一个同名虚函数，当父类指针指向子类对象，使用父类指针调用虚函数，实际调用的是子类的虚函数。

其原理是包含虚函数的类存在一个虚函数表，而每个对象实例都存储了一个指向虚函数表的指针。调用虚函数时，会使用指向虚函数表的指针去找到虚函数表，在虚函数表中索引找到对应虚函数的地址。

**二、为什么构造函数不能是虚函数？**

1、从实现的角度：编译器会在对象的构造函数执行过程中初始化虚函数表指针，所以在构造函数中，虚函数表指针可能还未初始化，无法索引到虚函数表，所以构造函数不能是虚函数。

2、从使用的角度：虚函数的使用就是父类指针指向子类对象并调用虚函数。而构造函数是在创建对象时调用的，所以不可能做到父类指针调用构造函数。

注：为什么析构函数可以是虚函数的问题也可以从以上两个角度回答。

析构函数定义成虚函数也是避免内存泄漏的一种好方法。

虚函数表是在编译时候生成的。

**三、为什么析构函数必须是虚函数？**

当通过基类指针删除派生类对象时，如果基类析构函数不是虚函数，则只会调用基类的析构函数，而不会调用派生类的析构函数。这会导致派生类资源无法正确释放。

## 2.2 友元

**友元**分为**友元函数**和**友元类**。

友元函数:

```c++
class ClassA {
    friend void friendFunction(ClassA &a);
    // ...
};

void friendFunction(ClassA &a) {
    // 可以访问 ClassA 的私有成员
}
```

友元类：

```c++
class ClassB; // 前向声明

class ClassA {
    friend class ClassB; // ClassB 为 ClassA 的友元，ClassB可以访问ClassA的保护成员和私有成员
    // ...
};
```

友元的特点：

- 访问权限：类的友元类或友元函数可以访问其类的保护成员和私有成员。
- 单向关系：如果类A是类B的友元，则类B并不自动成为类A的友元。
- 不继承：如果类 A 声明类 B 为其友元，那么类 B 可以访问类 A 的私有成员；但如果类 C 继承自类 A，类 B 并不能自动访问类 C 的私有成员。

# 3 STL

## 3.1 六大组件

容器：用来存储数据的类模板。

算法：各种常见算法。

迭代器：用于访问容器中元素的对象，提供通过的方式来遍历和访问不同的容器。可以理解为泛型指针。

仿函数：又名**函数对象**，是一种重载了operator()的class或class template。

适配器（配接器）：用来改变容器、迭代器或仿函数的接口，以便它们可以与其他组件配合使用。

配置器：负责管理内存分配和释放。

## 3.2 序列式容器

### 3.2.1 array

描述：固定大小的数组

特性：

- 支持随机访问
- 大小在编译时确定
- 提供更好的性能

### 3.2.2 vector

描述：动态数组

特性：

- 支持随机访问
- 自动扩展大小
- 支持高效的尾部插入

### 3.2.3 deque

描述：双向队列

特性：

- 支持随机访问
- 自动扩展大小
- 支持高效的头部和尾部插入

### 3.2.4 list

描述：双向链表

特性：

- 不支持随机访问
- 支持高效的任意位置插入
- 支持双向遍历

### 3.2.5 forward_list

描述：单向队列

特性：

- 不支持随机访问
- 支持高效的任意位置插入
- 仅支持单向遍历
- 内存开销小于list

### 3.2.6 stack

描述：栈，衍生于deque，属于容器适配器

特性：

- 先进后出

### 3.2.7 queue

描述：队列，衍生于deque，属于容器适配器

特性：

- 先进先出

### 3.2.8 priority_queue

描述：优先队列，衍生于vector，属性容器适配器

特性：

- 使用vector组织完全二叉树实现一个堆

## 3.3 关联式容器

基于**红黑树**

### 3.3.1 set

描述：集合

特点：

- 自动排序
- 不允许重复元素

### 3.3.2 map

描述：键值对

特点：

- 自动排序
- 不允许重复元素

### 3.3.3 multiset

描述：集合

特点：

- 自动排序
- 允许重复元素

### 3.3.4 multimap

描述：键值对

特点：

- 自动排序
- 允许重复元素

------

基于**哈希表**

### 3.3.5 unordered_set

描述：集合

特点：

- 不保证元素的顺序
- 不允许重复元素

### 3.3.6 unordered_map

描述：键值对

特点：

- 不保证元素的顺序
- 不允许重复元素

### 3.3.7 unordered_multiset

描述：集合

特点：

- 不保证元素的顺序
- 允许重复元素

### 3.3.8 unordered_multimap

描述：键值对

特点：

- 不保证元素的顺序
- 允许重复元素

## 3.4 适配器

STL的适配器其实就是实现了一种设计模式，属于在23个经典设计模式里的一种。作用是将一个类的接口转换为另外一个class的接口，使原本不兼容的接口可以协同工作。

STL适配器分为容器适配器、迭代器适配器和算法适配器。

### 3.4.1 容器适配器

```c++
template <class T, class Container = std::deque<T>>
class stack {
protected:
    Container c; // 底层容器
public:
    void push(const T& value) { c.push_back(value); }
    void pop() { c.pop_back(); }
    T& top() { return c.back(); }
    bool empty() const { return c.empty(); }
    size_t size() const { return c.size(); }
};
```

```c++
template <class T, class Container = std::deque<T>>
class queue {
protected:
    Container c; // 底层容器
public:
    void push(const T& value) { c.push_back(value); }
    void pop() { c.pop_front(); }
    T& front() { return c.front(); }
    bool empty() const { return c.empty(); }
    size_t size() const { return c.size(); }
};
```

```c++
template <class T, class Container = std::vector<T>, class Compare = std::less<typename Container::value_type>>
class priority_queue {
protected:
    Container c; // 底层容器
    Compare comp; // 比较函数
public:
    void push(const T& value) {
        c.push_back(value);
        std::push_heap(c.begin(), c.end(), comp);
    }
    void pop() {
        std::pop_heap(c.begin(), c.end(), comp);
        c.pop_back();
    }
    T& top() { return c.front(); }
    bool empty() const { return c.empty(); }
    size_t size() const { return c.size(); }
};
```

### 3.4.2 迭代器适配器

**back_inserter**：允许在容器的末尾插入元素

```c++
template <class Container>
class back_insert_iterator {
protected:
    Container* container;
public:
    explicit back_insert_iterator(Container& c) : container(&c) {}

    back_insert_iterator& operator=(const typename Container::value_type& value) {
        container->push_back(value);
        return *this;
    }
};
```

### 3.4.3 算法适配器

**bind**：用于将函数或可调用对象与部分参数绑定，从而创建一个新的可调用对象。

```c++
#include <iostream>
#include <functional>

void print_sum(int a, int b) {
    std::cout << "Sum: " << a + b << std::endl;
}

int main() {
    auto bound_print = std::bind(print_sum, 10, std::placeholders::_1);
    bound_print(5); // 输出: Sum: 15
    return 0;
}
```

## 3.5 配置器

STL配置器分为一级配置器和二级配置器，分配超过128字节的内存是使用一级配置器。分配128字节以下的内存是使用二级配置器。

一级配置器是使用malloc和free管理内存。

二级配置器维护了一个内存池和自由链表，提高了内存分配的效率和内存的利用率（减少内存碎片）。

二级配置器维护了16个自由链表，自由链表挂载的内存块大小分别是8、16、25...128字节。

二级配置器分配内存时，首先从自由链表获取，若不足，则向内存池获取，若内存池不足，则使用malloc重新申请内存池。若申请失败，则使用一级配置器以抛出异常。

![image-20250312145341349](C++.assets/image-20250312145341349.png)

3.2 交换两个变量

```c++
std::swap(a, b);
```

3.3 安全的分配一块内存空间

```
std::vector<std::byte> data;
```

# 4 内存管理

RAII（资源获取即初始化）是一种资源管理技术，核心思想是将资源的生命周期与对象的生命周期绑定。

- 当对象构造时获取资源。
- 当对象析构时释放资源。

# 5 模板编程

C++模板编程可以在不指定具体类型的情况下定义模板函数或模板类，使用时编译器会在编译期间根据实际类型自动生成的代码。这种机制提高了代码的复用性。

## 5.1 模板类型推导

模板类型推导时，编译器需要同时推导两个类型：

- T：模板类型。
- ParamType：函数形参类型。

模板类型的推导结果由函数形参类型和实参类型共同决定。主要分为三种情况：

**5.1.1 函数形参类型是指针或引用（非万能引用）**

若实参是引用，先忽略引用部分，然后将实参类型和形参类型匹配，推导出模板类型。

```c++
template<typename T>
void f(T& param);  // ParamType是T&

int x = 27;         // x是int
const int cx = x;   // cx是const int
const int& rx = x;  // rx是const int&

f(x);   // 实参是int → T=int，param类型是int&
f(cx);  // 实参是const int → T=const int，param类型是const int&
f(rx);  // 实参是const int&（忽略引用）→ T=const int，param类型是const int&
```

**5.1.2 函数实参类型是万能引用**

C++只存在两种引用，分别是左值引用（T&）和右值引用（T&&），C++不允许直接声明“引用的引用”，但模板类型推导可能间接产生这种情况，引用折叠规则正是用于处理这类场景。

**引用折叠**规则：

- 若组合中包含左值引用（&），则最终结果为左值引用（&）。
- 若组合中只有右值引用（&&），则最终结果为右值引用（&&）。



先根据引用折叠推导出左值引用或右值引用，然后将实参类型和形参类型匹配，推导出模板类型。

```c++
template<typename T>
void f(T&& param);  // 万能引用

int x = 27;         // 左值
const int cx = x;   // 左值
const int& rx = x;  // 左值

f(x);   // 左值 → T=int&，param类型int&（引用折叠：int& && → int&）
f(cx);  // 左值 → T=const int&，param类型const int&
f(rx);  // 左值 → T=const int&，param类型const int&
f(27);  // 右值 → T=int，param类型int&&
```

**5.1.3 函数实参类型是按值传递**

直接忽略实参的引用和const修饰。

## 5.2 模板特性

**5.2.1 有默认类型的模板**

```c++
template<typename T = int>
void f();

f();            // 默认为 f<int>
f<double>();    // 显式指明为 f<double>
```

**5.2.2 非类型模板**

非类型模块可以是接受值或者对象。

```c++
template<std::size_t N>
void f() { std::cout << N << '\n'; }

f<100>();
```

**5.2.3 重载模板**

```c++
// 模板1：单个参数
template<typename T>
void func(T x) { /* 实现1 */ }

// 模板2：两个参数（重载版本）
template<typename T, typename U>
void func(T x, U y) { /* 实现2 */ }

// 非模板函数（也可与模板构成重载）
void func(int x) { /* 非模板实现 */ }
```

**5.2.4 可变参数模板**

可变参数模板的核心是参数包，即包含零个或多个模板参数的集合。分为两种：

- 模板参数包
- 函数参数包

```c++
// 模板参数包：Args是一个包含零个或多个类型的参数包
template<typename... Args>
// 函数参数包：params是一个包含零个或多个参数的参数包
void func(Args... params) {
    // 展开参数包的代码
}
```

可变参数的展开可以通过折叠表达式。**折叠表达式**通过指定一个运算符和参数包，将参数包中的所有元素按运算符依次组合，形成一个表达式。

折叠表达式根据折叠方向和是否包含初始值可分为四种：

**一元左折叠**

从左到右依次应用运算符，(..., args) 等价于 ((arg1, arg2), arg3), ..., argN。

**一元右折叠**

从右到左依次应用运算符，(args + ...) 等价于 arg1 + (arg2 + (arg3 + ... + argN)...)。

**二元左折叠**

从左到右结合初始化值运算，(0 + ... + args) 等价于 (((0 + arg1) + arg2) + arg3) + ... + argN。

**二元右折叠**

从右到左结合初始值运算，(args + ... + 0) 等价于 arg1 + (arg2 + (arg3 + ... + (argN + 0)...))。

注：C++折叠表达式只能使用二元运算符。

**5.2.5 模板必须定义在.h文件**

C++采用**分离式编译**，即每个cpp文件独立编译为目标文件（.obj或.o），最后由链接器将所有文件合并为可执行文件。

模板仅在使用时进行**模板实例化**。若将模板的定义存储在cpp文件，由于cpp中未使用模板，所以不会进行模板实例化，最终生成的目标文件将没有模板的定义。

**5.2.6 模板全特化和模板偏特化**

模板全特化是指为模板的所有模板参数指定具体类型，从而为该特定参数组合提供专属实现。

```c++
// 通用函数模板
template<typename T>
void print(T value) {
    std::cout << "通用模板: " << value << std::endl;
}

// 全特化版本：为int类型定制实现
template<>
void print<int>(int value) {
    std::cout << "int特化版本: " << value << " (整数处理)" << std::endl;
}

// 全特化版本：为const char*类型定制实现
template<>
void print<const char*>(const char* value) {
    std::cout << "字符串特化版本: " << value << " (字符串处理)" << std::endl;
}
```

模板偏特化是指为模板的部分模板参数指定具体类型，从而为该特定参数组合提供专属实现。

```c++
// 通用类模板（两个参数）
template<typename T, typename U>
class Pair {
public:
    void print() const {
        std::cout << "通用模板: T=" << typeid(T).name() 
                  << ", U=" << typeid(U).name() << std::endl;
    }
};

// 偏特化：固定第一个参数为int，第二个参数保留
template<typename U>
class Pair<int, U> {
public:
    void print() const {
        std::cout << "偏特化(int, U): U=" << typeid(U).name() << std::endl;
    }
};

// 偏特化：固定第二个参数为double，第一个参数保留
template<typename T>
class Pair<T, double> {
public:
    void print() const {
        std::cout << "偏特化(T, double): T=" << typeid(T).name() << std::endl;
    }
};
```

# 6 并发编程

一个进程可与包含多个线程。进程是操作系统分配资源基本单位，拥有独立的虚拟内存。线程是CPU调度的基本单位，一个进程下的多个线程共享代码区、常量区、全局数据区和堆区，但拥有独立的栈区。

并发是逻辑上的同时，并行是物理上的同时。采用多线程技术的目的无非是**提高平均响应速度**和**实现并行**。

## 6.1 线程知识

**6.1.1 线程池的合适线程数**

合适线程数 = 硬件线程数 / 任务的计算时间占比

**6.1.2 一个进程最多可以创建的线程数**

每个线程拥有独立的栈空间，所以创建线程的资源开销是栈空间。那么最大线程数 = 进程剩余空闲内存 / 单个线程的栈空间。

## 6.2 线程管理

**6.2.1 创建线程**

通过std::thread构造函数，传入**可调用对象**（函数、lambda、函数对象）及参数，构造完成后线程立即启动。参数传递时默认是按值传递，若可调用对象的参数是引用，需要使用**std::ref**或**std::cref**显式传递引用。

```c++
void task(int a, const std::string& s) { /* 执行逻辑 */ }
int main() {
    std::string msg = "test";
    // 1. 传入函数+参数（用std::cref传递const引用）
    std::thread t1(task, 10, std::cref(msg));
    // 2. 传入lambda（捕获外部变量）
    std::thread t2([&msg]() { /* 使用msg */ });
}
```

**6.2.2 等待线程**

父线程调用子线程**join()**函数会阻塞自身等待子线程执行完毕。一个线程生命周期内仅能调用一次join函数。

```c++
std::thread t(task);
if (t.joinable()) { // 安全检查：避免重复join
    t.join(); // 主线程等待t执行完，再继续往下走
}
```

**6.2.3 线程分离**

调用**detach()**函数后，线程与线程对象会分离，线程对象不再管理线程。

```c++
void background_log() { /* 持续打印日志 */ }
int main() {
    std::thread t(background_log);
    t.detach(); // 线程分离，主线程退出时后台线程仍可能运行（需确保进程不退出）
    return 0; // 主线程退出，若后台线程未执行完，会被操作系统强制终止
}
```

**6.2.4 转移线程所有权**

```c++
// 空线程接收所有权
std::thread t1(task);
std::thread t2; // 空线程
t2 = std::move(t1); // t1所有权转移给t2，t1变为空线程（joinable() == false）
```

**6.2.5 可中断线程**

C++20引入std::jthread可中断线程，它基于RAII（资源获取即初始化）思想设计。在线程对象析构时自动调用join，并且可以执行中断操作，不过中断之后不可重新启动。

```c++
#include <iostream>
#include <thread>
#include <chrono>

// 可中断的任务函数
void interruptible_task(std::stop_token st) {
    for (int i = 0; i < 10; ++i) {
        // 检查是否收到中断请求
        if (st.stop_requested()) {
            std::cout << "Task interrupted\n";
            return;
        }
        
        std::cout << "Working... " << i << '\n';
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
}

int main() {
    // 创建 jthread 并传递可中断任务
    std::jthread t(interruptible_task);
    
    // 主线程等待 3 秒后请求中断
    std::this_thread::sleep_for(std::chrono::seconds(3));
    std::cout << "Requesting interrupt...\n";
    
    // 获取 stop_source 并请求中断
    auto& source = t.get_stop_source();
    source.request_stop();
    
    return 0;
}
```

## 6.3 线程间共享数据

线程间共享数据可能会出现恶性条件竞争，进而引发未定义行为。因此需要一些同步操作避免恶性条件竞争。

### 6.3.1 锁

**std::mutex 互斥锁**

支持加锁、尝试加锁、解锁。

```c++
#include <mutex>
#include <thread>

std::mutex m;
int shared_data = 0;

void increment() {
    m.lock();
    shared_data++;  // 临界区操作
    m.unlock();
}

int main() {
    std::thread t1(increment);
    std::thread t2(increment);
    t1.join();
    t2.join();
    return 0;
}
```

**std::recursive_mutex 递归锁**

支持同一线程多次锁定，但是需要对应次数的解锁操作。

```c++
#include <mutex>

std::recursive_mutex rm;
int count = 0;

void recursive_func(int depth) {
    rm.lock();
    count++;
    if (depth > 0) {
        recursive_func(depth - 1);  // 同一线程可再次锁定
    }
    rm.unlock();  // 需与锁定次数匹配
}

int main() {
    recursive_func(3);  // 会递归锁定4次
    return 0;
}
```

**std::timed_mutex 超时锁**

线程在指定的时间内尝试锁定互斥量，并在超时后选择放弃锁。

```c++
#include <mutex>
#include <chrono>

std::timed_mutex tm;

void try_lock_with_timeout() {
    // 尝试锁定1秒，超时返回false
    if (tm.try_lock_for(std::chrono::seconds(1))) {
        // 成功获取锁
        tm.unlock();
    } else {
        // 超时处理
    }
}
```

**std::recursive_timed_mutex 超时递归锁**

```c++
#include <iostream>
#include <mutex>
#include <chrono>
#include <thread>

std::recursive_timed_mutex rtm;

// 递归函数，演示多次锁定
void recursive_func(int level) {
    // 尝试锁定，最多等待1秒
    if (rtm.try_lock_for(std::chrono::seconds(1))) {
        std::cout << "第" << level << "层：获取锁成功\n";

        // 递归终止条件
        if (level > 0) {
            recursive_func(level - 1); // 同一线程再次锁定
        }

        rtm.unlock(); // 解锁（次数需与锁定次数一致）
        std::cout << "第" << level << "层：释放锁\n";
    }
    else {
        std::cout << "第" << level << "层：获取锁超时\n";
    }
}

int main() {
    // 测试递归锁定（共3层递归）
    recursive_func(2);
    return 0;
}

```

**std::shared_mutex 读写锁**

支持两种锁定模式：共享锁和独占锁。

```c++
#include <shared_mutex>
#include <vector>

std::shared_mutex sm;
std::vector<int> data;

// 读操作（共享锁）
int read_data(int index) {
    std::shared_lock<std::shared_mutex> lock(sm);  // 共享锁
    return data[index];
}

// 写操作（独占锁）
void write_data(int value) {
    std::unique_lock<std::shared_mutex> lock(sm);  // 独占锁
    data.push_back(value);
}
```

### 6.3.2 锁管理类

**std::lock_guard 锁管理类**

```c++
#include <mutex>

std::mutex m;

void safe_operation() {
    std::lock_guard<std::mutex> lock(m);  // 构造时锁定
    // 临界区操作（无需手动解锁）
}  // 析构时自动解锁
```

**std::scoped_lock 多锁管理类**

```c++
#include <mutex>

std::mutex m1, m2;

void process_data() {
    // 同时锁定多个互斥量，自动避免死锁
    std::scoped_lock lock(m1, m2);
    // 需同时持有m1和m2的操作
}  // 自动解锁所有互斥量
```

**std::unique_lock 独占锁管理类**

- 支持手动加锁、解锁。
- 可转移互斥量的所有权。
- 配合timed_mutex可支持超时加锁。
- 配合shared_mutex 可支持独占加锁。

```c++
#include <mutex>

std::timed_mutex tm;

void flexible_lock() {
    // 延迟锁定（不立即获取锁）
    std::unique_lock<std::timed_mutex> lock(tm, std::defer_lock);
    
    // 手动尝试锁定（超时1秒）
    if (lock.try_lock_for(std::chrono::seconds(1))) {
        // 操作...
        lock.unlock();  // 可提前解锁
        
        // 必要时重新锁定
        lock.lock();
    }
}
```

**std::shared_lock 共享锁管理类**

```c++
#include <shared_mutex>
#include <iostream>

std::shared_mutex sm;
int value = 0;

void reader() {
    std::shared_lock<std::shared_mutex> lock(sm);  // 共享读锁
    std::cout << "Read value: " << value << std::endl;
}  // 自动释放共享锁

int main() {
    // 多个读者可同时访问
    std::thread r1(reader);
    std::thread r2(reader);
    r1.join();
    r2.join();
    return 0;
}
```

### 6.3.3 线程变量

线程变量也称为线程局部变量，每个线程都拥有该变量的独立副本。

```c++
#include <iostream>
#include <thread>

// 声明线程局部变量
thread_local int counter = 0;

void increment_and_print() {
    // 每个线程都会修改自己的counter副本
    counter++;
    std::cout << "线程ID: " << std::this_thread::get_id()
        << ", counter值: " << counter << std::endl;
}

int main() {
    // 主线程的counter初始值为0
    std::cout << "主线程ID: " << std::this_thread::get_id()
        << ", 初始counter值: " << counter << std::endl;

    // 创建两个子线程
    std::thread t1(increment_and_print);
    std::thread t2(increment_and_print);

    t1.join();
    t2.join();

    // 主线程的counter仍为0（不受子线程影响）
    std::cout << "主线程ID: " << std::this_thread::get_id()
        << ", 最终counter值: " << counter << std::endl;
    return 0;
}

/*
主线程ID: 27152, 初始counter值: 0
线程ID: 27464, counter值: 1
线程ID: 23800, counter值: 1
主线程ID: 27152, 最终counter值: 0
*/
```

### 6.3.4 条件变量

条件变量实现了生产者和消费者模型，避免线程忙等待，提高CPU利用率。

条件变量有两种类型：

- std::condition_variable：仅支持与`std::unique_lock<std::mutex>` 配合使用。
- std::condition_variable_any：支持所有锁配合使用（如 `std::lock_guard`、`std::shared_lock`）。

使用流程：

加锁：用`std::unique_lock` 锁定互斥锁。

```c++
std::unique_lock<std::mutex> lock(mtx);
```

等待条件：使用带条件的等待避免虚假唤醒。

```c++
// 消费者等待队列非空
cv.wait(lock, []{ return !queue.empty(); });
```

操作共享资源：条件满足后操作数据。

```c++
int data = queue.front();
queue.pop();
```

通知对方：操作完成后通知等待线程。

```c++
cv.notify_one();  // 唤醒一个等待的生产者/消费者
```

完整示例

```c++
#include <iostream>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <queue>

// 共享队列（临界资源）
std::queue<int> data_queue;
// 保护队列的互斥锁
std::mutex mtx;
// 条件变量：用于通知“队列非空”（消费者等待）和“队列非满”（生产者等待）
std::condition_variable cv;
const int MAX_QUEUE_SIZE = 5;  // 队列最大容量

// 生产者：向队列存数据
void producer(int id) {
    for (int i = 0; i < 10; ++i) {
        // 1. 加锁保护临界资源
        std::unique_lock<std::mutex> lock(mtx);

        // 2. 等待“队列非满”（避免队列溢出）
        // 用 wait(lock, pred) 避免虚假唤醒
        cv.wait(lock, []() {
            return data_queue.size() < MAX_QUEUE_SIZE;
            });

        // 3. 生产数据（操作临界资源）
        int data = id * 100 + i;
        data_queue.push(data);
        std::cout << "生产者 " << id << " 生产：" << data
            << "，队列大小：" << data_queue.size() << std::endl;

        // 4. 通知消费者：队列非空了
        cv.notify_one();  // 只需唤醒一个消费者

        // 5. 解锁：unique_lock 析构时自动解锁
    }
}

// 消费者：从队列取数据
void consumer(int id) {
    for (int i = 0; i < 5; ++i) {  // 每个消费者消费5个数据
        // 1. 加锁保护临界资源
        std::unique_lock<std::mutex> lock(mtx);

        // 2. 等待“队列非空”（避免取空数据）
        cv.wait(lock, []() {
            return !data_queue.empty();
            });

        // 3. 消费数据（操作临界资源）
        int data = data_queue.front();
        data_queue.pop();
        std::cout << "消费者 " << id << " 消费：" << data
            << "，队列大小：" << data_queue.size() << std::endl;

        // 4. 通知生产者：队列非满了
        cv.notify_one();  // 只需唤醒一个生产者

        // 5. 解锁：unique_lock 析构时自动解锁
    }
}

int main() {
    // 创建2个生产者、4个消费者
    std::thread p1(producer, 1);
    std::thread p2(producer, 2);
    std::thread c1(consumer, 1);
    std::thread c2(consumer, 2);
    std::thread c3(consumer, 3);
    std::thread c4(consumer, 4);

    p1.join(); p2.join();
    c1.join(); c2.join(); c3.join(); c4.join();

    return 0;
}
```

### 6.3.5 信号量

信号量本质是一个非负整数计数器，通过两个核心操作控制线程行为：

- 获取：尝试将计数器减一，若尝试失败，线程会阻塞等待，直到计数器大于0为止。
- 发布：将计数器加一，唤醒等待n（默认为1）个等待线程。

有两种信号量类型：

- std::binary_semaphore：二进制信号量，计数器只能是0或1.
- std::counting_semaphore<LeastMaxValue>：计数信号量，计数器可以是0到LeastMaxValue之间的整数。

使用示例：

```c++
#include <iostream>
#include <semaphore>
#include <thread>
using namespace std;

const int buffer_size = 5;// 缓冲区大小
std::binary_semaphore b_mutex(1);
//容量为5 赋初值
std::counting_semaphore<buffer_size> b_full(0);
std::counting_semaphore<buffer_size> b_empty(5);
void Producer()
{
    while (true)
    {
        b_empty.acquire();
        b_mutex.acquire();
        std::cout << "Producer\n";
        b_mutex.release();
        b_full.release();
        //模拟生成过程
        std::this_thread::sleep_for(std::chrono::seconds(2));
    }
}
void Consumer()
{
    while (true)
    {
        b_full.acquire();
        b_mutex.acquire();
        std::cout << "Consumer\n";
        b_mutex.release();
        b_empty.release();
        //模拟消耗过程
        std::this_thread::sleep_for(std::chrono::seconds(2));
    }
}
int main()
{
    thread t0(Producer);
    thread t1(Producer);
    thread t2(Consumer);
    thread t3(Consumer);

    t0.join();
    t1.join();
    t2.join();
    t3.join();
}

```

**条件变量适用于复杂的唤醒条件。信号量适用于控制并发量。**

### 6.3.6 原子变量

C++可以将某些变量定义为原子变量，对原子变量执行的操作称为原子操作，原子操作具有不可分割性。

## 6.4 协程

**用户态线程**由应用程序创建和调度。

**内核态线程**由操作系统内核创建和调度。

协程分为有栈协程和无栈协程，有栈协程相当于用户态线程，无栈协程相当于可挂机和回复的函数。C++20协程采用的是无栈协程。

协程的工作流程：

**6.4.1 编译器识别协程函数**

当函数体内出现 `co_await`、`co_yield` 或 `co_return` 时，编译器会将其视为协程。接着编译器会检查函数返回值类型内部是否包含承若对象，否则编译报错。

**6.4.2 创建协程状态**

编译器会在堆上分配一块**协程帧**，由于保存以下数据：

- 局部变量（函数体局部变量、函数形参）
- 承若对象
- 恢复点信息

**6.4.3 自动调用承若对象接口处理协程事件**

- `get_return_object()`：获取协程函数返回值。
- `initial_suspend()`：决定协程是否在开始时立即挂起。
- `return_value()` / `return_void()`：处理 `co_return` 的值。
- `final_suspend()`：协程结束前的挂起点，通常用于调度清理。
- `unhandled_exception()`：处理协程内部未捕获的异常。

**6.4.4 通过等待体决定挂起策略**

标准库提供了两个简单的等待体：

- `std::suspend_never`：从不挂起。
- `std::suspend_always`：总是挂起

**6.4.5 通过协程句柄控制协程生命周期**

- `resume()`：恢复执行。
- `destroy()`：销毁协程帧，释放内存。

线程适合高并行需求，协程合适高并发需求。



























二段式构造：构造函数不应该泄漏this，因为该类可能是一个基类，难以保证对象已经完成构造。
顺序加锁：swap函数需要对两个对象进行加锁，若加锁顺序不确定，两个线程同时调用该函数可能出现死锁。





性能优化：

算法优化
1.视锥体过滤
2.面剔除
3.遮挡剔除（深度遮挡、窗口遮挡）

并行优化
1.多线程技术
2.线程块大小设计（CUDA）

空间换时间优化
1.延迟着色法
2.空间索引（构建BVH树）

内存布局优化
1.合并访问（CUDA 全局内存读取是以32字节为单位）
2.内存对齐

















































































# 附录

## C++11

1. auto
2. 基于范围的for
3. 只能指针
4. nullptr
5. Lambda表达式
6. 类枚举

## C++14

1. std::make_unique
2. 泛型 Lambda 表达式
3. 返回值后置

## C++17

1. std::byte
2. 结构化绑定
3. 内联变量
4. string_view

## C++20

1. 三路比较

2. 指向初始化

3. 协程

4. 模块化

   



# GL

VAO：顶点数组对象。

VBO：顶点缓冲对象。

EBO：索引缓冲对象。

FBO：帧缓冲对象。

RBO：渲染缓冲对象

## 渲染管线

渲染管线就是一堆原始图形数据经过各种变化处理最终出现在屏幕的过程。

渲染管线可以分为三个阶段：应用程序阶段、几何阶段和光栅化阶段

应用程序阶段由主要由CPU负责，CPU将GPU渲染想要的灯光、模型准备好，并设置好渲染状态，为GPU渲染做好准备。

几何阶段分为顶点着色器、图元装配和几何着色器

**顶点着色器**：以顶点坐标作为输入，将顶点坐标从局部空间变换为裁剪空间，然后输出

**几何着色器**：以一组顶点作为输入，添加新的顶点。然后输出一组顶点。该步骤可以改变几何形状。

**图元装配**：将所有的点装配成指定的图元的形状。

光栅化阶段分为

**光栅化**：把图元映射为屏幕上相应的像素，生成供片段着色器使用的片段。在片段着色器之间会执行裁切。

**片段着色器**：计算一个像素的最终颜色

**测试与混合**：进行深度测试和颜色混合

![image-20250213102739714](C++.assets/image-20250213102739714.png)

## **着色器**

uniform是全局可见的。

每个顶点和片段特有的数据一般使用VAO和VBO进行传输，通用的数据一般使用uniform传输。

## 纹理

纹理坐标：（0, 0) ~ (1, 1)

纹理环绕：

| 环绕方式           | 描述             |
| :----------------- | :--------------- |
| GL_REPEAT          | 重复纹理图像     |
| GL_MIRRORED_REPEAT | 镜像重复纹理图像 |
| GL_CLAMP_TO_EDGE   | 重复纹理边缘     |
| GL_CLAMP_TO_BORDER | 指定颜色         |

纹理过滤：

| 过滤方式   | 描述     |
| ---------- | -------- |
| GL_NEAREST | 临近过滤 |
| GL_LINEAR  | 线性过滤 |

多级渐远纹理

| 过滤方式                  | 描述                                                         |
| :------------------------ | :----------------------------------------------------------- |
| GL_NEAREST_MIPMAP_NEAREST | 使用最邻近的多级渐远纹理级别，并使用邻近插值进行采样         |
| GL_LINEAR_MIPMAP_NEAREST  | 使用最邻近的多级渐远纹理级别，并使用线性插值进行采样         |
| GL_NEAREST_MIPMAP_LINEAR  | 在两个最匹配的多级渐远纹理进行线性插值，然后使用邻近插值进行采样 |
| GL_LINEAR_MIPMAP_LINEAR   | 在两个最匹配的多级渐远纹理进行线性插值，然后使用线性插值进行采样 |

## 摄像机

欧拉角：

- 俯仰角
- 偏航角
- 滚转角

## 光照

环境光照

漫反射光照

镜面反射光照

Blinn-Phong引入了半程向量的概念，优化了镜面反射。计算半程向量和法向量的夹角。

## 帧缓冲

完整的帧缓冲：

1. 附加至少一个缓冲
2. 至少有一个颜色附件
3. 所有附件都是完整的
4. 每个缓冲都有相同的样本数

附件有两种：

1. 纹理附件
2. 渲染附件对象

## 延迟渲染

正向着色法：根据所有光源计算一个一个计算物体。

延迟着色法：

1. 几何处理阶段：
1. 光照阶段

优点：G缓冲中的片段和在屏幕上呈现内容是一样的，这样保证在光照处理阶段中每一个像素都只处理一次。

缺点：

- 占用大量显存。
- 不支持混色

## SSAO

光线会以任意方向散射，而且强度会发生变化，所以间接被照到的那部分场景不能直接使用一开始的环境光。间接关照的模拟叫做环境光遮蔽。

屏幕空间环境光遮蔽SSAO：对于铺屏四边形上的每一个片段，我们都会根据周边深度值计算一个遮蔽因子。遮蔽因子是通过采集片段周围半球型核心的多个深度样本，并和当前片段深度值对比而得到的。高于片段深度值样本的个数就是我们想要的遮蔽因子。

## 骨骼动画

动画节点 -> 持续时间 各个骨骼关键帧
骨骼 -> 名称 影响的顶点及权重

骨骼动画在实现时，动画节点存储持续时间和各骨骼关键帧，骨骼记录所影响的顶点及权重，程序运行时根据当前时间对关键帧插值得到骨骼矩阵，每个顶点通过自身绑定的骨骼 ID 和权重因子，将各骨骼影响加权组合成变换矩阵

assimp 艾辛普

learnOpenGL 论opengl

Blinn-Phong 布林-方

RenderDoc 问的doc