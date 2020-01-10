原文链接：

- [Deep dive into Pattern matching with ~= operator](https://swiftwithmajid.com/2019/03/20/pattern-matching-operator/)

知识点：

1. 模式匹配背后的原理： 实际上使用 **`~=`** 操作符进行比较

2. 如何自定义模式匹配：改写 **`~=`** 函数，函数的签名;

   1. 第1个参数：case 后面的值
   2. 第2个参数： switch 后面对应的 keyword
   3. 返回类型： **`Bool`**


在 [Pattern matching with case let](https://github.com/jamessawyer/learn_ios/blob/master/Translations/%235%20Pattern%20Matching%20with%20case%20let%20-%20Majid.md) 中我们谈到了使用 **`case let`** 进行模式匹配，swift 中模式匹配其实使用到的是 **`~=`** 操作符。

模式匹配的定义就是： **检测tokens的给定序列中是否存在某些模式的成分的行为**。

比如字符串的匹配操作符：

```swift
let message = "hello world!"

switch message {
case "hello": print("hello")
case "world": print("world")
case "hello world!": print("hello world!")
default: break
}
// 打印
hello world!
```

在大多数情况下， **模式匹配就是进行相等性比较（除了 `Range` 用来检测包含性）**，模式匹配的背后，其实是swift使用了 **`~=`** 操作符, swift中大多标准类型都对 **`~=`** 操作符进行了重写.下面是 **`String`** 类型中 **`~=`** 操作符：

```swift
func ~=(pattern: String, value: String) -> Bool {
  return pattern == value
}
```



了解这些后，我们可以很轻松的对模式匹配的规则进行自定义操作：

```swift
// 重写字符串模式匹配
func ~= (pattern: String, value: String) -> Bool {
  return value.contains(pattern)
}

let message = "hello world!"

switch message {
case "hello": print("hello")
case "world": print("world")
case "hello world!": print("hello world!")
default: break
}
// 打印
hello
```

可以看出来，模式匹配规则自定义后，匹配到的结果也不一样了。

示例：

```swift
struct User {
  let firstName: String
  let secondName: String
  let age: Int
}

extension User {
  // 对 user 自定义模式匹配
  // 第一个参数是描述 case 值    A
  // 第2个参数是switch 后面的keyword B
  static func ~= (range: ClosedRange<Int>, user: User) -> Bool {
    return range.contains(user.age)
  }
}

let user = User(firstName: "Majid", secondName: "Jay", age: 27)

// user 是 B
switch user {
  // case后面跟的 21...30 值部分对应 A
  case 21...30: print("user's age is bwtween 21 and 30")
  case 31...40: print("user's age is bwtween 31 and 40")
  default: break
}
// 打印
user's age is bwtween 21 and 30
```



另外在正则表达式中，常常会使用模式匹配：

```swift
struct Regex {
  let pattern: String
  
   static let email = Regex(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    static let phone = Regex(pattern: "([+]?1+[-]?)?+([(]?+([0-9]{3})?+[)]?)?+[-]?+[0-9]{3}+[-]?+[0-9]{4}")
}

extension Regex {
  static func ~= (regex: Regex, text: String) -> Bool {
    return text.range(of: regex.pattern, options: .regularExpression)
  }
}

let email = "cmecid@gmail.com"

switch emial {
case Regex.emial: print("email")
case Regex.phone: print("phone")
default: break
}
```



2020年01月11日00:33:21

