//  https://www.hackingwithswift.com/books/ios-swiftui/animating-gestures
//  GestureAnimation2.swift
//  Project06 Animations
//
//  Created on 2019/12/18.
//  Copyright © 2019 oscar. All rights reserved.
//

import SwiftUI

/// 6. 手势和动画相结合的示例 比较炫酷的动画效果
///  6.1 offset() | offset(offset: CGSize) 可以让视图位置进行移动
///  6.2 .gesture() modifier
///  6.3 DragGesture() 自身可以添加2个修饰符： onChange {}  & onEnded {} 可用于更新手势位置和视图位置
///  6.4 Animation.defalut.delay() 动画添加一个延迟
struct GestureAnimation2: View {
    let letters = Array("Hello SwiftUI")
    @State private var enabled = false
    @State private var dragAmount = CGSize.zero

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< letters.count) { num in
                Text(String(self.letters[num]))
                    .padding(5)
                    .font(.title)
                    .background(self.enabled ? Color.red : Color.blue)
                    .offset(self.dragAmount)
                    .animation(Animation.default.delay(Double(num) / 20)) // 添加一个延迟效果
            }
        }
        .gesture(
            DragGesture()
                .onChanged {
                    self.dragAmount = $0.translation
            }
            .onEnded { end in
                print("end", end)
                self.dragAmount = .zero
                self.enabled.toggle()
            }
        )
    }
}

struct GestureAnimation2_Previews: PreviewProvider {
    static var previews: some View {
        GestureAnimation2()
    }
}
