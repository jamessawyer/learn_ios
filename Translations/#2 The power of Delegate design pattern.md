文章来源：

- [The power of Delegate design pattern - Majid's blog](https://swiftwithmajid.com/2019/05/29/the-power-of-delegate-design-pattern/)

委托（**Delegate**）是iOS开发中最常见的一种设计模式，委托的定义：**在软件工程中，委托模式是一个面向对象的模式，允许代码通过组合的方式，完成像继承一样的代码复用。在委托中，对象A 通过 对象B 来完成请求。委托是一个辅助对象，但是拥有原对象的上下文环境。**



> 协议（Protocol）

在iOS开发中，委托模式很常见，比如：**`UITableView`** 委托 **`UITableViewDataSource`** 来生成table cells；**`UITableView`** 委托 **`UITableViewDelegate`** 完成table cell 被选中和其它的一些动作。

下面用一个示例来演示：假设开发一个游戏，将游戏逻辑提取到一个单独的类 **`Game`** 中，然后 **委托游戏状态改变给 渲染游戏的ViewController**

```swift
/// AnyObject 表示只有 class 实例才能服从这个协议
protocol GameDelegate: AnyObject {
  func stateChange(from oldState: Game.State, to newState: Game.State)
}

class Game {
  private var state: State = .notStarted {
    /// 每次state发生变化时 都会调用这个委托方法
    didSet {
      // oldValue 是 didSet中的关键字 表示旧的值
      delegate?.stateChanged(from: oldValue, to: state) // 调用委托方法完成
    }
  }
  /// 使用 weak 避免造成循环引用
  weak var delegate: GameDelegate? // 使用委托
  
  /// private(set) 表示 value 是一个只读值
  private(set) var value: Int = 0
  
  func start() {
    state = .started
  }
  
  func generateNextValue() {
    value = Int.random(in: 0..<1000)
    state = generateState(using: value)
  }
}

extension Game {
  // 游戏的几种状态 用枚举表示, 这样state只存在唯一值
  enum State {
    case notStarted
    case started
    case right
    case win
    case lost
  }
}
```

在 **`GameViewController`** 中：

```swift
class GameViewController: UIViewController {
  private let game: Game
  
  init(game: Game) {
    self.game = game
    super.init(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    game.delegate = self // 将当前VC 赋值给game的delegate属性
  }
  
  @IBAction func play() {
    game.start()
  }
  
  @IBAction func next() {
    game.generateNextValue()
  }
}

/// 上面 game.delegate = self
/// VC 需要服从该委托协议
extension GameViewController: GameDelegate {
  // 根据游戏的不同状态 渲染不同的内容
  func render(_ state: Game.State) {
    switch state {
    case .lost: renderLost()
    case .right: renderRight()
    case .win: renderWin()
    case .started: renderStart()
    case .notStarted: renderNotStarted()
    }
  }
  
  // 实现协议方法
  func stateChanged(from oldState: Game.State, to newState: Game.State) {
    render(newState)
  }
}
```



> 闭包

有时候委托中只有一个方法，这种情况，可以使用闭包完成相同的功能，思想是相同的。

```swift
class Game {
  /// 定义一个类型别名
  typealias StateHandler = (State) -> Void
  
  var handler: StateHandler?
  
  private var state: State = .notStarted {
    didSet {
      handler?(state) // 调用闭包 而不是调用委托方法
    }
  }
  
  private(set) var value: Int = 0
  
  func start() {
    state = .started
  }
  
  func generateNextValue() {
    value = Int.random(in: 0..<1000)
    state = generateState(using: value)
  }
}

class GameViewController: UIViewController {
  private let game: Game
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    game.handler = { [weak self] state in
      self?.render(state)
    }
  }
  
  @IBAction func play() {
    game.start()
  }
  
  @IBAction func next() {
    game.generateNextValue()
  }
}
extension GameViewController {
  // 根据游戏的不同状态 渲染不同的内容
  func render(_ state: Game.State) {
    switch state {
    case .lost: renderLost()
    case .right: renderRight()
    case .win: renderWin()
    case .started: renderStart()
    case .notStarted: renderNotStarted()
    }
  }
}
```



委托是iOS中最常见的一种设计模式，一定要掌握. 还有使用闭包方式解决相同的问题。



2020年01月09日16:26:30