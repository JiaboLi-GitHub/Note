# 1.QML语法

QtQuick是基于QML构建的框架，用于构建应用程序的用户界面。

## 1.1.属性

### 1.1.1.id属性

id是特殊的属性，id的值不是字符串类型，而是标识符，id需要在文档内保持唯一。

一个元素id应该只在当前文档中被使用。QML提供了动态作用域的机制，后加载的文档会覆盖之前加载文档的id号。

### 1.1.2.绑定

一个属性可以依赖一个或多个其他属性

绑定与赋值的区别在于绑定是一种契约，在绑定的整个生命周期内保存真实，而赋值是一次性赋值。赋值会打破契约。

### 1.1.3.新属性

新属性：property <type> <name> : <value>

可以使用关键字default将一个属性声明为默认属性，默认属性至多有一个。当定义对象时，如果其子对象没有明确的指定它要分配到的属性名，那么这个子对象就被赋值给默认属性。

### 1.1.4.别名

property alias <name>: <reference>

### 1.1.5.每个属性都自动提供了一个信号操作

## 1.2.脚本

定义一个JS函数，function <name>(<parameters>) { ... }

## 1.3.元素

元素可以被分为可视化元素与非可视化元素。

Items是所以可视化元素的基础对象，所以其他的可视化元素都继承自Item。

QtQuick中非常重要的概念：输入处理与可视化显示分开，这样交互区域可以比显示的区域大。

## 1.4.组件

### 1.4.1.单文件组件

在一个QML文件中定义整个组件，QML文件名就是新组件的名称。

## 1.5.定位器

定位器和布局的区别：定位器只管理Item的位置。布局除了管理Item的位置和大小。

QtQuick模块提供了Row，Column，Grid（栅格），Flow（流）原来作为定位器。

```
Row {
    Button { text: "Button 1" }
    Button { text: "Button 2" }
    Button { text: "Button 3" }
}

Column {
    TextField { placeholderText: "Name" }
    TextField { placeholderText: "Email" }
    Button { text: "Submit" }
}

Grid {
    columns: 3
    Button { text: "Button 1" }
    Button { text: "Button 2" }
    Button { text: "Button 3" }
    Button { text: "Button 4" }
    Button { text: "Button 5" }
    Button { text: "Button 6" }
}

Flow {
    width: parent.width
    Repeater {
        model: 10
        delegate: Rectangle {
            width: 50; height: 50
            color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)
        }
    }
}
```

































































QML结构：

```
元素名 {
    属性名1: 属性值1
    属性名2: 属性值2
    ...
    子元素1 {
        ...
    }
    子元素2 {
        ...
    }
    ...
}    
```

## 1.1 属性

### 1.1.1 id属性



### 1.1.2 自定义属性

```
[default] [required] [readonly] property <propertyType> <propertyName>
```

声明自定义属性会隐式地创建一个属性修改信号on<PropertyName>Changed

### 1.1.3 信号属性

1.1.4 信号处理属性

1.1.5 函数属性

1.1.6 附加属性

1.1.7 枚举属性
