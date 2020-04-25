

文章来源：

1. [the complete guide to the state Management](https://nalexn.github.io/state-management-guide-ios/)
2. [Callbacks, Part 1: Delegate, NotificationCenter, and KVO](https://nalexn.github.io/callbacks-part-1-delegation-notificationcenter-kvo/#delegate)
3. [Callbacks, Part 2: Closure, Target-Action, and Responder chain](https://nalexn.github.io/callbacks-part-2-closure-target-action-responder-chain/)
4. [Callbacks, Part 3: Promise, Event and Stream](https://nalexn.github.io/callbacks-part-3-promise-event-stream/)

处理应用状态，通常会碰到的问题：

1. **竞争状态（Race condition）**: 在并发环境中对数据的非同步访问，导致数据异常，甚至应用崩溃，并且这种bug很难调试
2. **异常副作用（Unexpected side effect）**: 多个实体引用同一个状态，但是某一个实体引发状态改变，导致其它实体异常。这通常是因为没有限制数据访问的原因，后果可能是UI卡顿，或者导致死锁
3. **值的连续性（Connascence of Values）**: 当多个实体通过存储自己的状态副本共享状态时，本地拷贝的状态的个改变不会自动影响其他备份。因此需要更新其他备份，如果没有处理好，会导致其它备份状态的不同步。
4. **类型的连续性（Connascence of Type）**: 有些动态语言，会不小心的改变变量类型



关于状态，经常会碰到的2个问题是：

1. 哪里存储状态数据？
2. 如何通知页面中其它实体，状态发生了变化？



## 1. 哪里存储状态（Where to store the state data?）

变量可以存在方法中，也可以存在在某个类中，亦或者存在全局中，它们的区别就是程序的读或写的**作用域**。

存储的原则就是：最小作用域原则。

本地状态比较简单，不和其它屏幕共享状态，对于不同的架构，存放的位置也不同，对于 **MVC** 就是 **`ViewController`**；对于 **MVVM** 就是 **`Model`**。

如果状态要被多个模块共享或者传递，事情就会变得比较复杂了，主要有2种情况：

1. 把状态传递给子页面，子页面完成任务后，再将状态传回给原来的页面
2. 有一个状态被整个应用共享。任何一个页面都可能使用或者改变这个状态

**对于父页面给子页面，传递属性，可以使用依赖注入（dependency injection）, 对于子页面回传给父页面，则比较麻烦一点**，下面会讲到如何进行回传。



## 2.如何通知其他实体，状态更新了（How to notify the other entities in the app about the state update?）

主要有以下几种方式：

1. **委托（delegate）**
2. **通知（NotificationCenter）**
3. **KVO**
4. **闭包（Closure）**
5. **Target-Action**
6. **响应链（Responder Chain）**

选择哪一种方式呢？

- **委托**： iOS开发中很常见的一种模式，但是使用 **闭包** 更加的灵活和简洁
- **Target-Action**：和委托差不多，只有在 **`UIController & UIGestureRecognizer`** 的子类中使用，因为在这些子类中， Target-Action是天然被支持的
- **闭包**：**最简洁的方式**。但是对于比较复杂的情形，比如需要后续的异步任务回调，或者需要通知多个模块时，使用 **`Promise | Event | Stream`** 就更合适了
- **Promise**：多用于处理一系列异步任务，比如调用后台接口；使用 **Stream of values** 也可以完成同样的任务，但是Promise更加简洁
- **Event**：这是一个轻量级的观察者模式，是 **`NotificationCenter & KVO`** 的一种比较好的替代品。可以提供订阅或者KVO风格的变化观察
- **Stream of values**：使用 **`RxSwift`**, 这个可用于替代上面的Promise和Event.但是函数式编程，各种操作符，会导致开发更加的困难
- **NotificationCenter**：使用通知，会导致很多意想不到的问题，除了苹果提供的非要使用通知外，其余的，最好使用Event | stream of values 替换
- **KVO**：当没有其他方式去观察状态时，才使用KVO。不可否定，**KVO** 技术很好，它是RxSwift的组成部分。可以使用 **Event** 替换
- **Responder Chain**：因为它不能在通知中携带数据，所以几乎很少用到。但是，假设我们只有一个对状态的引用，只需要一个trigger来完成UI刷新，只有这种方式。不推荐使用



### 2.1 委托（delegate）

示例：假设一个人做披萨，一个客户购买披萨，做披萨的不需要知道客户是谁，他只知道他做好披萨后，客户会拿走披萨。

```swift
// 委托协议
protocol PizzaTaker {
  func take(pizza: Pizza)
}

// 做披萨的
class Pizzaiolo {
  // 对 PizzaTaker 保持一个引用， 而不是Customer
  weak var pizzaTaker: PizzaTaker?
  
  func makePizza() {
    //...
  }
  
  private func onPizzaIsReady(pizza: Pizza) {
  	// 调用委托方法
    pizzaTaker?.take(pizza: pizza)
  }
}

// 消费者
// Customer遵循PizzaTaker协议
class Customer: PizzaTaker {
  var name: String
  var dateOfBirth: Date
  
  // 实现协议方法
  func take(pizza: Pizza) {
    // ...
  }
}
```

使用委托的优点：

1. 松耦合，Pizzaiolo 和 Customer之间不需要知道彼此，只需要通过委托 **PizzaTaker** 建立联系
2. IDE 支持好，如果遵循了协议，IDE会提示你要实现协议方法
3. 从调用委托，可以获取一个非空的结果。不像回调，委托既可以通知，也可以获取数据。在Cocoa中，经常可以看到 **`DataSource`** 协议
4. 性能好。委托相比于其他回调，它相当于直接调用函数，速度更快

缺点：

1. 单一接受者。例如，Pizzaiolo 不能同一时间给多个Customer 制作披萨。另外，如果另一个客户来了，而前一个客户的披萨还在制作中，那么事情就会变得很糟糕，新顾客会覆盖它自己在 Pizzaiolo上的 PizzaTaker 引用，之前的顾客是永远拿不到披萨的
2. 和业务逻辑联系太紧密（违反低聚合原则）。因为所有的回调方法都必须在接收者内部实现为单独的函数，因此不能使用匿名函数将动作和动作回调嵌套在一起，这会导致有时很难推断在哪种情况下调用回调
3. 步骤繁琐：为了使用委托，一般需要以下几步
   1. 定义一个新协议(**`PizzaTaker`**)
   2. 定义一个该协议的属性弱引用（**`weak var pizzaTaker: PizzaTaker?`**）
   3. 在目标类型中实现协议（**`class Customer:PizzaTaker `**）
   4. 委托引用赋值
   5. 如果使用OC，还需要使用 **`respondsToSelector:`** 检查委托是否可以处理消息
4. 造成 **Massive View Controller** 现象，即VC中，逻辑很臃肿。



## 2.2 NotificationCenter

通知在Cocoa中，提供了 **`publish-subscribe`** 功能。通知使用 **`Notification`** 类，它能够携带额外的数据负载，但一般用于 **通知**。

**`NotificationCenter`** 自身是一个数据总线（data bus）,它不会自行发送通知，仅当有人要求发送通知时。

**通知模式，主要优点就是，发送者（`sender`） 和 接收者（`recipients`）可以不用像委托那样直接交流**。

- 发送者（sender）调用 **`postNotification`**
- 接收者（recipients）添加监听 **`addObserver`**；不需要时，需要移除监听 **`removeObserver`**

**`NotificationCenter`** 还提供了一个单例 **`defaultCenter`**。

还是以上面pizza为例：

```swift
// 首先先声明一个新的通知类型
// 用于发送者和接收者之间进行识别
extension NSNotification.Name {
  static let PizzaReadiness = NSNotification.Name(rawValue: "pizza_is_ready")
}

class Pizzaiolo {
  func makePizza() {
    //...
  }
  
  private func onPizzaIsReady(pizza: Pizza) {
  	// Pizzaiolo通知所有对披萨好了 感兴趣的接收者
    NotificationCenter.default.post(
    	name: NSNotification.Name.PizzaReadiness,
    	object: self,
    	userInfo: ["pizza_object": pizza]
    )
  }
}

class Customer {
	// 注册一个监听
  func startListeningWhenPizzaIsReady() {
    NotificationCenter.default.addObserver(
    	self,
    	selector: #selector(pizzaIsReady(notification:)),
    	name: NSNotification.Name.PizzaReadiness,
    	object: nil
    )
  }
  
  // 当对通知不敢兴趣时 移除监听
  func stopListeningWhenPizzaIsReady() {
    NotificationCenter.default.removeObserver(
    	self,
    	name: NSNotification.Name.PizzaReadiness,
    	object: nil
    )
  }
  
  @objc dynamic func pizzaIsReady(notification: Notification) {
    if let pizza = notification.userInfo?["pizza_object"] as? Pizza {
      // got the pizza!
    }
  }
}
```

通知优点：

1. 可以存在多个接收者。
2. 松耦合，发送者和接收者之间不用知道彼此
3. 全局访问。当不需要（或不关心）代码中的依赖项注入时，单例风格方法 **`defaultCenter`** 允许您轻松地将两个随机对象连接在一起。

缺点：

1. 全局访问既是优点又是缺点。因为任何可全局访问的东西都会破坏您的代码的可测试性
2. 没有明显的流程控制。如果要理解通知的业务逻辑，可能很麻烦，因为到处都可能有接收者
3. 传输数据，装箱和拆箱 **`Dictionary`** 是易错的
4. 接收者必须取消订阅，避免内存泄漏和应用崩溃
5. 发送者不能获取非空的结果，这不同于 **`delegate & closure`**
6. 第3方库可能依赖相同的通知，导致相互干扰。
7. 任何人都可能发送通知，多人开发时，这将造成隐患



## 2.3 Key Value Observing(KVO)

KVO是任何 **`NSObject`** 内置的传统观察者模式。通过KVO，观察者可以对任何一个 **`@property`** 值的变化起到通知作用。它利用Objective-C **运行时（`runtime`）** 来自动发送通知。

**因此，对于Swift类，您需要通过继承 `NSObject` 并使用修饰符 `dynamic` 标记要观察的 `var`，从而选择使用Objective-C动态。 观察者也应该遵循 `NSObject` ，因为这是由KVO API强制必需的**。

```swift
// 被观察的类
class ObservedClass: NSObject {
	// 可被观察的属性
  @objc dynamic var value: CGFload = 0
}

class Observer {
  var kvoToken: NSKeyValueObservation?
  
  func observe(object: ObservedClass) {
    kvoToken = object.observe(\.value, options: .new) { (object, change) in
    	guard let value = change.new else { return }
    	print("new value is: \(value)")
    }
  }
  
  deinit {
    kvoToken?invalidate()
  }
}
```

优点：

1. 在 **`Cocoa`** 中，每个 **`NSObject`** 都只需要几行代码就可以实现观察者模式
2. 对于订阅者没有限制，可以存在多个观察者
3. 无需更改正在观察的类的源代码
4. 可以观察任何类的对象（包括系统框架中的对象）
5. 低耦合，需要被观察的属性，值需要标记 **`@property`** 即可（OC写法）
6. 通知中不仅包含新的值，还包含旧的值

缺点：

1. KVO是Cocoa中最差的API之一，但是可以使用更好的KVO替代：[PMKVObserver](https://github.com/postmates/PMKVObserver)
2. 订阅者使用的 **`keyPath`** 是一个字符串，不能静态的进行验证。Swift中幸运的存在 **`#keyPath`** 指令可以进行验证，而Objective-C中，如果改变了 **`@property`** 标记的属性名，经常会出现奔溃
3. 每个观察者都必须明确的在 **`deinit`**中 取消订阅，否则崩溃是不可避免的
4. 我们必须调用 **`observeValueForKeyPath`** 回调函数的父类实现，以确保我们不会破坏父类中的实现
5. 性能相对较慢。即使使用 **`-Os`** 优化进行编译，**对于 Objective-C，一个KVO通知也比函数调用慢30倍，对于Swift，它的速度要慢200倍。**



## 2.4 Closure（Block）

闭包在Cocoa中也称之为回调，定义为：**闭包是可以独立传递的功能块**。Objective-C中称闭包为 **`block`**。

```swift
// 闭包的类型可以预先定义，因为它是匿名的
// 因此它的声明看着像函数签名
typealias PizzaClosure = (Pizza) -> Void

class Pizzaiolo {
	// PizzaClosure 的`实例` 可以被视作对象一样
  private var completion: PizzaClosure?
  
  // PizzaClosure 作为参数传递
  func makePizza(completion: PizzaClosure) {
  	// 保存 'completion' 这样稍后可以进行调用
    self.completion = completion
    
    // Cooking the pizza
  }
  
  private func onPizzaIsReady(pizza: Pizza) {
    // 调用闭包，这样传递 pizza 做好的消息
    self.completion?(pizza)
    self.completion = nil
  }
}

class Customer {
  func askPizzaioloToMakeAPizza(pizzaiolo: Pizzaiolo) {
    // 我们将闭包的主体声明为将其作为输入参数传递的位置
    pizzaiolo.makePizza(completion: { pizza in
    	// We're inside the closure! And we've got the pizza!
    	// 当pizzaiolo调用我们传递给它的闭包时，这里的代码将执行
    })
  }
}
```

优点：

1. 松耦合，调用者和被调用者必须仅在闭包签名上一样，这是名称的最弱的连续性
2. 业务逻辑高聚合，动作和动作的响应能够声明在同一个地方
3. 从客户的上下文中捕获变量有助于进行状态管理，因为我们不需要将变量存储在类中，也不会面临潜在的访问问题，例如竞争条件。
4. 闭包和调用普通函数一样快
5. 和委托一样，闭包可以返回一个非空类型，因此它可以像 **`DataSource`** 一样，从客户代码中获取数据
6. 类型安全，IDE会自动检测类型

缺点：

1. 闭包和blocks语法都比较复杂
2. 对于新手，匿名函数（或lambda表达式）难以理解
3. 因为Swift和OC的自动引用计数内存管理，闭包可能因为形成  **retain cycle** 导致内存泄漏，使用闭包时要小心，有些地方需要使用 **`[weak]`** 修饰符来避免循环引用的问题
4. 当使用回调做异步操作时，可能会嵌套很多层进行判断，形成 **`callback hell`**
5. 闭包的参数没有参数labels，因此，客户端代码应为每个参数分配名称，这可能导致重构闭包签名后导致对参数的错误解释
6. OC中blocks在调用前，必须检测 **`NULL`**，否则app会崩溃



## 2.5 Target-Action(NSInvocation)

Target-action 本身就是一种设计模式，概念上是 **命令模式** 的一种变种形式。在iOS中，这种回调技术一般用于Cocoa中处理用户UI交互。

为了接收回调，客户端代码提供2个参数：

1. 一个对象： **`target`**
2. 一个函数：**`action`**

**回调通过对 `target` 调用 `action` 完成。这需要语言层面的支持，例如，swift不允许对任意对象调用任意一个方法，因此需要使用Objective-C来完成。**

在OC中，因为runtime，有几种方式对 `target` 实施 `action`。这里的示例，使用 **`NSInvocation`** 比较合适

```objective-c
@interface Pizzaiolo: NSObject
// target 和 action 分别发送
- (void)makePizzaForTarget:(id)target selector:(SEL)selector;
@end


@interface Customer: NSObject

- (void)askPizzaioloToMakePizza:(Pizzaiolo *)pizzaiolo;

@end


@implementation Pizzaiolo

- (void)makePizzaForTarget:(id)target selector:(SEL)selector
{
  NSInvocation *invocation = [self invocationForTarget:target selector:selector];
  
  // 保存invocation对象引用 以便稍后使用
  self.invocation = invocation
  
  // make pizza
}

- (void)onPizzaIsReady:(Pizza *)pizza
{
	// 参数索引从2开始，因为0和1是隐藏的参数 self 和 _cmd
  if (self.invocation.methodSignature.numberOfArguments > 2) {
    [self.invocation setArgument:&pizza atIndex:2];
  }
  [self.invocation invoke];
}

- (NSInvocation *)invocationForTarget:(id)target selector:(SEL)selector
{
  NSMethodSignature *signature = [target methodSIgnatureForSelector:selector];
  if (signature == nil) return nil;
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
  invocation.target = target;
  invocation.selector = selector;
  return invocation;
}

@end


@implementation Customer

- (void)askPizzaioloToMakePizza:(Pizzaiolo *)pizzaiolo
{
  [pizzaiolo makePizzaForTarget:self selector:@selector(takePizza:)];
}

- (void)takePizza:(Pizza *)pizza
{
  // Yeah! Objective "pizza" completed
}

@end
```

优点：

1. 某些方面 **`target-action`**  和 **`delegate`** 很相似，但相比委托模式，它有2个优点
   1. 回调函数名不是预先定义的，并且通过客户代码提供，这样将调用者和被调用者进行了解耦
   2. 它支持多个接收者，并为每个接收者调用单独的方法
2. **`NSInvocation`** 提供了一种获取非空结果的方式，因此，这种技术可用于请求数据（但是不建议这样做）
3. 静态代码分析器至少可以对作为操作提供的方法名称执行浅层检查

缺点：

1. 复杂的实现，都需要自己去实现
   1. 正确的构建 **`NSInvocation`**
   2. 为了支持多targets和actions，我们需要管理 **`NSInvocation`** 集合
2. 编译器不能够检测selector中的 **`action`**, 导致，代码重构时，导致应用崩溃
3. NSInvocation不会自动取消对释放对象的引用，因此触发回调时，应用可能在运行时崩溃，每个 **`target`** 都需要显式的从 target-action 中移除
4. 对于客户端代码，不能够清晰的知道 `action` 中的函数签名（有多少个参数，以及参数类型），这样传递参数是十分易错的，返回类型也一样
5. 和上面 **`delegate`** 的一样，和业务逻辑耦合，并且导致大量代码都在ViewController中实现



## 2.6 Responder chain

响应链的核心是**职责链**设计模式，主要使用到 **`UIResponder`** 类。

在Cocoa中，和UI相关的类，直接或间接的是 **`UIResponder`** 的子类，因此，响应链在每个应用中无处不在，每个视图，ViewController，以及 **`UIApplication`**。

假设有如下视图层级：

**`UIApplication - UIWindow - ViewController A - ViewController - View - Subview B`**

响应链允许 **`Subview B`** 很轻松给 **`ViewController A`** 发送消息。**`ViewController A`** 通过实现 **`Subview B`** 发送的 **`selector`** 成为响应链中的第一个。如果响应链中没有能够处理该 **`selector`** 的，该selector就会被抛弃，也不会出现崩溃。

**在Cocoa中，并不是所有的 `UIResponder` 都能够发送消息**，只有2个类能够发送：

1. **`UIApplication`**
2. **`UIControl`**：实际上也是调用 **`UIApplication`** API

**UIControl 发送消息：**

```swift
let control = UIButton()
// UIControl 要添加到视图层级中
view.addSubview(control)
control.sendAction(#selector(handleAction(sender:)), to: nil, for: nil)
```

**UIApplication发送**

```swift
UIApplication.shared.sendAction(
	#selector(handleAction(sender:)),
	to: nil,
	from: self,
	for: nil
)
```

如果在 **`from`** 参数中，提供一个非空的 **`UIResponder`** 对象，可以是当前视图或者当前viewcontroller。响应链会开始从这个元素开始遍历，当 **`from`** 为 **`nil`** 时，遍历从第一响应者（first responder） 开始。

优点：

1. 每个UIView和UIViewController都支持
2. 当视图层级发生变化时，响应链会自动进行管理
3. Interface Builder也支持，IB中可以选择谁成为第一响应者
4. 如果没有响应者，也不会崩溃

缺点：

1. 响应链只对 **`UIResponder`** 后代有用，任意对象不支持
2. 不能发送有用的数据，action预定义的参数是 **`sender: Any & event: UIEvent?`**
3. 调用不可能获得一个非空结果
4. 响应链是一个单纯形通道，无法选择方向
5. 对于新手来说，为什么他们必须使用晦涩的响应程序链来处理诸如在iOS中显示屏幕键盘这样的简单事情，这非常令人困惑



### 2.7 Promise

这个概念是来自JS社区，为了解决callback hell，并发和取消的问题。Promise使用 **`Closures`** 封装客户端代码。

假设：发送2个连续的请求，第一个加载一个 **`user`**， 然后使用其中的 **`id`** 作为第2个请求的参数，获取用户 **`posts`**。当发送请求时，我们需要显示 **`loading...`**, 当2个请求完成后或者其中某一个失败时，隐藏loading，然后显示错误信息。

如果使用Promise：

```swift
firstly {
  // 显示loading 发起第1个请求
  showLoadingIndicator()
  return urlSession.get("/user")
}.then { user in
  // 使用第一个请求中获取的数据
  return urlSession.get("/user/\(user.id)/posts")
}.always {
  // `always` 总是会被执行
  hideLoadingIndicator()
}.then { posts in
  // `then` 语句只有上面所有的promises都成功了 才会执行
  // 使用第2个请求中获取的 posts 数据
  display(posts: posts)
}.catch { error in
	// 错误处理
	showErrorMessage(error)
}
```

可以使用Swift版本的Promise：

- [PromiseKit](https://github.com/mxcl/PromiseKit)
- [BrightFutures](https://github.com/Thomvis/BrightFutures)

优点：

1. **`Closure`** 回调的一个好的替代品，解决了以下问题
   1. 链式调用，而不是嵌套，增加可读性
   2. 直白的错误处理，所有的错误都在一个地方进行处理
   3. 能从错误中恢复，继续原有的流程
   4. 可取消
   5. 写多个promises很容易
2. 自动捕获所有客户端抛出的错误
3. Promises被设计为只执行一次，然后自我销毁
4. 因为自我销毁，很难引起内存泄漏

缺点：

1. 正因为Promises自我销毁，因此替代不了像 **`delegate | NotificationCenter`** 这种多次调用
2. 取消不像其错误处理一样简单，PromiseKit中需要处理为一种特殊的Error类型
3. Promises比其他回调都要慢很多
4. 调试Promise很难



### 2.8 Event

如果Promise是闭包回调的替代品，则 **`Event`** 是 **`delegate & NotificationCenter & target-action`** 的替代品。

Events 提供一种给一个或多个接收者发送通知的泛型机制。

```swift
class DataProvider {
  let dataSignal = Signal<(data: Data, error: Error)>()
  let progressSignal = Signal<Float>()
  
  // ...
  func handle(receivedData: Data, error: Error) {
    // 当我们想通知订阅者时，我们触发信号，并提供负载数据
    progressSignal.fire(1.0)
    dataSignal.fire(data: receivedData, error: error)
  }
}
```

**`DataProvider`** 是通知源，**`DataConsumer`** 则是订阅者：

```swift
class DataConsumer {
  init(dataProvider: DataProvider) {
    dataProvider.progressSignal.subscribe(on: self) { progress in
    	// handle progress
    }.sample(every: 0.5)
    
    // 订阅
    dataProvider.dataSignal.subscribeOnce(on: self) { (data, error) in
    	// handle data or error
    }
  }
}
```

可以使用的Swift库：

- [Signals](https://github.com/artman/Signals)
- [emitter-kit](https://github.com/aleclarson/emitter-kit)

优点：

1. 支持多个接收者
2. 传输的任何数据，包括不包含数据 **`Void`** event，都可以进行静态检测
3. 自动取消订阅
4. 低耦合
5. 轻量的库
6. 库特色功能：
   1. 一次性订阅
   2. 延迟通知

缺点：

1. 2个或以上的events不能自然的结合在一起
2. Events只能单向的传递数据，而 **`delegate & Closure`** 是可以双向的
3. 需要注意循环引用，有些地方需要使用 **`[weak self]`**



### 2.9 Stream

流（或者异步数据流）是函数编程的主要概念，相关的库有：

- [RxSwift](https://github.com/ReactiveX/RxSwift)
- [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift)

相对于Events，它的特点是：

- 在其生命周期，它会记住所有发送过的值
- 可以和其它流结合
- 函数式编程方式
- 和Cocoa classes深度集成
- 除了observation,它还提供了更多泛型的使用方式

下面是 **`ReactiveSwift`** 的示例：

```swift
let searchResults = searchString
	.flatMap(.latest) { (query: String?) -> SignalProducer<(Data, URLResponse), AnyError> in
	let request = self.makeSearchRequest(escapedQuery: query)
  return URLSession.shared.reactive.data(with: request)
	}
	.map { (data, response) -> [SearchResult] in
  	let string = String(data: data, encoding: .utf8)!
  	return self.searchResults(fromJSONString: string)
  }
  .observe(on: UIScheduler())
```

优点：

1. Streams 可以替换Cocoa中所有的传统回调技术
2. 社区强大
3. 函数编程
4. Stream库包含很多Cocoa UI bindings 相关的库，可以减少代码量
5. 流借鉴了Events和Promises很多优点：
   1. 能够传输任何类型数据，并进行类型检测
   2. 支持多个观察者
   3. 能很容易的控制订阅者的生命周期
   4. 支持取消
   5. 集中处理错误
   6. 能从错误中修复并继续执行
   7. 延迟通知
   8. 过滤数据
   9. 将通知传递到特定的 **`OperationQueue`**

缺点：

1. 学习曲线高
2. 库比较大

