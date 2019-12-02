//
//  ContentView.swift
//  WeSplit
//
//  Created by lucian on 2019/11/23.
//  Copyright © 2019 oscar. All rights reserved.
//

// 100 Days of SwiftUI Project 1 - WeSplit
// https://www.hackingwithswift.com/100/swiftui/16

import SwiftUI

struct ContentView: View {
    @State private var amount = ""
    @State private var numberOfPeople = "2"
    @State private var tipPercentage = 2
    let tipsPercentages = [10, 15, 20, 25, 0]
    
    // 总的金额 = 消费 + 小费
    var totalAmount: Double {
        let totalMoney = Double(amount) ?? 0 // 总的金额
        let tipSelection = Double(tipsPercentages[tipPercentage]) // 选择的小费百分比
        let tipAmount = totalMoney * tipSelection / 100  // 小费
        return totalMoney + tipAmount
    }
    
    // 每人平均多少钱 （计算属性）
    var averageAmount: Double {
        let peopleTotal = Double(numberOfPeople) ?? 0 + 2 // 总的人数
        return totalAmount / peopleTotal
    }
    
//    // 每人平均多少钱 （计算属性）
//    var averageAmount: Double {
//        let totalAmount = Double(amount) ?? 0 // 总的金额
//        let tipSelection = Double(tipsPercentages[tipPercentage]) // 选择的小费百分比
//        let tipAmount = totalAmount * tipSelection / 100  // 小费
//        let peopleTotal = Double(numberOfPeople + 2) // 总的人数
//        let finalPayAmount = totalAmount + tipAmount
//        return finalPayAmount / peopleTotal
//    }

    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Total Money", text: $amount)
                        .keyboardType(.decimalPad)
                    
//                    Picker("Number of people", selection: $numberOfPeople) {
//                        ForEach(2 ..< 100) {
//                            Text("\($0) people")
//                        }
//                    }
                    
                    TextField("Number of people", text: $numberOfPeople)
                        .keyboardType(.numberPad)
                                            
                }
                
                Section(header: Text("How much tips yout want give?")) {
                    Picker("Percent of tip", selection: $tipPercentage) {
                        ForEach(0 ..< tipsPercentages.count) {
                            Text("\(self.tipsPercentages[$0])%")
                        }
            
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Total Amount")) {
                    // https://www.hackingwithswift.com/books/ios-swiftui/views-and-modifiers-wrap-up
                    // 项目3 任务2
                    // Go back to project 1 and use a conditional modifier to change the total amount text view to red if the user selects a 0% tip.
                    Text("$\(totalAmount, specifier: "%.2f")")
                        .foregroundColor(tipsPercentages[tipPercentage] == 0 ? Color.red : Color.black)
                }
                
                Section(header: Text("Amount per person")) {
                    // "%.2f" 表示保留2位小数 和C语言写法一样
                    Text("$\(averageAmount, specifier: "%.2f")")
                }
            }
            .navigationBarTitle("WeSplit")
        }
        
    }
}

// View 是一个 Protocol
// 它只有一个必要条件就是必须存在一个返回类型为some View 的计算属性body
//struct ContentView: View {
//    // body 是一个计算属性 是swiftUI视图 必须要存在的一个属性
//    // some View 表示 返回某个遵循View协议的视图
//    // some 为返回的视图添加一个限制 表示返回的类型确定后不能再改变
//    var body: some View {
//        NavigationView {
//            Form {
//               Section {
//                   Text("Hello World swiftui")
//                   Text("Hello World swiftui")
//               }
//            }
//            .navigationBarTitle(Text("SwiftUI"), displayMode: .inline)
//        }
//    }
//}
//struct ContentView: View {
//    @State private var name = ""
//
//    var body: some View {
//        Form {
//            // $name 表示双向绑定
//            TextField("Enter your name", text: $name)
//            // name 表示只是读取当前值
//            Text("Your name is \(name)")
//        }
//    }
//}

//struct ContentView: View {
//    let students = ["james", "kobe", "durant"]
//    @State private var selectedStudent = 0
//
//    var body: some View {
//        VStack {
//            Picker("Select one student", selection: $selectedStudent) {
//                ForEach(0 ..< students.count) {
//                    Text("\(self.students[$0])")
//                }
//            }
//            Text("selected Student is \(students[selectedStudent])")
//        }
//
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
