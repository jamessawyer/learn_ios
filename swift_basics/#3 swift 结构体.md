内容梗概：

1. 存储属性和计算属性 （stored properties and computed propterties）
2. 属性观察器（property observers） **`willSet & didSet`** 
3. 可变方法（mutating methods） 关键词 **`mutating`**
4. 懒加载属性 （lazy properties） 关键词 **`lazy`**
5. 静态属性和方法 （static properties and methods） 关键词 **`static`**



来源：

- [Day 8 strcut - hackingwithswift 100 Days of swiftui](https://www.hackingwithswift.com/100/swiftui/8)

- [Day 9 struct](https://www.hackingwithswift.com/100/swiftui/9)



首先结构体是一种 **值类型**，另外swift中的基本类型都是结构体，比如 **`Array, Dictionary, Set, Bool`** 等等。



> 1.存储属性和计算属性



```swift
struct Sport {
  // 存储属性
  var name: String
  var isOk: Bool
  
  // 计算属性
  var description: String {
    if isOk {
      return "\(name) is a good sport"
    } else {
      return "\(name) is harmful"
    }
  }
}

var sport = Sport(name: "tennis", isOk: true) // 调用结构体默认构造器
sport.description
```



> 2.属性观察器

当属性值发生变化前或后，可以做一些操作，相当于一个生命周期钩子。 **`didSet`** 用的比较多， **`willSet`** 用得比较少

```swift
struct Progress {
  var task: String
  var amount: Int {
    didSet {
      print("\(task) has done \(amount)%")
    }
  }
}

var progress = Progress(task: "homework", amount: 0)
progress.amount = 30 // 打印 homework has done 30%
progress.amount = 100 // 打印 homework has done 100%
```

可以看出在初始化之后， **`amount`** 属性发生变化时，都会触发 **`didSet`** 



> 3. 可变方法

因为结构体是一个值类型，值类型是 **`immutable`**， 只有方法使用 **`mutating`** 关键字标记的方法，才能显式的更改结构体中的 **存储属性**



```swift
struct Person {
  var name: String
  
  // 如果这里忽略 mutating 关键字 会报错
  // cannot assign to property: 'self' is immutable
  mutating func changeName(newName: String) {
    name = newName
  }
}
var person = Person(name: "kobe")
person.changeName(newName: "james")
```

可参考：

- [swift mutating - stackoverflow](https://stackoverflow.com/questions/49253299/cannot-assign-to-property-self-is-immutable-i-know-how-to-fix-but-needs-unde)



> 4. 懒加载属性

比如有一些操作比较耗性能，**只有使用到的时候才需要**，这个时候可以使用 **`lazy`** 标记属性，这样属性第一次被访问时，才会初始化。



```swift
struct FamilyTree {
  init() {
    print("create a family tree")
  }
}

struct Person {
  var name: String
  var tree = FamilyTree()
  
  init(name: String) {
    self.name = name
  }
}

var person = Person(name: "james")
// 发现会打印 create a family tree
```

**`lazy`** 关键词

```swift
struct Person {
  var name: String
  
  // lazy 标记属性
  lazy var tree = FamilyTree()
  
  init(name: String) {
    self.name = name
  }
}

var person = Person(name: "james") // 并不会产生打印

// 第一次使用 tree 的时候才会产生打印
person.tree

// 第2次也不会产生打印
person.tree
```



> 5. 静态属性和方法

这个和其他语言基本类似， 静态属性和方法属于结构体或者类自身，而不是属性某个实例，从而可以实现共享数据。

```swift
struct User {
  // 静态属性 static 关键词
  static var count = 0
  
  init() {
    User.count += 1
  }
  
  // 静态方法
  static func printCount() {
    print(User.count)
  }
}

var user1 = User()
var user2 = User()

print(User.count) // 2
print(User.printCount) // 2
```



更多关于结构体，可参考：

- [struct and class - cnswift](https://www.cnswift.org/classes-and-structures)
- [swift类和结构体 - 简书](https://www.jianshu.com/p/29f44bb95f3e)

2019年11月13日01:46:06