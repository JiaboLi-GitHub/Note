# C++

## 1 基础语法

### 1.1 类型转换

C++类型转换有四种：

1. static_cast
2. dynamic_cast
3. const_cast
4. reinterpret_cast



```
static_cast<T>(expression);
static_cast<T*>(expression);
```

静态转换有两种用法：

- 基本数据类型的转换。
- 类层次结构中分类和子类之间指针或引用的转换。

将子类的指针或引用通过静态转换为父类指针是安全的，反之不安全。static_cast仅在编译时进行类型检查。



```
dynamic_cast<T*> (expression)
```

动态转换仅支持带有虚函数的类指针或引用，转换失败返回nullptr。dynamic_cast在运行时进行类型检查。



```
const_cast<T*>(expression);
```

const_cast不会改变原始对象的const属性，若修改一个被const声明的对象，其结果是未定义的。其意义在于配合某些函数的使用。例如：

```c++
#include<iostream>
using namespace std;

const int* Search(const int* a, int n, int val);

int main()
{
    int a[10] = { 0,1,2,3,4,5,6,7,8,9 };
    int val = 5;
    int* p;
    p = const_cast<int*>(Search(a, 10, val));
    if (p == NULL)
    {
        cout << "Not found the val in array a" << endl;
    }
    else
    {
        *p = 500;
        cout << "hvae found the val in array a and the val = " << *p << endl;
    }
    return 0;
}

const int* Search(const int* a, int n, int val)
{
    int i;
    for (i = 0; i < n; i++)
    {
        if (a[i] == val)
            return &a[i];
    }
    return  NULL;
}
```



```
reinterpret_cast<T*>(expression);
```

重新解释转换允许将指针类型转换未任何其他类型的指针，甚至是完全不相关的类型。



### 1.2 const

```c++
const T* ptr;	// 数据不可修改
T* const ptr;	// 指针不可修改
```

左定值，右定向。

### 1.3 指定初始化

```
struct Point {
    int x;
    int y;
};

Point p{.x = 10, .y = 20}; // C++20 中的指定初始化
```

聚合初始化

## 2 面向对象编程

## 3 STL

### 3.1 交换两个变量

```c++
std::swap(a, b);
```

### 3.2 安全的分配一块内存空间

```
std::vector<std::byte> data;
```

```

```





























































## 4 内存管理

## 5 异常处理

## 6 模板编程

## 8 并发编程

## 附录

### C++11

1. auto
2. 基于范围的for
3. 指针指针
4. nullptr
5. Lambda表达式
6. 类枚举

### C++14

1. std::make_unique
2. 泛型 Lambda 表达式
3. 返回值后置

### C++17

1. std::byte
2. 结构化绑定
3. 内联变量
4. string_view

### C++20

1. 三向比较
2. 指向初始化
3. 协程
