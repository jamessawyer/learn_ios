项目2 [GuessTheFlags](https://github.com/jamessawyer/learn_ios/blob/master/SwiftUIProjects/Project02%20GuessTheFlags/Project02%20GuessTheFlags/ContentView.swift) 中涉及到的知识点小结：

1. **`HStack & VStack & ZStack`** 布局组件
2. **`Color`** 组件的使用
3. **`LinearGradient & RadialGradient & AngularGradient`** 几种常见的渐变色
4. **`Button & Image & Alert & Spacer`** 等组件的基本使用

另外还会接触到各种各样的 **修饰符** （本质上就是函数）

- **`edgesIgnoringSafeArea(.all)`** 是否忽略安全区域
- **`Text`** 组件常见的修饰符 **`forgroundColor(Color.white) & font(.largeTitle) & frame(width: 200, height: 50)`**
- **`padding`** 通用修饰符的使用
- **`Image`** 组件组合使用的修饰符 **`renderingMode | clipShape | overlay | shadow`**
- **`alert`** 修饰符的使用

还有几个函数：

1. **`shuffled()`** 数组随机打乱函数
2. **`Int.random(in range: ClosedRange<Int>)`** 随机生成一个整数



> 1. HStack & VStack & ZStack

这个是最常用的几种布局组件，它们之间可以相互组合。

**`HStack`** 

就相当于css 中 flexbox中 **`flex-direction: row`**,将多个子元素水平排列。几种使用方式：

```swift
// 默认子元素居中
HStack {
  Text("Item 1")
  Text("Item 2")
}

// 可以指定对其方式 默认为 .center
HStack(alignment: .top) {
  Text("Item 1")
  Text("Item 2")
}

// 也可以指定子元素之间的间距
HStack(spacing: 20) {
  Text("Item 1")
  Text("Item 2")
}

// 或者2者同时进行指定
HStack(alignment: .top, spacing: 20) {
  Text("Item 1")
  Text("Item 2")
}
```



**`VStack`**

就相当于css 中 flexbox中 **`flex-direction: column`**,将多个子元素垂直排列。使用方式和上面的 **`HStack`** 一样

```swift
VStack(spacing: 20) {
  Text("Item 1")
  Text("Item 2")
}
```



**`ZStack`**

这个就相当于 **`position: 'absolute'`**, 对元素进行绝对定位，一层堆叠在另一层的上面，默认 **`alignment: .center`**

```swift
// 表示将图片作为背景图片 文字摆放在图片上
ZStack {
  Image("someBackgroundImage")
  	.renderingMode(.original)
  Text("hello world")
}
```

**另外，ZStack 最常用的是作为整个组件的容器，给页面添加一个背景色或者背景图片**

```swift
var body: some View {
  ZStack {
    // 添加一个红色背景色
    Color.red.edgesIgnoringSafeArea(.all)

    VStack {
      // 页面中其它的元素
    }
	}
}

// 或者添加一个渐变的背景色
var body: some View {
  ZStack {
    // 添加一个渐变色当背景
    LinearGradient(
      gradient: Gradient(colors: [.blue, .black]),
      startPoint: .top,
      endPoint: .bottom
    )
    	.edgesIgnoringSafeArea(.all)

    VStack {
      // 页面中其它的元素
    }
	}
}
```



> 2. Color

这个上面已经介绍到了，一般用于定义颜色属性

```swift
// 部分 Color 定义
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct Color : Hashable, CustomStringConvertible {
	public init(_ colorSpace: Color.RGBColorSpace = .sRGB, red: Double, green: Double, blue: Double, opacity: Double = 1)
    public init(_ colorSpace: Color.RGBColorSpace = .sRGB, white: Double, opacity: Double = 1)
    public init(hue: Double, saturation: Double, brightness: Double, opacity: Double = 1)
    public init(_ color: UIColor)
    
    public static let clear: Color
    public static let black: Color
    public static let white: Color
}
```

颜色相关的定义大多数使用这个结构体进行定义。



> 3. LinearGradient & RadialGradient & AngularGradient

这3种渐变依次称之为： 线性渐变，径向渐变，锥形渐变。

**`LinearGradient`**

```swift
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct LinearGradient : ShapeStyle, View {
    public init(gradient: Gradient, startPoint: UnitPoint, endPoint: UnitPoint)
}
```

其中 **`UnitPoint`** 多用于定义方位：

```swift
// 部分UnitPoint代码
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct UnitPoint : Hashable {
    public var x: CGFloat
    public var y: CGFloat
    @inlinable public init()
    @inlinable public init(x: CGFloat, y: CGFloat)
    public static let zero: UnitPoint

    public static let center: UnitPoint
    public static let leading: UnitPoint
    public static let trailing: UnitPoint
    public static let top: UnitPoint
    public static let bottom: UnitPoint
    public static let topLeading: UnitPoint
    public static let topTrailing: UnitPoint
    public static let bottomLeading: UnitPoint
    public static let bottomTrailing: UnitPoint
}
```

其中 **`Gradinent`** 有2个构造器

```swift
// Gradient(colors: [Color])
LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .top, endPoint: .bottom)      

// Gradient(stops: [Gradient.Stop])
LinearGradient(
  gradient: Gradient(
    stops: [
      Gradient.Stop(color: .white, location: 0.0),
      Gradient.Stop(color: .black, location: 0.5),
      Gradient.Stop(color: .white, location: 1.0),
    ]
  ),
  startPoint: .top,
  endPoint: .bottom
)
```



**`RadialGradient`**

```swift
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct RadialGradient : ShapeStyle, View {
    public init(gradient: Gradient, center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat)
}
```

示例：

```swift
let colors = Gradient(colors: [.blue, .black])
RadialGradient(
  gradient: colors,
  center: .center,
  startRadius: 2,
  endRadius: 650
)
```



**`AngularGradient`**

```swift
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct AngularGradient : ShapeStyle, View {
    public init(gradient: Gradient, center: UnitPoint, startAngle: Angle = .zero, endAngle: Angle = .zero)
    public init(gradient: Gradient, center: UnitPoint, angle: Angle = .zero)
}
```

示例：

```swift
let colors = Gradient(colors: [.green, .blue, .black, .green, .blue, .black, .green])
AngularGradient(
	gradient: colors,
	center: .center
)
```

关于swiftUI渐变可以参考：

1. [how to render a gradient  - hackingWithSwift](https://www.hackingwithswift.com/quick-start/swiftui/how-to-render-a-gradient)
2. [Gradient in SwiftUI](https://ashishkakkad.com/2019/10/gradient-in-swiftui/)



> 3. Button & Image & Alert & Spacer

**`Button`**

常见的几种用法

```swift
// 多用于简单的按钮
Button(title: StringProtocol, action: () -> void)

// 多用于自定义按钮 使用的更多
Button(action: () -> Void, label: () -> _)
```

示例：

```swift
Button(title: "press me") {
  print("tapped")
}

Button(action: {
  print("tapped")
}) {
	// 自定义按钮内容
  HStack {
        Image(systemName: "trash")
            .font(.title)
        Text("Delete")
            .fontWeight(.semibold)
            .font(.title)
    }
    .padding()
    .foregroundColor(.white)
    .background(Color.red)
    .cornerRadius(40)
}
```

更多关于SwiftUI Button 的用法：

1. [SwiftUI Buttons - AppCoda](https://www.appcoda.com/swiftui-buttons/)



**`Image`**

图片还是比较复杂的，下面仅做简单的示例，有待以后进一步的补充

```swift
Image("Moon.jpg")
	.renderMode(.original)
```



**`Alert`**

显示一个iOS样式的提示框

```swift
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct Alert {
    public init(title: Text, message: Text? = nil, dismissButton: Alert.Button? = nil)
    public init(title: Text, message: Text? = nil, primaryButton: Alert.Button, secondaryButton: Alert.Button)
}
```

示例：

```swift
Alert(
  title: Text("Alert Title"),
  message: Text("Alert Body"),
  dismissButton: .default(Text("Continue")
) {
	// do something when Alert dismissed
})
```

**`Spacer`**

这个多用于填充多余的空间的辅助组件,类似于flutter中的 **`Expand`** 组件

```swift
VStack {
  Text("hello") // 这样Text会跑到顶部位置
  Spacer() // 填充剩余的空间
}
```



> 5. 修饰符

修饰符的本质就是函数，不同的组件会有一些通用的修饰符和一些独有的修饰符。

- **修饰符的顺序很重要**，即函数的调用顺序不同，产生的结果是不一样的

下面是修饰符的几个示例：

```swift
Text("Hello")
	.forgroundColor(.white)
	.font(.largeTitle)
	.fontWeight(.black)
	
Image("Moon")
	.renderingMode(.original)
	.clipShape(Capsule()) // 4种形状 rectangle | rounded rectangle | capsule | circle
	.overlay(Capsule().stroke(.black, lineWidth: 1))
	.shadow(color: .black, radius: 2)
```

说明顺序很重要的示例

```swift
// 顺序1
Text("Hello World")
    .background(Color.purple) // 1. Change the background color to purple
    .foregroundColor(.white)  // 2. Set the foreground/font color to white
    .font(.title)             // 3. Change the font type
    .padding()   // 4. Add the paddings with the primary color (i.e. white)

// 顺序2
Text("Hello World")
    .padding()                // 1. Add the paddings
    .background(Color.purple) // 2. Change the background color to purple including the padding
    .foregroundColor(.white)  // 3. Set the foreground/font color to white
    .font(.title)             // 4. Change the font type
```



**`.alert`** 修饰符 ，特别说明一下：

```swift
struct ContentView: View {
  @State private var isShow = false
  
  var body: some View {
    VStack {
      Button(action: {
        self.openAlert()
      }) {
        Text("Open")
      }
    }
     // 此处使用双向绑定 在dismiss之后 自动回会设置为false
    .alert(isPresented: $isShow) {
      // Alert()...
    }
  }
  
  func openAlert() {
    isShow = true
  }
}
```



这一期内容比较多，需要慢慢的去实践和消化，整体感觉这种写法还是挺舒服的。



2019年11月30日23:51:01