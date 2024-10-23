# TBB学习笔记

## 1.并行算法

### 1.1.parallel_invoke

多个函数对象并行执行

```c++
template<typename... Fs>
void parallel_invoke(Fs&&... fs)	
```

### 1.2.parallel_for

将一个循环体分解成多个独立的任务并发执行

```c++
template<typename Range, typename Body>
void parallel_for(const Range& range, Body&& body);
```

- Range：表示要迭代的范围，可以是简单的整数范围或复杂的对象。
- Body：表示循环体的可调用对象（如 Lambda 表达式或函数对象）。

### 1.3.parallel_reduce

将一个数据范围分解成多个独立的部分，并在这些部分上并行执行归约操作。

```c++
template<typename Range, typename Body, typename Reducer>
ResultType parallel_reduce(const Range& range, ResultType init, Body&& body, Reducer&& reducer);
```

- Range：表示要处理的数据范围。
- init：归约操作的初始值。
- body：用于定义归约操作的可调用对象（如 Lambda 表达式）。
- reducer：用于合并结果的函数（如 std::plus）。

