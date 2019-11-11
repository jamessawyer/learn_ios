### 5.1 如何阻止UITableView中空的行分割线出现

- [How to stop empty row separators appearing in UITableView?](https://www.hackingwithswift.com/example-code/uikit/how-to-stop-empty-row-separators-appearing-in-uitableview)

表视图默认会在空的行间显示分割线，下面代码可以让ios不绘制这些分割线：

```swift
tableView.tableFooterView = UIView()
```

实际上你创建了一个空的 **`UIView`**，让其充当表尾（表中最底部可见区域）。当iOS到达最底部单元格时，它会绘制这个UIView 而不是绘制空的行和分割线，因此达到隐藏分割线的目的



### 5.2 如何让UITableViewCell的分割线边缘靠边缘？

- [How to make UITableViewCell separators go edge to edge?](https://www.hackingwithswift.com/example-code/uikit/how-to-make-uitableviewcell-separators-go-edge-to-edge)

默认情况，所有的单元格底部都有一个分割线，但是分割线距离屏幕的边缘会有一点间距。如果你想要从所有单元格中分割线和屏幕宽度一样，你需要做两件事：

```swift
tableView.layoutMargins = UIEdgeInsets.zero
tableView.separatorInset = UIEdgeInsets.zero

// 现在在 'cellForRowAt' 方法添加 swift4中并不需要这一个了
cell.layoutMargins = UIEdgeInsets.zero
```

示例：

```swift
class TableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        // 或简写为
        // tableView.layoutMargins = .zero
        // tableView.separatorInset = .zero
    }
}
```



可参考：

- [how to set the full width of separator in UITableView - stackoverflow](https://stackoverflow.com/questions/26519248/how-to-set-the-full-width-of-separator-in-uitableview)

### 5.3 什么是IndexPath?



- [what is an IndexPath?](https://www.hackingwithswift.com/example-code/uikit/what-is-an-indexpath)

Index path 是用来描述一个item在table view 或者collection view内的位置，存储了section和section position。例如，一个table 的第一行是 **`section 0, row 0`**, 而第4个section中的第8行是 **`section 3, row 7`**.

在iOS中会经常使用index path,例如，用户什么时候点击了某行，什么时候UIKit需要知道是否某个item被编辑。

当使用collection views时，你需要使用item的index path 数字，而不是行号，因为当多个items共享同一行时，row number表示不同的东西。



### 5.4 如何给UITableViewCell添加一个按钮？

- [How to add a button to a UITableViewCell?](https://www.hackingwithswift.com/example-code/uikit/how-to-add-a-button-to-a-uitableviewcell)

在table view添加按钮需要2步，第一步是像这样添加按钮：

```swift
cell.accessoryType = .detailDisclosureButton
```

第2步是当按钮被点击时，产生动作，在 **`accessoryButtonTappedForRowWith`** 方法中：

```
override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith index: IndexPath) {
    doSomethingWithItem(indexPath.row)
}
```



### 5.5 如何给table view添加一个section header？

- [How to add a section header to a table view?](https://www.hackingwithswift.com/example-code/uikit/how-to-add-a-section-header-to-a-table-view)

可以使用内置的iOS table section headers，使用 **`titleForHeaderInSection`**：

```swift
override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Section \(section)"
}
```

如果想要添加自定义header视图，而不仅仅是文字，可以使用 **`viewForHeaderInSection`**:

```swift
override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let vw = UIView()
    vw.backgroundColor = .red
    
    return vw
}
```



### 5.6 如何给UITableView 添加 peek and pop?

- [How to add peek and pop to UITableView?](https://www.hackingwithswift.com/example-code/uikit/how-to-add-peek-and-pop-to-a-uitableview)



**`Peek and pop`** 是一种3D Touch 功能，即用力按压屏幕弹出子菜单，显示更多信息。

在table view cells 和 collection view cells中添加这个功能很简单，如果使用SB和segue则会更简单。

如果你使用StoryBoard(SB) 和 segues，XCode会帮你自动处理。（请用真机调试）

如果不使用 segues，则需要自己写一点代码。首先，使视图控制器遵循 **`UIViewControllerPreviewingDelegate`** 协议，这样可以正确的响应预览请求；然后，需要在viewDidLoad中通过 **`registerForPreviewing()`**方法告诉系统我们希望支持预览

```
registerForPreviewing(with: self, sourceView: tableView)
```

