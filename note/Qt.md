# 1 多线程编程

## 1.1 Qt实现多线程的方式

方法一：继承QThread，重写run函数，调用start函数启动线程。

方法二：继承QObject实现业务逻辑，通过moveToThread函数移动到新线程中。

方法三：使用QThreadPool线程池

方法四：使用QtConcurrent模块提供的高层API，实现并行计算。

