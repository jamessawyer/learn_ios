//  https://www.hackingwithswift.com/books/ios-swiftui/controlling-the-animation-stack
//  ModifierOrderImpactAnimation.swift
//  Project06 Animations
//
//  Created on 2019/12/18.
//  Copyright © 2019 oscar. All rights reserved.
//

import SwiftUI

/// 5. 动画modifier的几种重要特点
///  5.1 modifiers的顺序很重要，.animation() modifier上面的属性才有可能产生动画效果
///  5.2 可以使用多个modifers, 因此可以使用多个 .animation() modifiers 对不同的属性使用不同的动画效果
///  5.3 使用.animation(nil)，则在这个modifier上面的属性将不再产生动画效果 ✨
///  5.4 条件语句产生的动画 .background(enabled ? Color.red : Color.blue)
///  5.5 .clipShape(RoundedRectangle()) 圆倒角的创建方式
struct ModifierOrderImpactAnimation: View {
    @State private var enabled = false
    var body: some View {
        Button("Tap me") {
            self.enabled.toggle()
            //self.enabled = !self.enabled
        }
        .frame(width: 200, height: 200)
        .background(enabled ? Color.red : Color.blue)
        .animation(.default)
//        .animation(nil) // 如果不想background有动画 则可以传入一个nil
        .foregroundColor(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: enabled ? 60 : 0))
        .animation(.interpolatingSpring(stiffness: 10, damping: 1))
        .navigationBarTitle("modifier顺序")
    }
}


struct ModifierOrderImpactAnimation_Previews: PreviewProvider {
    static var previews: some View {
        ModifierOrderImpactAnimation()
    }
}
