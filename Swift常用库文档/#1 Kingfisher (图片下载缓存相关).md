- [Kingfisher 5.13.2](https://github.com/onevcat/Kingfisher)

- [Kingfisher Cheatsheet 翻译来源](https://github.com/onevcat/Kingfisher/wiki/Cheat-Sheet)

- [API References - 如果想深入了解](https://onevcat.github.io/Kingfisher/)

- [Kingfisher 源码导读 - 掘金](https://juejin.im/post/5e47b517e51d452703135c6b)


功能：

- 异步图片下载和缓存
- 通过 **`URLSession`** 或者 本地提供的数据加载图片
- 提供图片处理和滤镜效果
- 提供多层缓存机制，内存和磁盘
- 良好的缓存控制，设置过期时间和限制缓存文件大小
- 可取消的下载和自动重用先前下载好的内容，提升性能
- 独立组件。下载器,缓存系统，和处理器都是功能独立的
- 预加载图片，并且从缓存中展示图片
- **`UIImageView & UIButton & NSImageView & NSButton`** 扩展，可直接设置一个 **`URL`** 即可
- 设置图片时，内置过渡动画
- 图片处理和图片格式处理扩展简易
- 支持SwiftUI



## 1. 需求和安装

需求：

- iOS10.0+
- Swift 4.0+

安装（这里只写pod安装方式）：

```ruby
# Podfile
pod 'Kingfisher', '~> 5.0'
```

然后 **`pod install`**



## 2. Cheat Sheet

这里介绍Kingfisher在iOS开发中最常见的使用方式，用于MacOS等也是差不多的。



### 2.1 最常见的任务（Most common tasks）

优先使用视图扩展（**`UIImageView & UIButton`**）的方式，因为这种方式最简单.



> 1. 使用 URL 设置 image

```swift
let url = URL(string: "https://example.com/some.jpg")!
imageView.kf.setImage(with: url)
```

上面代码的实际步骤是：

1. 是否图片缓存在key为 **`url.absoluteString`** 的缓存中
2. 如果图片再缓存（内存或者磁盘）中，则将其设置给 **`imageView.image`** 
3. 如果缓存中没找到，则会创建一个请求，通过给的url去下载图片
4. 将下载的数据（**`Data`**类型）转化为 **`UIImage`** 类型
5. 将图片缓存到内存缓存中，将数据存储在磁盘缓存中
6. 然后设置 **`imageView.image`**，将其显示出来

如果有缓存在，则只进行 **`1-2`** 步骤，如果没有缓存，或者缓存被清理了，则进行 **`3-6`** 步骤。



> 2. 显示一个占位图(showing a placeholder)

```swift
let image = UIImage(named: "default_profile_icon")
imageView.kf.setImage(with: url, placeholder: image)
```

占位图 **`image`**  将在下载完成之前，显示在imageView中.

**也可以自定义一个UIView作为占位图，只要服从 `Placeholder` 协议， 比如：**

  ```swift
class MyView: UIView {
  // your custom implementation of view
}
extension MyView: Placeholder {
  // just leave it empty
}

imageView.kf.setImage(with: url, placeholder: MyView())
  ```

自定义的 **`MyView`** 实例将根据需要添加到imageView（图片未下载完成） 或者 从 imageView中移除（图片下载完成）.



> 3. 下载过程中显示一个loading指示器（showing a loading indicator while downloading）

```swift
imageView.kf.indicatorType = .activity
imageView.kf.setImage(with: url)
```

在下载图片过程中，在imageView中心显示一个 **`UIActivityIndicatorView`** 



> 4. 给下载图片添加渐变动画效果(Fading in downloaed image)

```swift
imageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
```



> 5. 完成回调（completion handler）

```swift
imageView.kf.setImage(with: url) { result in
  switch result {
  case .success(let value):
    // 设置给 imageView 的 图片
    print(value.iamge)
    
    // 从哪里获取的图片，3种可能
    // - .none: 从网上下载
    // - .momory: 从内存缓存中获取
    // - .disk: 从磁盘中获取
    print(value.cacheType)
    
    // source 对象，包含 url 等信息
    print(value.source)
    
  case .failure(let error):
    // 发生错误
    print(error)
  }
}
```



> 6. 给图片设置倒角（Round Corner image）

```swift
let processor = RoundCornerImageProcessor(cornerRadius: 20)
imageView.kf.setImage(with: url, options: [.processor(processor)])
```

这个库还内置了其它的 **`Processor`**。



> 7. 没有UI获取图片（Getting an image without UI）

有时可能只想通过这个库获取图片，而不去将其显示在某个 imageView中，可以使用 **`KingfisherManager`** 达成这个目的：

```swift
KingfisherManager.shared.retrieveImage(with: url) { result in 
  // do something with `result`
}
```



### 2.2 缓存（Cache)

Kingfisher 使用一个混合的 **`ImageCache`** 管理缓存图片，它由 **内存存储和磁盘存储** 组成,提供了高级的APIs操作缓存系统。如果没有指定，则 将默认使用 **`ImageCache.default`** 。



> 1. 使用自定义缓存key（using another cache key）

默认情况下，使用 **`url`** 的 **`absoluteString`** 作为缓存的key,可以使用 **`ImageResource`** 创建自定义缓存key：

```swift
let resource = ImageResource(downloadURL: url, cacheKey: "my_cache_key")
imageView.kf.setImagge(with: resource)
```

这个库会使用 **`cacheKey`** 在缓存中进行搜索。不同的key对应不同的图片.



> 2. 检测某个图片是否在缓存中（check whether an image in the cache）

```swift
let cache = ImageCaceh.default
let cached = cache.isCached(forKey: cacheKey)

// 缓存的地址 .memory | .disk | .none
let cacheType = cache.imageCachedType(forKey: cacheKey)
```

如果使用了处理器 （**`processor`**）, 则处理了的图片将被缓存.这种情况，可以传递处理标识符

```swift
let processor = RoundCornerProcessor(cornerRadius: 20)
imageView.kf.setImage(with: url, options: [.processor(processor)])

// later
cache.isCached(forKey: cacheKey, processorIdentifier: processor.identifier)
```



> 3. 从缓存中获取图片（Get an image from cache）

```swift
cache.retrieveImage(forKey: "cacheKey") { result in
  switch result {
  case (let value):
    print(value.cacheType)
    // 如果 value.cacheType 为 .none 表示没有缓存该图片
    // value.image 将为 nil
    print(value.image)
    
  case (let error):
    print(error)
  }
}
```



> 4. 设置缓存大小限制 （set limit for cache）

对内存存储，可以设置 **`totalCostLimit`** 和 **`countLimit`**:

```swift
// 300MB
cache.memoryStorage.config.totalCostLimit = 300 * 1024 * 1024

// 150张图片
cache.memoryStorage.config.countLimit = 150
```

默认情况下。 **`totalCostLimit`** 是设备总内存的 **`25%`**，图片则没有默认限制。



对于磁盘存储，可以设置 **`sizeLimit`** 设置文件空间

```swift
// 1GB 磁盘缓存限制
cache.diskStorage.config.sizeLimit = 1000 * 1024 * 1024
```



> 5. 设置缓存默认过期时间（set default expiration for cache）

内存和磁盘缓存都有默认的过期时间。内存缓存是 **5分钟**， 磁盘缓存是 **1星期**。可以自定义：

```swift
// 单位s， 即此处为 10min
cache.memoryStorage.config.exporation = .seconds(600)

// 永不过期
cache.diskStorage.config.exporation = .never
```

如果想对特定的图片设置特定的过期时间，则可以在 **`options`** 中进行设置：

```swift
imageView.kf.setImage(with: url, options: [.memoryCacheExpiration(.never)])
```

过期的 **内存缓存**，将在2分钟内被清除，这个清除时间也是可以设置的：

```swift
// 30s
cache.memoryStorage.config.cleanInterval = 30
```



> 6. 手动将图片存储到缓存中（Store images to cache manually）

默认情况下， **`KingfisherManager`** 和 视图扩展方法，会自动对下载的图片进行缓存。但是你也可以手动缓存：

```swift
let image: UIImage = //...
cache.store(image, forKey: cacheKey)
```

如果是 **image data**, 则将其传给 **`ImageCache`**, 它将帮助Kingfisher决定存储格式：

```swift
let data: Data = //...
let image: UIImage = //...
cache.store(image, original: data, forKey: cacheKey)
```



>7. 手动从缓存中移除图片（Remove images form cache manually）

从缓存中移除某个图片：

```swift
cache.default.removeImage(forKey: cacheKey)
```

或者更多移除细节控制：

```swift
cache.removeImage(
  forKey: cacheKey,
  processorIdentifier: processor.identifier,
  fromMemory: false,
  fromDisk: true
) {
  print("removed")
}
```



> 8. 清理缓存（clear the cache）

```swift
// 移除所有的缓存
cache.clearMemoryCache()
cache.clearDiskCache { print("Done") }

// 移除过期的缓存
cache.cleanExpiredMemoryCache()
cache.cleanExpiredDiskCache()
```



> 9. 报告磁盘存储空间（Report the disk storage size）

```swift
ImageCache.default.calculateDiskStorageSize { result in
  switch result {
  case .success(let size):
    print("Disk cache size: \(Double(size) / 1024 / 1024) MB")
  
  case .failure(let error):
    print(error)
  }
}
```



> 10. 创建自定义缓存并使用 （Create  your own cache and use it）

```swift
// name 用于识别磁盘缓存绑定的是哪一个 ImageCache
let cache = ImageCache(name: "my-own-cache")
imageView.kf.setImage(with: url, options: [.targetCache(cache)])
```



### 2.3 下载器（Downloader）

**`ImageDownloader` 是对下载图片的 `URLSession` 的封装，和 `ImageCache.default` 一样，也存在一个 `ImageDownloader.default` 单例，对应下载任务**。



> 1. 手动下载某个图片（Downloading an image manully）

通常 **`KingfisherManager`** 会自动的取回图片，先去缓存中寻找，没找到再去网上下载，从而避免不必要的下载任务。有时，可能希望去下载目标图片，而不进行缓存操作：

```swift
let downloader = ImageDownloader.default
downloader.downloadImage(with: url) { result in
  switch result {
  case .success(let value):
    print(value.image)
  case .failure(let error):
    print(error)
  }
}
```



> 2. 发送请求前，对请求进行修改（Modify a request before sending）

当对图片资源有权限控制时，你可以使用 **`.requestModifier`** 修改请求：

```swift
let modifier = AnyModifier { request in
  var r = request
  r.setValue("abc", forHTTPHeaderField: "Access-Token")
  return r
}

downloader.downloadImage(with: url, options: [.requestModifier(modifier)]) { result in
  // ...
}

// 这个modifier 对视图扩展也同样适用
imageView.kf.setImage(with: url, options: [.requestModifier(modifier)])
```



> 3. 取消下载任务（cancel a download task）

如果下载开始了， 将返回一个 **`DownloadTask`**，可以用它取消正在进行的下载任务：

```swift
let task = downloader.downloadImage(with: url) { result in
  // ...
  case .failure(let error):
    print(error.isTaskCancelled) // true
}

// after for a while, before download task finishes
task?.cancel()
```

如果任务已经完成了，再调用 **`task?.cancel()`** 没有任何效果。

同样，试图扩展也可以使用：

```swift
let task = imageView.kf.setImage(with: url)
task?.cancel()
```

或者，对 **imageView** 调用 **`cancelDownloadTask`** 取消当前下载：

```swift
let task1 = imageView.kf.setImage(with: url1)
let task2 = imageView.kf.setImage(with: url2)

// task2将被取消，而task1将继续
// 但是imageView不会设置task1下载好的图片 因为imageView希望使用的url2下载的图片
imageView.kf.cancelDownloadTask()
```



> 4. 使用NSURLCredential进行验证 （Authentication with NSUCrediential）

**`ImageDownloader`** 使用默认的行为（**`.performDefaultHandling`**）从服务器上取回数据.如果你想提供一些自己的证书，可以设置 **`authenticationChallengeResponder`**:

```swift
// 在 ViewController 中
ImageDownloader.default.authenticationChallengeResponder = self

extension ViewController: AuthenticationChallengeResponsable {
  var disposition: URLSession.AuthChallengeDisposition { // ... }
  let credential: URLCredential? { // ... }
  
  func downloader(
    _ downloader: ImageDownloader,
    task: URLSessionTask,
    didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
  ) {
    // 提供自定义的 AuthenticationChallenge 和 URLCredential
    completionHandler(disposition, credential)
  }
}
```



> 5. 下载超时（Download timeout）

默认情况，超时时间为 **`15s`**，可以自定义：

```swift
// 设置为60s
downloader.downloadTimeout = 60
```

对某个特定的请求设置超时时间，使用 **`.requestModifier`**:

```swift
let modifier = AnyModifier { request in
  var r = request
  r.timeoutInterval =60
  return r
}

downloader.downloadImage(with: url, options: [.requestModifer(modifier)])
```



### 2.4 图片处理器（Processor）

**`ImageProcessor`** 会对图片（或者图片数据）转换为另一张图片。可以给 **`ImageDownloader`** 对下载的数据提供一个处理器。处理好的数据会发送给image view 和缓存。



> 1. 使用默认处理器（Use the default processor）

```swift
imageView.kf.setImage(with: url)
// 上面的写法实际等价于
imageView.kf.setImage(with: url, options: [.processor(DefaultImageProcessor.default)])
```

**`DefaultImageProcessor`** 将下载的数据转换为对应的图片对象，支持 **`PNG & JPEG & GIF`** 格式。



> 2. 内置处理器（Build-in processors）

```swift
// 圆角 Round corner
let processor = RoundCornerImageProcessor(cornerRadius: 20)

// 向下采样 Downsampling
let processor = DownsamplingImageProcessor(size: CGSize(with: 100, height: 100))

// 裁剪 Cropping
let processor = CroppingImageProcessor(size: CGSize(with: 100, height: 100), anchor: CGPoint(x: 0.5, y: 0.5))

// 模糊 Blur
let processor = BlurImageProcessor(blurRadius: 5.0)

// 色块覆盖 overlay with a color & fraction
let processor = OverlayImageProcessor(overlay: .red, fraction: 0.7)

// 上色 Tint with a color
let processor = TintImageProcessor(tint: .blue)

// 调色 adjust color
let processor = ColorControlsProcessor(brightness: 1.0, constrast: 0.7, saturation: 1.1, inputEV: 0.7)

// 黑白 Black & White
let processor = BlackWhiteProcessor()

// 混合(iOS) Blend
let processor = BlendImageProcessor(blendMode: .darken, alpha: 1.0, backgroundColor: .lightGray)

// 合成 Compositing
let processor = CompositingImageProcessor(compositingOperation: .darken, alpha: 1.0, backgroundColor: .lightGray)

// 在视图扩展中使用处理器
imageView.kf.setImage(with: url, options: [.processor(processor)])
```



> 3. 多个处理器（multiple processors）

```swift
// 先模糊 后圆角
let processor = BlurImageProcessor(blurRadius: 4) >> RoundCornerImageProcessor(cornerRadius: 20)

imageView.kf.setImage(with: url, options: [.processor(processor)])
```



> 4. 自定义处理器（Creating  your own processor）

服从 **`ImageProcessor`** 协议，实现 **`identifier`** 和 **`process`**

```swift
struct WebpProcessor: ImageProcessor {
  // 对于相同属性和功能的处理器，identifier 需要相同
  // 因为在图像存储到缓存中，或者从缓存中取出时需要这个标识符
  let identifier = "com.yourdomain.webpprocessor"
  
  func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> Image? {
    switch item {
    case .image(let image):
    	print("already an image")
    	return image
    case .data(let webpData):
      return WebpFramework,createImage(from: webpData)
    }
  }
}

// 使用
let processor = WebpProcessor()
let url = URL(string: "https://example.com/image.webp")
imageView.kf.setImage(with: url, options: [.processor(processor)])
```



> 5. 使用CIFilter创建处理器（Creating a processor from CIFilter）

如果你有一个准备好的 **`CIFilter`**， 则可以快速的创建一个处理器：

```swift
struct MyCIFilter: CIImageProcessor {
  let identifier = "com.yourdomain.myCIFilter"
  
  let filter = Filter { input in
  	guard let filter = CIFilter(name: "xxx") else { return nil }
  	filter.setValue(input, forKey: kCIInputBackgroundImageKey)
  	return filter.outputImage
  }
}
```



### 2.5 序列化器（Serializer）

**`CacheSeriaizer`** 将数据转换为图像对象（image  object），用于从磁盘缓存中检索。反之亦然，可用于将其存储在磁盘缓存中。



> 1. 使用默认的序列化器（use the default serializer）

```swift
imageView.kf.setImage(with: url)
// 等价于
imageView.kf.setImage(with: url, options: [.cacheSerializer(DefaultCacheSerializer.default)])
```

**`DefaultCacheSerializer`** 将缓存的数据转换为对应的图片对象，支持 **`PNG & JPEG & GIF`** 格式。



> 2. 序列化某个特定格式（serializer to force a format）

为了指定一个特定的图片格式，可以使用 **`FormatIndicatedCachedCacheSerializer`**.它提供了所有支持格式的序列化器：**`FormatIndicatedCacheSerializer.png & FormatIndicatedCacheSerializer.jpeg & FormatIndicatedCacheSerializer.gif`**.

原始转换器，就是拿到什么格式就显示什么格式。但是有时候这不一定是你想要的，比如拿到了 **`jpegg`** 格式，然后给它一个 **圆角**， 这时就需要将其转换为 **`PNG`** 格式：

```swift
let roundCorner = RoundCornerImageProcessor(cornerRadius: 20)
imageView.kf.setImage(
  with: url,
  options: [
  	.procssor(roundCorner),
  	.cacheSerializer(FormatIndicatedCacheSerializer.png)
  ]
)
```



> 3. 创建自定义序列化器（creating your own serializer）

服从 **`CacheSerializer`** 协议，实现 **`data(with:original)`** 和 **`image(with:options)`**:

```swift
struct WebpCacheSerializer: CacheSerializer {
  func data(with image: Image, original: Data?) -> Data? {
    return WebpFramework.webpData(of: image)
  }
  
  func image(with data: Data, options: KingfisherParsedOptionsInfo?) -> Image? {
    return WebpFramework.createImage(from: webpData)
  }
}

let serializer= WebpCacheSerializer()
let url = URL(string: "https://example.com/image.webp")
imageView.kf.setImage(with: url, options: [.cacheSerializer(serializer)])
```



### 2.6 预取（Prefetch）

对列表数据中的图片，可以在显示之前，对其进行预取：

```swift
let urls = ["https://xxx/img1.png", "https://xxx/img2.png"].map { URL(string: $0) }
let prefetcher = ImagePrefetcher(urls: urls) {
	skippedResources, failedResources, completedResources in
	print("预取的资源有: \(completedResources)")
}
prefethcer.start()

// 稍后需要时进行显示
imageView.kf.setImage(with: urls[0])
antherImageView.kf.setImage(with: urls[1])
```



> 在UICollectionView 或 UITableView中 使用ImagePrefetcher

对于iOS10，苹果引入了预取行为，这和ImagePrefetcher工作原理类似.

```swift
override func viewDidLoad() {
  super.viewDidLoad()
  collectionView?.prefetchDataSource = self
}

extension ViewController: UICollectionViewDataSourcePrefetching {
  func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    let urls = indexPaths.flatMap { URL(string: $0.urlString) }
    ImagePrefetcher(urls: urls).start()
  }
}
```



### 2.7 ImageDataProvider

除了从网上下载图片，Kingfisher还支持从数据提供者处设置图片。这对本地数据图片很有用，这样就可以使用Kingfisher提供的选项来处理和管理这些图片了。



> 1. 图片来自本地文件 （Image from local file）

**`LocalFileImageDataProvider`** 是服从 **`ImageDataProvider`** 的类型，它用于加载本地图片文件的URL。

```swift
let url = URL(fileURLWithPath: path)
let provider = LocalFileImageDataProvider(fileURL: url)
imageView.kf.setImage(with: provider)
```

也可以传入选项：

```swift
let processor = RoundCornerImageProcessor(cornerRadius: 20)
imageView.kf.setImage(with: provider, options: [.processor(processor)])
```



> 2. 创建自定义图片数据提供者（creating your own image data provider）

Kingfisher中，提供了 **`Base64ImageDataProvider`** 来加载Base64字符串形式的图片,还有 **`RawImageDataProvider`** 用来加载原始图片数据（raw data）.

通过服从 **`ImageDataProvider`** 协议，实现 **`cacheKey & data(handler:)`** 创建自定义图片数据提供者：

```swift
// 创建一个用户名首字符形成的图片
struct UserNameLetterIconImageProvider: ImageDataProvider {
  var cacheKey: String { return letter }
  let letter: String
  
  init(userNameFirstLetter: String) {
    self.letter = userNameFirstLetter
  }
  
  func data(handler: @escaping (Result<Data, Error>) -> Void) {
    let letter = self.letter as NSString
    let rect = CGRect(x: 0, y: 0, width: 250, height: 250)
    let render = UIGraphicsImageRenderer(size: rect.size)
    let data = renderer.pngData { context in
      UIColor.black.setFill()
      context.fill(rect)
      
      // 计算文字所占的宽高
      let attributes = [
        NSAttributedString.Key.foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: 20)
      ]
      let textSize = letter.size(withAttributes: attributes)
      let textRect = CGRect(
        x: (rect.width - textSize.width)/2,
        y: (rect.height - textSize.height)/2,
        width: textSize.width,
        height: textSize.height
      )
      // 绘制文字
      letter.draw(in: textRect, withAttributes: attributes)
    }
    
    // Provide the image data in `handler`
    handler(.success(data))
  }
}

let provider = UserNameLetterIconImageProvider(userNameFirstLetter: "J")
imageView.kf.setImage(with: provider)
```

你可能注意到了 **`data(handler:)`** 包含了一个回调，你可以用来从其他线程使用异步的的方式提供图片数据。



### 2.8 指示器（Indicator）

用图片作为指示器：

```swift
let path = Bundle.main.path(forResource: "loader", ofType: "gif")!
let data = try! Data(contentOf: URL(fileURLWithPath: path))

imageView.kf.indicatorType = .image(imageData: data)
imageView.kf.setImage(with: url)
```

使用自定义视图，作为指示器：

```swift
struct MyIndicator: Indicator {
  let view: UIView = UIView()
  func startAnimatingView() { view.isHidden = false }
  func stopAnimatingView() { view.isHidden = true }
  
  init() {
    view.backgroundColor = .red
  }
}

let i = MyIndicator()
imageView.kf.indicatorType = .custom(indicator: i)
```



> 使用百分比指示器（Updating your own indicator with percentage）

```swift
imageView.kf.setImage(with: url, progressBlock: {
  receivedSize, totalSize in
  let percentage = (Float(receivedSize) / Float(totalSize)) * 100.0
  print("下载进度： \(percentage)%")
  myIndicator.percentagge = percentage
})
```

只有服务器响应数据头中包含 **`Content-Lenght`** 时，  **`progressBlock`** 才会被调用。



### 2.9 其它选项（other options）

> 1. **跳过缓存搜索，强制去下载新的图片**:

```swift
imageView.kf.setImage(with: url, options: [.forceRefresh])
```



> 2. **只从缓存中搜索图片，没搜索到，也不去下载**

这使应用变成一种离线模式：

```swift
imageView.kf.setImage(with: url, options: [.onlyFromCache])
```

如果图片不在缓存中，则会以 **`.imageNotExisting`** 的理由，抛出  **`.cacheError`** 错误。



> 3. **同步的加载磁盘文件**

默认情况下，包括磁盘缓存加载，为了性能，所有的操作都是异步的。有时，在某个tableview中，你希望重新加载某个图片，如果缓存的图片只存在于磁盘缓存中，则会出现闪烁的情况。这是因为图片设置首先被分配到 **I/O** 队列中，当图片加载或者处理完成后，又被重新异步分发到主队列中。

为了避免闪烁，可以在重新加载图片时，传入 **`.loadDiskFileSynchronously`** 选项：

```swift
let options: [KingfisherOptionsInfo]? = isReloading ? [.loadDiskFileSynchronously] : nil
imageView.kf.setImage(with: url, options: options)
```



> 4. **等待缓存完成**（Waiting for cache finishing）

将图片存储到磁盘缓存中，是一种异步操作。然而，在将图片设置到image view 和调用完成回调之前，前面说的操作不是必需的。换句话说，在回调完成后，磁盘缓存不一定存在：

```swift
imageView.kf.setImage(with: url) { _ in
  ImageCache.default.retrieveImageInDiskCache(forKey: url.cacheKey) { result in
    switch result {
    case .success(let image):
      // `image` may be nil here
    case .failure: break
    }
  }
}
```

这在大多数情况下都不是问题，但是，如果你的应用逻辑依赖磁盘缓存的存在，则可以将 **`.waitForCache`** 作为一个选项，Kingfisher 会在调用完成回调之前，等到磁盘缓存完成。

```swift
imageView.kf.setImage(with: url, options: [.waitForCache]) { _ in
  ImageCache.default.retrieveImageInDiskCache(forKey: url.cacheKey) { result in
    switch result {
    case .success(let image):
      // `image` exists
    case .failure: break
  }
}
```

这只对磁盘缓存有效，这涉及到异步I/O.对于内存缓存，所有的操作都是同步的，因此图片永远在内存缓存中。



### 2.10 设置按钮图片 （For UIButton & NSButton）

```swift
let uiButton: UIButton = // ...
uiButton.kf.setImage(with: url, for: .normal)
uiButton.kf.setBackgroundImage(with: url, for: .normal)
```



### 2.11 可动画图片

Kingfisher支持GIF动画。



> 1. 加载GIF（loading a GIF）

```swift
let imageView: UIImageView = // ...
imageView.kf.setImage(with: URL(string: "your_animated_gif_image_url")!)
```

如果在加载大的gif遇到内存问题，可以尝试使用 **`AnimatedImageView`** 替代普通的image view来显示GIF。它会只解码GIF图片的部分帧，从而减少内存的使用（但是会增大CPU负荷）。

```swift
let imageView = AnimatedImageView()
imageView.kf.setImage(with: URL(string: "your_animated_gif_image_url")!)
```



> 2. 只加载GIF第一帧（Only load the first frame of GIF）

```swift
imageView.kf.setImage(
  with: URL(string: "your_animated_gif_image_url")!,
  options: [.onlyLoadFirstFrame]
)
```

这对只想显示静态的GIF图片很有用。



### 2.12 性能建议（Performance Tips）



> 1. 取消不必要的下载任务（Cancelling unnecessary downloading tasks）

一旦任务开始，即使你此时再更换url，任务仍会继续进行直到结束。

```swift
imageView.kf.setImage(with: url1) { result in
  // result 是 `.failure(.imageSettingError(.notCurrentSOurceTask))`
  // 但是下载(和缓存)完成
}

// 立马更换为第2个url
imageView.kf.setImage(with: url2) { result in
  // result 是 `.success`
}
```

尽管因为重新设置了url2，导致url1的结果是 **`.failure`**, 但是url1自身的下载任务还是会完成，下载的图片数据也会被处理并被缓存下来。

对url1图片的下载和缓存操作还是会占用网络，CPU,内存和电池。

如果你确信不需要url1图片，再启用另一个下载任务前，可以取消掉url1任务。

```swift
imageView.kf.setImage(with: ImageLoader.sampleImageURLs[8]) { result in
  // 任务失败，并被取消
}

// 再开启新任务前，将旧的下载任务取消
imageView.kf.cancelDownloadTask()
imageView.kf.setImage(with: ImageLoader.sampleImageURLs[9]) { result in
  // `result` 是 '.success'
}
```

这个技术处理对于UICollectionView和UITableView列表有时候很有用，当用户快速滚动列表时，很多下载任务被创建，可以在 **`didEndDisplaying`** 委托方法处取消这些不必要的下载任务:

```swift
func collectionView(
  _ collectionView: UICollectionView,
  didEndDisplaying cell: UICollectionViewCell,
  forItemAt indexPath: IndexPath
) {
  // 这会取消那些没有显示的 未完成的任务
  cell.imageView.kf.cancelDownloadTask()
}
```



> 2. 将ImageCache和processor一起使用（Using processor with ImageCache）

Kingfisher会智能的将处理后的图片进行缓存，然后将对应的 **`ImageProcessor`** 处理后的图片进行取回。因为每个 **`ImagfeProcessor`** 都包含一个 **`identifier`**(用于缓存处理后的图片)。

如果没有 **`identifier`**, Kingfisher 不能够从缓存中取出正确的图片。假设你必须从同一个url存储2个版本的图片，一个是圆角的，一个是模糊效果的。你需要使用2个不同的缓存keys。在所有的Kingfisher内置的图片处理器。例如，一个圆角为20的处理器的标识符为 **`round-corner-20`**，而另一个圆角为40的则需要是 **`round-corner-40`**。

因此，当创建自定义处理器时，则需要对不同的处理器实例，提供不同的 **`identifier`**，这能够帮助处理器更好的配合缓存工作。



> 3. 使用处理器，但是缓存原始图片（Cache original image when using a processor）

如果你做如下操作：

1. 对同一图片使用不同的处理器，获得不同版本的图片
2. 使用除默认处理器之外的处理器，然后稍后显示原始图片

将 **`.cacheOriginalImage`** 作为选项传入，还是很有价值的。这样，会同时缓存原始图片：

```swift
let p1 = MyProcessor()
imageView.kf.setImage(with: url, options: [.processor(p1), .cacheOriginalImage])
```

被 **`p1`** 处理后的图片和原始图片都被缓存。稍后，你可以使用其他的处理器：

```swift
let p2 = AnotherProcessor()
imageView.kf.setImage(with: url, options: [.processor(p2)])
```

这样Kingfisher会优先使用缓存下来的原始图片，而不必重新去下载。



> 4. 对高分辨率的图片使用 DownsamplingImageProcessor（Using DownsamplingImageProcessor for high resolution images）

例如，对列表数据，我们很可能只是需要很小质量的thumbnails，减小内存消耗。但是现实中，服务器不可能单独配置这些低分辨率的thumbnails，这时就可以使用 **`DownsamplingImageProcessor`** 对高分辨率的图片进行向下采样，减少内存的消耗。

```swift
imageView.kf.setImage(
  with: resource,
  placeholder: placeholderImage,
  options: [
    .processor(DownsamplingImageProcessor(size: imageView.size)),
    .scaleFactor(UIScreen.main.scale),
    .cacheOriginalImage
  ]
)
```

一般情况下，**`DownsamplingImageProcessor`** 会和 **`scaleFactor & cacheOriginalImage`** 一起使用，这样能提供一个合理的图片像素尺寸，同时通过缓存原始图片阻止下次再次下载原始的高分辨率图片。







