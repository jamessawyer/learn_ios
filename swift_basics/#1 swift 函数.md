函数

- [Day 5 function - 100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui/5)



> 可变参数函数（**`variadic functions`**）

- 可变参数在函数内部会转换为数组
- 可变参数函数可能不传入任何值
- 一个可变参数函数的表达方式为 类型+ **`...`** , 比如 **`Int...`**



```swift
func square(numbers: Int...) {
  for number in numbers {
    print("\(number) squared is \(number * number)")
  }
}

square(numbers: 1, 2, 3, 4)
```

来源：

- [100 Days of swiftUI Day5 functions- hackingWithSwift](https://www.hackingwithswift.com/sixty/5/7/variadic-functions)



>  可抛出错误的函数（**`throwing functions`**）

- 使用 **`throws`** 关键词
- 使用 **`do`** 开始包裹一个可抛出错误的函数 **`do { try someThrowingFunc() }`**
- 必须捕获所有抛出的错误， 使用 **`catch`** 关键词
- 任何函数都可以标记为可抛出错误的函数
- 抛出错误函数，调用时必须使用 **`try`** 关键词
- 抛出的错误类型必须实现 **`Error`** 协议



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
  let isOk = try checkoutPassword("password")
} catch {
  print("Obvious password is not safe")
}
```





> **`inout`** 参数标记的函数

- 使用 **`inout`** 标记函数类型
- 普通函数参数以常量的形式传入，而 **`inout`** 参数必须是变量
- 在函数内改变一个 inout 参数，同时会在函数外面改变这个变量
- inout 参数传递时需要使用 **`&`** （类似C++取地址符）

```swift
func doubleYourNumber(number: inout Int) {
  number *= 2
}

var luckyNumber = 8
doubleYourNumber(number: &luckyNumber)
print("\(luckyNumber)") // 16
```

