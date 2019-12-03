项目3 [ViewsAndModifiers](https://github.com/jamessawyer/learn_ios/blob/master/SwiftUIProjects/Project03%20ViewsAndModifiers/Project03%20ViewsAndModifiers/ContentView.swift) 中涉及到的知识点小结：

1. SwiftUI使用结构体的原因：性能，状态管理更清晰
2. modifiers的使用顺序为什么很重要：**泛型类型 `ModifiedContent<OurThing, OurModifier>`** 
3. 使用 **`some View`** 不透明返回类型的原因，**`TupleView`** 解释了一个组件最多接收10个子组件的原因
4. 条件渲染 Modifier 需要注意的点，返回的泛型类型可能不同
5. 环境Modifiers 和 普通 Modifiers 的区别
6. 视图作为属性，**let text = Text("Hello")** 便于复用
7. 视图组合， **将组件拆分为更小的单元**
8. 自定义Modifiers
   1. **`ViewModifier`** 协议
   2. **`.modifer(Modifier: T)`** 修饰符
   3. **`func body(content: Content) -> some View {}`**
   4. **`Content`** 类型 和 content 的使用
   5. swift 扩展

9. 自定义容器
   1. **`@ViewBuilder`**
   2. 逃逸闭包 **`content: @escaping (Int, Int) -> Content`**



> 1.为什么使用structs 而不使用classes

在SwiftUI中，大量使用structs，而不是像UIKits 中那样大量使用classes，原因有：

1. structs 性能更好
2. UIKits中的每个view都继承自 **`UIView`**， 而UIView中包含了大量的属性，所有继承的子类不管用没用到这些属性和方法，都会被包含到代码中，使代码更加的臃肿
3. 使用structs，能够很清楚的知道自己需要什么，拥有什么，不需要什么，代码更加的简洁
4. SwiftUI 让我们的状态管理更加的干净



> 2. 为何modifiers的顺序很重要？

我们知道下面的2种组件显示的效果是不一样的

```swift
// 组件1
Button("Hello World") {
	print(type(of: self.body))
}
.background(Color.red)
.frame(width: 200, height: 60)
// 打印结果
ModifiedContent<ModifiedContent<Button<Text>, _BackgroundModifier<Color>>, _FrameLayout>

// 组件2
Button("Hello World") {
	print(type(of: self.body))
}
.frame(width: 200, height: 60)
.background(Color.red)
// 打印结果
ModifiedContent<ModifiedContent<Button<Text>, _FrameLayout>, _BackgroundModifier<Color>>
```

可以看出：

1. 每次使用modifer修改一个view，都会产生一个这样的泛型： **`ModifiedContent<OurThing, OurModifier>`**
2. 如果使用多次，产生的泛型类型会嵌套，**因此顺序会决定返回的泛型类型是不一样的**，如上面的打印结果所示

**我们可以这样进行理解，每次使用一个modifier时，一个新的结构体被返回。** 当然实际运行原理并不是这样的，这只是一种便于理解的方式。

另外，相同的modifier可以多次的调用,例如：

```swift
Text("Hello World")
	.padding()
	.background(Color.red)
	.padding()
	.background(Color.green)
```



> 3. 为什么SwiftUI 使用 `some View` 作为其视图类型？

**`some View`** 称之为 **不透明返回类型 ( `opaque return types` )** , 表示： **一个服从 `View` 协议的具体类型，但是我们不想知道具体是什么类型，这些交给编译器去处理就可以了。**



返回 **`some View`** 和返回 **`View`** 有2点重要的区别：

1. 我们必须总是返回相同类型的视图，这对性能很重要
2. 即使我们不知道具体返回什么类型，但是编译器是知道的

返回 **`View`** 类型是不合法的，因为编译器需要知道具体是什么类型：

```swift
// Error
// Protocol 'View' can only be used as a generic constraint because it has Self or associated type requirements
struct ContentView: View {
  var body: View {
    Text("Hello")
  }
}
```

如果我们能告诉编译器具体返回什么类型，也是可以的：

```swift
struct ContentView: View {
  // OK
  var body: Text {
    Text("Hello")
  }
}
```

**扩展阅读： 使用 `VStack` 里面为什么可以存在多种不同类型？**

这是因为SwiftUI返回了一个包含对应个数元素和类型的 **`TupleView`**, 并且 **`TupleView`** 构造器最多可以传入 **`10`** 个参数，这也是为什么组件不能包含超过10个子元素的原因：

```swift
TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>
```



> 4. 条件渲染Modifier

有时候可能根据组件的某个状态来渲染不同的样式，一般使用下面的方式：

```swift
struct ContentView: View {
  @State private var isRed = false
  
  var body: some View {
    Button("Hello") {
      // 相当于 self.isRed = !self.isRed
      self.isRed.toggle()
    }
    .forgroundColor(isRed ? Color.red : Color.green)
  }
}
```

而用 **`if`** 来判断返回的类型，只在很少数的情况下可行，因为我们知道modifier实际上返回的是用 **`ModifierContent`** 包裹的泛型，**因此一般不使用 `if` 进行条件返回** 

```swift
// 可行
struct ContentView: View {
  @State private var isRed = false
  
  var body: some View {
    if self.isRed {
      return Text("hello").forgroundColor(Color.red)
    } else {
      return Text("hello")
    }
  }
}

// 报错
// Function declares an opaque return type, but the return statements in its body do not have matching underlying types
struct ContentView: View {
  @State private var isRed = false
  
  var body: some View {
    if self.isRed {
      return Text("hello").background(Color.red)
    } else {
      return Text("hello")
    }
  }
}
```



> 5. 环境修饰符和普通修饰符

环境修饰符可以用于修饰容器，对其容器内的子元素产生相同的作用，并且子元素的修饰符优先级更高。

比如 **`.font()`** 就是一个环境modifier：

```swift
VStack {
  Text("A")
  Text("B")
  Text("C")
}
.font(.title)
// 相当于
VStack {
  Text("A")
  	.font(.title)
  Text("B")
  	.font(.title)
  Text("C")
  	.font(.title)
}

// 但是子元素优先级更高
VStack {
  Text("A")
  	.font(.largeTitle)
  Text("B")
  Text("C")
}
.font(.title)
// 相当于
VStack {
  Text("A")
  	.font(.largeTitle)
  Text("B")
  	.font(.title)
  Text("C")
  	.font(.title)
}
```

至于什么是环境modifier，什么是普通modifier，则需要自己进行尝试才能得知。

比如 **`.blur()`** 就是一个普通modifier：

```swift
VStack {
  Text("A")
  	.blur(radius: 0) // 此处并没有生效
  Text("B")
  Text("C")
}
.blur(radius: 5)
// 相当于
VStack {
  Text("A")
  	.blur(radius: 5) // 此处并没有生效
  Text("B")
  	.blur(radius: 5)
  Text("C")
	  .blur(radius: 5)
}

```



> 6. 视图作为属性

这样可以将视图从 **`body`** 中提取出来，并且进行复用

```swift
struct ContentView: View {
  let text1 = Text("Hello")
  let text2 = Text("World")
  
  var body: some View {
    VStack {
      text1
      	.forgroundColor(Color.red)
      text2
    }
  }
}
```

也可以是计算属性：

```swift
struct ContentView: View {
  let text1 = Text("Hello")
  var text2: some View {
    Text("WORLD")
  }
  
  var body: some View {
    VStack {
      text1
      	.forgroundColor(Color.red)
      text2
    }
  }
}
```

**但是SwiftUI 不允许一个属性视图引用本地的另一个存储属性，这样可能产生错误**

```swift
// Error
struct ContentView: View {
  let text1 = Text("Hello")
  var text2: some View {
    Text("WORLD")
  }
  @State private var name = ""
  // 视图绑定本地一个存储属性 不允许
  let textInput = TextField("enter your name", $name)
  
  var body: some View {
    VStack {
      text1
      	.forgroundColor(Color.red)
      text2
    }
  }
}
```



> 7. 视图组合

这个是声明式UI的精华，将大的组件拆分为小的组件，然后进行组合起来。比如：

```swift
struct ContentView: View {  
  var body: some View {
    VStack {
      Text("Hello")
        .font(.largeTitle)
        .padding()
        .background(Color.red)
        .clipShape(Capsule())
  
      Text("Hello")
        .font(.largeTitle)
        .padding()
        .background(Color.red)
        .clipShape(Capsule())
    }
  }
}
```

可以将：

```swift
Text("Hello")
	.font(.largeTitle)
	.padding()
	.background(Color.red)
	.clipShape(Capsule())
```

部分单独封装为一个小的组件

```swift
struct CapsuleText: View {
  var title: String
  var body: some View {
    Text(title)
    	.font(.largeTitle)
      .padding()
      .background(Color.red)
      .clipShape(Capsule())
  }
}

struct ContentView: View {  
  var body: some View {
    VStack {
      CapsuleText("Hello")
      CapsuleText("WORLD")
    }
  }
}
```

**另外，还可以在封装的组件上添加modifiers**

```swift
struct ContentView: View {  
  var body: some View {
    VStack {
      CapsuleText("Hello")
      	.forgroundColor(Color.red)
      CapsuleText("WORLD")
    }
  }
}
```



> 8. 自定义修饰符

自定义修饰符可以极大的提高组件的可扩展性，主要用到：

1. **`ViedModifier`** 协议
2. **`.modifer(Modifier: T)`** 修饰符
3. **`func body(content: Content) -> some View {}`**
4. swift 扩展



比如给某些组件添加一组特定的样式：

```swift
struct Title: ViewModifier {
  func body(content: Content) -> some View {
    content
    	.font(.largeTitle)
    	.foregroundColor(Color.white)
    	.padding()
    	.background(Color.blue)
    	.clipShape(RoundedRectangle(cornerRadius: 10))
  }
}

// 使用 .modifier(Modifier: T) 方法
struct ContentView: View {  
  var body: some View {
    VStack {
      Text("HELLO")
      	.modifier(Title())
    }
  }
}
```

另外一般为了更加方便，会对 **`View`** 协议进行扩展：

```swift
extension View {
  func titleStyle() -> some View {
    self.modifier(Title())
  }
}

struct ContentView: View {  
  var body: some View {
    VStack {
      Text("HELLO")
      	.titleStyle()
    }
  }
}
```

**除了上面的对已经存在的修饰符进行扩展，还可以创建新的结构体**

比如下面给视图添加水印的扩展

```swift
struct Watermark: ViewModifier {
 var text: String
  
  func body(content: Content) -> some View {
    // 给视图的右下角添加水印
    ZStack(alignment: .bottomTrailing) {
      content
      Text(text)
      	.font(.caption)
      	.foregroundColor(.white)
      	.padding(5)
      	.background(Color.black)
    }
  }
}
extension View {
  func watermarked(with text: String) -> some View {
    self.modifier(Watermark(text: text))
  }
}

struct ContentView: View {  
  var body: some View {
    VStack {
      Color.blue
      	.frame(width: 300, height: 200)
      	.watermarked(with: "Hacking with Swift")
    }
  }
}
```



> 9. 自定义容器

除了可以自定义修饰符以外，还可以自定义容器。什么是容器，就类似于：

```swift
// 最常见的容器
struct ContentView: View {  
  var body: some View {
    
  }
}
```

自定义容器需要使用：

1. 使用泛型 **`<Content: View>`**
2. **`Content`** 类型
3. 还可能使用到 **`@ViewBuilder`**, 以及 **`@escaping`** 逃逸闭包的知识

比如自定义一个 **`GridStack`** 的自定义容器，下面有2种写法，待以后进一步学习了解：

方式1

```swift
struct GridStack<Content: View>: View {
  let rows: Int
  let columns: Int
  let content: (Int, Int) -> Content // 闭包
  
  var body: some View {
    VStack {
      ForEach(0 ..< rows) { row in
        HStack { row in
					ForEach(0 ..< self.columns) { column in
						self.content(row, column)
					}
        }
      }
    }
  }
}
struct ContentView: View {
  var body: some View {
		GridStack(rows: 4, columns: 4) { row, column in
			HStack {
				Image(systemName: "\(row * 4 + column).circle")
        Text("R\(row) C\(column)")
      }
    }
  }
}
```

方式2：

```swift
struct GridStack<Content: View>: View {
  let rows: Int
  let columns: Int
  let content: (Int, Int) -> Content // 闭包
  
  var body: some View {
    VStack {
      ForEach(0 ..< rows) { row in
        HStack { row in
					ForEach(0 ..< self.columns) { column in
						self.content(row, column)
					}
        }
      }
    }
  }
  
  // 定义一个构造器
  // @ViewBuilder ??
  // @escaping 表示逃逸闭包 用于将闭包进行存储 稍后再使用
  init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content) {
    self.rows = rows
    self.columns = columns
    self.content = content
  }
}
struct ContentView: View {
  var body: some View {
  	// 使用自定义容器方式2
  	// 会隐式的创建一个 HStack
    GridStack(rows: 4, columns: 4) { row, column in
			Image(systemName: "\(row * 4 + column).circle")
			Text("R\(row) C\(column)")
		}
  }
}
```



项目来源：

- [Day23-24 Project03 ViewsAndModifiers - 100DaysOfSwiftUI](https://www.hackingwithswift.com/100/swiftui/23)

2019年12月02日23:44:45