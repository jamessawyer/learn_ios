// Day 32-34 of 100DaysOfSwiftUI
// Animations
// https://www.hackingwithswift.com/100/swiftui/32
//  ContentView.swift
//  Project06 Animations
//
//  Created on 2019/12/15.
//  Copyright © 2019 oscar. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ImplicitAnimation()) {
                    Text("隐式动画.animation的使用")
                }
                NavigationLink(destination: OnAppearAnimation()) {
                    Text("OnAppear 和 repeat 动画")
                }
                NavigationLink(destination: BindingValueAnimation()) {
                    Text("给Binding值添加动画")
                }
                NavigationLink(destination: ExplicitAnimation()) {
                    Text("withAnimation创建动画")
                }
                NavigationLink(destination: ModifierOrderImpactAnimation()) {
                    Text("多个animation修饰符的使用")
                }
                Section(header: Text("手势拖动效果").foregroundColor(Color.gray)) {
                    NavigationLink(destination: GestureAnimation1()) {
                        Text("DragGesture拖动渐变视图")
                    }
                    NavigationLink(destination: GestureAnimation2()) {
                        Text("DragGesture拖动文字带延迟效果")
                    }
                }
                Section(header: Text("transition动画").foregroundColor(Color.gray)) {
                    NavigationLink(destination: TransitionAnimation()) {
                        Text("transition便利动画效果")
                    }
                    NavigationLink(destination: CustomTransitionModifierAnimation()) {
                        Text("自定义transiton效果")
                    }
                }
                
            }
            .navigationBarTitle("SwiftUI Animations")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
