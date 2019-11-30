//
//  ContentView.swift
//  Project02 GuessTheFlags
//
//  Created by lucian on 2019/11/27.
//  Copyright © 2019 oscar. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Monaco", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2) // 产生一个0-2之间的随机值
    @State private var showAlert = false // 是否显示Alert
    @State private var scoreTitle = ""
    @State private var score = 0
    @State private var alertMessage = ""

    
    var body: some View {
        
        ZStack {
//            Color.blue.edgesIgnoringSafeArea(.all)
            LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                VStack {
                    Text("Select a country")
                        .foregroundColor(Color.white)
                    
                    Text("\(countries[correctAnswer])")
                        .foregroundColor(Color.white)
                        .font(.largeTitle)
                        .fontWeight(.black)
                }
                
               
                ForEach (0 ..< 3) { number in
                    Button(action: {
                        self.flagTapped(number)
                    }) {
                        Image(self.countries[number])
                            .renderingMode(.original)
                            .clipShape(Capsule()) // 4种形状 rectangle | rounded rectangle | capsule | circle
                            .overlay(Capsule().stroke(Color.black, lineWidth: 1)) // 使用 overlay 绘制一个border
                            .shadow(color: .black, radius: 2)
                    }
                    
                }
                
                Text("Your score: \(score)")
                    .foregroundColor(.white)
                    
                
                Spacer()
                
            }
        }
        .alert(isPresented: $showAlert) { // 此处使用双向绑定 在dismiss之后 自动回会设置为false
            Alert(title: Text(scoreTitle), message: Text("\(alertMessage)"), dismissButton: .default(Text("Continue")) {
                self.askQuestion()
            })
        }
    }
    
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct"
            score += 1
            alertMessage = "You're so bright!"
        } else {
            scoreTitle = "Wrong"
            alertMessage = "Wrong! That’s the flag of \(countries[number])"
        }
        
        showAlert = true
    }
    
    // 每次确认完答案之后
    func askQuestion() {
        countries = countries.shuffled() // 将国家顺序进行混淆
        correctAnswer = Int.random(in: 0 ... 2)
    }
        
//        Button(action: {
//            print("Click me")
//        }) {
//            HStack(spacing: 20) {
//                Text("Fake Icon")
//                Text("main")
//            }
//            .padding(EdgeInsets(top: 20, leading: 50, bottom: 20, trailing: 50))
//
//            // .padding([.horzontal], 50) 表示水平方向是50
//            // .padding(50) 表示所有方向都是50
//            // 如果同时定义水平和垂直方向的padding
//        }
//        .background(Color.red)
        
        
//        VStack {
//            Text("green")
//                .frame(width: 200, height: 50, alignment: .center)
//                .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.yellow]), startPoint: .leading, endPoint: .trailing))
//                .cornerRadius(25)
//        }
        
//        LinearGradient(gradient: Gradient(colors: [Color.blue, Color.pink]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
        
//        RadialGradient(gradient: Gradient(colors: [Color.blue, Color.yellow]), center: .center, startRadius: 30, endRadius: 240)
        
//        AngularGradient(gradient: Gradient(colors: [Color.red, Color.green, Color.pink, Color.gray]), center: .center)
        
//        ZStack {
//            Color.red.edgesIgnoringSafeArea(.all)
//            Text("hello")
//
//        }
        
        
//        ZStack {
//
        //           Text("中间人")
//            .foregroundColor(.white)
//
//       }
//        VStack(spacing: 20) {
//            Text("Hello World")
//                .foregroundColor(.yellow)
//                .font(Font.system(size: 40))
//
//
//
//            HStack(alignment: .top) {
//                Text("Hello great")
//                Text("我是")
//            }
//
//        }
        
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
