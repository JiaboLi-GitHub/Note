# TBB学习笔记

## 1.并行算法

多个函数对象并行执行

```c++
template<typename... Fs>
void parallel_invoke(Fs&&... fs)	
```



将一个循环体分解成多个独立的任务并发执行

```c++
template<typename Range, typename Body>
void parallel_for(const Range& range, Body&& body);
```

