原文链接：

- [Hiding third party dependencies with protocols and extensions](https://swiftwithmajid.com/2019/02/13/hiding-third-party-dependencies-with-protocols-and-extensions/)

知识点：

1. 如果使用扩展，对第3方插件方法再封装，节省重构成本
2. 让第3方插件使用自定义协议，对第3方插件的具体实现进行隐藏
3. 依赖注入



有时候我们可能碰到第三方插件停止维护的情况，导致有时候需要更换别的第3方插件的情况，如果更换项目中所有使用到的旧的第三方插件，这样不仅很麻烦，也很容易出错。

下面2种方式可以很好的帮助我们隐藏第3方依赖，使替换和重构变得十分的方便。



> 1. 使用扩展

比如，我们经常会使用 [Kingfisher](https://github.com/onevcat/Kingfisher) 这个库对网络图片进行下载缓存。Kingfisher中 **`UIImageView`** 有一个 扩展方法 **`setImage`** 。在项目中，我们很方便的使用 **`kf.setImage(with:URL)`** 这个方法。

假设，现在我们将 **`Kingfisher`** 更换为另一个第3方插件 **`AlamofireImage`** 。如果像上面说的一样，在项目中到处使用 **`kf.setImage(with:URL)`** 这个方法，现在进行替换，则会很不方便。为了解决这个问题，我们可以使用扩展的方式，对 **`kf.setImage(with:URL)`** 进行封装：

```swift
import UIKit
import Kingfisher

extension UIImageView {
  func setImage(from url: URL) {
    kf.setImage(with: url)
  }
}
```

在项目中我们可以这样使用：

```swift
let imageView = UIImageView()
imageView.setImage(from: "https://www.pic.com/some.png")
```

**现在如果我们更换了Kingfisher这个库，我们只需要在扩展的位置进行更改即可**



> 2. 使用协议

再比如我们依赖第3方 [KeychainSwift](https://github.com/evgenyneu/keychain-swift) 库对敏感数据进行加密存储:

```swift
let keychain = KeychainSwift()
keychain.set("hello world", forKey: "my key") // 加密存储
keychain.get("my key") // 返回 "hello world"
```

如果我们不想在代码中导出都这样写，我们可以通过协议的方式将其具体使用过程进行隐藏：

```swift
protocol TokenStore {
  var accessToken: String { get set }
  var refreshToken: String { get set }
}
```

然后 **`KeychainSwift`** 采用上面的协议：

```swift
extension KeychainSwift: TokenStore {
  private enum Keys {
    static let accessToken = "accessToken"
    static let refreshToken = "refreshToken"
  }
  
  var accessToken: String {
    get { return get(Keys.accessToken) // 此处get是 KeychainSwift中的方法 }
    set {
      set(newValue, forKey: Keys.accessToken) // 此处set是KeychainSwift中的方法
    }
  }
  
  var refreshToken: String {
    get { return get(Keys.refreshToken) }
    set {
      set(newValue, forKey: Keys.refreshToken)
    }
  }
}
```

现在我们可以在代码中使用 **`TokenStore`** 协议，而不用直接使用 **`KeychainSwift`**:

```swift
class AuthenticationService {
  private let tokenStore: TokenStore
  
  // 依赖注入
  init(tokenStore: TokenStore) {
    self.tokenStore = tokenStore
  }
  
  func fetchToken(for credentials: Credentials) {
    // 在此保存tokens
    // tokenStore.accessToken = 
    // tokenStore.refreshToken = 
  }
}
```

