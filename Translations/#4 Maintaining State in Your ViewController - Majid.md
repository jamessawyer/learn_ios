原文链接：

- [Maintaing state in your ViewController - Majid's blog](https://swiftwithmajid.com/2019/01/23/maintaining-state-in-view-controllers/)

前面 [使用协议和协议扩展](https://github.com/jamessawyer/learn_ios/blob/master/Translations/%233%20Using%20protocols%20as%20composable%20extensions%20-%20Majid.md) 对通用的loading和错误显示隐藏逻辑进行了封装。**今天使用协议对ViewControllers中的状态进行保持。**



假设某个页面显示用户正在观看的电视剧,使用第三方服务下载这些数据。可以使用3个变量来描述VC的状态：

```swift
class HistoryViewController: UIViewController {
  var loading: Bool = false {
    didSet {
      renderLoading()
    }
  }
  
  var shows: [Show]? {
    didSet {
      renderShows()
    }
  }
  
  var error: Error? {
    didSet {
      renderError()
    }
  }
}
```

即：

1. **`loading`** 显示是否VC在加载数据或者加载完成了
2. **`shows`** 存储实际的观看历史记录
3. **`error`** 表示请求是否存在错误



下面是请求数据的方法：

```swift
private func fetch() {
  loading = true
  historyService.fetch { [weak self] result in
  	self?.loading = false
  	switch result {
    case .success(let shows): self?.shows = shows
    case .failure(let error): self?.error = error
  	}
  }
}
```

在开始请求前，先将 **`loading`** 设置为 **`true`**， 调用 **`renderLoading()`** 方法, 然后发起请求获取数据。然后，请求结果设置 **`shows`** 或者 **`error`** ,初看之下，这种解决方法没什么问题，但是这样做有几个缺点：

1. 我们必须对每个请求都重置 **`loading & error & shows`** ，避免无效的状态。如果不重置，在第一请求失败后，用户重新请求后成功了，**`error`** 仍然存在。
2. 在任何时候，我们都想要 **`loading & error & shows` 唯一的状态** **， 这里可能出现多种状态混合的情况,这样可能导致状态模糊的情况



> **`Enums`**

如果想要唯一的状态，使用枚举再合适不过了。枚举在任意时间，都能返回唯一的值，下面是重构的方案：

```swift
enum State {
  case loading
  case error(Error)
  case loaded([Show])
}

class HistoryViewController: UIViewController {
  private var state: State {
    didSet {
      render()
    }
  }
}

extension HistoryViewController {
  func render() {
    switch state {
    case .loading: // render loading
    case .error(let error): // render error
    case .loaded(let shows): // render shows
    }
  }
}
```

这里使用 **`State`** 枚举来描述状态情况,当 state 发生变化时，会调用相应的方法。



> 协议和关联类型（Protocols and associated types）

上面的重构对当前VC已经很好了，但是要想做到通用性，则可以给 **`State`** 枚举添加一个泛型的约束,使其对其它VC 也能适用，因为大多数VC的状态，只有显示的数据存在差异。

```swift
enum State<Data> {
  case loading
  case loaded(Data)
  case error(Error)
}
```

结合之前的协议和协议扩展，对 **`State`** 进一步的封装，将其封装为一个协议:

```swift
protocol StatePresentable: ActivityPresentable, ErrorPresentable {
  associatedtype Data
  
  var state: State<Data> { get set }
  func render()
  func render(_ data: Data)
}

extension StatePresentable {
  func render() {
    switch state {
    case .loading:
    	setActivityStatus(.visible)
    case .error(let error):
    	setActiviityStatus(.hidden)
    	present(error)
    case .loaded(let data):
      setActivityStatus(.hidden)
      render(data)
    }
  }
}
```

这里使用 **`StatePresentable`** 协议扩展 Activity 和 Error 协议。 StatePresentable 有一个关联类型 **`Data`** ，这个类型也是 **`State`** 枚举中的泛型约束,使其适用于任何类型的数据,同时对 **`render`** 方法添加了默认的实现。

使用：

```swift
class HistoryViewController: UIViewController {
  private var state: State<[Show]> {
    didSet {
      render()
    }
  }
}

extension HistoryViewController: StatePresentable {
  func render(_ data: [Show]) {
    // render data here
  }
}
```

这里所做的就是服从 **`StatePresentable`** 协议, 对 **`state`** 属性添加 **`didSet`** 属性观察器,并且实现 **`render`** 方法,用于添加数据显示逻辑。

使用协议和关联类型可以使得代码更具通用性。



2020年01月10日12:10:12