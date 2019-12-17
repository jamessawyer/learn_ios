//  https://www.hackingwithswift.com/books/ios-swiftui/animating-gestures
//  GestureAnimation1.swift
//  Project06 Animations
//
//  Created on 2019/12/18.
//  Copyright © 2019 oscar. All rights reserved.
//

import SwiftUI

/// DragGesture的使用 详细知识点参见 GestureAnimation2
struct GestureAnimation1: View {
    @State private var dragAmount = CGSize.zero // 手势拖动量
    /// 方式1 使用显式动画
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing)
        .frame(width: 300, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .offset(dragAmount)
        .gesture(
            DragGesture()
                .onChanged {
                    self.dragAmount = $0.translation
                }
                .onEnded { _ in
                    /// 使用显式动画
                    withAnimation(.spring()) {
                        self.dragAmount = CGSize.zero // 回到原来的位置
                    }
                }
        )
    }
    /// 方式2 使用隐式动画
//    var body: some View {
//        LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing)
//        .frame(width: 300, height: 200)
//        .clipShape(RoundedRectangle(cornerRadius: 10))
//        .offset(dragAmount)
//        .gesture(
//            DragGesture()
//                .onChanged {
//                    self.dragAmount = $0.translation
//                }
//                .onEnded { _ in
//                    self.dragAmount = CGSize.zero // 回到原来的位置
//                }
//        )
//        .animation(.spring()) // 隐式动画
//    }
}

struct GestureAnimation1_Previews: PreviewProvider {
    static var previews: some View {
        GestureAnimation1()
    }
}
