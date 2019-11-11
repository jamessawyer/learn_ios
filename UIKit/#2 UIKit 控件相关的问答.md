### 3 UIViewController



### 3.1什么是UIViewController?

- [What is a UIViewController?](https://www.hackingwithswift.com/example-code/uikit/what-is-a-uiviewcontroller)

iOS中经常看到MVC模式，因此代码中有的充当M，有的充当V,有的充当C的角色，但是 **`UIViewController`** 既有 **View**，又有 **Controller**，那么他到底是什么呢？

这个问题没有唯一答案，在iPhone早期， **`UIViewController`** 表示一屏的内容，例如，你的邮箱是一个视图控制器，当你阅读某条邮件，将显示另一个不同的视图控制器。

但是真实情况远比这个复杂，因为视图控制器的容器性，你可以将一个视图控制器放到另一个视图控制器中。结果，一屏的内容可能包含多个视图控制器一起协同工作。

**视图控制器主要的不可推脱的角色是 响应视图生命周期事件**。即当你的视图控制器将在视图被创建，显示，隐藏和销毁时被调用，你可以利用这些生命周期来实现自己的逻辑。

有些人将他们的视图控制器更偏向于视图部分（例如，处理布局），一些人则更偏向控制部分（例如，将布局代码放在 **`UIView`** 子类中，将粘合剂代码放在视图控制器中），还有一些人同时做2项（将视图代码和控制器代码放在同一个地方）。



### 3.2 如何使用视图控制器容器？

- [how to use view controller containment?](https://www.hackingwithswift.com/example-code/uikit/how-to-use-view-controller-containment)

视图控制器容器允许你在一个视图控制器中插入另一个视图控制器，这能够简化和有利于你组织代码。可以按照下面4步：

1. 在你的父视图控制器中调用 **`addChild()`**,参数是子视图控制器
2. 如果你使用frames，则设置你需要的子视图控制器的frame
3. 将子视图添加到主视图中，添加自动布局约束
4. 在子视图控制器中调用 **`didMove(toParentViewController:)`**,参数使用你的主视图控制器

```swift
addChild(child)
child.view.frame = view.frame
view.addSubview(child.view)
child.didMove(toParent: self)
```

当你完成了上面这些，下面步骤理论上相似，但是是相反的：

1. 调用 **`willMove(toParent:)`**, 传入 **`nil`**
2. 从父视图控制器中移除子视图控制器
3. 在子视图控制器中调用 **`removeFromParent()`**

```swift
willMove(toParent: nil)
view.removeFromSuperview()
removeFromParent()
```



为了方便，你可以考虑给 **`UIViewController`** 添加一个小的，私有的扩展来帮你完成这项任务，注意你需要按照顺序来运行，否则很容易出错：

```swift
// @nonobjc 用来避免和iOS自己的代码产生冲突
@nonobjc extension UIViewController {
    func add(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)
        
        if let frame = frame {
            child.view.frame = view.frame
        }
        
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
```

**注意这里的代码的方法名和原文的不一样，此处使用的swift版本是4.2**

示例：

```swift
// 创建一个子视图控制器
import UIKit
class ChildViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建一个视图控件
        let bg = UIView()
        bg.backgroundColor = .yellow
        bg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bg)
        
        NSLayoutConstraint.activate([
            bg.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            bg.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            bg.heightAnchor.constraint(equalToConstant: 200),
            bg.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])

        // Do any additional setup after loading the view.
    }
}
```

将子视图控制器添加到父视图控制器中：

```swift
// 父视图控制器
import UIKit

class ViewController: UIViewController {
    
    let child = ChildViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .orange
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
    }

}
```





## 4.UIView

### 4.1 如何强制UIView重绘： setNeedsDisplay()



- [How to force a UIView to redraw: setNeedsDisplay()](https://www.hackingwithswift.com/example-code/uikit/how-to-force-a-uiview-to-redraw-setneedsdisplay)

所有的视图及其子类都是使用 **`drawRect()`** 方法进行渲染的，但是你不该直接自己调用这个方法。实际上，它是由系统在需要绘制时调用的，这可以避免多次绘制的发生。

但是，如果你想要一个视图立即重绘，你应该像这样调用 **`setNeedsDisplay()`**:

```swift
myButton.setNeedsDisplay()
```

这个方法将会通知UIKit使用 **`drawRect()`** 重绘该button,但是需要重绘（redraw）不在队列中。



### 4.2 如何使用一个UIView遮挡另一个UIView？

- [How to mask one UIView using another UIView?](https://www.hackingwithswift.com/example-code/uikit/how-to-mask-one-uiview-using-another-uiview)

所有的views都有一个 **`mask`** （蒙版）属性，可以让你依据情况剪切部分视图。这个mask可以是任意的UIView，例如，用一个label遮挡一个image view

```swift
let redView = UIView(frame: CGRect(x: 50, y: 50, width: 128, height: 128))
redView.backgroundColor = .red
view.addSubview(redView)
```

接着创建一个mask作为单独的UIView。可能需要给视图一个背景色或者某些内容，因为mask alpha通道到决定原始视图上显示什么。

下面是一个和原始视图相同尺寸的mask，但是它向右偏移了64像素，以及一个64point的圆角。当用作先前视图的mask时，它会出现一个半圆的效果

```swift
// 注意这里的 x: 64 表示的是向右偏移64
let maskView = UIView(frame: CGRect(x: 64, y: 0, width: 128, height: 128))
maskView.backgroundColor = .blue
maskView.layer.cornerRadius = 64
redView.mask = maskView
```

蓝色背景并不可见，它只是用来当做遮挡的蒙版。



### 4.3 如何使用removeFromSuperview()从父视图中移除一个UIView？

- [How to remove a UIView from its superview with removeFromSuperview()](https://www.hackingwithswift.com/example-code/uikit/how-to-remove-a-uiview-from-its-superview-with-removefromsuperview)

如果你动态的创建一个视图，然后想移除，可以直接调用 **`removeFromSuperview()`** 方法。当你调用时，视图会立即被移除，可能被销毁（如果存在引用，可能不会被销毁）：

```swift
yourView.removeFromSuperview()
```



### 4.4 如何把一个子视图放在一个UIView的前面？

- [How to bring a subview to the front of a UIView?](https://www.hackingwithswift.com/example-code/uikit/how-to-bring-a-subview-to-the-front-of-a-uiview)

UIKit 从后向前绘制视图，这表示在栈中比较高的视图将绘制在其它视图的上面。如果你想要把一个视图放在前面，可以使用 **`bringSubviewToFront(_ view: UIView)`**:

```
parentView.bringSubviewToFront(childView)
```

这个方法可以将任何子视图放在前面，即使你不确定它在哪里：

```swift
childView.superView?.bringSubviewToFront(childView)
```

**注意，此处使用的是swift4.2，和原文中的API有所不同**

示例：

```swift
import UIKit
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       let orangeView = UIView(frame: CGRect(x: 64, y: 100, width: 128, height: 128))
        orangeView.backgroundColor = .orange
        view.addSubview(orangeView)
        
        // 蓝色视图在栈的上面
        // 因此会遮挡住上面的橘色视图
        let blueView = UIView(frame: CGRect(x: 64, y: 100, width: 200, height: 200))
        blueView.backgroundColor = .blue
        view.addSubview(blueView)
 
// 使用下面方法将橘色视图放在父视图的最前面
//        view.bringSubviewToFront(orangeView)
        orangeView.superview?.bringSubviewToFront(orangeView)
    }
}
```



### 4.5 如何使用自动布局锚点让一个UIView填充整个屏幕？

- [how to make a UIView fill the screen using Auto Layout anchors?](https://www.hackingwithswift.com/example-code/uikit/how-to-make-a-uiview-fill-the-screen-using-auto-layout-anchors)



你可以将4个角和父视图容器的4个角对齐来填充整个屏幕，下面是扩展：

```
extension UIView {
    func pinEdges(to ohter: UIView) {
        leadingAnchor.constraint(equalTo, other.leadingAnchor).isActive = true
   		trailingAnchor.constraint(equalTo: other.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: other.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: other.bottomAnchor).isActive = true
    }
}
```



然后可以这样调用 **`pinEdges(to: someOtherView)`**.



### 4.6 如何设置UIView的着色？

- [How to set the tint color of a UIView?](https://www.hackingwithswift.com/example-code/uikit/how-to-set-the-tint-color-of-a-uiview)

**`tintColor`** 属性可以改变着色效果，具体效果要看控件的类型：对导航条和tab bars表示的是按钮上的文字和图标，对文字视图表示选择光标和高亮文字，对进度条表示的是track的颜色。

**`tintColor`** 可以单独给某个视图设置颜色，对在视图控制器中的所有视图，甚至真个应用窗口都可以一次性设置颜色。

设置当前视图控制器的颜色，可以使用下面代码：

```swift
override func viewDidLoad() {
    view.tintColor = .red
}
```

如果你想应用中所有的视图进行着色，可以在 **`AppDelegate.swift`**:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    window?.tintColor = UIColor.red
    return true;
}
```



示例：

```swift

import UIKit

class ViewController: UIViewController {
    
    let child = ChildViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//       let orangeView = UIView(frame: CGRect(x: 64, y: 100, width: 128, height: 128))
//        orangeView.backgroundColor = .orange
//        view.addSubview(orangeView)
//        
//        let blueView = UIView(frame: CGRect(x: 64, y: 100, width: 200, height: 200))
//        blueView.backgroundColor = .blue
//        view.addSubview(blueView)
//        
////        view.bringSubviewToFront(orangeView)
//        orangeView.superview?.bringSubviewToFront(orangeView)
        
        
        let button = UIButton(type: .system)
        button.setTitle("hello world", for: .normal)
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        // 将button居中
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        // 改变tintColor的颜色
        // 会发现button内文字的颜色也变成了红色
        view.tintColor = .red
    }


}
```



### 4.7 如何使用 viewWithTag() 找到一个UIView的子视图？



- [How to find a UIView subview using viewWithTag()?](https://www.hackingwithswift.com/example-code/uikit/how-to-find-a-uiview-subview-using-viewwithtag)

如果你想快速的从一个复杂层级的视图内获取一个视图引用，可以使用 **`viewWithTag(_ tag: Int)`** 方法，这个方法会搜索所有的子视图，以及子子视图，直到找到匹配的tag number.这个方法返回一个 **`UIView?`**类型，因此使用时要注意解包：

```swift
if let foundView = view.viewWithTag(0xDEADBEEF) {
    // 将找到的视图从父视图中移除
    foundView.removeFromSuperview()
}
```

tags 例如**`0xDEADBEEF`** 是很常见的coders。这个方法只是偶尔使用的一种捷径，不要在开发中依赖这种方法。



### 4.8 如何给UIView添加一个阴影？

- [How to add a shadow to a UIVie?](https://www.hackingwithswift.com/example-code/uikit/how-to-add-a-shadow-to-a-uiview)

iOS可以动态的给任何UIView添加阴影，这些阴影会自动的适配item的形状，甚至能够沿着UILabel内文字的曲线。

- **`shadowColor`**: 设置阴影的颜色，需要是一个 **`CGColor`** 类型
- **`shadowOpacity`**: 阴影的透明度，0表示不可见，1表示最强
- **`shadowOffset`**：阴影的偏移，给一种3D偏移效果
- **`shadowRadius`**: 设置阴影的宽度

例如：

```swift
yourView.layer.shadowColor = UIColor.black.cgColor
yourView.layer.shadowOpactiy = 1
yourView.layer.shadowOffset = CGSize.zero
yourView.layer.shadowRadius = 10
```

动态的产生阴影是很消耗内存的，因为iOS必须按照视图形状绘制。如果可以的话，可以将**`shadowPath`** 设置 为一个具体值，这样iOS不需要动态计算透明度。例如，下面创建一个等于view frame的阴影：

```swift
yourView.layer.shadowPath = UIBezierPath(rect: yourView.bounds).cgPath
```

另外可以告诉ios缓存渲染的阴影，这样避免重复绘制：

```swift
yourView.layer.shouldRasterize = true
```



### 4.9 如何使用 convert() 将一个UIView里面的CGPoint转换到另一个视图中？

- [How to convert a CGPoint in one UIView to another view using convert()?](https://www.hackingwithswift.com/example-code/uikit/how-to-add-a-shadow-to-a-uiview)

每一个视图都有自己的坐标系统，这意味着如果我点击一个按钮，询问iOS我点在哪里了，它将告诉我按钮相对于左上角的位置。但如果您想将一个视图中的位置转换为一个位置，那么这很容易做到。

例如，下面代码创建2个视图，创建一个虚拟的点击，然后将其从第一个视图坐标空间转换到第二个视图中：

```swift
let view1 = UIView(frame: CGRect(x: 50, y: 50, width: 128, height: 128))
let view2 = UIView(frame: CGRect(x: 200, y: 200, width: 128, height: 128))

let tap = CGPoint(x: 10, y: 10)
// convertedTap 将变为 (-140.0，-140.0)
let convertedTap = view1.convert(tap, to: view2)
```



### 4.10 如何使用CGAffineTransform对UIView进行缩放，伸展，移动和旋转？

- [How to scale, stretch, move and rotate UIViews using CGAffineTransform?](https://www.hackingwithswift.com/example-code/uikit/how-to-scale-stretch-move-and-rotate-uiviews-using-cgaffinetransform)

每一个 **`UIView`** 都有一个 **`transform`** 属性，可以用来操控视图的尺寸，位置和旋转（使用affine transform）。这个属性是可动画的，这意味着可以改变某个值，使一个视图平滑的变大变小，旋转。

```swift
// double view size
imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
// 移动到左边256位置
imageView.transform = CGAffineTransform(translateX: -256, y: -256)
// 旋转180度
imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)

// 恢复成原样
imageView.transform = CGAffineTransform.identity
```



