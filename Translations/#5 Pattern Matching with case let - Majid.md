原文链接：

- [Pattern Matching with case let](https://swiftwithmajid.com/2019/02/06/pattern-matching-with-case-let/)

知识点：

1. **`case let`** 对枚举类型进行模式匹配
2. **`case let`** 对可选类型（本质上还是枚举） 进行模式匹配
   1. **`value?`**: 等价于 **`.some(your_value)`**
   2. **`.some(your_value)`**: 可选类型不为空的情况
   3. **`.none`**: 可选类型为空的情况
3. **`case let`** 对元组类型的模式匹配
4. **`case let`** 和流程控制配合使用
   1. **`if case let`**
   2. **`guard case let`**
   3. **`for-in`** 语句中使用

swift使用 **`case let`** 关键词进行模式匹配。

在 [Maintaining State in Your ViewControllers](https://github.com/jamessawyer/learn_ios/blob/master/Translations/%234%20Maintaining%20State%20in%20Your%20ViewController%20-%20Majid.md) 中，我们定义了 **`State`** 枚举，用来描述VC的状态, 下面我们更改为模式匹配的方式：

```swift
// 使用枚举
enum State<Data> {
  case loading
  case loaded(Data)
  case failed(Error)
}

// 对枚举值进行模式匹配
switch state {
case .loading: renderLoading()
/// 相当于 case let shows = .loaded(shows)
case let .loaded(shows) where shows.isEmpty: renderEmptyView()
case let .loaded(shows): render(shows)
case let .failed(error): render(error)
}
```

可以看出使用 **`case let`** 相比于普通的 **`case`** 的有点在于，可以匹配后，将其赋值给一个变量（也可以省略）,另外还可以配合 **`where`** 对值进行过滤操作.



> Optionals (可选类型)

swift中的可选类型本质上就是包含2种case的枚举。对可选类型，除了和上面一样进行模式匹配外，还可以有些额外的功能：

```swift
let value: Int? = 10

switch value {
/// value? 其实等同于 .some(value)
case let value? where value > 10: print("value greater than 10")
/// .some() 表示可选类型为非空时
case let .some(value): print(value)
/// .none 表示值为nil时
case .none: print("none")
}
```



> **Tuples （元组）**

元组通常用于轻量级别的数据组合，也能想枚举一样用于模式匹配：

```swift
let auth = (username: "majid", password: "veryStrongPassword")

switch auth {
case ("admin", "admin"): renderAdmin()
case let (_, password) where password.count < 6: renderShortPasswordMessage()
case let (username, password): renderUserProfile(username, password)
}
```



> case let with flow statements （case let和流程控制语句）

和 **`if`** 语句组合：

```swift
if case let .loaded(shows) = state, shows.isEmpty {
  renderEmptyView()
}
```

和 **`guard`** 语句组合：

```swift
guard case let .loaded(shows) = state, shows.isEmpty else {
  // do something here
}
renderEmptyView()
```

和**`for-in`** 语句组合：

```swift
let stateHistory: [State<[Show]>] = [.loaded([]), .loading]

for case let .loaded(shows) in stateHistory where shows.count > 2 {
  // do something here
}
```



2020年01月11日00:10:40