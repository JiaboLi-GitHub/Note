# JS 面向对象

面向对象编程（OOP）是一种编程范式，它通过对象来组织和管理代码。JavaScript 作为一种多范式编程语言，支持面向对象编程，使得开发者能够以更自然的方式建模现实世界的事物。以下是创建对象和实现继承的主要方式。

## 1 创建对象

JavaScript 创建对象的方式主要有四种，每种方式都有其特定的用途和场景。

### 1.1 对象字面量

对象字面量是一种简单且直观的方式来创建对象。它允许开发者快速定义对象并初始化属性。

```
const obj = {
    name: "Alice",
    age: 25
};
```

这种方式适合创建单一对象，且在对象属性较少时显得非常清晰。

### 1.2 构造函数

构造函数是创建对象的另一种常用方法。通过定义一个函数并使用 new 关键字实例化对象，构造函数可以为多个对象实例提供相同的属性和方法。

```
function Person(name, age) {
    this.name = name;
    this.age = age;
}
const alice = new Person("Alice", 25);
```

这种方法的优势在于可以通过参数化创建多个对象实例，适合需要共享行为的对象。

### 1.3 Object.create()

Object.create() 方法创建一个新对象，并指定其原型对象。这种方法非常灵活，允许开发者在创建对象时显式地定义其原型。

```
const proto = {
    greet() {
        console.log("Hello!");
    }
};
const obj = Object.create(proto);
```

使用 Object.create() 可以实现更复杂的继承关系，适合需要动态创建对象的场景。

### 1.4 class 语法

ES6 引入了 class 语法，使得面向对象编程在 JavaScript 中更加清晰和易于理解。通过 `class`，开发者可以更直观地定义构造函数和方法。

```
class Animal {
    constructor(name) {
        this.name = name;
    }
    speak() {
        console.log(`${this.name} makes a noise.`);
    }
}
const dog = new Animal("Dog");
```

这种语法糖使得继承和方法定义更加简洁，适合现代 JavaScript 开发。

## 2 继承

继承是面向对象编程的核心特性之一，它允许一个对象获取另一个对象的属性和方法。在 JavaScript 中，实现继承的方式主要有以下几种。

### 2.1 原型链继承

原型链继承是 JavaScript 中最基本的继承方式。通过将子类的原型指向父类的实例，子类可以访问父类的属性和方法。

```
function Person() {
    this.head = 1;
    this.hand = 2;
}

function YellowRace() { }
YellowRace.prototype = new Person();

const hjy = new YellowRace();

console.log(hjy.head); // 1
console.log(hjy.hand); // 2
```

这种方式的缺点在于所有子类实例共享父类实例的属性，可能导致意外的属性共享。

### 2.2 盗用构造函数

盗用构造函数是通过在子类构造函数中调用父类构造函数来实现继承。这种方式可以确保每个实例都有自己的属性，避免了原型链共享的问题。

```
function Person(eyes) {
    this.eyes = eyes;
    this.colors = ['white', 'yellow', 'black'];
}

function YellowRace() {
    Person.call(this, 'black'); // 调用构造函数并传参
}

const hjy = new YellowRace();
console.log(hjy.colors); // ['white', 'yellow', 'black']
console.log(hjy.eyes); // black
```

这种方式适合需要每个实例都有独立属性的场景，但仍然需要通过原型链来继承方法。

### 2.3 组合继承

组合继承结合了原型链继承和盗用构造函数的优点，通过先调用父类构造函数以获取独立属性，再将父类的原型赋值给子类，形成完整的继承关系。

```
function Person(name) {
    this.name = name;
    this.colors = ['white', 'yellow', 'black'];
}
Person.prototype.sayHello = function() {
    console.log(`Hello, my name is ${this.name}`);
};

function YellowRace(name) {
    Person.call(this, name);
}
YellowRace.prototype = Object.create(Person.prototype);
YellowRace.prototype.constructor = YellowRace;

const hjy = new YellowRace("Hjy");
hjy.sayHello(); // Hello, my name is Hjy
```

这种方式在实际开发中常用，能够确保每个实例都有独立属性，并且可以访问父类的方法。

### 2.4 class 语法的继承

使用 ES6 的 class 语法，继承变得更加简单和清晰。通过 extends关键字，子类可以轻松继承父类的属性和方法。

```
class Person {
    constructor(name) {
        this.name = name;
    }
    sayHello() {
        console.log(`Hello, my name is ${this.name}`);
    }
}

class YellowRace extends Person {
    constructor(name) {
        super(name); // 调用父类构造函数
    }
}

const hjy = new YellowRace("Hjy");
hjy.sayHello(); // Hello, my name is Hjy
```

这种方式不仅语法简洁，而且提高了代码的可读性，适合现代 JavaScript 开发