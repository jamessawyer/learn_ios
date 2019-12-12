项目4 [BetterRest](https://github.com/jamessawyer/learn_ios/blob/master/SwiftUIProjects/Project04%20BetterRest/Project04%20BetterRest/ContentView.swift) 项目中涉及的知识点:

1. **`Date`** & **`DateComponents`**  & **`DateFormatter`** & **`Calender`** 日期时间相关的接口
2. **`DatePicker`** 和 **`Stepper`** 组件
3. 双向绑定的原理:  **`Binding`**
4. 为什么需要使用 **`static `** 静态属性 赋值为 结构体中其它属性



> 1. 日期时间相关的接口

日期和时间是一个比较复杂的类型，Swift通过提供的APIs对时间类提供了很好的封装：

1. **`Date`**： 用于创建一个时间
2. **`DateFormatter`**: 用于对时间进行格式化，可以将 **`Date`** 类型转换为 **`String`** 类型，或者 **`String`** 类型转换为 **`Date`** 类型
3. **`DateComponents`**: 用于将时间拆分为小的组件，比如 **`year | month | day | hour | minute | second`** 等等
4. **`Calender`**: 用于进行 **`Date`** 和 **`DateComponents`** 之间的转换

**`Date`**:

说到时间就要注意 **时区** 的问题。创建时间的方式有：

```swift
init()
init(timeIntervalSinceNow: TimeInterval)
init(timeIntervalSince1970: TimeInterval)
init(timeInterval: TimeInterval, since date: Date)
init(timeIntervalSinceReferenceDate ti: TimeInterval)
```

示例：

```swift
let date1 = Date()
// 2019-12-12 00:38:30 +000

let date2 = Date(timeIntervalSinceNow: 5)
// 当前时间+5秒

// UTC 时间
// 以 1970-1-1 00:00:00 为起点
let date3 = Date(timeIntervalSince1970: 0)

// 根据给定时间 增加多少秒
// 当前表示当前时间+2s
// 和 date2 很像 date2默认给定当前时间为 Date()
let date4 = Date(timeInterval: 2, since: Date())
```

还有一些 Date 相关的属性：

1. **`timeIntervalSinceNow`**: 表示给定时间距离当前时间的时间间隔
2. **`timeIntervalSince1970`**: 返回当前时间距1970-1-1 00:00:00 的时间差



**`DateFormatter`**:

用于 Date 和 String 之间的转换

```swift
func string(from date: Date) -> String
func date(from string: String) -> Date?
```

格式化和样式：

```swift
var dateFormat: String! // 自定义时间格式 用的比较多
var dateStyle: DateFormatter.Style // 年月日 格式
var timeStyle: DateFormatter.Style // 时分秒 格式

// 其中 DateFormatter.Style 是一个枚举
extension DateFormatter {
  enum Style: UInt {
    case none
    case short
    case medium
    case long
    case full
  }
}
```

示例：

```swift
let date = Date()
let formatter = DateFormatter()
formatter.dateStyle = .full
formatter.dateStyle = .full

// Date -> String
let dateString = formatter.string(from: date)
// "Thursday, December 12, 2019 at 12:48:11 AM China Standard Time"

// 还可以自定义格式化 可以自定义各种格式
formatter.dateFormatter = "yyyy-MM-dd HH:mm:ss"
// 2019-12-12 00:48:11
```

时间戳和时间之间的转换：

```swift
// Date -> TimeInterval
let now = Date()
// 当前时间的时间戳
let timeInterval: TimeInterval = now.timeIntervalSince1970
let timeStamp = Int(timeInterval)

// 时间戳 -> Date
let timeStamp = 1553677582
let timeInterval = TimeInterval(timeStamp)
let date = Date(timeIntervalSince1970: timeInterval)
```



**`DateComponents & Calender`**:

将日期进行拆分， **`Calender`** 用于 **`Date`** 和 **`DateComponents`** 之间的转换

```swift
// Date -> DateComponents
let calender = Calender.current

let currentDate = Date()
let dateComponents = calender.dateComponents(
  [.year, .month, .day, .hour, .minute, .second],
  from: currentDate
)
// 获取时间各个部分
year: dateComponents.year  // 返回一个 Int? 类型
month: dateComponents.month
// ...

// DateComponents -> Date
var dc = DateComponents()
dc.day = 12
dc.month = 12
dc.year = 2019
dc.hour = 0
dc.minute = 59
dc.second = 16
let date = calender.date(from: dc)
print(date!)
```

swift日期相关的文章：

1. [iOS swift Date 相关用法 - 简书](https://www.jianshu.com/p/487d65628e48)
2. [DateFormatter 轻度优化 - 掘金](https://juejin.im/post/5c171582518825138d261943)
3. [SwiftDate 日期开源库 - github](https://github.com/malcommac/SwiftDate)
4. [Computing dates in swift - swiftbysundell](https://www.swiftbysundell.com/articles/computing-dates-in-swift/)



> 2. DatePicker 和 Stepper 组件



**`DatePicker`**:

日期选择器是常用的一种组件，主要用法如下：

```swift
struct ContentView: View {
  @State private var wakeUp = Date()
  
  var body: some View {
    DatePicker(
    	"Please enter a time",
    	selection: $wakeUp,
    	// 只显示 hour 和 minute
    	displayedComponents: .hourAndMinute
    )
    .labelsHidden() // 隐藏前面的label
    .datePickerStyle(WheelDatePickerStyle()) // 显示组件 组要用于 Form 中
  }
}
```

注意 **`DatePicker`** 如果在 **`Form`** 组件中， 默认是不显示选择器的，点击表单后才显示。 添加 **`datePickerStyle`** 之后表示常显示.

另外还可以限定选择时间的范围：

```swift
struct ContentView: View {
  @State private var wakeUp = Date()
  let now = Date()
  let tomorrow = now.addingTimeInterval(24 * 60 * 60)
  
  var body: some View {
    let dateRange = now ... tomorrow
    DatePicker(
    	"Please enter a time",
    	selection: $wakeUp,
    	in: dateRange
//    	in: now ...  // 或者只指定一个下限 没有上限
    )
  }
}
```



**`Stepper`**

表示一个区间范围选择，可以指定跨度

```swift
struct ContentView: View {
  @State private var sleepHours = 8.0
  
  var body: some View {
    Stepper(
    	value: $sleepHours,
    	in: 4 ... 12, // 限定选择区间
    	step: 0.25
    ) {
      Text("\(sleepHours, specifier: "%g") hours")
    }
  }
}
```



> 3. 双向绑定： Binding

前面提到双向绑定，我们都是直接使用 **`$`** 进行绑定。本质上可以使用 **`Binding`** ：

```swift
struct ContentView: View {
  @State private var agreedToTerms = false
  @State private var agreedToPrivacyPolicy = false
  @State private var agreedToEmails = false
  
  var body: some View {
  	// 一个按钮 表示 全部同意
  	let agreeToAll = Binding<Bool>(
			get: {
				self.agreedToTerms && self.agreeToPrivacyPolicy && self.agreedToEmails
			},
			set: {
        // $0 表示 agreedToAll 本身的值
        self.agreedToTerms = $0
        self.agreeToPrivacyPolicy = $0
        self.agreedToEmails = $0
			}
		)
		
		return VStack {
			// 使用双向绑定
      Toggle(isOn: $agreeToTerms) {
				Text("agree to terms")
			}
			Toggle(isOn: $agreeToPrivacyPolicy) {
				Text("agree to privacy policy")
			}
			Toggle(isOn: $agreedToEmails) {
				Text("agree to emails")
			}
			
			// 使用 Binding 进行绑定
			Toggle(isOn: agreeToAll) {
				Text("agree to all")
			}
		}
  }
}
```

具体参考：

- [Working with Bindings - hackingWithSwiftUI](https://www.hackingwithswift.com/guide/ios-swiftui/2/2/key-points)



> 4. 为什么需要使用static赋值给结构体中其它属性

如果结构体中一个属性依赖另一个属性，直接进行引用会抛出错误，这是因为 **属性的创建的先后顺序是不知道，而使用 `static` 变为静态属性，不依赖实例，则不受这种约束**

```swift
// Error 因为属性创建的先后顺序不确定
struct ContentView: View {
  var defaultWakeUpDate: Date {
    var components = DateComponents()
    components.hour = 7
    components.minute = 0
    return Calender.current.date(from: components) ?? Date()
  }
  @State private var wakeUp = defaultWakeUpDate
}

// OK
// 使用静态属性 不依赖属性实例化
struct ContentView: View {
  static var defaultWakeUpDate: Date {
    var components = DateComponents()
    components.hour = 7
    components.minute = 0
    return Calender.current.date(from: components) ?? Date()
  }
  @State private var wakeUp = defaultWakeUpDate
}
```



来源：

- [26-28 Day of 100DaysOfSwiftUI ](https://www.hackingwithswift.com/100/swiftui/26)



2019年12月12日01:30:46





