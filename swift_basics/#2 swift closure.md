内容梗概：
  1. 如何定义一个闭包

  2. 闭包函数可接受参数

  3. 闭包函数可以有返回值

  4. 函数作为其他函数的参数

  5. 尾部闭包的写法

  6. 闭包可以传入参数

  7. 闭包可以返回值

  8. 可以使用 **`$0`** , **`$1`**  表示闭包参数

  9. 闭包可以作为返回值， 高级函数

  10. 闭包值捕获


> 1.如何定义一个闭包

```swift
// 将一个匿名函数作为一个变量传递给一个变量 () -> ()
let driving = {
  print("I am driving")
}

// 调用函数
driving()
```

> 2.闭包函数也可以接受参数

```swift
// (String) -> ()
let driving = { (place: String) in
  print("I'm going to \(place) in my car")
}

driving("London")
```

> 3.闭包也可以有返回值(Returning value from a closure)

```swift
// (String) -> String
let driving = { (place: String) -> String in
  return "I'm going to \(place) in my car"
}
```

如果是简单的闭包，可以省略返回类型
```swift
// return 关键词 也可以省略
let driving = { (place: String) in "I'm going to \(place) in my car"
}

driving("US")
```


> 4.闭包作为函数的参数（closure as function parameters）

swift中函数和js中一样是一级公民，可以作为变量进行赋值，作为参数传入函数

```swift
let driving = { (place: String) in "I'm going \(place) in my car"
}

// 需要传递一个签名为 (String) -> String 的函数
func travel(place: String, tool: (String) -> String) {
  print("Start traveling")
  let progress = tool(place)
  print(progress)
  print("End traveling")
}

travel(place: "US", tool: driving)
```

> 5.尾部闭包 （Trailing Closure）

当传入的闭包是函数的最后一个参数时，可以写为另一种形式，本质上是一种比较简洁语法糖

```swift
func travel(action: () -> Void) {
  print("Traveling start")
  action()
  print("End")
}

// 有以下几种写法
func tool() {
  print("I'm using a car")
}
// 方式1 传入一个函数 普通写法
traval(action: tool)

// 方式2 传入一个匿名函数
traval(action: { print("I'm using a car") })

// 方式3 尾部闭包
traval() {
  print("I'm using a car")
}

// 因为 traval 函数只有一个参数
// 可以进一步简化为
traval {
  print("I'm using a car")
}
```


> 6.闭包函数也可以传入参数

上面的提到的闭包签名都为 **`() -> Void`**, 其实闭包也可以接受参数的

```swift
func sayHello(to name: String, action: (String) -> Void) {
  action(name)
}

sayHello(to: "james") { (name: String) in 
  print("I'm saying hello to \(name)")
}
// I'm saying hello to James
```


> 7.闭包函数还可以返回值

```swift
// 闭包签名 (String) -> String
func traval(action: (String) -> String) {
 print("Start")
 // 返回值
 let des = action("USA")
 print(des)
 print("End")
}

traval { (place) -> String in
  return "I'm travaling to \(place)"
}

// 打印
Start
I'm traveling to USA
End
```

> 8.闭包参数名简写 (Shorthand parameters names)

这个特性还是十分简洁的，闭包函数的参数列表，可以依次使用 **`$0`** , **`$1`** ... 来表示

上面示例等价于：
```swift
func traval(action: (String) -> String) {
 print("Start")
 // 返回值
 let des = action("USA")
 print(des)
 print("End")
}

// 上面闭包只有一个参数 可以用 $0 表示
traval { "I'm travaling to \($0)" }
```


比如多个参数：
```
func traval(action: (String, String) -> String) {
 print("Start")
 // 返回值
 let des = action("USA", "17:40")
 print(des)
 print("End")
}

// 上面闭包有2个参数 依次用 $0 $1 表示
traval { "I'm travaling to \($0) at \($1)" }
// 打印
Start
I'm traveling to USA at 17:40
End
```

来源：
  - [Shorthand parameter names](https://www.hackingwithswift.com/sixty/6/8/shorthand-parameter-names)


> 9.闭包函数作为返回类型

这个就类似于js中的高阶函数
```swift
func getLuckyFunc() -> ((Int) -> Void) {
  return {
    // 闭包函数可以使用上下文中的参数
    print("\($0) is my lucky number")
  }
}
let myLuckyFunc = getLuckyFunc()
myLuckyFunc(18)

// 或者
// 返回的函数不使用括号包起来 个人感觉使用括号包裹起来可读性更强
func getLuckyFunc() -> (Int) -> Void {
  return {
    // 闭包函数可以使用上下文中的参数
    print("\($0) is my lucky number")
  }
}
getLuckyFunc()(18)
```

> 10.闭包值捕获 （Capture value）

这个和js中闭包含义类似，内部函数能够访问外部函数中的变量
```swift
func getLuckyFunc() -> ((Int) -> Void) {
  var counter = 1
  return {
    // 闭包函数可以使用上下文中的参数
    print("\($0) is my lucky number")
    print("counter is \(counter)")
    counter += 1
  }
}

let myLuckyFunc = getLuckyFunc()
// 调用多次
myLuckyFunc(20)
myLuckyFunc(20)
myLuckyFunc(20)

// 打印
20 is my lucky number
counter is 1
20 is my lucky number
counter is 2
20 is my lucky number
counter is 3
```



更多关于闭包参考：

- [swift closure - cnswift](https://www.cnswift.org/closures)

2019年11月12日00:49:26