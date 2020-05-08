这一章主要介绍 **`UIView`** 相关的子类视图控件，包括：

- **`UIActivityIndicatorView`**
- **`UIProgressView`**
  - **`Progress`** 类型
- **`UIPickerView`**: 用法和 **`UITableView`** 基本相似
  - **`UIPickerViewDataSource`**
  - **`UIPickerViewDelegate`**
- **`UISearchBar`**: 对 **`UITextField`** 的封装
  - **`UISearchController`**
  - **`UISearchResultsUpdating`** 协议
  - **`UISearchBarDelegate`** 协议



## 1. UIActivityIndicatorView

这个控件比较简单，主要用于表示当前界面正在发生一些耗时的任务，比如网络请求。其定义：

```swift
open class UIActivityIndicatorView: UIView, NSCoding {
	/// 构造器
	// 可以选定
  public init(style: UIActivityIndicator.Style)
  public init(frame: CGRect)
  public init(coder: NSCoder)
  
  // 大小样式（枚举）
  // .medium | .large
  open var style: UIActivityIndicator.Style
  
  // 当动画结束时，是否隐藏视图 默认是 true
  open var hidesWhenStopped: Bool
  
  // loading 条幅的颜色
  open var color: UIColor!
  
  // 开始和结束动画
  open func startAnimating()
  open func stopAnimating()
  
  // 是否正在动画（只读）
  open var isAnimating: Bool { get }
}

extension UIActivityIndicator {
  public enum Style: Int {
    @available(iOS 13.0, *)
    case medium
    @available(iOS 13.0, *)
    case large
    
    // iOS13之前 已废弃 更名为 large
    @available(iOS, introduced: 2.0, deprecated: 13.0, renamed: "UIActivityIndicator.Style.large")
    case whiteLarge
    
    @available(iOS, introduced: 2.0, deprecated: 13.0, renamed: "UIActivityIndicator.Style.medium")
    case white
    
    @available(iOS, introduced: 2.0, deprecated: 13.0, renamed: "UIActivityIndicator.Style.medium")
    case gray
  }
}
```

注意点，通过代码改变 **`UIActivityIndicatorView`** 大小，之后改变背景大小，中心转动的条幅大小是不会改变的，参考 [Increasing the size of UIActivityIndicatorView - stackoverflow](https://stackoverflow.com/a/50660443)；要想改变中心条幅大小，需要使用 **`transform`** 属性，进行缩放：

```swift
// 整体被缩放 包括背景
activityIndicatorView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
```

参考 [ Change UIActivityIndicatorView spokes Size - stackoverflow](https://stackoverflow.com/a/50660443)

示例：

```swift
// 自定义UITableCell
// 点击单元格 进行网络请求，请求完成 跳转到detail页面
class CustomTableCell: UITableCell {
  override func setSelected(_ selected: Bool, animated: Bool) {
    if selected {
      let v = UIActivityIndicator(style: .large)
      v.color = .white
      v.backgroundColor = UIColor(white: 0.2, alpha: 0.6)
      v.layer.cornerRadius = 19
      // 单元格高度 上下小 10pt
      v.frame = v.frame.insetBy(dx: -10, dy: -10)
      v.center = self.contentView.convert(self.bounds.center, from: self)
      v.tag = 10001
      self.contentView.addSubview(v)
      v.startAnimating()
    } else {
      self.viewWithTag(10001)?.removeFromSuperview()
    }
    super.setSelected(selected, animated: animated)
  }
}
```

另外还可以通过 **`CALayer`** 相关的类，绘制自定义Loading视图，这个以后再讲，可参考：

- [UIActivityIndicatorView - 简书](https://www.jianshu.com/p/3002f9f517c2)



## 2. UIProgressView

像温度计一样的进度条相关的视图，这个类比较简单，其定义如下：

```swift
extension UIProgressView {
  public enum Style: Int {
    // 默认高度 2px
    case `default`
    // 高度3px
    case bar
  }
}

open class UIProgressView: UIView, NSCoding {
  public init(frame: CGRect)
  public init?(coder: NSCoder)
  // 有2种样式： .default | .bar
  public convenience init(progressViewStyle style: UIProgressView.Style)
  
  open var progressViewStyle: UIProgressView.Style
  
  // 0.0 - 1.0
  open var progress: Float
  
  // 进度条的颜色
  open var progressTintColor: UIColor?

  // 未完成部分的颜色
  open var trackTintColor: UIColor?

	// 图片表示的进度
	open var progressImage: UIImage?
	open var trackImage: UIImage?
	
  // 设置进度条的值
	open func setProgress(_ progress: Float, animated: Bool)
	// KVO 观察进度值
	open var observedProgress: Progress?
}
```

对于UIProgressView高度可以使用下面方式进行改变：

1. 使用约束布局，使用height约束
2. 通过 **`transform`** 属性进行缩放
3. 集成 **`UIProgressView`**, 改写 **`sizeThatFits(_:)`** 方法，改变其固有属性

对于进度条，还可以使用使用以下几种方式自定义实现：

1. 使用绘图的方式，自己绘制UIView
2. 使用 **`UIButton` + `CAShaperLayer`** 进行绘制

关于这2种方式，可以参考：

- [swift UIProgressView 进度条 - 简书](https://www.jianshu.com/p/8adff2f818f1)

另外还需要注意 **`Progress`** 对象。



## 3. UIPickerView

这个滑动选择，在日期或者城市选择中很常见，它和 **`UITableView`** 的设置很像：

- **`numberOfComponents(in:)`**: 有多少列数据
- **`pickerView(_:numberOfRowsInComponent)`**: 每一列中有多少行数据
- **`pickerView(_:titleForRow:forComponent:)`**: **对应列所在的行的标题，可以是普通的NSString | NSAttributedString | 某个View(比如UILabel)**
- **`pickerView(_:attributedTitleForRow:ForComponent:)`**: 使用特性字符串，如果这个方法和上面方法同时实现了，这个方法优先级更高
- **`pickerView(_:viewForRow:forComponent:reusing:)`**: 和tableView一样实现复用，前提条件是，每一行使用相同的类型，比如都是用字符串，或者都是用特性字符串

定义如下：

```swift
open class UIPickerView: UIView, NSCoding {
	// 默认是nil 数据相关的协议
  weak open var dataSource: UIPickerViewDataSource?
  // 默认是nil 委托方法
  weak open var delegate: UIPickerViewDelegate?
  
  // 有多少列 只读
  open var numberOfComponents: Int { get }
  
  // 某一列有多少行数据
  open func numberOfRows(inComponent component: Int) -> Int
  
  // 某一行的尺寸
  open func rowSize(forComponent component: Int) -> CGSize
  
  // 只有使用 pickerView:viewForRow:forComponent:reusingView: 这个委托方法
  // 才会返回复用的组件
  open func view(forRow row: Int, forComponent component: Int) -> UIView?
  
  // 重新加载整个视图
  open func reloadAllComponents()
  // 重新加载单列数据
  open func reloadComponent(_ component: Int)
  
  // 选择某一列某一行 支持动画滚动效果
  open func selectRow(_ row: Int, inComponent component: Int, animated: Bool)
  
  // 返回当前用户正在交互列 所在行 的索引
  open func selectedRow(inComponent component: Int) -> Int
}
```

**`UIPickerViewDelegate & UIPickerViewDataSource` 协议**：

```swift
public protocol UIPickerViewDelegate: NSObjectProtocol {

	/// 下面4种组件 任选其一
	// 对应列对应行 标题的字符串
	optional func pickerView(
		_ pickerView: UIPickerView,
		titleForRow row: Int,
		forComponent component: Int
	) -> String?
	// 对应列对应行 标题的特性字符串
	optional func pickerView(
		_ pickerView: UIPickerView,
		titleForRow row: Int,
		forComponent component: Int
	) -> NSAttributedString?
	// 对应列对应行 使用的视图
	optional func pickerView(
		_ pickerView: UIPickerView,
		titleForRow row: Int,
		forComponent component: Int
	) -> UIView
	/// 复用行组件 性能优化
	optional func pickerView(
		_ pickerView: UIPickerView,
		viewForRow row: Int,
		forComponent component: Int,
		reusing view: UIView?
	) -> UIView
	
	/// 选择了哪一列的哪一行 回调
	optional func pickView(
		_ pickerView: UIPickerView,
		didSelectRow row: Int,
		inComponent component: Int
	)

	// 返回每一列的宽度
  optional func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
  // 返回每一列的行高
  optional func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
}

public protocol UIPickerViewDataSource: NSObjectProtocol {
	// 有多少列
  func numberOfComponents(in pickerView: UIPickerView) -> Int
  
  // 每一列中有多少行数据
  func pickerView(
  	_ pickerView: UIPickerView,
  	numberOfRowsInComponent component: Int
  ) -> Int
}
```



## 4. UISearchBar & UISearchController

这个一般就是通常看到的应用中的搜索框部分, 一般和 **UITableView** 进行结合，过滤搜索结果 ，但那实际上是 **`UISearchController`**, **`UISearchBar`** 则是  **`UISearchController`** 的一个属性。

先看 **`UISearchBar`** 的部分定义

```swift
open class UISearchBar: UIView, UIBarPositioning, UITextInputTraits {
  public convenience init()
  public init(frame: CGRect)
  public init?(coder: NSCoder)
  
  // 默认是 `default`
  open var barStyle: UIBarStyle
  
  // 当前搜索框中的文字
  open var text: String?
  // 这个相当于html中的label 用来说明搜索框的意图
  open var prompt: String?
  
  // 输入框中的展位文字
  open var placeholder: String?
  
  open var showCancelButton: Bool
  
  
  open var tintColor: UIColor!
  // 背景部分的颜色
  open var barTintColor: UIColor?
  
  // 底下的segment controller
  // array of NSStrings
  open var scopeButtonTitles: [String]?
  // 当前选中的scope button的索引
  open var selectedScopeButtonIndex: Int
  
  /// scope 可以自定义背景图片 还有很多相关属性 这里就不详细介绍了
  open var backgroundImage: UIImage?
  open var scopeBarBackgroundImage: UIImage?
}
```

再看比较重要的 **`UISearchController`**:

```swift
open class UISearchController: UIViewController,
						UIViewControllerTransitioningDelegate,
						UIViewControllerAnimatedTransitioning {
	// 如果使用当前VC作为相同结果时 可以传入nil; 也可以自定义VC显示搜索结果
	public init(searchResultsController: UIViewController?)
	// 插入一个没有result controller的 search controller
	public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
	public init?(coder: NSCoder)
	
	/// ! 重要的协议
  // 用于更新searchResultsController的搜索结果
	weak open var searchResultsUpdater: UISearchResultsUpdating?
	
  // searchResultsController 是否激活
	open var isActive: Bool
	
	/// ! 重要的协议
	/// 用于监控搜索vc的出现或消失 可以执行一些生命周期方法
	weak open var delegate: UISearchControllerDelegate?
	
	// 是否遮挡当前的VC 默认是true
	@available(iOS 9.1, *)
    open var obscuresBackgroundDuringPresentation: Bool
  
    // 是否隐藏NavigationBar， 默认true
    open var hidesNavigationBarDuringPresentation: Bool
    // 只读
    open var searchResultsController: UIViewController? { get }
  
    // 可以成为search bar的委托 监听文字的变化 和 按钮的点击
    open var searchBar: UISearchBar { get }
}
```

比较重要的2个协议：

```swift
public protocol UISearchResultsUpdating: NSObjectProtocol {
  // 更新搜索结果VC
  func updateSearchResults(for searchController: UISearchController)
}

// 这个协议基本上和 UITextField 中的委托差不多
// 用于监听 searchBar中的文字的变化以及scopeButtons index的变化
public protocol UISearchBarDelegate: UIBarPositioningDelegate {
	optional func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
  optional func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
}
```

**实现搜索框，相关文章：**

1. [How to use UISearchController to let users enter search words](https://www.hackingwithswift.com/example-code/uikit/how-to-use-uisearchcontroller-to-let-users-enter-search-words)
2. [UISearchController Tutorial – Building a Search Feature in Swift](https://www.iosapptemplates.com/blog/ios-programming/uisearchcontroller-swift)
3. [✨UISearchController Tutorial: Getting Started](https://www.raywenderlich.com/4363809-uisearchcontroller-tutorial-getting-started)

依据第3篇文章，项目地址：

- [UISearchBarDemo - github](https://github.com/jamessawyer/learn_ios/blob/master/Book_Programing_iOS13/chapter12%20controllers/UISearchBarDemo/UISearchBarDemo/MasterViewController.swift)



