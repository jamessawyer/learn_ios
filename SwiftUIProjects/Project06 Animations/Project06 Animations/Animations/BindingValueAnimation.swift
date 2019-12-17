//  https://www.hackingwithswift.com/books/ios-swiftui/animating-bindings
//  BindingValueAnimation.swift
//  Project06 Animations
//
//  Created on 2019/12/18.
//  Copyright © 2019 oscar. All rights reserved.
//

/// 3. Binding Animations 绑定值添加动画
///  3.1 $animationValue.animation()
///  3.2 $animationValue.animation(Animation.easeIn(duration: 1).repeatCount(3, autoreverses: true))
///  3.3 Animation 结构体
///  3.4 .clipShape(Circle()) 添加一个圆形的形状
import SwiftUI

struct BindingValueAnimation: View {
    @State private var animationValue: CGFloat = 1
    var body: some View {
        VStack {
            /// Binding value 动画
            Stepper("Scale amount", value: $animationValue.animation(
                Animation.easeInOut(duration: 1)
                    .repeatCount(3, autoreverses: true)
            ), in: 1...10)
            Spacer()
            Button("Tap me") {
                self.animationValue += 1
            }
            .padding(40)
            .background(Color.red)
            .foregroundColor(Color.white)
            .clipShape(Circle())
            .scaleEffect(animationValue)
        }
        .navigationBarTitle("Binding值添加动画")
    }
}

struct BindingValueAnimation_Previews: PreviewProvider {
    static var previews: some View {
        BindingValueAnimation()
    }
}
