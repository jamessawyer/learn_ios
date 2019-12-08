// 26-28 Day of 100DaysOfSwiftUI
// https://www.hackingwithswift.com/100/swiftui/26
// https://www.hackingwithswift.com/100/swiftui/27
// https://www.hackingwithswift.com/books/ios-swiftui/betterrest-wrap-up
// challenge参考 https://github.com/roblack/100DaysOfSwiftUI/blob/master/BetterRest/BetterRest/ContentView.swift
//  ContentView.swift
//  Project04 BetterRest
//

/// 知识点
/// 1. Date 和 DateComponents 的使用
/// 2. Calender 的使用
/// 3. DateFormatter 的用法
/// 4. 几个组件：DatePicker & DatePicker 在Form 中的样式变化 & Stepper
/// 5. static 静态属性赋值给 @State private var 属性
/// 6. 双向绑定实际运作机理 和 Binding

/// 复习的知识点
/// 1. Section 的使用
/// 2. Picker 的使用
/// 3. NavigationView & navigationBarTitle

import SwiftUI

struct ContentView: View {
    // 这里需要使用 static 将 defaultWakeUpDate设置为静态属性 否则无法复制给 wakeUp
    // 一个属性访问另一个属性 因为swift无法得知哪一个属性将先被创建 因此不用static将其变为静态属性 则编译错误
    // 变为静态属性后 这个属性属于 ContentView 而不依赖实例
    static var defaultWakeUpDate: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    @State private var wakeUp = defaultWakeUpDate
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var msgTitle = ""
    @State private var msgContent = ""
    @State private var isShow = false
    
    var bedTime: String {
        calculateBedtime()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("When do you want to wake up?").font(.headline)) {
                        
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(WheelDatePickerStyle()) // 表示将日期选择器直接显示
                        // 如果不直接显示 在Form中 显示后再隐藏DatePicker 存在动画的bug
                    }
                    Section(header: Text("Desired amount of sleep").font(.headline)) {
                        Stepper(value: $sleepAmount, in: 4 ... 12, step: 0.25) {
                            Text("\(sleepAmount, specifier: "%g") hours")
                        }
                    }
                    Section(header: Text("Daily coffee intake").font(.headline)) {
                        Picker("", selection: $coffeeAmount) {
                            /// ForEach 里面的 Range 和 ClosedRange 的区别
                            ///https://stackoverflow.com/questions/59082927/swiftui-foreach-open-vs-closed-range
                            ForEach(1...20, id: \.self) { num in
                                num == 1 ? Text("\(num) cup") : Text("\(num) cups")
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity, maxHeight: 150)
                    }
                }
                .alert(isPresented: $isShow) {
                    Alert(title: Text(msgTitle), message: Text(msgContent), dismissButton: .default(Text("OK!")))
                }
                
                VStack {
                    Text("Optimal bedtime")
                    Text("\(bedTime)")
                    .font(.largeTitle)
                    .fontWeight(.black)
                }
            }
            .navigationBarTitle("BetterRest")
        }
    }
    
    func calculateBedtime() -> String {
        // ML model
        let model = SleepCalculator()
        
        let components: DateComponents = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        // 换算成 秒
        let hours = (components.hour ?? 0) * 60 * 60
        let minutes = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hours + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            // Swift 中 可以直接使用 Date - 秒  得到一个Date 对象
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            
//            msgTitle = "Your ideal bedtime is..."
//            msgContent = formatter.string(from: sleepTime)
            
            return formatter.string(from: sleepTime)
        } catch {
            isShow = true
            msgTitle = "Error"
            msgContent = "Sorry, there is something wrong with calculating bedtime"
            return ""
        }
        
        
    }
}


//struct ContentView: View {
//    @State private var wakeUp = Date()
//    let now = Date()
//    let tomorrow = Date().addingTimeInterval(86400) // 添加一天的事件
//
//
//    var body: some View {
//
//        /// DateComponents
//        // 设置时间
//        var components = DateComponents()
//        components.hour = 8
//        components.minute = 0
//        let date = Calendar.current.date(from: components) ?? Date()
//
//        /// Calendar
//        // 解析时间
//        let parsedDate = Calendar.current.dateComponents([.hour, .minute], from: Date())
//        let hour = parsedDate.hour ?? 0
//        let minute = parsedDate.minute ?? 0
//
//        /// DateFormatter
//        // Date 转换为 String 类型
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        let dateString = formatter.string(from: Date())
//
//        print("\(hour) : \(minute)")
//        print("dateString: \(dateString)")
//        return DatePicker("Please enter a date", selection: $wakeUp, in: now...)
//    }
//
//}

//struct ContentView: View {
//    @State private var wakeUp = Date()
//    let now = Date()
//    let tomorrow = Date().addingTimeInterval(86400) // 添加一天的事件
//
//
//    var body: some View {
//        let range = now ... tomorrow
//        // 限定事件范围
////        return DatePicker("Please enter a date", selection: $wakeUp, in: range)
//        // 除了上面指定一个范围外 还可以指定一个下限 上限则不进行限定
//        return DatePicker("Please enter a date", selection: $wakeUp, in: now...)
//    }
//
//    /// displayeedComponents 显示的时间
////    var body: some View {
////        // displayedComponents: .hourAndMinute 只显示小时和分钟
////        DatePicker("Please enter a date", selection: $wakeUp, displayedComponents: .hourAndMinute)
////    }
//
//      /// 插入一个 Form 中 样式发生变化
////    var body: some View {
////        Form {
////            DatePicker("Please enter a date", selection: $wakeUp)
////        }
////    }
//    /// 使用 .labelsHidden modifier 隐藏label
////    var body: some View {
////        DatePicker("Please enter a date", selection: $wakeUp)
////        .labelsHidden()
////    }
//}

/// Stepper 的使用
//struct ContentView: View {
//    @State private var sleepAmount = 8.0
//    var body: some View {
//        Stepper(value: $sleepAmount, in: 4 ... 12, step: 0.25) {
//            // "%g" 如果小数点后面不是0 则保留2位小数 如果是0 则将小数点后面的数字去除
//            Text("\(sleepAmount, specifier: "%g") hours")
//        }
//    }
//}

/// 双向绑定内部运作机制  Binging 关键词
/// https://www.hackingwithswift.com/guide/ios-swiftui/2/2/key-points
//struct ContentView: View {
//    @State private var agreedToTerms = false
//    @State private var agreedToPrivacyPolicy = false
//    @State private var agreedToEmails = false
//
//
//    var body: some View {
//        let agreedToAll = Binding<Bool>(
//            get: {
//                self.agreedToTerms && self.agreedToPrivacyPolicy && self.agreedToEmails
//            },
//            set: {
//                // $0 表示 agreedToAll 本身的值
//                self.agreedToTerms = $0
//                self.agreedToPrivacyPolicy = $0
//                self.agreedToEmails = $0
//            }
//        )
//        return VStack {
//            Toggle(isOn: $agreedToTerms) {
//                Text("Agree to terms")
//            }
//            Toggle(isOn: $agreedToPrivacyPolicy) {
//                Text("Agree to privacy policy")
//            }
//            Toggle(isOn: $agreedToEmails) {
//                Text("Agree to receive shipping emails")
//            }
//            Toggle(isOn: agreedToAll) {
//                Text("Agree to all")
//            }
//        }
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
