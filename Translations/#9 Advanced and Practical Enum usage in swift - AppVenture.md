这是我见过讲Swift 枚举最详细最全的一篇文章了。

原文链接：

- [Advanced and Practical Enum usage in Swift](http://appventure.me/guides/advanced_practical_enum_examples/introduction.html)

**枚举用于声明有限组合的状态和相应的值。通过嵌套，方法，关联值和模式匹配，枚举能够定义任意层级的数据结构。**



## 1. Basic Enums

假设一个游戏里面，英雄只能朝着4个方向移动。因此英雄的移动方向被限制了。可以使用下面的方式定义：

```swift
if movement == "left" { ... }
else if movement == "right" { ... }
```

这样做有个弊病，因为使用字符串，我们有可能将 **`left`** 不小心写错为 **`leeft`**。可能我们会想到定义变量的方式来规避这种风险：

```swift
let moveLeft = 0
let moveRight = 1
if movement == moveLeft { ... }
else if movement == moveRight { ... }
```

这有可能解决拼写的错误，但是随着 `movements` 的增加，我们有可能忘记处理所有的movements。



> Defining Basic Enums

枚举用于将特定的集合的 **`cases`** 组合起来。

```swift
enum Movement {
  case left
  case right
}
```

结合 `switch` 使用:

```swift
let myMovement = Movement.left
switch myMovement {
case .left: player.goLeft()
case .right: player.goRight()
}
```



### 1.1 Enum values

可以给枚举的cases赋值，C语言只能给枚举赋数值，而swift则更加灵活

```swift
// 赋值数字
enum Binary {
  case zero = 0
  case one = 1
}

// 赋值字符串
enum House: String {
  case baratheon = "ours is the Fury"
  case stark = "Winter is Coming"
}

// Float 或者 Double
enum Constants: Double {
  case π = 3.14159
  case e = 2.71828
  case φ = 1.61803398874
  case λ = 1.30357
}
```

**对于 `Int` 和 `String` 类型，swift会自动的赋值**

```swift
// mercury = 1, vernus = 2, ... , neptune = 8
enum Planet: Int {
  case mercury = 1, venus, earth, mars, jupiter, saturn, uranus, neptune
}

// north = "north", south = "south"
enum CompassPoint: String {
  case north, south, ease, west
}
```

Swift 支持下面类型的枚举值：

- Boolean
- Integer
- Floating Point
- String

可以使用 **`rawValue`** 数据获取枚举的值：

```swift
enum House: String {
  case baratheon = "ours is the Fury"
  case stark = "Winter is Coming"
}
let stark = House.stark
print(stark.rawValue) // "Winter is Coming"
```

另外，枚举还可以使用 **`init(rawValue:)`** 从 rawValue 创建一个case，这是一个 **`failable initializer`**, 因此返回的结果是一个 **可选值**

```swift
enum Movement: Int {
  case left = 0
  case right = 1
  case top = 2
  case bottom = 3
}

// 创建一个 movement.Right 的 case
// rightMovement 是一个可选类型
let rightMovement = Movement(rawValue: 1)
```

为什么是一个可选类型呢？这是因为 rawValue个的值，原枚举中根本就不存在：

```swift
// Movement 中不存在 rawValue为40的case
let someMovement = Movement(rawValue: 40)
```



### 1.2 Nesting Enums

有时可能在枚举中存在子类型的需求，swift中我们可以嵌套枚举。比如在一个RPG游戏中，存在 **`Character`** (角色) 这个枚举，不同的角色都可以使用 **`Weapon`** 这个枚举里面的某种武器，而游戏中的其它部分，没有对武器使用的需求，将 **`Weapon`** 嵌套在 **`Character`** 中比较合适

```swift
enum Character {
  // 武器
  enum Weapon {
    case bow
    case sword
    case lance //矛
    case dagger
  }
  // 头盔
  enum Helmet {
    case wooden
    case iron
    case diamond
  }
  
  // 角色
  case thief
  case warroir
  case knight
}
```

使用：

```swift
let character = Character.thief
let weapon = Character.Weapon.bow
let helmet = Character.Helmet.iron

func strength(
  of character: Character,
  with weapon: Character.Weapon,
  and armor: Character.Helemt
) {
  // ...
}

strength(of: character, with: weapon, and: helemt)
// 或者
strength(of: .thief, with: .bow, and: .iron)
```



> 在struct 和 class 中包含枚举

枚举还可以包含在结构体或者类中：

```swift
struct Character {
  enum CharacterType {
    case thief
    case warroir
    case knight
  }
  // 武器
  enum Weapon {
    case bow
    case sword
    case lance //矛
    case dagger
  }
	let type: CharacterType
	let weapon: Weapon
}
//
let warroir = Character(type: .warroir, weapon: .lance)
```



### 1.3 Associated Values

这个是swift枚举特有的功能，使得swift枚举功能更加的强大，用于给 **`enum case`** 添加额外的信息。

比如有个交易系统，有2种交易方式： **`buy & sell`**, 每种交易方式都能指定交易的股票名和数量。

如果没有关联值的功能，我们可能这样写：

```swift
enum Trade {
  case buy
  case sell
}
func trade(tradeType: Trade, stock: String, amount: Int) {}
```

很明显 **`stock & amount`** 应该属于 **`Trade`** ，将其分离，使得代码不够紧凑。使用关联值就可以很好的解决这一个问题：

```swift
enum Trade {
  case buy(stock: String, amount: Int)
  case sell(stock: String, amount: Int)
}
func trade(type: Trade) {}

// 使用
let trade = Trade.buy(stock: "APPL", amount: 500)
```



> Pattern Matching

在 [swift pattern matching](https://github.com/jamessawyer/learn_ios/blob/master/Translations/%235%20Pattern%20Matching%20with%20case%20let%20-%20Majid.md) 中，已经看到了 结合 **`case let`** 对枚举进行模式匹配：

```swift
let trade = Trade.buy(stock: "APPL", amount: 500)
if case let Trade.buy(stock, amount) = trade {
  print("buy \(amount) of \(stock)")
}
// 打印
buy 500 of APPL
```

理解上面写法的意思：**这里的 `if` 语句，需要从右到左进行理解，如果 `trade` 是 `Trade.buy` 类型， 则让 `stock & amount` 2个变量赋予 `trade` 中，相对应的值 **。

上面的写法等价于：

```swift
let trade = Trade.buy(stock: "APPL", amount: 500)
if case Trade.buy(let stock, let amount) = trade {
  print("buy \(amount) of \(stock)")
}
```



> Labels

关联值可以不需要标签，只写类型，初始化的时候不需要带上标签

```swift
// 带标签
enum Trade {
  case buy(stock: String, amount: Int)
  case sell(stock: String, amount: Int)
}
// 初始化
let trade = Trade.buy(stock: "APPL", amount: 500)

// 不带标签
enum Trade {
  case buy(String, amount)
  case sell(String, amount)
}
// 初始化
let trade = Trade.buy("APPL", 500)
```



> Use Case Examples

几个简短的示例：

```swift
enum UserAction {
  case openURL(url: URL)
  case switchProcess(process: UInt32)
  case restart(time: NSDate?, intoCommandLine: Bool)
}

// 假设一个编辑器
// 可以多个选中，或者单个选中文字
enum Selection {
  case none
  case single(Range<Int>)
  case multiple([Range<Int>])
}

// 条形码和二维码
enum Barcode {
  case UPCA(numberSystem: Int, manufacturer: Int, product: Int, check: Int)
  case QRCode(productCode: String)
}

// RPG
enum Wearable {
  enum Weight: Int {
    case light = 1
    case mid = 4
    case heavy = 10
  }
  enum Armor: Int {
    case light = 2
    case strong = 8
    case heavy = 20
  }
  case helmet(weight: Weight, armor: Armor)
  case shield(weight: Weight, armor: Armor)
  case breatplate(weight: Weight, armor: Armor)
}
let woodenHelmet = Wearable.helmet(weight: .light, armor: .light)
```



### 1.4 Methods and Properties

Swift中的枚举和结构体或类一样，可以添加方法和属性.和类或结构体不同的是，使用枚举，可以直接在 **`switch`** 中使用 **`self`**:

```swift
enum Transportation {
  case car(Int)
  case train(Int)
  
  func distance() -> String {
    switch self {
    case .car(let miles): return "\(miles) miles by car"
    case .train(let miles): return "\(miles) miles by train"
    }
  }
}
```

再比如：

```swift
enum Wearable {
  enum Weight: Int {
    case light = 1
  }
  enum Armor: Int {
    case light = 2
  }
  case helmet(weight: Weight, armor: Armor)
  // 返回一个 tuple
  func attributes() -> (weight: Int, armor: Int) {
    switch self {
    case .helmet(let w, let a):
      return (weight: w.rawValue * 2, armor: a.rawValue * 4)
    }
  }
}

// 使用
let woodenHelmetProps = Wearable.helmet(weight: .light, armor: .light).attributes()
let (weight, armor) = woodenHelmetProps
print("\(weight) \(armor)") // 2 8
```



> **Properties**

**枚举不允许添加存储属性，只能添加计算属性(只读的)**。

```swift
// 不允许添加存储属性
// 下面写法错误
enum Device {
  case iPad
  case iPhone
  
  // 存储属性 Error
  let introduced: Int
}

// 添加计算属性 Ok
enum Device {
  case iPad
  case iPhone
  
  // 计算属性 OK
  var introduced: Int {
    switch self {
    case .iPhone: return 2007
    case .iPad: return 2010
    }
  }
}
```

如果想要存储或者改变信息，可以使用 **关联值(accociated values)** 的特性：

```swift
enum Character {
  case wizard(name: String, level: Int)
  case warrior(name: String, level: Int)
}
extension Character {
  var level: Int {
    switch self {
    case .wizard(_, let level): return level
    case .warrior(_, let level): return level
    }
  }
}
```



> **Static methods**

这个和结构体或类一样：

```swift
enum Device {
  static var newestDevice: Device {
    return .appleWatch
  }
  
  case iPad
  case iPhone
  case appleWatch
}
```



> **Mutating Methods**

这个和结构体一样，允许改变 case 底层的 self参数。比如有一个台灯，灯光强度有3种状态： **`off & low & bright`**, 下面定义一个方法，让其在3种状态中依次循环切换：

```swift
enum TriStateSwitch {
  case off, low, bright
  
  mutating func next() {
    switch self {
    case .off: self = .low
    case .low: self = .bright
    case .bright: self = .off
    }
  }
}
var ovenLight = TriStateSwitch.low
ovenLight.next() // .bright
print(ovenLight) // "bright"
ovenLight.next()
print(ovenLight) // "off"
ovenLight.next()print(ovenLight) // "low"
```



### 1.5 Recap

再回头看最开头关于枚举的定义：

**`Enums declare types with finite sets of possible states and accompanying values. With nesting, methods, accociated values,and pattern matching, howerve, enums can define any hierarchically organized data`**。

这样就很直白了。

相比结构体，枚举的优势是能够编码分类和使层次结构清晰：

```swift
// 结构体
struct Point { let x: Int, y: Int}
struct Rect { let x: Int, y: Int, width: Int, height: Int}

// 枚举
enum GeometricEntity {
  case point(x: Int, y: Int)
  case rect(x: Int, y: Int, width: Int, height: Int)
}
```

还可以添加属性和方法以及静态方法：

```swift
// C语言枚举
enum Trade {
  case buy
  case sell
}
func order(trade: Trade) {}

// swift 枚举
enum Trade {
  case buy
  case sell
  
  func order(trade: Trade) {}
}
```



## 2. Advanced Enum Usage

上面介绍了swift枚举的基本使用方法，但是swift枚举是swift语言中最具特色的功能之一， 它还可以做更多的事情。

枚举可以和协议，扩展一起使用，还可以添加泛型。



### 2.1 Protocols

比如 **`CustomStringConvertible`** 协议，是swift中用于自定义打印信息的一个协议:

```swift
protocol CustomStringConvertible {
  var description: String { get }
}

// 枚举服从协议
enum Trade: CustomStringCOnvertible {
  case buy, sell
  
  // 自定义打印信息
  var description: String {
    switch self {
    case .buy: return "buying something"
    case .sell: return "selling something"
    }
  }
}
let sell = Trade.sell
print(sell) // "selling something"
```

有时一些协议需要处理内部状态，比如一个管理银行的账户：

```swift
protocol AccountCompatible {
  var remainingFunds: Int { get }
  mutating func addFunds(amount: Int) throws
  mutating func removeFunds(amount: Int) throws
}
```

这种情况使用结构体很容易实现，但是使用枚举也能够实现，因为枚举不能有存储属性，所以这里的 **`var remainingFunds: Int {get}`** 需要写成计算属性：

```swift
enum Account {
  case empty
  case funds(remaining: Int)
  case credit(amount: Int)
  
  var remainingFunds: Int {
    switch self {
    case .empty: return 0
    case .funds(let remaining): return remaining
    case .credit(let amount): return amount
    }
  }
}

// 实现 AccountCompatible 协议
extension Account: AccountCompatible {
  mutating func addFunds(amount: Int) {
    var newAmount = amount
    // 下面 if case let 语句表示
    // 如果当前 self 是 Account.funds 类型
    // 例如 var fund = Account.funds(remaining: 20)
    // 则 remaining = 20
    if case let .funds(remainging) = self {
      newAmount += remaining
    }
    if newAmount < 0 {
      self = .credidt(newAmount)
    } else if newAmount == 0 {
      self = .empty
    } else {
      self = .funds(remaining: newAmount)
    }
  }
  
  mutating func removeFunds(amount: Int) throws {
    try self.addFunds(amount * -1)
  }
}

// 使用
var account = Account.funds(remaining: 20)
try? account.addFunds(amount: 20)
print(account.remainingFunds) // 40
```



### 2.2 Extensions

上面可以看到协议和扩展一起配合使用的情况。扩展枚举和扩展其他类型差不多。

```swift
enum Entity {
  case soldier(x: Int, y: Int)
  case tank(x: Int, y: Int)
}

extension Entity: CustomStringConvertible {
  var description: String {
    switch self {
    case let .solider(x, y): return "\(x) \(y)"
    case let .tank(x, y): return "\(x) \(y)"
    }
  }
}

extension Entity {
  mutating func move(dist: CGVector) {}
  mutating func attack() {}
}
```



### 2.3 Generic Enums

枚举和关联值一起使用，关联值的类型可以是一个泛型。最常见的就是Swift中的 **`Optional`** 类型。可选类型本质上就是一个枚举。

```swift
// 简写的 Optional 定义
enum MyOptional<T> {
  case none
  case some(T)
}
```

枚举也可以有多个泛型参数，比如：

```swift
enum Either<T1, T2> {
  case left(T1)
  case right(T2)
}
```

也可以像结构体或类一样给泛型添加约束：

```swift
enum Bag<T: Sequence> where T.Iterator.Element==Equatable {
  case empty
  case full(contents: [T])
}
```



### 2.4 Recursive/Indirect Type

间接类型允许关联值里面的 case的类型和枚举类型一样。

比如一个文件系统有文件和文件夹，而文件夹里面可以包含多个文件。如果 **`File & Folder`** 都是枚举cases， 而 **`Folder`** case 的关联值里面包含多个 **`File`** 数组，从而形成一种递归。

```swift
enum FileNode {
  case file(name: String)
  // 文件夹里面也是一个 FileNode
  indirect case folder(name: String, files: [FileNode])
}
```

也可以直接给枚举本身添加一个 **`indirect`**:

```swift
indirect enum Tree<Element: Comparable> {
  case empty
  case node(Tree<Element>, Element, Tree<Element>)
}
```

这个特性这对用枚举创建复杂的关系十分有用。



### 2.5 Cusom Data Types

在上面 **`1.1 Basic Emums`** 中我们说过枚举的值只能为Integer,Floating Point, String 和 Boolean 类型。为了支持其他的类型，我们需要将自定义类型服从 **`ExpressibleByStringLiteral`** 协议，然后将字符串类型转换为想要的类型， 具体可参考：

- [Custom enumeration raw values](https://andybargh.com/custom-enumeration-raw-values/)

比如使用枚举列举出所有的iphone尺寸

```swift
// Error
// CGSize is not a literal
enum Devices: CGSize {
  case iPhone5 = CGSize(width: 320, height: 568)
  case iPhone6 = CGSize(width: 375, height: 667)
}
```

自定义类型：

```swift
extension CGSize: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    let components = value.split(separator: ",")
    guard components.count == 2,
    let width = components[0],
    let height = components[1] else {
      self.init(width: 0, height: 0)
      return
    }
    self.init(width: width, height: height)
  }
}

enum Devices: CGSize {
  // 注意这里使用的是字符串
  case iPhone5 = "320,568"
  case iPhone6 = "375,667"
}

// 使用
let iPhone5 = Devices.iPhone5
// 这里可以使用 iPhone5.width
print("the phone size string is \(iPhone5), width: \(iPhone5.width), height: \(iPhone5.height)")
```



### 2.6 Comparing Enums

枚举和字符串或者数值一样，可以进行相等性比较。

对于简单类型，可以直接的比较：

```swift
enum Toggle {
  case on, off
}
Toggle.on == Toggle.off // false
```

对于含有关联值的cases, **如果cases不包含自定义类型，则让枚举服从 `Equatable` 协议即可进行对比** 

```swift
// 只包含 String, Int, [String]类型 
// String, Int 本身就是服从 Equatable 协议的
enum Character: Equatable {
  case warrior(name: String, level: Int, strength: Int)
  case wizard(name: String, magic: Int, spells: [String])
}
```

如果包含自定义类型，则让自定义类型也要服从 **`Equatable`** 协议

```swift
struct Weapon: Equatable {
  let name: String
}

enum Character: Equatable {
  // 包含自定义类型 Weapon
  case warrior(name: String, level: Int, strength: Int, weapon: Weapon)
  case wizard(name: String, magic: Int, spells: [String])
}
```

**另外除了服从 `Equatable` 协议方法外，还可以自定义 `==` 函数**：

```swift
struct Stock {}

enum Trade {
  case buy(stock: Stock, amount: Int)
  case sell(stock: Stock, amount: Int)
}
// 自定义相等性
func ==(lhs: Trade, rhs: Trade) -> Bool {
  switch (lhs, rhs) {
  case let (.buy(stock1, amount1), .buy(stock2, amount2))
  	where stock1 == stock2 && amount1 == amount2
  	return true
  case let (.sell(stock1, amount1), .buy(stock2, amount2))
  	where stock1 == stock2 && amount1 == amount2
  	return true
  default: return false
  }
}
```



### 2.7 Custom Initializers

可以给枚举添加一个自定义的构造器，便于实现自定义逻辑：

```swift
enum Device {
  case appleWatch
  // failable initializer
  init?(term: String) {
    if term == "iWatch" {
      self = .appleWatch
    } else {
      return nil
    }
  }
}
var watch = Device(term: "iWatch")
print("\(iWatch ?? "no result")")
```

示例2：

```swift
enum NumberCategory {
  case small
  case medium
  case big
  case huge
  
  init(number n: Int) {
    if n < 1000 { self = .small }
    else if n < 10000 { self = .medium }
    else if n < 100000 { self = .big }
    else { self = .huge }
  }
}
```



### 2.8 Iterating over Enum Cases

对于没有关联值的简单枚举，可以使其服从 **`CaseIterable`** 协议，使用 **`allCases`** 对其进行循环

```swift
enum Drink: String, CaseIterable {
  case coke, beer, water
}
for drink in Drink.allCases {
  print("For lunch I like to drink \(drink)")
}
```

对于包含关联值的枚举，则无法使用上面的方法

```swift
// Compile Error
enum Drink: CaseIterable {
  case beer
  // associated value
  case cocktail(ingredients: [String])
}
```



### 2.9 Objective-C Support

对于数值类型的枚举，可以使用 **`@objc`** 桥接到OC中：

```swift
@objc enum Bit: Int {
  case zero = 0
  case one = 1
}
```



到目前为止，基本上枚举相关的特性，都做了简单的介绍，枚举是swift中很重要的特性，熟练掌握枚举，对开发帮助很大。

原文最后一章还有一些关于枚举在实际代码中的使用情况，不在此赘述，可以参考原文。

2020年01月19日21:32:25



·





