协议和扩展（**`protocols` & `extensions`**）：

- 协议相当于其他语言中的抽象类，只提供属性或方法，不提供实现
- 扩展可以理解为JS中的原型链，用于对已有类型进行扩展
- 协议和扩展一起组合，扩展可以扩充协议或者给协议提供默认实现



内容梗概：

1. 如何写一个协议，使用 **`protocol`** 关键词
2. 一个协议可以服从另外一个或几个其它协议
3. 如何写一个扩展，使用 **`extension`** 关键词, 以及扩展可以遵循某个或几个协议
4. 协议扩展的写法，和swift中的面向协议编程（Protocol-oriented programming, aka **`POP`**）

来源：

- [Day11 Protocols and extensions - 100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui/11)



> 1. 如何写一个协议



```swift
// 定义一个协议
protocol Identifiable {
  // id 可以是 存储属性 也可以是计算属性
  var id: String { get set }
  func identify()
}

// 服从一个协议
struct User: Identifiable {
  var id: String
  func identify() {
    print("my ID is \(id)")
  }
}

// 作为一种参数类型
func displayID(thing: Identifiable) {
  print("My ID is \(thing.id)")
}
```



> 2. 协议服从其它一个或多个协议

类自能单继承，但是可以服从多个协议，协议自身也可以服从其它一个或多个协议。

```swift
protocol Payable {
  func calculateWages() -> Int
}

protocol NeedsTraining {
  func study()
}

protocol HasVacation {
  func takeVacation(days: Int)
}

protocol Employee: Payable, NeedsTraining, HasVacation {}
```





> 3. 如何写一个扩展

使用 **`extension`** 关键词

比如对 **`Int`** 类型进行扩展

```swift
extension Int {
  // 添加一个方法 求平方
  func square() -> Int {
    return self * self
  }
  
  // 添加一个属性 加倍数字
  var double: Int { self + self }
}

extension Int {
  var isEven: Bool {
    return self % 2 == 0
  }
}

var num = 10
print(num.square()) // 100
print(num.double) // 20
print(num.isEven) // true
print(num) // 10
```

也可以为结构体添加 **`mutating`** 方法

```swift
extension Int {
  mutating func changeSquare() {
    self = self * self
  }
}
var a = 10
a.changeSquare()
print(a) // 100
```



扩展遵循某个协议：

```swift
extension SomeType: SomeProtocol, AnotherProtocol {}
```



> 4. 协议扩展

扩展可以扩充协议：

```swift
let beatles = Set(["John", "Paul", "George", "Ringo"])

// 因为 Set 结构体 服从 Collection 协议
// 下面对 Collection 协议进行扩充
extension Collection {
  func summarize() {
    // count 是 Collection 自身的一个属性
    print("There are \(count) of us")
    
    for name in self {
      print("\(name)")
    }
  }
}

beatles.summarize()
// 打印
There are 4 of us
John
Paul
George
Ringo
```



扩展给协议提供默认实现：

```swift
protocol Identifiable {
  var id: String { get set } // get || get & set 访问器属性不能省
  func identify()
}

extension Identifiable {
  func identify() {
    print("My id is \(id)")
  }
}

// 因为上面的扩展协议给 identify 提供了默认实现
// 因此这里不需要再提供 identify 函数了
struct User: Identifiable {
  var id: String
}

var user = User(id: "110")
user.identify() // My id is 110
```

当然你也可以不使用默认实现：

```swift
struct User: Identifiable {
  var id: String
  
  func identify() {
    print("override defalut implementation")
  }
}
var user = User(id: "110")
user.identify() // override defalut implementation
```



另外：

关于 **扩展**，这里没谈到的还有：

1. 提供便利初始化器
2. 扩充下标
3. 内嵌类型

更多可参考：

- [extensions - cnswift](https://www.cnswift.org/extensions)



关于 **协议**，没有谈到的有：

1. 在协议中添加初始化器，**`required`** 关键词是否使用的问题
2. 协议和 **委托**， 一种重要的设计模式，iOS开发中用的比较多的一种模式
3. 有条件的遵循协议， **`where`** 关键词的使用
4. 类专用的协议， 协议添加 **`AnyObject`** 关键词， 比如 **`protocol SomeProtocol: AnyObject`** ，则只有类能够使用该协议，结构体和枚举则不能遵循该协议
5. 协议组合，比如 **`Codable`** 协议就是 **`Encodable & Decodable`** 的协议组合
6. 可选协议， **`@objc`** 关键词

协议的用法多种多样，具体参考：

- [protocols - cnswift](https://www.cnswift.org/protocols)

2019年11月16日01:33:17



