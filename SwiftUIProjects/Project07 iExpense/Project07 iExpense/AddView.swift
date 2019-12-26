//  Day36-38 of 100DaysOfSwiftUI
//  https://www.hackingwithswift.com/100/swiftui/36
//  AddView.swift
//  Project07 iExpense
//
//  Created on 2019/12/24.
//  Copyright © 2019 oscar. All rights reserved.
//
/// 知识点

import SwiftUI

struct AddView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var expense: Expenses
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = ""
    
    @State private var isShowAlert = false
    
    static let types = ["Buiness", "Personal"]
    
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                
                Picker("Type", selection: $type) {
                    ForEach(Self.types, id: \.self) {
                        Text($0)
                    }
                }
                
                TextField("Amount", text: $amount)
                    .keyboardType(.numberPad)
            }
            .alert(isPresented: $isShowAlert, content: { () -> Alert in
                Alert(title: Text("Error"), message: Text("You should only input numbers in Amount"), dismissButton: .default(Text("Ok")))
            })
            .navigationBarTitle("Add new Expense")
            .navigationBarItems(trailing: Button("Save") {
                if let actualmount = Int(self.amount) {
                    let item = ExpenseItem(name: self.name, type: self.type, amount: actualmount)
                    self.expense.items.append(item)
                    self.name = ""
                    self.amount = ""
                    self.presentationMode.wrappedValue.dismiss() // 隐藏sheet
                } else {
                    self.isShowAlert = true
                }
            })
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(expense: Expenses())
    }
}
