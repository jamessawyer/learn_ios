//
//  ContentView.swift
//  Chanllenge01 RockPaperScissors
//
//  Day 25 of 100DaysOfSwiftUI Chanllenge 1
//  https://www.hackingwithswift.com/guide/ios-swiftui/2/3/challenge
//  未处理情况就是 选择一样结果的情况

import SwiftUI

struct ContentView: View {
    let moves = ["Rock", "Paper", "Scissors"]
    let max_round = 10 // 比赛的场次
    
    @State private var round = 0 // 比赛的场次
    @State private var currentMove = Int.random(in: 0 ... 2) // 机器随机选择的数字
    @State private var isWannaWin = Bool.random() // 是否希望赢
    @State private var score = 0 // 最后得分
    @State private var showAlert = false // 是否显示弹窗
    @State private var gameResult = "" // Alert title
    @State private var alertMessage = "" // alert content
    
    var body: some View {
        VStack(spacing: 40) {
            HStack(spacing: 20) {
                Text("Robot move:")
                Text(moves[currentMove])
                    .foregroundColor(Color.red)
                    .font(.largeTitle)

            }
            
            Text("You want to \(isWannaWin ? "win" : "lose")")
                .font(.largeTitle)
            
            HStack(spacing: 30) {
                ForEach(0 ..< self.moves.count) { index in
                    Button(self.moves[index]) {
                        self.onPressButton(selectIndex: index)
                    }
                    .frame(width: 80, height: 34)
                    .foregroundColor(Color.white)
                    .background(Color.red)
                    .cornerRadius(10)
                }
            }
            if round ==  max_round {
                // 如果游戏结束 则显示最后的得分
                //https://stackoverflow.com/questions/56490250/dynamically-hiding-view-in-swiftui
                Text("Your score is: \(score)")
            }
            
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(gameResult), message: Text(alertMessage), dismissButton: .default(Text("Continue")) {
                self.continueGame()
            })
        }
    }
    
    // 显示提示框 表示是否用户回答正确
    func onPressButton(selectIndex: Int) {
        if round == max_round {
            // 如果大于了最大次数则结束游戏
            gameResult = "Notice"
            alertMessage = "GAME IS OVER!"
            showAlert = true
            return
        }
        let result = whetherUserWin(current: currentMove, select: selectIndex)
        
        if isWannaWin == result {
            // 如果选择想赢 最后结果也是赢了 则加1分
            // 或者选择了想输 最后结果也是输了 则也加1分
            score += 1
            gameResult = "Correct"
            alertMessage = "You're so bright!"
        } else {
            score -= 1
            gameResult = "Wrong"
            alertMessage = "Sorry!"
        }
        showAlert = true
    }
    
    /// 是否用户赢得了机器人
    func whetherUserWin(current: Int, select: Int) -> Bool {
        switch current {
        case 0:
            // 如果机器人选的是 石头， 用户选择 布 才能赢
            return select == 1
        case 1:
            return select == 2
        case 2:
            return select == 0
        default:
            return false
        }
    }
    
    func continueGame() {
        if round == max_round {
            return
        }
        currentMove = Int.random(in: 0 ... 2)
        isWannaWin = Bool.random()
        round += 1 // 每次游戏结束 回合加1
        print("isWannaWin: \(isWannaWin)")
        print("比赛的场次: \(round)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
