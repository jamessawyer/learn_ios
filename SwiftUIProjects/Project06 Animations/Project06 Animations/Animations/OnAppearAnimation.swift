//  https://www.hackingwithswift.com/books/ios-swiftui/customizing-animations-in-swiftui
//  OnAppearAnimation.swift
//  Project06 Animations
//
//  Created on 2019/12/18.
//  Copyright © 2019 oscar. All rights reserved.
//

/// 2. onAppear 结合动画 页面出现时就产生动画 和 重复性动画效果
///  2.1 .animation(Animation.easeOut(duration: 1).repeatForever(autoreverses: false)
///  2.2 .animation(Animation.easeOut(duration: 1).repeatForever()
///  2.3 对 .overlay 进行动画效果
///  2.4 Circle() 组件
import SwiftUI

struct OnAppearAnimation: View {
    @State private var scale: CGFloat = 1

    var body: some View {
        Button("Tap me") {
        }
        .padding(50)
        .background(Color.red)
        .foregroundColor(Color.white)
        .clipShape(Circle()) // 将按钮变成一个圆形
        .overlay(
            Circle()
                .stroke()
                .scaleEffect(scale)
                .opacity(Double(2 - scale)) // 从 1 -> 0
                .animation(
                    // pulsing 动画效果
                    Animation.easeOut(duration: 1)
                        .repeatForever(autoreverses: false)
//                        .repeatForever()
                )
        )
        .onAppear {
            self.scale = 2
        }
        .navigationBarTitle("OnAppear & repeat动画")
    }
}

struct OnAppearAnimation_Previews: PreviewProvider {
    static var previews: some View {
        OnAppearAnimation()
    }
}
