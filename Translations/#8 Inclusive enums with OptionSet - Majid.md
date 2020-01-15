原文链接：

- [Inclusive enums with OptionSet](https://swiftwithmajid.com/2019/04/10/inclusive-enums-with-optionset/)

知识点：

1. 枚举服从 **`OptionSet`** 协议，轻松处理枚举成员union的情形



枚举是swift的一个很强大特性，多用于表示多种cases在任何时候，只存在唯一的情况（可参考 [Maintaining State in Your ViewController](https://github.com/jamessawyer/learn_ios/blob/master/Translations/%234%20Maintaining%20State%20in%20Your%20ViewController%20-%20Majid.md)）。如果我们想要同时存在多种cases的情形怎么办呢？**答案是使用 `OptionSet` 协议**。



> 唯一性枚举(Exclusive Enums)

假设我们某个 **`HistoryFetcher`** 类，用于从缓存（`cache`）或者网络或者同时从缓存和网络中获取数据。

```swift
enum FetchSource {
  case memory
  case disk
  case remote
  case cache
  case all
}
```

根据资源的来源我们可以定义下面的 `fetch` 方法：

```swift
class HistoryFetcher {
  func fetch(
  	from source: FetchSource = .all,
  	handler: @escaping Handler<History>
  ) {
    switch source {
    case .memory:
    	fetchMemory(handler: handler)
    case .disk:
    	fetchDisk(handler: handler)
    case .remote:
    	fetchRomote(handler: handler)
    case .cache:
    	fetchMemory(handler: handler)
    	fetchDisk(handler: handler)
    case .all:
    	fetchMemory(handler: handler)
    	fetchDisk(handler: handler)
    	fetchRemote(handler: handler)
    }
  }
}
```

使用上面这种方式有几个缺点：

1. 如果我们增加 **`FetchSource`** 的种类，我们必须在单独的添加一个 **`case`** 语句，同时还需要在 **`.all`** 中添加函数
2. 创建多种 sources 交叉的情况，很不方便，比如同时从memory和remote 或者 disk和remote来获取，需要添加额外的逻辑去处理.

> **OptionSet 来解决上面的困扰** 

**`OptionSet`** 一个表示 **`bitset`** 类型的协议，其中单独的 **`bits`** 表示set中成员。对自定义类型采用这个协议，可以使用set相关的操作，比如对这些类型进行 **`tests & unions & intersections`**。

**OptionSet 协议只需要一个服从 `FixedWidthInteger` 协议（通常使用 `Int` 即可）的 `rawValue` 属性**

```swift
struct FetchSource: OptionSet {
  let rawValue: Int
  
  /// << 即移位运算符
  static let memory = FetchSource(rawValue: 1 << 0)
  static let disk = FetchSource(rawValue: 1 << 1)
  static let remote = FetchSource(rawValue: 1 << 2)
  
  // 表示同时从memory和disk中获取
  static let cache: FetchSource = [.memory, .disk]
  // 直接使用 .cache
  // 表示从 memory & disk & remote中获取
  static let all: FetchSource = [.cache, .remote]
}
```

可以看出创建多个 **union members** 非常的容易。

接着重构上面的 **`HistoryFetcher`**:

```swift
class HistoryFetcher {
  func fetch(
  	from source: FetchSource = .all,
  	handler: @escaping Handler<History>
  ) {
    if source.contains(.memory) {
      fetchMemory(handler: handler)
    }
    
    if source.contains(.disk) {
      fetchDisk(handler: handler)
    }
    
    if source.contains(.remote) {
      fetchRemote(handler: handler)
    }
  }
}
```

再添加新的source类型进行组合就十分的方便了。



2020年01月15日23:41:33