  
// 29-31 Day of 100DaysOfSwiftUI
// https://www.hackingwithswift.com/100/swiftui/29
//
//  ContentView.swift
//  Project05 WordScramble
//
//  Created on 2019/12/12.
//  Copyright © 2019 oscar. All rights reserved.
//
  
/// 知识点
/// 1. List 的使用，创建列表的多种方式
/// 2. Bundle.main.url(forResource: String, withExtension: String): 获取打包后的资源文件地址 ✨
/// 3. String 相关的方法:
///     3.1 lowercased(): 将字符串转换为小写
///     3.2 trimmingCharacters(in: .whitespacesAndNewlines): 删除字符串开始和尾部空格和换行符等
///     3.3 components(separatedBy: "\n"): 将字符串按照某个字符进行分割 返回一个字符串数组
///     3.4 String(contentOf: URL): 读取某个路径下的文件，并返回为可选字符串 ✨
///     3.5 firstIndex(of: Character): 返回某个字符首次出现的位置
///     3.6 count | string.utf16.count: 返回字符串的长度 或 编码为utf16时的计算长度
/// 4.数组相关的属性和方法：
///     4.1 insert(newElement: Element, at: Int): 在指定索引位置插入一个新的元素
///     4.2 randomElement(): 随机返回数组中的某个元素，可能返回nil
///     4.3 count: 数组的长度
///     4.4 contains(someElement: Element): 是否包含某个元素
/// 5. UITextChecker: 单词拼写检查 使用OC实现， 需要使用到 NSRange
/// 6. fatalError(): 抛出错误 直接终止程序
/// 7. .onAppear(): 生命周期修饰符 ✨
  
/// 复习的知识点
/// 1.  .alert 修饰符的使用
/// 2. guard let 解包语句的使用
/// 3. NavigationView & navigationBarTitle & navigationBarItems

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var isShowAlert = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
                List(usedWords, id: \.self) {
                    /// SF symbols 添加一个带数字的⭕️
                    Image(systemName: "\($0.count).circle")
                    Text("\($0)")
                }
                
                Text("得分: \(score)")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(leading: Button(action: startGame, label: {
                Text("换一个词")
            }))
            .onAppear(perform: startGame) /// 生命周期
            .alert(isPresented: $isShowAlert) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // 添加新的词语
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "单词已经存在", message: "来点原创的吧")
            return
        }
        
        guard isLongEnough(word: answer) else {
            wordError(title: "单词太短了", message: "单词不能少于3个字符")
            return
        }
        
        guard isDiffientWord(word: answer) else {
            wordError(title: "抄袭", message: "不能和给定的单词一样")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "单词不能被识别", message: "不要自己编造单词")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "这不是一个真的单词")
            return
        }

        usedWords.insert(answer, at: 0) // 将新的元素添加的数组的开头
        score += 1 // 输入成功+1分
        newWord = "" // 然后将输入框清空
    }
    
    // 开始加载文件
    func startGame() {
        if let stringUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let stringWords = try? String(contentsOf: stringUrl) {
                let allWords = stringWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    /// 对输入的单词进行校验
    /// 1.是否已经存在该单词
    /// 2.输入的单词是否可以由 随机产生的rootWord 中的字母组成一个新的单词
    /// 3.单词是否存在拼写错误
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    // 比如rootWord是 dentally
    // 输入的为tall 则满足要求
    // 输入 apple 则 不能满足要求
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    // 不能少于3个字符
    func isLongEnough(word: String) -> Bool {
        return word.count > 3
    }
    
    // 不能和rootWord一样
    func isDiffientWord(word: String) -> Bool {
        return word != rootWord
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        isShowAlert = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
