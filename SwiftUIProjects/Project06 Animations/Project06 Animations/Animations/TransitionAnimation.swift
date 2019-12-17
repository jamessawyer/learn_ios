//  https://www.hackingwithswift.com/books/ios-swiftui/showing-and-hiding-views-with-transitions
//  TransitionAnimation.swift
//  Project06 Animations
//
//  Created on 2019/12/18.
//  Copyright © 2019 oscar. All rights reserved.
//

import SwiftUI

/// 7. 视图的显示和隐藏时的动画设置
///  7.1 使用 .transition(.scale) 修饰符设置对称性动画
///  7.2 .transition(.asymmetric(insertion: .scale, removal: .opacity)) 设置不对称动画
///  7.3 Rectangle() 可以很方便设置一个简单的视图
struct TransitionAnimation: View {
    @State private var isShow = false

    var body: some View {
        VStack {
            Button("Tap me") {
                // 使用显式动画
                withAnimation {
                    self.isShow.toggle()
                }
            }

            if isShow {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 200, height: 200)
//                    .transition(.scale) // 缩放
                    // 不对称动画 入场动画为缩放 出场动画为透明度变化
                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
            }
        }
        .navigationBarTitle("transition提供便利的动画")
    }
}

struct TransitionAnimation_Previews: PreviewProvider {
    static var previews: some View {
        TransitionAnimation()
    }
}
