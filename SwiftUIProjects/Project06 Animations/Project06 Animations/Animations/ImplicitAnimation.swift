//  https://www.hackingwithswift.com/books/ios-swiftui/creating-implicit-animations
//  ImplicitAnimation.swift
//  Project06 Animations
//
//  Created on 2019/12/18.
//  Copyright © 2019 oscar. All rights reserved.
//
/// 1. 隐式动画
///  1.1 .animation(.default)
///  1.2 animation(.interpolatingSpring(stiffness: 50, damping: 1))
///  1.3 .animation(.easeInOut(duration: 2))
///  1.4 .animation(Animation.easeIn(duration: 2).delay(1))
///  1.5 .animation(Animation.easeInOut(duration: 1).repeatCount(3, autoreverses: true))

import SwiftUI

struct ImplicitAnimation: View {
    @State private var scale: CGFloat = 1

    var body: some View {
        // 注意点击的时候 要点中文字部分 不知道这是不是一个bug
        // https://stackoverflow.com/questions/57333573/swiftui-button-tap-only-on-text-portion
        Button("Tap me") {
            self.scale += 1
        }
        .frame(width: 100, height: 100)
        .background(Color.red)
        .foregroundColor(Color.white)
        .clipShape(Circle())
        .scaleEffect(scale)
        .blur(radius: (scale - 1) * 3)
        /// 5. 添加一个重复动画效果 bounce-back & forword 重复次数为3次 scale-shrink-scale
        .animation(
            Animation.easeInOut(duration: 1)
            .repeatCount(3, autoreverses: true)
        )
        .navigationBarTitle("隐式动画")
         /// 4. 给动画添加一个延迟
//        .animation(
//            Animation.easeInOut(duration: 2)
//            .delay(1)
//        )
        /// 3. 定义动画时间
//        .animation(.easeInOut(duration: 2))
        /// 2. spring animation
//        .animation(.interpolatingSpring(stiffness: 50, damping: 1))
        /// 1. default: ease in, ease out
//        .animation(.default)
    }
}

struct ImplicitAnimation_Previews: PreviewProvider {
    static var previews: some View {
        ImplicitAnimation()
    }
}

