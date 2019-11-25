项目1 **`WeSplit`** 中涉及到的关于SwiftUI中的知识点小结：

1. **`View`** 协议 和 **`var body: some View`**  计算属性
2. **`some View`** 类型
3. 初步接触的SwiftUI组件（本质上是结构体）
   1. **`Form`**
   2. **`Text`** && `specifier`
   3. **`Group`**
   4. **`Section`** && `header` && `footer`
   5. **`TextField `** && `keyborderType(.decimalPad)`
   6. **`ForEach`**
   7. **`Picker`** && `pickerStyle()` && `SegmentedPickerStyle`
4. 导航组件 **`NavigationView`** 和 修饰符（**`modifier`**）的用法 `navigationBarTitle()`
5. **`@State private var`** 视图状态 和 双向数据绑定 **`$`** 符号进行双向绑定



> 1. View 协议 和 body 计算属性

SwiftUI中引入了一种新的协议类型 **`View`**, 它有一个必须计算属性 **`body`**, 这样每次 **`body`** 的值发生变化时，遵循 **`View`** 的组件都会重新被创建，从而刷新视图。

```swift
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol View {

    /// The type of view representing the body of this view.
    ///
    /// 当创建一个自定义视图时，swift会通过必需的 body 属性来推断它的类型
    associatedtype Body : View

    /// 声明这个视图的内容和行为
    var body: Self.Body { get }
}
```

**`View`** 协议还有很多扩展，这个可以查文档。

```swift
// 一个最简单的视图
// 遵循 View 协议
// 存在一个返回类型为some View 的 body 计算属性
struct ContentView: View {
  var body: some View {
    Text("hello SwiftUI")
  }
}
```



> 2. some View

**`some`** 是SwiftUI中引入的新关键词。**`some View`** 表示为返回的视图添加一个限制 一旦确认了返回的类型了，后面不能将其改变为其它类型。



> 3. 初识的基本组件

这些组件本质上都是结构体，存在不同的构造函数和方法。通过声明式的方式，可以灵活的进行组合。

**注意SwiftUI对一些组件能接受的子元素属性进行了限制，一般不能超过 `10`， 如果超过了 `10`， 则需要通过其他的方式处理**。



**`Form`**：

- 常用的表单容器，表示表单list， 默认样式，背景变为灰色，子元素有白色的底色

```swift
// 这种 {} 的写法，实际上就是一个尾部闭包
Form {
  Text("Hello world")
}
```

如果超过 **`10`** 个子元素：

```swift
Form {
    Text("Hello World")
    Text("Hello World")
    Text("Hello World")
    Text("Hello World")
    Text("Hello World")
    Text("Hello World")
    Text("Hello World")
    Text("Hello World")
    Text("Hello World")
    Text("Hello World")
    Text("Hello World")
}
// 报错 Ambiguous reference to member 'buildBlock()'
```

解决办法，使用 **`Group`**, 对元素进行分组：



**`Text`**:

最常见的文字组件，可以通过 **`specifier`** 来限定样式，这个对于字符串类型的数字，限制位数很方便。写法和C语言中一样

```swift
var num = 19.280012
Text("$\(num, specifier: "%.2f")") // 保留2位小数 即 19.28
```



 **`Group`**:

```swift
Form {
    Group {
      Text("Hello World")
      Text("Hello World")
      Text("Hello World")
      Text("Hello World")
      Text("Hello World")
      Text("Hello World")
    }
    
    Group {
      Text("Hello World")
      Text("Hello World")
      Text("Hello World")
      Text("Hello World")
      Text("Hello World")
    }
}
```



**`Section`** :

另外还可以使用 **`Section`** 组件，这个组件将元素通过空白分为一块一块的，可参考iphone中的 **`Settings`** 界面。

另外Section还可以给块添加一个 **`header | footer`**:

```swift
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct Section<Parent, Content, Footer> {
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Section : View where Parent : View, Content : View, Footer : View {
    public typealias Body = Never
    public init(header: Parent, footer: Footer, @ViewBuilder content: () -> Content)
  	public init(footer: Footer, @ViewBuilder content: () -> Content)
	  public init(header: Parent, @ViewBuilder content: () -> Content)
	  public init(@ViewBuilder content: () -> Content)
}
```

示例：

```swift
Form {
    Section(header: Text("Section One")) {
      Text("Hello World")
      Text("Hello World")
      Text("Hello World")
    }
    
    Section(header: Text("Section Two")) {
      Text("Hello World")
    }
}
```



**`TextField`**:

这个是一个表单输入组件，这个组件多需要进行 **双向数据绑定**， 下面会讲解

```swift
Form {
  TextField("this is TextField's placeholder text", "some value")
}
```

它可以使用 **`keyboardType`** 修饰符选择打开键盘的类型

```swift
Form {
  TextField("this is TextField's placeholder text", "some value")
  	.keyboardType(.decimalPad) // 数字0-9 和 . 的键盘
}
```



**`ForEach`**:

 **用于遍历数组和Range**，可产生多个类似的组件

```swift
Form {
  ForEach(0 ..< 100) {
    Text("Row \($0)")
  }
}
```



**`Picker`**:

这个组件在不同的使用上下文中，会表现出不同的样式和使用逻辑。比如单独使用，会出现一个iOS中常见的滚轮选择（比如时间选择滚轮），放在表单中，如果是单行的，点击后则会跳转到另一个页面进行选择。

还可以添加一个 **`pickerStyle`** 修饰符，将其变为一个 **`SegmentedPickerStyle`** 的滑块选择。

```swift
// 下面例子提前使用到了 状态 和 双向数据绑定
// 滚轮的样式
var names = ["james", "kobe", "durant"]
@State private var currentNameIndex = 0
var body: some View {
	Picker("choose your name", selection: $currentNameIndex) {
    ForEach(0 ..< names.count) {
      Text(self.names[$0])
    }
	}
}

// 打开新的页面
Form {
  Picker("Select your name", selection: $currentNameIndex) {
    ForEach(0 ..< names.count) {
      Text(self.names[$0])
    }
  }
}

// 使用到修饰符的概念
// 滑块的样式
Picker("Select your name", selection: $currentNameIndex) {
  ForEach(0 ..< names.count) {
      Text(self.names[$0])
    }
}
.pickerStyle(SegmentedPickerStyle())
```



> 4. NavigationView 和 修饰符

在SwiftUI中使用导航器很简单，只需要将页面包裹到 **`NavigationView`** 中即可。

**需要注意的修饰符的位置**

```
// 正确
NavigationView {
  Form {
    
  }
  .navigationBarTitle("WeSplit")
}
```

而不是：

```swift
// 错误放置修饰符的位置
NavigationView {
  Form {
    
  }
}.navigationBarTitle("WeSplit")
```

这是因为 **`NavigationView`** 在程序运行时，能够展示很多视图，将标题放在导航视图内，可以让iOS更加方便的修改标题。

上面的 **`navigationBarTitle`** 默认是大的标题，可以通过 **`displayMode`** 来修改样式

```swift
NavigationView {
  Form {
    
  }
  // large (默认) || inline || automatic
  .navigationBarTitle("WeSplit", displayMode: .inline)
}

```



> 5. @State 和 双向数据绑定 $

这个概念就类似于React中的 state了，双向数据绑定使用 **`$`** 对状态进行修饰，这样无论哪一边数据发生变化，都会对值进行回传。

```swift
import SwiftUI

struct ContentView: View {
  // @State 对可能变化的状态进行修饰
  @State private var amount = ""
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Production Price")) {
          // 双向数据绑定 使用 $amount
          TextField("Total Money", text: $amount)
          	.keyboardType(.decimalPad)
          
          // 只获取当前状态值
          Text("Total amount", "$\(amount, specifier: "%.2f")")
        }
      }
      .navigationBarTitle("We Split")
    }
  }
}
```



具体内容可以参考：

- [Day 16 -18  -- Project 1 WeSplit 100DaysOfSwiftUI](https://www.hackingwithswift.com/100/swiftui/16)

