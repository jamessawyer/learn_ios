## 1.frame 和 bounds的区别

[what's the difference bewteen frame and bounds?](https://www.hackingwithswift.com/example-code/uikit/whats-the-difference-between-frame-and-bounds)

所有的 **`UIKit`** 子类都有2个第一眼看上去很像的属性： **`frame`** 和 **`bounds`**，2者都是 **`CGRect`**类型，一个包含X和Y位置，还有宽高的矩形。但是2者有所区别。

一个视图的bounds指的是相对于自身空间(就好像其余的视图层级不存在)的坐标系，然而frame指的是相对于父容器空间的坐标：

1. 如果你创建一个视图，X:0，Y:0 ，width:100, height:100,它的frame和bounds是一样的
2. 如果你将视图移到X:100,它的frame将会发生变化，都是bounds不会受到影响。记住bounds是相对视图自身空间的，这里，视图自身没有发生变化，因此bounds没有变化
3. 如果你将试图进行transform操作，比如，旋转或者缩放试图，frame将会发生变化，但是bounds仍然不会发生变化，因为视图只关心内部变化，transform并不会都内部视图造成影响

当你改变frame或者bounds的宽或者高时，另外一个值也会相应的跟着一起更新，通常来讲，最好修改 **`bounds`** + **`center`** 和 **`transform`**， 让UIKit帮你去计算 **`frame`**



## 2.布局相关的知识点



### 2.1 什么是safe area layout guide

- [what is the safe area layout guide?](https://www.hackingwithswift.com/example-code/uikit/what-is-the-safe-area-layout-guide)

用来限制视图边缘，因此不会被iPhone X的刘海屏遮挡的一种功能。

你不需要将你的视图放在安全区域中，实际上，对于应填充在你屏幕后的视图，通常会忽略此视图。例如，内置的天气应用背后的图形运行在边缘，然后将其主体内容放在安全区域内。

如果你使用 **`UINavigationController`** 或者 **`UITabBarController`**等视图控制容器，它们会自动使你的内容远离安全区域，因此你不需要担心这一点。否则，你应该将所有的自动布局约束切换到IB内的安全区域布局指南，IB将自动对老版本的iOS产生向后兼容约束



### 2.2 什么是内容压缩抵抗（CR）

- [what is content compression resistance?](https://www.hackingwithswift.com/example-code/uikit/what-is-content-compression-resistance)

当自动布局没有足够的空间对所有视图以它们的自然尺寸无法很好的进行布局时，自动布局必须做出决定：一个或多个视图需要腾出空间给其它视图，但是是哪些视图腾出空间呢？这就需要内容压缩抵抗这个属性了，它的值从 **1-1000**，这个值越大，表示越不愿意腾出空间给别人。

如果你将一个视图的CR设置为1，则这个视图将最先腾出空间给别的视图。如果你设置CR为1000，则表示这个视图不愿意腾出空间来。视图的CR默认值是 **`750`**，这表示，我倾向于不腾出空间来，但是有时我们需要将CR的值设置为 **`749`** 或者 **`751`**， 这表示我虽然不愿意，但是没有办法的时候还是会给别的视图腾出一些空间来



### 2.3 什么是视图自然内容尺寸？



- [what is a view's intrinsic content size?](https://www.hackingwithswift.com/example-code/uikit/what-is-a-views-intrinsic-content-size)



所有的视图都有一个自然内容尺寸，表示一个视图将其内容完美显示出来所需要的空间，例如，一个 **`UILabel`** 的自然内容尺寸就是，label的文字加上你对文字的配置。

自然内容尺寸很重要，因为它允许视图有一个自然的宽和高，而不需要非要去设置其宽高。要想使自动布局正常运行，则必须知道一个视图精确的位置：即X，Y，width和height值。有了自然内容尺寸，我们可以说，“将一个button放在距顶部20 points，水平居中的地方”，这样就足够了，剩下的，自动布局会依据button的自然内容尺寸去进行计算。

虽然，自动布局会根据自然内容尺寸给视图需要的空间，但是所有视图还有一个 **`CR(Content Resistance 偏向于放大，值越大，越容易扩展空间)`**优先级 和 **`CH(Content Hugging 偏向于缩小，值越大，越偏向于缩小)`** 优先级，来决定视图自身如何保持其自然内容尺寸，当孔用的空间不足或者过剩时。



### 2.4 如何识别你的自动布局约束？



- [how to identify your auto layout constraints](https://www.hackingwithswift.com/example-code/uikit/how-to-identify-your-auto-layout-constraints)

所有的约束都有一个内置的 **`identifier`** 属性可以用来作为识别它们的唯一标志。

这是一个可选的字符串，如果你设置了这个值，你就可以很快的查看是哪个约束出问题了。

如果你用代码常见的约束，则可以将 **`identifier`** 属性设置成任意你想要的字符串，例如 'Main Title Horizontal Center'.如果你使用IB，你可以选择任何约束，然后设置其identifier。

没有什么理由不在约束中不去设置identifiers，它可以使你的代码更容易调试，而且不会影响你的布局



### 2.5 如何修复自动布局问题？

- [how to fix auto layout problems?](https://www.hackingwithswift.com/example-code/uikit/how-to-fix-auto-layout-problems)

可以采取下面措施进行优化和调试： 

- 给每个约束添加 **`identifier`** 属性，者有利于排错
- 对出现问题的视图可以尝试调用 **`exerciseAmbioguityInLayout()`** 方法。这是一个用于调试的方法，会让视图随机的在你添加的所有约束中进行切换，如果你多跑几次，就会清楚是什么造成的问题：如果2个视图宽度是变化的，者意味着你当前约束是模糊的
- 尝试使用IB创建约束。如果你喜欢用代码，也可以不用IB，但是如果你使用IB创建，IB会对错误进行标识
- 可以将xcode自动布局的错误在 [http://www.wtfautolayout.com/](http://www.wtfautolayout.com/) 中进行查找，这个网站会将错误转化为可视图

### 2.6 如何用代码创建UI



- [how to make your user interface in code](https://www.hackingwithswift.com/example-code/uikit/how-to-make-your-user-interface-in-code)

使用代码常见UI更加的灵活，对一步一步的调试方便，复用组件代码更加容易，监控变化。不好的地方是，不容易进行segues（页面切换功能），table views 镜头单元格设计不方便，同时预览多个设备也不方便。

如果使用代码编写UI，在某个view controller的 **`viewDidLoad()`** 方法中，你可能会看到这样的代码：

```swift
backgroundColor = UIColor(white: 0.9, alpha: 1)

let stackView = UIStackView()
stackView.translatesAutoresizingMaskIntoConstraints = false
stackView.spacing = 10
view.addSubview(stackView)

stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
stackView.axis = .vertical

let notice = UILabel()
notice.numberOfLines = 0
notice.text = "YOur child has attempted to share the following photo from the camera:"
stackView.addArrangedSubview(notice)

let imageView = UIImageView(image: shareImage)
stackVIew.addArrangedSubview(imageView)

let propt = UILabel()
prompt.text = "what do you want to do?"
stackView.addArrangedSubview(prompt)

for option in ["always allow", "allow once", "Deny", "Manage Settings"] {
    let button = UIButton(type: .system)
    button.setTitle(option, for: .normal)
    stackView.addArrangedSubview(button)
}
```



这是一个复杂的UI，如果把这放在 **`viewDidLoad()`** 方法中，将是一个大的错误。

上面的代码从字面上讲是视图代码，而不是controller代码，应该属于 UIView 的一个子类。

可以将上面的代码复制出来放在 **`UIKit`** 的一个子类中，比如叫 **`SharePromptView`** ，然后讲view controller的类更改为新的子类

```swift
class SharePromptView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubview()
    }
    
    required init?(code aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createSubviews()
    }
    
    func createSubviews() {
        // 将上面的代码复制到这里
    }
}
```



所有的 **`UIKit`** 的子类必须实现 **`init(coder:)`**方法，当你用代码常见UI时，还需要实现 **`init(frame:)`** 方法。**`createSubview()`** 需要在2个构造器中被调用。

感谢UIKit子类，现在你可以在view controller中很干净利落的调用代码

```swift
class ViewController: UIViewController {
    var shareView = ShareProptView()
    
    override func loadView() {
        view = shareView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
```



使用 **`shareView`** 属性，可以让你调用你在 SharePromptView 中声明的任何属性方法，而不需要将其转换为一个 view



### 2.7 如何阻止自动布局和autoresizing masks 冲突：translatesAutoresizingMaskIntoConstraints



- [how to stop Auto Layout and autoresizing masks conflicting: translatesAutoresizingMaskIntoContraints](https://www.hackingwithswift.com/example-code/uikit/how-to-stop-auto-layout-and-autoresizing-masks-conflicting-translatesautoresizingmaskintoconstraints)



如果在视图中用代码创建UI-text，buttons， labels等等，当给它们添加自动布局约束时要小心，因为iOS会为你创建约束来匹配新视图的尺寸和位置，如果你自己添加自己的约束，将会产生冲突。

有2种解决办法

1. 在代码中不给视图添加自动布局约束，这条感觉没啥用

2. 告诉ios不要自动创建自动布局约束，使用下面代码：

   ```swift
   yourView.translatesAutoresizingMaskIntoContraints = false
   ```



### 2.8 如何用代码创建自动布局约束: constraints(withVisualFormat)

- [how to create auto layout constraints in code: constraints(withVisualFormat)](https://www.hackingwithswift.com/example-code/uikit/how-to-create-auto-layout-constraints-in-code-constraintswithvisualformat)

有一种叫做VFL（Visual Format Language）的方法像写ASCII码一样，可以告诉iOS如何布局。

示例，下面创建2个labels，添加不同的颜色

```swift
// 写在view controller中并不是一种好的做法
// 下面仅为了示例简洁性
override func viewDidLoad() {
    super.viewDidLoad()
    
    let label1 = UILabel()
    label1.translatesAutoresizingMaskIntoConstraints = false
    label1.backgroundColor = .red
    label.text = "THESE"
    
   let label2 = UILabel()
    label2.translatesAutoresizingMaskIntoConstraints = false
    label2.backgroundColor = .red
    labe2.text = "THESE" 
    
    view.addSubview(label1)
    view.addSubview(label2)
}
```



如果运行代码，将会发现，所有的labels都在左上角，下面使用VFL让每个label占据和屏幕一样的款度，然后依次向下排列开。

当使用VFL时，你需要创建一个视图字典，这个字典key是视图的名字，value是视图的引用：

```swift
// 放在上面view.addSubview(label2) 下面
let viewsDictionary = ["label1": label1, "label2": label2]

// 占据屏幕宽度
for label in viewsDictionary.keys {
    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[\(label)]|", options: [], metrics: nil, views: viewsDictionary))
}

// 让labels依次的向下排列
view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1]-[label2]|"), options: [], metrics: nil, views: viewsDictionary)
```



最后发现实现效果并不太好。



### 2.9 如何将视图放在容器中间

- [How to center a view in its container](https://www.hackingwithswift.com/example-code/uikit/how-to-center-a-view-in-its-container)

将一个 **`UIView`** 视图放在另一个视图的中间有2种方式

不适用自动布局，只需要一行代码：

```swift
child.center = parent.center
```

这种方式，当设备旋转时，视图并不会跟着更新。



如果使用自动布局，可以使用下面方式：

```swift
child.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
child.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
```

当可以获得的空间发生变化时，约束将自动的更新



### 2.10 如何使用 activate() 激活多个自动布局约束？

- [how to activate multiple auto layout constraints using activate()](https://www.hackingwithswift.com/example-code/uikit/how-to-activate-multiple-auto-layout-constraints-using-activate)

使用自动布局是创建复杂布局，自动适配它们环境的一种好方式，但是添加和移除大量约束可能造成性能问题。

示例，下面是一个简单的UIView

```swift
let vw = UIView()
vm.translatesAutoresizingMaskIntoConstraints = false
vm.backgroundColor = .red
view.addSubview(vm)
```

我们可以使用自动布局锚点添加约束：

```swift
vm.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
vm.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
vm.heightAnchor.constraint(equalToConstant: 100).isActive = true
vm.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
```

这种方式可读性好，对不太复杂的布局很好，还有另一种更高效的方式， **`NSLayoutConstraint`** 这个类有一个方法叫 **`activate()`**, 可以一次性的激活多个约束，这样auto layout可以一次性的更新整个布局

所以上面的代码等价于：

```swift
NSLayoutConstraint.activate([
    vm.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
    vm.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
    vm.heightAnchor.constraint(equalToConstant: 100),
    vm.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
])
```

如果你先个取消某个约束，有个对于的 **`deactivate()`** 方法。

注意： 自动布局其实是很智能的，即使使用 **`isActive`** 方式



### 2.11 如何将一个背景图片放在安全区域内？

- [how to make a background image run under the safe area?](https://www.hackingwithswift.com/example-code/uikit/how-to-make-a-background-image-run-under-the-safe-area)

广义上讲，放置视图非常重要，因为它们位于安全区域布局指南中，但在某些情况下，你希望忽略它，并在安全区域下运行，例如，Apple的weather应用和背景天气图形边缘一致，然后把重要的内容放在安全区域内。

这很容易实现：只需要用主视图的leading，trailing，top和bottom锚点使背景图边缘靠边缘，然后对你的前景(foreground)视图使用安全区域布局指南

```swift
let background = UIView()
background.translatesAutoresizingMaskIntoConstraints = false
background.backgroundColor = .red
view.addSubview(background)

let foreground = UIView()
foreground.translatesAutoresizingMaskIntoConstraints = false
foreground.backgroundColor = .blue
view.addSubview(foreground)

background.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
background.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
background.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
background.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

foreground.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
foreground.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide..trailingAnchor).isActive = true
foreground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide..topAnchor).isActive = true
foreground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide..bottomAnchor).isActive = true
```

或者写为：

```swift
let bg = UIView()
bg.translatesAutoresizingMaskIntoConstraints = false
bg.backgroundColor = .orange
view.addSubview(bg)

let fg = UIView()
fg.translatesAutoresizingMaskIntoConstraints = false
fg.backgroundColor = .cyan
view.addSubview(fg)

NSLayoutConstraint.activate([
bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
bg.topAnchor.constraint(equalTo: view.topAnchor),
bg.bottomAnchor.constraint(equalTo: view.bottomAnchor)
])

NSLayoutConstraint.activate([
fg.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
fg.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
fg.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
fg.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
])
```

![# 2-11 背景图 安全区域](/Users/lucian/Documents/swift学习/UIKit/# 2-11 背景图 安全区域.png)



### 2.12 如何给UIStackView添加一个背景色？

- [How to give a UIStackVIew a background color?](https://www.hackingwithswift.com/example-code/uikit/how-to-give-a-uistackview-a-background-color)

并不能这么做，因为 **`UIStackView`** 是一个非绘制视图，这表示 **`drawRect()`** 不会被调用，它的背景色将会被忽略，如果真的想要一个背景色，可以考虑将stack view‘放在一个UIView中，将背景色添加到UIView上。



### 2.13 如何给UIStackView中的items添加自定义空间？

- [how to add custom spacing to UIStackView items?](https://www.hackingwithswift.com/example-code/uikit/how-to-add-custom-spacing-to-uistackview-items)

每一个UIStackView都有一个总的 **`spacing`** 属性，这个属性将会影响所有的子视图的空间，但是你也可以给特定视图添加自定义空间，，比如 “给这个button底部添加20points的空间”

为了实现这个需求，可以使用对stack view调用 **`setCustomSpacing()`** 方法：

```swift
let stackView = UIStackView()
let btn = UIButton()

stackView.addArrangedSubview(btn)
stackView.setCustomSpacing(20, after: btn)

```



### 2.14 UIStackView distribution 的几种类型是什么？

- [what are the different UIStackView distribution types?](https://www.hackingwithswift.com/example-code/uikit/what-are-the-different-uistackview-distribution-types)



UIStackView 有5种不同distribution类型：

- **`Fill`**: 使子视图占据尽可能多的空间，其余的保持它们的自然尺寸，它决定了哪个视图进行扩展，通过检验每个子视图的CH(Content Hugging) 优先级
- **`Fill Equally`**: 调整每个子视图，所有的空间将被利用
- **`Fill Proportionally`**: 这个是最有趣的，因为它确保子视图保持相同的尺寸，但是仍可对剩余空间的扩张。例如，一个视图是100，另一个是200，stack view决定使它们进行扩展，占据更多的空间，第一个视图可能扩展到150，另一个视图扩展到300，都增长50%
- **`Equal Centering`**: 尝试确保让每一个子视图的中心是等间隔的，而不管每个子视图的边缘位置有多远



### 2.15 使用aspect fill, aspect fit和scaling如何调整图片的内容模式？



- [how to adjust image content mode using aspect fill, aspect fit and scaling](https://www.hackingwithswift.com/example-code/uikit/how-to-adjust-image-content-mode-using-aspect-fill-aspect-fit-and-scaling)

所有视图（包括那些不包含图片的视图）都具有影响其绘制内容的方式的内容模式。默认值是 **`Scale To Fill`**，因为它是最快的，视图的内容只是伸展（或向下）以适应可用空间。但是你会经常使用到其他2个： **`Aspect Fill`** 和 **`Aspect Fit`**.

- **`Aspect Fit`** 表示 将图片尽可能大的拉伸，但要确保所有图片都可见，同时保持其原始的宽高比。当你希望图像尽可能大而不拉伸其比例时，这非常有用，并且，这有可能是最常用的内容模式
- **`Aspect Fill`** 表示将图片尽可能的拉伸，裁剪掉任何不合适的部分，同时保持其原始纵横比。当你希望图像填充其图像视图时，这十分有用，即使这意味着丢失水平或垂直边缘。如果要强制图像填充特定空间，但希望保持其纵横比，则应使用此属性。



### 2.16 如何找到image视图内使用aspect fit属性的图片的尺寸？

- [how to find an aspect fit image's size inside an image view?](https://www.hackingwithswift.com/example-code/uikit/how-to-find-an-aspect-fit-images-size-inside-an-image-view)

每个图片都有一个自然尺寸，即图片的宽高像素。所有的image 视图也有一个尺寸，即自动布局约束产生的宽和高。

当你把一个图片放在image 视图中，并且使用 **`Aspect Fit`** 内容模式时，事情就变得复杂了，图片会进行缩放来适配图片视图的尺寸，以使图片的所有部分都可见。

如果你想要找出一个image视图中使用Aspect Fit 模式的图片的尺寸，可以使用下面的扩展：

```swift
extension UIImageView {
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.width > 0 && imagge.height > 0 else { return bounds }
        
        let scale: CGFloat
        if image.width > image.height {
            scale = bounds.width / image.width
        } else {
            scale = bounds.height / image.height
        }
        
        let size = CGSize(width: image.width * scale, height: image.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
```

然后就可以使用 **`imageView.contentClippingRect`** 来获取内部图片的位置信息和尺寸信息。



## 3.什么是 Size 类？

- [What are size classes?](https://www.hackingwithswift.com/example-code/uikit/what-are-size-classes)



**Size** 类是iOS中用来创建响应式布局的方法。

有了Size类，你不用考虑设备转向，甚至设备尺寸问题。你需要关心你是否以紧凑尺寸（compact size）或者正常尺寸在运行，iOS负责映射不同设备尺寸和方向，iOS会通知当size class发生了变化，你需要更新你的UI。

例如，ipad应用已肖像模式以正常水平和垂直size类全屏运行。在landscape模式，它也会拥有正常的水平和垂直size类。如果你的app在ios9多任务中使用，它的size类会是下面中的一种：

- 如果多个应用横向平均分隔，2个应用都拥有复合水平和垂直size类
- 如果多个应用横向分布不平均，主app拥有正常横纵size尺寸，另一个则是紧凑水平size类，垂直正常尺寸
- 如果纵向不平均分配，则2个应用都拥有紧凑的水平尺寸类和正常的垂直尺寸类

Size 类可以以代码形式实现，但是使用IB会更简单