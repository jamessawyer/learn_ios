//  https://www.hackingwithswift.com/books/ios-swiftui/creating-explicit-animations
//  ExplicitAnimation.swift
//  Project06 Animations
//
//  Created on 2019/12/18.
//  Copyright © 2019 oscar. All rights reserved.
//

import SwiftUI

/// 4. withAnimation 显式动画 & ratation3DEffect 效果
///  4.1 withAnimation {}
///  4.2 withAnimation(.interpolatingSpring(stiffness:5, damping: 1)) {}
///  4.3 rotation3DEffect(.degrees(animtionValue), axis: (x: 0, y: 1, z: 0)) x, y, z轴可以有多个轴为1
struct ExplicitAnimation: View {
    @State private var animationValue = 0.0
    var body: some View {
        Button("Tap me") {
//            withAnimation {
//                self.animationValue += 360
//            }
            withAnimation(.interpolatingSpring(stiffness: 5, damping: 1)) {
                self.animationValue += 360
            }
        }
        .padding(40)
        .background(Color.red)
        .foregroundColor(Color.white)
        .clipShape(Circle())
        .rotation3DEffect(.degrees(animationValue), axis: (x: 0, y: 1, z: 0))
        .navigationBarTitle("withAnimation")
    }
}


struct ExplicitAnimation_Previews: PreviewProvider {
    static var previews: some View {
        ExplicitAnimation()
    }
}
