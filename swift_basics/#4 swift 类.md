类和结构体很类似，但它们之间存在着以下差异：

1. 类没有类似结构体那样的 **`wise initializer`**, 即当类中有属性没有被赋值的时候，需要明确的定义 **构造器**， 而结构体会默认的提供一个这样的构造器
2. 类能够实现继承，而结构体不存在继承。另外如果类不想被其他类继承，可以使用 **`final`** 关键词修饰类
3. 类是引用类型，结构体是值类型
4. 类存在 **`deinit`** 函数，在类的实例被销毁时调用
5. 类中属性如果使用 **`var`** 声明，不论实例是声明为常量，还是变量，都可以修改属性的值。而结构体只允许变量修饰的实例，才允许修改其属性。
6. 类中通过函数改变属性变量，不需要使用 **`mutating`** 关键词修饰函数



> 1. 类中不存在结构体中wise initializer

```swift
struct Student {
  var name: String // 没有赋值
  var age = 10
}

// 结构体的 wise initializer
// 相当于
struct Student {
  var name: String // 没有赋值
  var age = 10
  
  init(name: String) {
    self.name = name
  }
}
```

而类则需要明确的，自己补充构造器函数：

```swift
class Student {
  var name: String // 没有赋值
  var age = 10
  
  // 必须要手动补充这个构造器
  init(name: String) {
    self.name = name
  }
}
```



> 2. 类的继承

继承也是面向对象的三大特征之一。而结构体不存在继承

```swift
class Animal {
  var name: String
  var specy: String
  
  init(name: String, specy: String) {
    self.name = name
    self.specy = specy
  }
  
  func eat() {
    print("animal need eat something")
  }
}

// 继承
class Dog {
  init(specy: String) {
    // super  调用父类中的构造器
    super.init(name: "Dog", specy: specy)
  }
  
  // override 父类中的方法
  override func eat() {
    print("Dog eat meat")
  }
}
```

如果不希望 **`Animal`** 被其他类继承，则可以使用 **`final`** 修饰 class

```swift
final class Animal {
  // ...
}

// 其他类则不能再继承 Animal 类
```



> 3. 类是引用类型，结构体是值类型

当2个变量指向同一个类实例时，则两个变量指向同一个内存地址。而结构体是值类型，不同的变量，通过分配不同的内存空间

```swift
class Singer {
  var name = "Taylor swift"
}

var singer1 = Singer()
print(singer1.name) // "Taylor swift"

// 变量2
var singer2 = singer1
singer2.name = "Justin Biber"

print(singer1.name) // "Justin Biber"
```

**`singer1`** 和 **`singer2`** 2个变量指向同一个内存地址。

假如将 **`Singer`** 换成结构体:

```swift
struct Singer {
  var name = "Taylor swift"
}

var singer1 = Singer()
print(singer1.name) // "Taylor swift"

// 变量2 值类型， 分配不同的内存空间
var singer2 = singer1
singer2.name = "Justin Biber"

// singer1 和 singer2 不会相互影响
print(singer1.name) // "Taylor swift"
```



> 4. 类中存在 deinit 函数

在类实例被销毁时， 会调用 **`deinit`** 函数

**注意不要写成 `deinit()`, 没有 `()`**

```swift
class Person {
    var name = "John"
    
    init() {
        print("\(name) is init")
    }
    
    func printGreet() {
        print("hello, \(name)")
    }
    
    func changeName(newName: String) {
        name = newName
    }
    
    deinit {
        print("Goodbye, \(name)")
    }
}

for _ in 1..<2 {
    let person = Person()
    person.printGreet()
}

// 打印结果
John is init
hello, John
Goodbye, John // 实例被销毁时 调用 deinit 函数
```



> 5. 类对常量不会和结构体一样严格

```swift
class Person {
    var name = "John" // 变量
}

// 实例化
let person = Person() // 此处 person 为常量
person.name = "Kobe" // 依旧可以修改类中变量属性
```



如果换成结构体

```swift
struct Person {
    var name = "John" // 变量
}

// 实例化
let person = Person() // 此处 person 为常量
// 尝试修改常量person 中的 name 变量属性
// 抛出错误: error: cannot assign to property: 'person' is a 'let' constant
person.name = "Kobe"


// 解决办法
// 将实例化对象 用 var 声明为变量
var person = Person() // 此处 person 为变量
// oK
person.name = "Kobe
```



> 6. 类中修改变量，不需要使用 `mutating`



```swift
class Child {
  var age = 10
  
  // 修改属性变量
  func grow() {
    age += 1
  }
}


struct Child {
  var age = 10
  
  // 修改属性变量 需要添加 mutating 关键词
  mutating func grow() {
    age += 1
  }
}
```

另外注意:

```swift
struct Kindergarten {
	var numberOfScreamingKids = 30
	mutating func handOutIceCream() {
		numberOfScreamingKids = 0
	}
}
let kindergarten = Kindergarten() // 这是一个常量
// error 错误的原因请参考上面的第5条
kindergarten.handOutIceCream()

// 正确做法
var kindergarten = Kindergarten()
kindergarten.handOutIceCream()
```





文章参考来源：

- [Day10 classes and inheritance - 100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui/10)

另外可参考：

- [classes and structures - cnswift](https://www.cnswift.org/classes-and-structures)
- [swift 类和结构体 - 简书](https://www.jianshu.com/p/29f44bb95f3e)



2019年11月15日00:13:07