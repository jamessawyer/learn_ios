内容梗概：

1. 可选类型
2. 可选类型解包， **`if-let`**  和 **`guard-let-else | guard-else`** 语句 
3. 强制解包， **`!`** 符
4. 隐式解包类型， 比如 **`Int! | String!`** 等等
5. 空值处理， 使用 **`??`** 给解包后可能存在的空值，提供默认值
6. 可选链， **`?.`** 符，某个类型可能存在，也可能不存在， 使用 **`?.`** 安全访问器属性或方法
7. **`try?`** 和 **`try!`** 操作符
8. 可失败构造器 **`init?()`**
9. 类型转换， **`as?`** & **`as!`**



文章来源：

- [Day 12 Optionals - 100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui/12)



> 1. 可选类型

某个值可能存在，也可能不存在，这个时候就需要可选类型了，比如

```swift
// 一开始可能为nil 后面再赋值
var age: Int? = nil
age = 38
```



又或者某个属性有可能存在

```swift
struct Home {
  var address: String?
}
```



> 2. If let & guard let 语句

这2个语句都是可选类型进行解包操作，使用基本差不多，看个人偏好。

```swift
var name: String? = nil

if let unwrapped = name {
  // 因为 if let 已经对name进行解包操作了
  // 这里就不需要再使用 unwrapped?.count 了
  print("\(unwrapped.count) letters")
} else {
  print("Missing name")
}
```

换成 **`guard let`** 语句：

```swift
// guard let 一般配合 else ... return 使用
guard let unwrapped = name else {
  print("Missing name")
  return // 退出
}

print("\(unwrapped.count) letters")
```

可以看出2者使用顺序稍微有点不一样，另外， **`guard let`** 多用于函数中，这样提前进行检验，如何不满足直接退出函数，避免后面的操作无效

```swift
func greet(_ name: String?) {
  guard let unwrapped = name else {
    print("You didn't provide a name!")
    return
  }
  // 如果传入的 name 参数 为 nil 直接退出函数
  print("Hello, \(unwrapped)!")
}
```

**注意不要对非可选类型进行 `if let | guard let` 解包操作**

另外，**`guard`** 不一定要配合 **`let`** 进行解包,有可能仅仅进行条件判断

```swift
func title(for page: Int) -> String? {
	guard page >= 1 else {
		return nil
	}
	let pageCount = 132
	if page < pageCount {
		return "Page \(page)"
	} else {
		return nil
	}
}
let pageTitle = title(for: 16)!
```





> 3. 强制解包（Forced unwrapped）

强制解包一般用于，你能百分百确认该变量存在值，如果不存在值，程序直接崩溃

```swift
let str = "5"

let num = Int(str) // num 的类型为 Int? 类型
```

如果你百分百确定 **`str`** 一定是一个数字字符串，可以进行强制解包

```swift
let num = Int(str)! // num 的类型现在为 Int 类型
```

**注意如果 `str` 不是一个数字字符串，程序将崩溃**



> 4. 隐式解包类型

一般表示，某个变量一开始没有值，但是当你使用前，它的值一定存在，这个时候使用隐式解包类型。

**隐式解包类型好像已经被解过包， 因此不需要使用 `if let | guard let` 语句再进行解包操作**

比如，使用 **storyboard** 工具时，某个 **`UITextField`** 在UI绘制前不存在，在你进行交互操作时，能肯定它是存在的，使用隐式解包类型就十分合适

```swift
@IBOutlet weak var nameTextField: UITextField!
```



> 5. 空值处理 **`??`** 操作符

表示如果某个可选类型返回为 nil， 可以给变量赋一个默认值

```swift
func username(for id: Int) -> String? {
  if id == 1 {
    return "Taylor Swift"
  }
  
  return nil
}

// 如果 username(for: 15) 为 nil 则 user 为 "Anonymous"
let user = username(for: 15) ?? "Anonymous"
```



> 6. 可选链 **`?.`** 操作符

比如访问 **`a.b.c`**, 其中 **`b`** 是一个可选类型，则可以使用 **`a.b?.c`** 进行访问，避免大量的 **`if let | guard let`** 语句。



```swift
let names = ["kobe", "james"]
let firstName = names.first // firstName 为 String? 类型
let upperName = firstName?.uppercased()

// 如果使用 if let
if let unwrapped = firstName {
  upperName = unwrapped.uppercased()
} else {
  // ...
}
```



> 7. **`try?`** && **`try!`** 操作符



**`try`** 语句 用于异常捕获中。使用 **`try?`** 则表示，如果抛出异常，则返回 **`nil`** 值；而 **`try!`** 则表示你能确定不会抛出异常，如果最后还是抛出了异常，则程序将崩溃。



```swift
enum PasswordError: Error {
  case obvious
}

func checkPassword(_ password: String) throws -> Bool {
  if password == "password" {
    throw PasswordError.obvious
  }
  return true
}

do {
  try checkoutPassword("password")
  print("That password is good")
} else {
  print("You can't use that password.")
}
```

上面的 **`do try else`** 是一般做法，下面使用 **`try?`** 语句

```swift
// 如果 try? checkPassword("password") 抛出异常
// 则 result == nil
if let result = try? checkPassword("password") {
  print("Result was \(result)")
} else {
  print("D'oh")
}
```

如果能确保用户不输入 **`password`** 作为密码，抛出错误，则可以使用 **`try!`** 语句

```swift
try! checkoutPassword("hahaword")
print("OK!")
```



> 8. 可失败构造器 **`init?`**

上面示例中的 **`Int`** 类型就包含一个可失败构造器，比如

```swift
let str = "12"
// 返回类型为 Int?
// 如果str 不是数字类型 则返回一个nil
let num = Int(str)
```

可失败构造器（**`Failable Initializer`**）

```swift
struct Person {
  var id: String
  
  // init?
  init?(id: String) {
    if id.count == 9 {
      self.id = id
    } else {
      return nil
    }
  }
}

var person = Person(name: "lily")
// person 为 Person? 类型
print(person?.id) // nil
```



> 9. **`as?`** & **`as!`** 类型转换

在继承或者实现协议时，swift 不能准确的知道某个变量具体是哪一种类型。如果要调用某个特定类型的某个方法或访问某个属性，则需要进行类型转换操作。

一般使用 **`if-let-as?`** 语句

```swift
class Animal {}
class Fish: Animal {}

class Dog: Animal {
  func bark() {
    print("woof")
  }
}

// pets 为 [{Animal}, {Animal}, {Animal}, {Animal}] 类型
let pets = [Fish(), Dog(), Fish(), Dog()]
```

如果想要调用 **`bark()`** 则需要尝试进行类型转换：

```swift
for pet in pets {
  // 是否 dog 是 Dog 类型
  if let dog = pet as? Dog {
    dog.bark()
  }
}
```

如果确认是 **`Dog`** 类型，则可以使用 **`as!`** 语句，上面的示例可以写为：

```swift
for pet in pets {
  // 先判断pet 是否是 Dog 类型
  if pet is Dog {
    // 然后进行类型转换， 因为pet 是 Animal 类型
    // 上面的 is 又确保 当前pet 又是一个 Dog 类型
    // 因此可以使用 as! 将Animal向下转化为Dog类型
    (pet as! Dog).bark()
  }
}
```

可参考

- [Difference between is and as keyword in swift](https://stackoverflow.com/questions/35388549/difference-between-is-and-as-keyword-in-swift)



详细文档，可参考：

- [可选类型 - cnswift](https://www.cnswift.org/the-basics#spl-19)

- [可选链 optional chaining - cnswift](https://www.cnswift.org/optional-chaining)
- [类型转换 type cast - cnswift](https://www.cnswift.org/type-casting)

相关文章：

- [Optionals in swift: The ultimate guide](https://learnappmaking.com/swift-optionals-how-to/)
- [可选类型本质是一个枚举 - 官方文档Optional](https://developer.apple.com/documentation/swift/optional)



2019年11月18日01:43:24