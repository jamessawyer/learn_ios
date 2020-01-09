文章来源:

- [Mastering MVVM on iOS - Majid's blog](https://swiftwithmajid.com/2018/01/11/mastering-mvvm-on-ios/)



MVC模式在iOS中开发的最大问题就是职责混淆，导致大量代码在ViewController中实现。

ViewController中因为生命周期（viewDidLoad, viewWillLayoutSubviews等等）的原因，因此产生大量视图布局相关的代码，其View特性比Controller更加的显著。

**`ViewModel` 是视图所有数据相关的模型， 一个视图应该只存在一个ViewModel实例，用于管理操作数据**。

示例：

```swift
/// ViewModel
import Foundation

class ItemsViewModel {
  var items: [Item] = []
  var error: Error?
  var refreshing = false
  
  /// 使用 DataManager 来获取数据
  private let dataManager: DataManager
  init(dataManager: DataManager) {
    self.dataManager = dataManager
  }
  
  func fetch(completion: @escaping () -> Void) {
    refreshing = true
    dataManager.fetchItems { [weak self] (items, error) in
    	self?.items = items ?? []
    	self?.error = error
    	self?.refreshing = false
    	completion()
    }
  }
}
```

ViewController则使用该ViewModel实例:

```swift
import UIKit

class ItemsViewController: UIViewController {
  @IBOutlet private weak var tableView: UITableView!
  private var viewModel: ItemsViewModel // ViewModel 实例
  
  init(viewModel: ItemsViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewModel.fetch { [weak self] in
    	self?.tableView.reloadData()
    }
  }
}

extension ItemsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.items.count
  }
}
```



> **响应式绑定**

**视图和视图模型之间的绑定是MVVM架构的核心思想， 上面使用闭包的方式。** 因为iOS没有现成的绑定能力，可以使用第三方库（比如 **`ReactiveCocoa | RxSwfit | Bond`**）来完成绑定。下面使用 **`Bond`** 库做示例：

```swift
/// ViewModel
import Foundation
import Bond ///

class ItemsViewModel {
	/// 可观察的对象
  var items = Observable<[Item]>([])
  var error = Observable<Error?>(nil)
  var refreshing = Observable<Bool>(false)
  
  /// 使用 DataManager 来处理数据
  private let dataManager: DataManager
  init(dataManager: DataManager) {
    self.dataManager = dataManager
  }
  
  func fetch(completion: @escaping () -> Void) {
    refreshing = true
    dataManager.fetchItems { [weak self] (items, error) in
    	self?.items = items ?? []
    	self?.error = error
    	self?.refreshing = false
    	completion()
    }
  }
}
```

视图对模型进行绑定：

```swift
import UIKit

class ItemsViewController: UIViewController {
  @IBOutlet private weak var tableView: UITableView!
  private let activityIndicator = ActivityIndicatorView() // loading图标
  private var viewModel: ItemsViewModel // ViewModel 实例
  
  init(viewModel: ItemsViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    bindViewModel()
    viewModel.fetch()
  }
  
  func setupUI() {
    view.addSubview(activityIndicator)
  }
  // 绑定视图模型
  // 当refreshing值发生变化时，会影响activityIndicator的显示或隐藏
  // items发生变化时，自动刷新UITableView
  func bindViewModel() {
    viewModel.refreshing.bind(to: activityIndicator.reactive.isAnimating)
    viewModel.items.bind(to: self) { stroingSelf, _ in
    	strongSelf.tableView.reloadData()
    }
  }
}

extension ItemsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.items.value.count // 可观察对象的值使用 value
  }
}
```



> 多个ViewModels组合

有时候一个VC中会包含多个视图模型，但是 **一个VC应该只拥有一个视图模型，我们可以把多个视图模型合并成一个总的视图模型传递给VC。** 有点类似于redux中将多个reducers合并成一个reducer。

比如Instagram的profile页面需要user信息和对应user的所有相片。处理方式是：分别处理2个视图模型，然后将其组合成profile页面所需要的一个ViewModel

```swift
import Bond
import ReactiveKit

// ViewModel 1
class UserViewModel {
  let refreshing = Observable<Bool>(false)
  let username = Observable<String>("")
  
  /// 使用 UserManager 来获取数据
  private let manager: UserManager
  init(dataManager: DataManager) {
    self.manager = manager
  }
  
  func fetch() {
    refreshing.value = true
    manager.fetch(user: id) { [weak self] (user, error) in
    	self?.username.value = "@\(user.username)"
    	self?.refreshing.value = false
    }
  }
}

// ViewModel 2
class PhotosViewModel {
  let refreshing = Observable<Bool>(false)
  let photos = Observable<[Photo]>([]) // Photo是一个自定义类型
  
  /// 使用 PhotoManager 来获取数据
  private let manager: PhotoManager
  init(manager: PhotoManager) {
    self.manager = manager
  }
  
  func fetch() {
    refreshing.value = true
    manager.fetch(user: id) { [weak self] (photos, error) in
    	self?.photos.value = photos ?? []
    	self?.refreshing.value = false
    }
  }
}

// 将其组合成给Profile页面使用的ViewModel
class UserProfileViewModel {
  let refreshing = Observable<Bool>(false)
  let username = Observable<String>("")
  let photos = Observable<[Photo]>([])
  
  /// 组合起来
  private let userViewModel: UserViewModel
  private let photosViewModel: PhotosViewModel
  
  init(userManager: UserManager, photoManager: PhotoManager) {
    userViewModel = UserViewModel(manager: userManager)
    photosViewModel = PhotosViewModel(manager: photoManager)
    
    userViewModel.username.bind(to: username)
    photosViewModel.photos.bind(to: photos)
    
    /// 函数式编程
    combineLatest(userViewModel.refreshing, photosViewModel.refreshing)
    	.map { $0 || $1 }
    	.bind(to: refreshing)
  }
  
  func fetch() {
    userViewModel.fetch()
    photosViewModel.fetch()
  }
}
```



2020年01月09日15:29:54







