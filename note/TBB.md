# TBB学习笔记

**强缩放**：强缩放是指在固定问题规模的情况下，通过增加计算资源（如处理器、线程）来减少计算时间的能力。

**弱缩放**：弱缩放是指在增加计算资源的同时，增加问题规模，以保持每个处理单元的工作量不变。

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

使用场景：**负载均衡**

### 1.3.parallel_reduce

并行归约操作。

```c++
template<typename Range, typename Body, typename Reducer>
ResultType parallel_reduce(const Range& range, ResultType init, Body&& body, Reducer&& reducer);
```

- Range：表示要处理的数据范围。
- init：归约操作的初始值。
- body：用于定义归约操作的可调用对象（如 Lambda 表达式）。
- reducer：用于合并结果的函数（如 std::plus）。

适合场景：数组**总和**、均值、最小值、最大值。

示例：

```c++
#include <iostream>
#include <vector>
#include <tbb/tbb.h>

constexpr int N = 100000000;

int main()
{

	std::vector<int> a;
	for (int i = 1; i <= N; i++)
		a.push_back(i);

	int max = tbb::parallel_reduce(
		tbb::blocked_range<int>(0, a.size()),
		0,
		[&](const tbb::blocked_range<int>& r, int init) -> int
		{
			for (int i = r.begin(); i != r.end(); ++i)
			{
				init = std::max(init, a[i]);
			}
			return init;
		},
		[](int x, int y)
		{
			return std::max(x, y);
		}
	);

	std::cout << max << std::endl;
	return 0;
}
```

### 1.4.parallel_scan

并行聚合操作（扫描操作）。

```c++
template<typename Range, typename Body, typename Reducer>
ResultType parallel_reduce(const Range& range, ResultType init, Body&& body, Reducer&& reducer);
```





