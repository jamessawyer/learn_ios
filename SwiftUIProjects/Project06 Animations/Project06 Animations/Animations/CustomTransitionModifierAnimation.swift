//  https://www.hackingwithswift.com/books/ios-swiftui/building-custom-transitions-using-viewmodifier
//  CustomTransitionModifierAnimation.swift
//  Project06 Animations
//
//  Created on 2019/12/18.
//  Copyright © 2019 oscar. All rights reserved.
//

import SwiftUI

/// 8. 自定义Modifier 用来实现自定义的 transition效果
/// 此处为一个裁切的效果
///  8.1 UnitPoint 类型
///  8.2 rotationEffect 和 rotation3DEffect 的区别
///  8.3 AnyTransiton 协议
struct CornerRotateModifier: ViewModifier {
    let amount: Double
    let anchor: UnitPoint // UnitPoint 用于控制 anchor 比如 .trialing | .topLeading 等等

    func body(content: Content) -> some View {
        // rotationEffect 和 rotation3DEffect 很像， 除了前者转动轴始终为z轴
        // clipped()表示 当视图旋转时，位于其自然矩形之外的部分不会被绘制 即产生扇形的效果
        content.rotationEffect(.degrees(amount), anchor: anchor).clipped()
    }
}
extension AnyTransition {
    static var pivot: AnyTransition {
        .modifier(
            // .topLeading 表示的是以左上角作为转动的中心
            active: CornerRotateModifier(amount: -90, anchor: .topLeading),
            identity: CornerRotateModifier(amount: 0, anchor: .topLeading)
        )
    }
}

struct CustomTransitionModifierAnimation: View {
    @State private var isShow = false

    var body: some View {
        VStack {
            Button("Tap me") {
                withAnimation {
                    self.isShow.toggle()
                }
            }

            if isShow {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 200, height: 200)
                    .transition(.pivot) // 使用自定义transition 效果
            }

        }
        .navigationBarTitle("自定义transition效果")
    }
}


struct CustomTransitionModifierAnimation_Previews: PreviewProvider {
    static var previews: some View {
        CustomTransitionModifierAnimation()
    }
}
