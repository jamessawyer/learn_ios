//
//  ContentView.swift
//  Project07 iExpense
//
//  Created by lucian on 2019/12/21.
//  Copyright © 2019 oscar. All rights reserved.
//

import SwiftUI

/// Identifiable 协议 表明这个类型可唯一的标识
/// Identifiable 协议唯一要求就是需要一个唯一的 id
struct ExpenseItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: String
    let amount: Int
}
// 这个是所有页面共享的数据模型
class Expenses: ObservableObject {
    // 每次数据更新的时候 这里都会更新 将数据存储在本地
    @Published var items: [ExpenseItem] {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        // 从本地存储中读取数据
        if let items = UserDefaults.standard.data(forKey: "Items") {
            let decoder = JSONDecoder()
            /// [ExpenseItem].self 表示 type object 表示类型自身
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items) {
                self.items = decoded
                return
            }
        }
        // 如果没有读取到则将其设置为一个空数组
        self.items = []
    }
    
}


struct ContentView: View {

    @ObservedObject var expenses = Expenses()
    @State private var showAddView = false
    
    var body: some View {
        NavigationView {
            List {
                /// id 一定要保持唯一性 这样才能正确的移除item
                /// 因为 ExpenseItem 遵循 Identifiable 协议 确保 items是唯一的 因此可以省略掉 id: \.id
                ForEach(self.expenses.items) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.type)
                                .foregroundColor(Color.gray)
                        }
                        Spacer()
                        self.itemValue(amount: item.amount)
//                        /// 下面这种条件渲染不行 不知道为什么
                          /// https://www.hackingwithswift.com/books/ios-swiftui/conditional-modifiers
//                        if item.amount < 10 {
//                            Text("\(item.amount)")
//                                .forgroundColor(Color.yellow)
//                        } else if item.amount >= 10, item.amount < 100 {
//                            Text("\(item.amount)")
//                            .forgroundColor(Color.red)
//                        } else {
//                            Text("\(item.amount)")
//                            .forgroundColor(Color.green)
//                        }
                    }
                }
                .onDelete(perform: removeItem)
            }
            .sheet(isPresented: $showAddView, content: {
                AddView(expense: self.expenses)
            })
            .navigationBarTitle(Text("Expenses"))
                .navigationBarItems(leading: EditButton(),trailing: Button(action: {
                self.showAddView = true
            }, label: {
                Image(systemName: "plus")
            }))
        }
    }
    
    func removeItem(at offset: IndexSet) {
        expenses.items.remove(atOffsets: offset)
    }
    
    // 条件渲染不同类型的组件
    func itemValue(amount: Int) -> Text {
        switch (amount < 10, amount > 100) {
        case (true, false): return Text("\(amount)").foregroundColor(Color.green)
        case (false, true): return Text("\(amount)").foregroundColor(Color.red)
        case (false, false): return Text("\(amount)").foregroundColor(Color.yellow)

        default:
            return Text("")        }
    }
}


/// 5
/// UserDefaults & property wrapper 高级使用方式
/// https://www.vadimbulavin.com/advanced-guide-to-userdefaults-in-swift/
//extension Key {
//    static let tapCount: Key = "TapCount"
//}
//struct Storage {
//    @UserDefault(key: .tapCount)
//    var tapCount: Int
//
//}
//struct ContentView: View {
//    // 如果没有取到 返回默认值 0
//    static var storage = Storage()
//    @State private var number = storage.tapCount ?? 0
//
//    var body: some View {
//        Button("Tap me \(number)") {
//            self.number += 1
//            ContentView.storage.tapCount = self.number
//        }
//    }
//}

/// 4
/// 4.1 UserDefaults 存储少量数据 <512kb
/// 4.2 存储需要时间 因此如果快速点击 然后快速退出应用 有可能数据没保存上
//struct ContentView: View {
//    // 如果没有取到 返回默认值 0
//    @State private var number = UserDefaults.standard.integer(forKey: "Tap")
//
//    var body: some View {
//        Button("Tap me \(number)") {
//            self.number += 1
//            UserDefaults.standard.set(self.number, forKey: "Tap")
//        }
//    }
//}

/// 3
/// 还可以配合NavigationView 添加一个 EditButton() 进行编辑使用
//struct ContentView: View {
//    @State private var rows = [Int]()
//    @State private var currentRow = 1
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                List {
//                    ForEach(rows, id: \.self) {
//                        Text("\($0)")
//                    }
//                    .onDelete(perform: removeRow)
//                }
//
//                Button("Add Item") {
//                    self.rows.append(self.currentRow)
//                    self.currentRow += 1
//                }
//            }
//            .navigationBarItems(leading: EditButton())
//        }
//    }
//    /// 需要添加一个 IndexSet 类型
//    func removeRow(index: IndexSet) {
//        rows.remove(atOffsets: index)
//    }
//}
/// List & ForEach 的 onDelete modifier
/// 如果要对List使用 onDelete， 则不能省略 ForEach
//struct ContentView: View {
//    @State private var rows = [Int]()
//    @State private var currentRow = 1
//
//    var body: some View {
//        VStack {
//            List {
//                ForEach(rows, id: \.self) {
//                    Text("\($0)")
//                }
//                .onDelete(perform: removeRow)
//            }
//
//            Button("Add Item") {
//                self.rows.append(self.currentRow)
//                self.currentRow += 1
//            }
//        }
//    }
//    /// 需要添加一个 IndexSet 类型
//    func removeRow(index: IndexSet) {
//        rows.remove(atOffsets: index)
//    }
//}

/// 2
/// @Environment 相当于React 里面的 Context
/// .sheet() 使用方式类似于 .alert() ,但它将从底部弹出另一个视图 类似于modal
/// presentationMode包含2个属性：是否当前视图被显示了 和  关闭当前视图
//struct SecondView: View {
//    @Environment(\.presentationMode) var presentationMode
//    var name: String
//    var body: some View {
//        VStack {
//            Text("Hello \(name)")
//            Button("Dismiss the presentation") {
//                /// presentationMode 是一种会随着系统变化的binding
//                /// wrappedValue 则是其实际存储的值
//                self.presentationMode.wrappedValue.dismiss()
//            }
//        }
//    }
//}
//struct ContentView: View {
//    @State private var isShow = false
//    var body: some View {
//        Button("Open sheet") {
//            self.isShow.toggle()
//        }
//        .sheet(isPresented: $isShow) {
//            SecondView(name: "James")
//        }
//    }
//}

/// 1
/// @ObservableObject & @Published & @ObservedObject
/// 类似发布订阅 可用于全局
/// @State 一般表示局部状态 类似于React 里面的 state
//class User: ObservableObject {
//    @Published var firstName = "lily"
//    var lastName = "Bobby"
//}
//
//struct ContentView: View {
//    @ObservedObject var user = User()
//    var body: some View {
//        VStack {
//            Text("user name: \(user.firstName) \(user.lastName)")
//            TextField("first name", text: $user.firstName)
//            TextField("first name", text: $user.lastName)
//        }
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
