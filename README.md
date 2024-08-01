---
coverY: 0
---

# 线性代数

## 1.向量

## 1.1.归一化

计算方法

```cpp
 //计算向量的模长
 length = sqrt(x^2 + y^2 + z^2)
 //每个分量除以模长
 normalized_x = x / length
 normalized_y = y / length
 normalized_z = z / length
     
 glm::normalize
```

特点

* 模长为1
* 只包含方向信息，不包含大小信息

\
