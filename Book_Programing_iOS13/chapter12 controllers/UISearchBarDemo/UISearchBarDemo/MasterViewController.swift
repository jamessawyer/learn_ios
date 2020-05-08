// 示例来源
// [UISearchController Tutorial: Getting Started](https://www.raywenderlich.com/4363809-uisearchcontroller-tutorial-getting-started)
// 知识点
// 1.UISearchController
//   - searchController.searchBar
//   - searchController.isActive
//   - searchController.searchResultsUpdater = self
//   - searchController.obscuresBackgroundDuringPresentation = self
// 2.navigationItem.searchController 在导航栏中添加搜索
// 3.UISearchResultsUpdating 委托 搜索框中的文字发生变化
// 4.UISearchBarDelegate 检测searchBar scopeButton 发生变化

/// 相关文章
/// 1. [How to use UISearchController to let users enter search words](https://www.hackingwithswift.com/example-code/uikit/how-to-use-uisearchcontroller-to-let-users-enter-search-words)
/// 2. [UISearchController Tutorial – Building a Search Feature in Swift](https://www.iosapptemplates.com/blog/ios-programming/uisearchcontroller-swift)

import UIKit

class MasterViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchFooter: SearchFooter!
    @IBOutlet var searchFooterBottomConstraint: NSLayoutConstraint!

    var candies: [Candy] = []
    var filteredCandies: [Candy] = []
    // 传入nil 表示使用当前VC显示搜索结果 也可以传入自定义VC
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        candies = Candy.getCandies()
        tableView.dataSource = self
        
        // 委托
        // 用于获取 UISearchBar 中搜索文字的变化
        searchController.searchResultsUpdater = self
        // 是否遮挡当前VC
        // 如果使用当前VC 则不需要遮挡；如果使用另外一个VC 则需要进行遮挡
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Candies"
//        searchController.searchBar.tintColor = .white
//        searchController.searchBar.barTintColor = UIColor.candyGreen
        
        // 添加scope buttons
        // Candy.Category 枚举服从 CaseIterable 协议
        searchController.searchBar.scopeButtonTitles = Candy.Category.allCases.map { $0.rawValue }
        searchController.searchBar.delegate = self
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { (notification) in
            self.handleKeyboard(notification: notification)
        }
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
            self.handleKeyboard(notification: notification)
        }
        
        // 注意这个属性需要 iOS11+
        navigationItem.searchController = searchController
        // 也可以放在tableView 的headerView中 但是效果和上面的有所不同
//        searchController.hidesNavigationBarDuringPresentation = true
//        tableView.tableHeaderView = searchController.searchBar
        // 如果导航到其它页面 隐藏 UISearchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 去除tableView 选择cell之后的高亮
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "ShowDetailSegue",
            let indexPath = tableView.indexPathForSelectedRow,
            let detailViewController = segue.destination as? DetailViewController
        else {
            return
        }
        
        let candy: Candy
        
        if isFiltering {
            candy = filteredCandies[indexPath.row]
        } else {
            candy = candies[indexPath.row]
        }
        
        detailViewController.candy = candy
    }
    
    func filterContentForSearchText(_ searchText: String, category: Candy.Category? = nil) {
        
        filteredCandies = candies.filter({ (candy: Candy) -> Bool in
            let doesCategoryMatch = category == .all || candy.category == category
            if isSearchBarEmpty {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && candy.name.lowercased().contains(searchText.lowercased())
            }
        })
        
        tableView.reloadData()
    }
    
    func handleKeyboard(notification: Notification) {
        guard notification.name == UIResponder.keyboardWillChangeFrameNotification else {
          searchFooterBottomConstraint.constant = 0
          view.layoutIfNeeded()
          return
        }

        guard
          let info = notification.userInfo,
          let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
          else {
            return
        }
        
        let keyboardHeight = keyboardFrame.cgRectValue.size.height
        
        UIView.animate(withDuration: 0.1) {
            self.searchFooterBottomConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
}

extension MasterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredCandies.count, of: candies.count)
            return filteredCandies.count
        }
        searchFooter.setNotFiltering()
        return candies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let candy: Candy
        if isFiltering {
            candy = filteredCandies[indexPath.row]
        } else {
            candy = candies[indexPath.row]
        }
        cell.textLabel?.text = candy.name
        cell.detailTextLabel?.text = candy.category.rawValue
        return cell
    }
}

// 为了 MasterViewController 能响应search bar 必须实现UISearchResultsUpdating协议
extension MasterViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let category = Candy.Category(rawValue: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        
        filterContentForSearchText(searchBar.text!, category: category)
    }
}

extension MasterViewController: UISearchBarDelegate {
    // scope button 发生变化时 生效
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let category = Candy.Category(rawValue: searchBar.scopeButtonTitles![selectedScope])
        filterContentForSearchText(searchBar.text!, category: category)
    }
}
