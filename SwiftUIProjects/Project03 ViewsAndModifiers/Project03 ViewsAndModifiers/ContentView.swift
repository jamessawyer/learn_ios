//
//  ContentView.swift
//  Project03 ViewsAndModifiers
//
//  Created by lucian on 2019/12/1.
//  Copyright © 2019 oscar. All rights reserved.
//

import SwiftUI

// 自定义容器 方式2
struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content
    
    var body: some View {
        VStack {
            ForEach(0 ..< rows) { row in
                HStack {
                    ForEach(0 ..< self.columns) { column in
                        self.content(row, column)
                    }
                }
            }
        }
    }
    
    
    // @ViewBuilder ??
    // @escaping 表示逃逸闭包 用于将闭包进行存储 稍后再使用
    init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.content = content
    }
}

struct ContentView: View {
    var body: some View {
        // 使用自定义容器方式2
        // 会隐式的创建一个 HStack
        GridStack(rows: 4, columns: 4) { row, column in
            Image(systemName: "\(row * 4 + column).circle")
            Text("R\(row) C\(column)")

        }

//        GridStack(rows: 4, columns: 4) { row, column in
//            HStack {
//                Image(systemName: "\(row * 4 + column).circle")
//                Text("R\(row) C\(column)")
//            }
//        }
    }
}


// 自定义容器 方式1
//struct GridStack<Content: View>: View {
//    let rows: Int
//    let columns: Int
//    let content: (Int, Int) -> Content
//
//    var body: some View {
//        VStack {
//            ForEach(0 ..< rows) { row in
//                HStack {
//                    ForEach(0 ..< self.columns) { column in
//                        self.content(row, column)
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct ContentView: View {
//    var body: some View {
//        GridStack(rows: 4, columns: 4) { row, column in
//            HStack {
//                Image(systemName: "\(row * 4 + column).circle")
//                Text("R\(row) C\(column)")
//            }
//        }
//    }
//}

/// 自定义修饰符 1
struct Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(Color.white)
            .padding()
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
extension View {
    func textStyle() -> some View {
        self.modifier(Title())
    }
}
// 自定义修饰符 2
struct Watermark: ViewModifier {
    var text: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
            Text(text)
                .foregroundColor(.white)
                .padding(5)
                .background(Color.black)
        }
    }
}
extension View {
    func watermarked(with text: String) -> some View {
        self.modifier(Watermark(text: text))
    }
}

struct RedBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            Color.red.edgesIgnoringSafeArea(.all)
            content
        }
    }
}
extension View {
    func redBackground() -> some View {
        self.modifier(RedBackground())
    }
}

// https://www.hackingwithswift.com/books/ios-swiftui/views-and-modifiers-wrap-up
// challenge 1
// Create a custom ViewModifier (and accompanying View extension) that makes a view have a large, blue font suitable for prominent titles in a view.
struct LargeTextTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.blue)
            .font(.largeTitle)
    }
}
extension View {
    func largeTextTitle() -> some View {
        self.modifier(LargeTextTitle())
    }
}




//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Text("Swift")
//            Text("Hello")
//                .foregroundColor(Color.white)
//        }.redBackground()
//    }
//}



//Text("Hello")
//.modifier(Title())
//
//Text("World")
//.textStyle()
//
//Color.blue
//    .frame(width: 300, height: 200)
//    .watermarked(with: "hacking with swiftui")

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}
