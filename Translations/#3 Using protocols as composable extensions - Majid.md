原文链接：

- [Using protocols as composable extensions - Majid's blog](https://swiftwithmajid.com/2019/01/17/using-protocols-as-composable-extensions/)



协议和协议扩展是swift中很强大的功能。使用协议作为**可组合扩展**，对ViewControllers 进行扩展，能够在不使用继承的情况下，实现高度组合和可复用代码的功能。

一般我们使用继承的方式来实现代码的复用，比如 **`BaseViewController`**: 

```swift
import UIKit

class BaseViewController: UIViewController {
  private let activityIndicator: UIActivityIndicatorView(style: .whiteLarge)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(activityIndicator)
    
    // loading 居中
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
      activityIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
    ])
  }
  
  func presentActivity() {
    activityIndicator.startAnimating()
  }
  func dismissActivity() {
    activityIndicator.stopAnimating()
  }
  
  // 出现错误 则弹出错误提示
  func present(_ error: Error) {
    let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
    alert.addAction(.init(title: "Cancel", style: .cancel))
    present(alert, animated: true)
  }
}
```

这个 **`BaseViewController`** 看着很直白，因为大多数VC在加载数据的时候都需要一个loading,和错误处理。但是随着业务的越来越复杂，我们可能添加越来越多的功能到 **`BaseViewController`** 中，这样会导致 BaseViewController 变得十分的臃肿。另外这种方式，有2个十分明显的问题：

1. BaseViewController 破坏了单一职责原则，将所有的功能都在一个地方进行实现，这样会导致ViewController变得越来越庞大
2. 继承BaseViewController 的 ViewControllers都需要使用它提供的全部功能。如果BaseViewController中某个功能存在bug，则所有继承这个基类的VCs都会存在bug



## 使用协议和协议扩展

在 [委托](https://github.com/jamessawyer/learn_ios/blob/master/Translations/%232%20The%20power%20of%20Delegate%20design%20pattern.md) 中，我们使用到了协议。使用协议还可以实现可组合扩展。

比如：

使用 **`ActivityPresentable`** 协议来完成loading的显示和隐藏功能

```swift
protocol ActivityPresentable {
  func presentActivity()
  fun dismissActivity()
}

/// 给出默认实现
/// 这个协议只能被 UIViewController 类型服从
extension ActivityPresentable where Self: UIViewController {
  func presentActivity() {
    // 如果存在 UIActivityIndicatorView 则直接调用开始动画方法
    if let activityIndicator = findActivity() {
      activityIndicator.startAnimating()
    } else {
      let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
      activityIndicator.startAnimating()
      view.addSubview(activityIndicator)
      
      // loading 居中
      activityIndicator.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        activityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        activityIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
    ])
    }
  }
  
  func dismissActivity() {
    findActivity()?.stopAnimating()
  }
  
  /// 查看当前视图中是否存在 UIActivityIndicatorView
  func findActivity() -> UIActivityIndicatorView? {
    return view.subviews.compactMap { $0 as? UIActivityIndicatorView }
  }
}
```

对错误显示的逻辑，也可以使用协议进行扩展：

```swift
protocol ErrorPresentable {
  func present(_ error: Error)
}

extension ErrorPresentable where Self: UIViewController {
	func present(_ error: Error) {
    let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
    alert.addAction(.init(title: "Cancel", style: .cancel))
    present(alert, animated: true)
	}
}
```

现在2个功能都被独立出来了，可以给不同的ViewController需求进行组合。比如：

```swift
class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    presentActivity()
  }
}

// 服从需要的协议
extension ViewController: ActivityPresentable, ErrorPresentable {}
```

**上面我们使用协议默认的实现，我们也可以根据需要，自定义协议方法逻辑**

```swift
class CustomViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    presentActivity()
  }
}

// 服从需要的协议
extension CustomViewController: ActivityPresentable, ErrorPresentable {
  func presentActivity() {
    // 自定义逻辑
  }
  
  func dismissActivity() {
    // 自定义逻辑
  }
}
```

通过协议和协议扩展的方式：

1. 更加灵活
2. 单一职责
3. 组合方便

另外需要注意的点有：

- **`extension ActivityPresentable where Self: UIViewController`**: 对能服从协议的对象添加限制







