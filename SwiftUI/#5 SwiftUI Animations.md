项目6 [Animations](https://github.com/jamessawyer/learn_ios/blob/master/SwiftUIProjects/Project06%20Animations/Project06%20Animations/ContentView.swift) （主要是讲动画）中涉及到知识点：

1. 使用 **`.animation()`** 修饰符创建隐式动画 和 **`Animation`** 结构体
2. **`onAppear()`** 和 动画：出现视图就开启动画
3. （Binding animations）给绑定值值添加动画
4. 使用 **`withAnimation() {}`** 显式定义动画
5. 修饰符的顺序和种类对动画效果的影响
6. 手势和动画的结合
   1. **`offset() | offset(_ offset: CGSize)`**
   2. **`.gesture`**
   3. **`DragGesture()`**: 拖拽手势，自身可以添加 **`onChange{} & onEnded {}`** 2个修饰符
7. **`transition`** 系统提供的便捷动画方式，和自定义transition 修饰符



> 1. .animation() 和 Animation结构体

这那些 **可动画属性** 的修饰符后面添加 **`animation()`** 修饰符，当那些 **可动画属性** 的值发生变化时，就会产生动画效果。另外，**`.animation()`** 修饰符可以提供多种不同的动画函数曲线。

```swift
Button("hello") {
  self.scale += 1 // 缩放比例
}
.frame(width: 100, height: 100)
.scaleEffect(scale) // scaleEffect对视图进行缩放
.animation(.default)
```

其余的一些动画曲线：

```swift
// 1. 默认动画效果： ease in, ease out
.animation(.default)

// 2. 弹簧动画效果
// 还有一个函数 interpolatingSpring(mass:stiffness:damping:initialVelocity)
.animation(.interpolatingSpring(stiffness: 50, damping: 1))

// 3. 定义动画时间
// Animation被省略 这里只有一个修饰符
// Animation.easeInOut()
// 当有多个修饰符时 Animation不能省略
.animation(.easeInOut(duration: 2)) // 2s

// 4. 给动画添加一个延迟
// .delay()
.animation(
	Animation.easeInOut(duration: 1)
	.delay(1)
)

// 5. repeatCount 添加一个重复动画
// 可以定义是否自动反向
.animation(
  Animation.easeInOut(duration: 1)
  	.repeat(3, autoreverses: true)
)
```

详细参考：[ImplicitAnimation](https://github.com/jamessawyer/learn_ios/blob/master/SwiftUIProjects/Project06%20Animations/Project06%20Animations/Animations/ImplicitAnimation.swift)



> 2. onAppear() 和 动画

这个一般就是先定义某个属性，当视图出现了，改变该视图，然后产生动画效果的方式

```swift
@State private var scale: CGFloat = 1.0 // 初始值

Button("hello") {}
	.frame(width: 100, height: 100)
	.scaleEffect(scale)
	.animation(.defalut)
	.onAppear {
		self.scale = 2 // 视图出现时将这个值变化为2
	}
```

详细参考： [OnAppearAnimation](https://github.com/jamessawyer/learn_ios/blob/master/SwiftUIProjects/Project06%20Animations/Project06%20Animations/Animations/OnAppearAnimation.swift)

另外这个页面中还涉及到的知识点还有：

1. **`.circel(Circle())`** 将一个视图变为一个圆形
2. **`.overlay()`** 给视图添加一个图层
3. **`Circle().stroke()`** 描边
4. **`.repeatForever(autoreverses:) & .repeatForever()`** 一直重复动画

> 3. 给绑定值添加动画

上面的动画都是给属性添加动画，swiftUI还可以给绑定值添加动画，当绑定值发生变化时，自动产生动画效果

```
@State private var animationValue: CGFloat = 1

VStack {
  Stepper(
  	"scale",
  	$animation.animation(.default),
  	in: 1...10
  )
  Button("Hello"){
    self.animationValue += 1
    .padding(40)
    .clipShape(Circle())
    .scaleEffect(animationValue)
  }
}
```

我们会发现使用 **`Stepper`** 修改 **`animationValue`** 会使按钮产生动画效果，而直接点击按钮是没有动画效果的，这是因为按钮自身并没有添加 **`.animation`** 修饰符。

详细参考： [BindingValueAnimation](https://github.com/jamessawyer/learn_ios/blob/master/SwiftUIProjects/Project06%20Animations/Project06%20Animations/Animations/BindingValueAnimation.swift)



> 4. withAnimation {} 显式定义动画

除了使用 **`.animation()`** 定义隐式的动画，还可以使用 **`withAnimation`** 定义显式的动画。

```swift
@State private var rotation = 0.0

Button("hello") {
  // 显式的定义动画
  withAnimation(.default) {
    self.rotation += 360
  }
}
	.padding(40)
	.backgroundColor(Color.red)
	.clipShape(Circle())
	.rotation3DEffect(
	 	.degrees(rotation),
	 	axis: (x: 0, y: 1, z: 0)
	)
```

这里还使用到了，另一个动画效果：**`rotation3DEffect()`**, 还有个相识的 **`rotationEffect()`**, 后者转动轴始终为 **`z`轴**，而前者可以定义多个轴。

详细参考： [ExplicitAnimation](https://github.com/jamessawyer/learn_ios/blob/master/SwiftUIProjects/Project06%20Animations/Project06%20Animations/Animations/ExplicitAnimation.swift)



> 5. 修饰符的顺序对动画的影响

首先要说的是，**和其它修饰符一样，我们可以多次的使用 `.animation()` 修饰符， 每次 `.animation()` 出现的位置，只能对其前面可动画属性的起到作用， 如果想要部分属性，不产生动画效果，可以使用 `.animation(nil)`**

```swift
@State private var enabled = false

Button("hello") {
  self.enabled.toggle()
}
.frame(width: 200, height: 200)
.background(enabled ? Color.red : Color.blue)
.animation(.default)
.clipShape(RoundedRectangle(cornerRadius: enabled ? 60 : 0))
.animation(.interpolatingSpring(stiffness: 50, damping: 1))
```

上面对不同的属性，使用了2种不同的动画曲线。

详细参考： [ModiferOrderImpactAnimation](https://github.com/jamessawyer/learn_ios/blob/master/SwiftUIProjects/Project06%20Animations/Project06%20Animations/Animations/ModifierOrderImpactAnimation.swift)

额外知识点：

- 使用 **`clipShape(RoundedRectangle(cornerRadius:))`** 生成一个倒角效果



> 6. .gesture & DragGesture()

这里主要是手势和动画相结合的效果。

```swift
@State private var dragMount = CGSize.zero

Color.red
.frame(width: 300, height: 200)
.clipShape(RoundedRectangle(cornerRadius: 10))
.offest(dragMount)
.gesture(
	DragGesture()
	.onChanged {
		// 手势不断的变化 产生不同的值
    self.dragMount = $0.translation
	}
	.onEnded { _ in
	  // 释放手势
    withAnimation(.spring()) {
      // 回到起点
      self.dragAmount = CGSize.zero
    }
	}
)
```

详细参考：

1. [GestureAnimation1- drag card spring](https://github.com/jamessawyer/learn_ios/blob/master/SwiftUIProjects/Project06%20Animations/Project06%20Animations/Animations/GestureAnimation1.swift)
2. [GestureAnimation2 - drag text with delay effect](https://github.com/jamessawyer/learn_ios/blob/master/SwiftUIProjects/Project06%20Animations/Project06%20Animations/Animations/GestureAnimation2.swift)

额外知识点：

1. **`CGSize`** 类型
2. **`offset() & offset(_ offset: CGSize)`** 视图位置的偏移



> 7. .transition() 和 自定义 transition 效果

**`transition`** 是系统提供的便利动画效果，主要包括对位移，缩放，透明度等

使用起来也很方便 

```
@State private var isShow = false

VStack {
  Button("hello") {
    withAnimation {
      self.isShow.toggle()
    }
  }
  
  // 视图隐藏和显示
  if isShow {
    Rectangle()
     .fill(Color.red)
     .frame(with: 200, height: 200)
     //.transition(.scale)
     .transition(.asymmetric(insertion: .scale, removal: .opacity))
  }
}
```

详细参考：[TransitionAnimation](https://github.com/jamessawyer/learn_ios/blob/master/SwiftUIProjects/Project06%20Animations/Project06%20Animations/Animations/TransitionAnimation.swift)

1. **`transition(.scale)`** 用于定义一个缩放动画
2. **`transition(.asymmetric(insertion:removal))`** 用于定义不对称动画，入场动画和出场动画效果

另外关于自定义Transition动画修饰符，可以参考： [CustomTransitionModifier](https://github.com/jamessawyer/learn_ios/blob/master/SwiftUIProjects/Project06%20Animations/Project06%20Animations/Animations/CustomTransitionModifierAnimation.swift)



SwiftUI是我见过定义动画最简洁明了的一种方式。更多动画效果可以参考：

- [✨SwiftUI Animations - youtube nimbbble](https://www.youtube.com/watch?v=gN7xW2YyoBA&list=PLTz6PJ9dfcu30W4CDtFv7f2PAoFMn0Xmb)

2019年12月21日12:09:52