原文链接：

- [View Controller Lifecycle Explained: When to Use viewDidLayoutSubviews - AppCoda](https://www.appcoda.com/view-controller-lifecycle/)



ViewController的3个生命周期：

- **`viewDidLoad`**: 类似React中的 **`componentDidMount`**, 表示控制器的view加载到内存中了，这是VC中第一个调用的方法。如果想要应用首先加载或者设置的代码，可以写在这里。比如设置view的 **`backgroundColor`**
- **`viewLayoutSubviews`**: 在 **`viewDidLoad`** 调用完成后，会立刻调用这个方法。每次view size 或者 layout发生变化，重新计算时，都会出发这个方法。
  - 这个方法调用多少次，是不确定的。 [Why viewDidLayoutSubviews is called twice only on first run?](https://stackoverflow.com/a/37227733/7185283)
  - 横屏和竖屏之间的切换，使用autolayout布局方式等，如果导致视图的**bounds发生变化**，会触发这个方法
- **`viewDidAppear`**：每次用户能看到视图上的组件了，都会触发这个方法。比如，刚开始进入A页面，A页面上的内容能看到了，会触发这个方法，如果从A跳转到B页面，再从B回到A页面，又会触发这个方法。



示例：

```swift
import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var button: UIButton!
  
  override func viewDidLoad() {
  	super.viewDidLoad()
  	view.backgroundColor = .green
    print("viewDidLoad")
  }
  
  override func viewLayoutSubviews() {
    super.viewLayoutSubviews()
    print("viewLayoutSubviews")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("viewDidAppear")
  }
}
```

刚加载VC：

```swift
// 打印结果
viewDidLoad
viewLayoutSubviews  (这个可能打印多次)
viewDidAppear
```

从当前VC跳转到另一个VC，再返回，会打印：

```swift
viewDidAppear
```

如果上面的button，使用了自动布局，按钮的宽度始终和屏幕的宽度相同，从横屏切换到竖屏，会导致button的bound发生变化，会触发 **`viewLayoutSubviews`**:

```swift
// 可能会触发多次，不能确定
viewLayoutSubviews
viewLayoutSubviews
```



