翻译：

- [Alamofire basic usage - github](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#using-alamofire)

Alamofire是swift写的一个HTTP网络库,有以下特点：

- 链式请求和链式响应方法
- URL/JSON 参数编码
- 上传文件/数据/流/多组表格数据
- 使用请求或者恢复数据形式下载文件
- **`URLCredential`** 验证
- HTTP 响应验证
- 上传和下载进度
- cURL 命令行输出
- 动态适配和重新请求
- TLS证书和公钥固定
- 网络可访问性（Network Reachability）
- 单元测试和集成测试



## 1. 要求和安装使用

对于 **`Alamofire5.0+`**:

- iOS10.0+
- swift5.0+
- Xcode 10.2+

使用CocoaPods做示例：

```ruby
pod 'Alamofire', '~> 5.0'
```



## 2. 基本使用

Alamofire本质上是基于Apple原生提供的 [URL loading System](https://developer.apple.com/documentation/foundation/url_loading_system/) 的封装。主要是对 **`URLSession & URLSessionTask`** 进行扩展。

Alamofire5.0之前的版本，可以像下面这样使用：

```swift
import Alamofire

Alamofire.request()
//或者直接
request()
```

Alamofire5.0+ 移除了上面的写法，使用 **`AF`** 作为全局命名空间，它是对 **`Session.default`** 的引用：

```swift
import Alamofire

AF.request()
```



下面的实例都是在，引入了Alamofire的前提下（在某个文件中 **`import Alamofire`**）

### 2.1 发起请求（Making Requests）

最简单的一种写法：

```swift
AF.request("https://some.api").response { response in
	debugPrint(response)
}
```

请求有2种形式，第2种形式有可能在未来版本中废弃：

第1种形式:

```swift
// 推荐
// 返回 DataRequest 可用于组合请求
open func request<Parameters: Encodable>(
  _ convertiable: URLConvertiable,
  method: HTTPMethod = .get,
  parameters: Parameters? = nil,
  encoder: ParameterEncoder	= URLEncodedFormParameterEncoder.default,
  headers: HTTPHeaders? = nil,
  interceptor: RequestInterceptor? = nil
) -> DataRequest
```

第2种形式比较精简：

```swift
// 未来版本可能被移除
open func request(
	_ urlRequest: URLRequestConvertiable,
	interceptor: RequstInterceptor? = nil
) -> DataRequest
```



### 2.2 HTTP 方法

http方法，Alamofire中的定义如下：

```swift
public struct HTTPMethod: RawRepresentable, Equatable, Hashable {
  public static let connect = HTTPMethod(rawValue: "CONNECT")
  public static let delete = HTTPMethod(rawValue: "DELETE")
  public static let get = HTTPMethod(rawValue: "GET")
  public static let head = HTTPMethod(rawValue: "HEAD")
  public static let options = HTTPMethod(rawValue: "OPTIONS")
  public static let patch = HTTPMethod(rawValue: "PATCH")
  public static let post = HTTPMethod(rawValue: "POST")
  public static let put = HTTPMethod(rawValue: "PUT")
  public static let trace = HTTPMethod(rawValue: "TRACE")
  
  public let rawValue: String
  
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}
```

这些值可以传递到 **`AF.request`** 的 **`method`** 参数中：

```swift
AF.request("https://some.api") // 默认是 .get
AF.request("https://some.api", method: .post)
```

**Alamofire 提供了用于桥接 能返回  `HTTPMEthod`值  的 `httpMethod` 属性的扩展**

```swift
public extension URLRequest {
	// 返回的 `httpMethod` 可以作为 Alamofire 自定义的 `HTTPMethod`
  var method: HTTPMethod? {
    get { return httpMethod.flatMap(HTTPMethod.init) }
    set { httpMethod = newValue?.rawValue }
  }
}
```

如果Alamofire提供的 HTTPMethod 不能满足你的要求，可以自定义：

```swift
extension HTTPMethod {
  static let custom = HTTPMethod(rawValue: "CUSTOM")
}
```



### 2.3 请求参数和参数编码（Request Parameters and Parameter Encoders）

Alamofire 支持任何服从 **`Encodable`** 的数据类型作为请求参数，这些参数然后通过符合 **`ParameterEncoder`** 协议的类型传递，并添加到URLRequest中，然后通过网络发送。 Alamofire包括两种ParameterEncoder兼容类型：

1. **`JSONParameterEncoder`** : 主流编码形式
2.  **`URLEncodedFormParameterEncoder`**： 将所有参数拼接到请求url上的形式，表单形式

示例：

```swift
struct Login: Encodable {
  let email: String
  let password: String
}

let login = Login(email: "test@test.com", password: "abc123")

// encoder 类型： JSONParameterEncoder || URLEncodedFormParameterEncoder
AF.request(
  "https://some.api",
  method: .post,
  parameters: login,
  encoder: JSONParameterEncoder.default
).response { response in 
	debugPrint(response)
}
```



#### 2.3.1 **URLEncodedFormParameterEncoder**

**表单编码（现在用得比较少了，一般用 JSON）**。

URLEncodedFormParameterEncoder 将值编码为url编码的字符串，用来设置或者附加到任何现有URL查询字符串或者设置为请求的HTTP body。通过设置编码的 **`destination`** 属性，可以控制编码字符串设置的位置。 **`URLEncodedFormParameterEncoder.destination`** 是一个枚举：

- **`.methodDependent`**：将编码的查询字符串结果应用在 **`.get & .head & .delete`** 请求的现有查询字符串，并将其设置为使用任何其他HTTP方法进行请求的HTTP正文.
- **`queryString`**：设置或者添加到请求的 **`URL`**
- **`httpBody`**：将编码字符串设置为 **`URLRequest`** 的http body

使用这个编码，**`Content-Type`** 将默认设置为 **`application/x-www-form-urlencoded;charset=utf-8`**。

**`URLEncodedFormParameterEncoder`** 内部实际上是使用 **`URLEncodedFormEncoder`**，将一个 **`Encodable`** 类型URL编码形式字符串。这个编码器可用于自定义各种类型的编码：

- Array 使用 **`ArrayEncoding`**
- Bool 使用 **`BoolEncoding`**
- Data 使用 **`DataEncoding`**
- Date 使用 **`DateEncoding`**
- coding keys 使用 **`KeyEncoding`**
- space 使用 **`SpaceEncoding`**



> **GET请求的 URL参数编码**（GET Request with URL-Encoded Parameters）

```swift
let parameters = ["foo": "bar"]

// 下面调用形式都是一样的
AF.request("https://some.api/get", parameters: parameters) // 默认使用 `URLEncoding.default`
AF.request("https://some.api/get", encoder: URLEncodedFormParameterEncoder.default)
AF.request("https://some.api/get", encoder: URLEncodedFormParameterEncoder(destination: .methodDependent))

// 都得到
"https://some.api/get?foo=bar"
```



> **POST请求的URL参数编码**

```swift
let parameters: [String: [String]] = [
  "foo": ["bar"],
  "baz": ["a", "b"],
  "qux": ["x", "y", "z"]
]
// 下面调用形式都是一样的
AF.request("https://some.api/post", method: .post, parameters: parameters) // 默认使用 `URLEncoding.default`
AF.request("https://some.api/post", method: .post, encoder: URLEncodedFormParameterEncoder.default)
AF.request("https://some.api/post", method: .post, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))

// http body
"qux[]=x&qux[]=y&qux[]=z&baz[]=a&baz[]=b&foo[]=bar"
```



> **配置编码值的排序**

因为字典是无序的，这意味着编码的参数的顺序是可变的，这对缓存和其他行为有影响。默认情况下， **`URLEncodedFormEncoder`** 将对编码的键值对进行排序，这样对所有的 **`Encodable`** 类型都产生一样的输出结果。可以将 **`alphabetizeKeyValuePairs`** 设置为 **`false`**:

```swift
let encoder = URLEncodedFormParameterEncoder(encoder: URLEncodedFormEncoder(alphabetizeKeyValuePairs: false))
```



> **数组参数的配置**

**`URLEncodedFormEncoder.ArrayEncoding`** 提供了以下2种参数编码方式：

1. **`.brackets`**: 默认的方式，带括号
2. **`.noBrackets`**: 不带括号，将数组拆开

```swift
// 参数
foo = [1, 2]

// .brackets 默认
// 编码为
foo[]=1&foo[]=2


// .noBrackets
// 编码为
foo=1&foo=2
```

可以指定 **`ArrayEncoding`** 的编码方式：

```swift
let arrayEncoder = URLEncodedFormParameterEncoder(
	encoder: URLEncodedFormEncoder(arrayEncoding: .noBrackets)
)
```



> **`Bool参数的编码`**

2种方式：

1. **`.numeric`**: 将 `true` 编码为 **`1`**， **`false`** 编码为 `0`， **默认**的方式
2. **`.literal`**: 字面量编码， 将 `true` 编码为字符串 `"true"`

```swift
let boolEncoder = URLEncodedFormParameterEncoder(
	encoder: URLEncodedFormEncoder(boolEncoding: .numeric)
)
```



> **Data类型参数编码**

**`DataEncoding`** 对 `Data` 类型的编码方式有3种：

1. **`deferredToData`**: 使用 `Data` 原生的 **`Encodable`** 支持
2. **`.base64`**: 作为 `base64` 字符串进行编码， **默认**
3. **`custom((Data) -> throws -> String)`**: 自定义，使用给定的闭包函数

```swift
let dataEncoder = URLEncodedFormParameterEncoder(
	encoder: URLEncodedFormEncoder(dataEncoding: .base64)
)
```



> **Date类型参数编码**

将Date转换为字符串， **`DateEncoding`** 有以下几种编码方式：

1. **`.deferredToDate`**： 使用Date的原生Encodable支持， **默认**
2. **`.secondsSince1970`**: UTC 1970.1.1 午夜作为起点，到当前时间的秒数
3. **`.millisecondsSince1970`**: 同上，但是是按照毫秒算的
4. **`.iso8601`**: 根据ISO 8601 和 RFC3339 标准编码的日期
5. **`.formatted(DateFormatter)`**: 使用给定的 **`DateFormatter`** 编码
6. **`custom((Date) throws -> String)`**: 使用给定的闭包编码

```swift
let dateEncoder = URLEncodedFormParameterEncoder(
	encoder: URLEncodedFormEncoder(dateEncoding: .iso8601)
)
```



> **Coding Keys 编码**

参数键值风格， **`KeyEncoding`** 提供了基于 **`.lowerCamerCase`** 形式（即 `oneTwoThree`这种形式的key）的key的几种编码：

1. **`useDefaultKeys`**: 使用每个类型指定的keys，**默认**
2. **`.convertToSnakeCase`**: 转换为蛇形key，即 `oneTwoThree` -> `one_two_three`
3. **`.convertToKebabCase`**: 转换为连字符形式，即 `oneTwoThree` -> `one-two-three`
4. **`.capitalized`**: 首字符大写形式，即 `oneTwoThree` -> `OneTwoThree`
5. **`.uppercased`**: 全部大写，即 `oneTwoThree` -> `ONETWOTHREE`
6. **`.lowercased`**: 全部小写，即 `oneTwoThree` -> `onetwothree`
7. **`.custom((String) -> String)`**: 自定义闭包转换

```swift
let keyEncoder = URLEncodedFormParameterEncoder(
	encoder: URLEncodedFormEncoder(keyEncoding: .convertToSnakeCase)
)
```



> **空格部分编码**

空格有以下2种方式编码：

1. **`.percentEscaped`**: 使用百分比转义，即 `" "` -> `%20` ，**默认**
2. **`.plusReplaced`**: 使用 `+` 代替空格，即 `" "` -> `+`

```swift
let spaceEncoder = URLEncodedFormParameterEncoder(
	encoder: URLEncodedFormEncoder(spaceEncoding: .plusReplaced)
)
```



#### 2.3.2 JSONParameterEncoder

现在一般通过json的形式进行传递参数，上面的 **`URLEncodedFormParameterEncoder`** 表单形式，现在开发中用的比较少了，但是还是有些情况下需要使用表单。

**`JSONParameterEncoder`** 使用 Swift 的 **`JSONEncoder`** 将参数设置为 `URLRequest` 的 `httpBody`。 **`Content-Type: "application/json"`** 为默认http请求头参数。



> **POST 请求参数编码**

```swift
let parameters: [String: [String]] = [
  "foo": ["bar"],
  "baz": ["a", "b"],
  "qux": ["x", "y", "z"]
]

AF.request(
	"https://some.api/post",
	method: .post,
	parameters: parameters,
	encoder: JSONParameterEncoder.default
)

AF.request(
	"https://some.api/post",
	method: .post,
	parameters: parameters,
	encoder: JSONParameterEncoder.prettyPrinted
)

AF.request(
	"https://some.api/post",
	method: .post,
	parameters: parameters,
	encoder: JSONParameterEncoder.sortedKeys
)

// 请求体 以json的形式
{"baz":["a","b"],"foo":["bar"],"qux":["x","y","z"]}
```



> **自定义JSONEncoder**

可以传入一个自定义的 `JSONEncoder` 来自定义JSON的编码风格：

```swift
let encoder = JSONEncoder()
encoder.dateEncoding = .iso8601
encoder.keyEncodingStrategy = .convertToSnakeCase
let parameterEncoder = JSONParameterEncoder(encoder: encoder)
```



> **使用URLRequest手动编码参数**

除了使用Alamofire封装的2种编码风格外，还可以使用系统自动的 `URLRequest` 手动设置参数编码

```swift
let url = URL(string: "https://some.api")
let urlRequest = URLRequest(url: url)

let parameters = ["foo": "bar"]
let encodedURLRequest = try URLEncodedFormParameterEncoder.default.encode(parameters, into: urlRequest)
```



### 2.4 HTTP Headers

Alamofire 包含自己的 HTTPHeaders 类型，它们是保留顺序且大小写敏感的 **`name/value`** 对。

添加自定义请求头：

```swift
let header: HTTPHeaders = [
  "Authentication": "Basic VNdlllskwekskfjlsk=",
  "Accept": "application/json"
]

AF.request("https://some.api", headers: headers).responseJSON { response in
	debugPrint(response)
}
```

**`HTTPHeaders`** 也可以从 `HTTPHeader` 数组构造：

```swift
let headers: HTTPHeaders = [
  .authorization(username: "Username", password: "Password"),
  .accept("application/json")
]
AF.request("https://some.api", headers: headers).responseJSON { response in
	debugPrint(response)
}
```

Alamofire提供了一些**默认的请求头**：

1. **`Appect-Encoding`**: **`br;q=1.0, gzip;q=0.8, deflate;q=0.6`**
2. **`Accept-Languagge`**: 默认是系统前6的语言
3. **`User-Agent`**: 包含当前应用的版本信息，比如： `iOS Example/1.0(com.alamofire.iOS-Example; build:1; iOS 13.0.0) Alamofire/5.0.0`

如果需要自定义上麦你的这些请求头，可以自定义一个 **`URLSessionConfiguration`**, 将参数应用到 **`Session`** 实例，使用 **`URLSessionConfiguration.af.default`** 自定义配置，同时保留Alamofire默认的请求头。



### 2.5 响应验证（Response Validation）

默认情况下，只要请求返回了结果，不能是什么，Alamofire都认为请求成功了。在response之前调用 **`validate()`** ，如果状态码或者MIME类型不是预期的，都会抛出错误.



> 自动验证（Automatic Validation）

**`validate()`** 自动验证状态码，是否在 **`200..<300`** 之间，响应的 **`Content-Type`** 和 请求头中的 **`Accept`** 知否匹配

```swift
AF.request("https://some.api").validate().responseJSON { response in 
  debugPrint(response)
}
```



> 手动验证（Manual Validation）

```swift
AF.request("https://some.api")
	.validate(statusCode: 200..<300)
	.validate(contentType: ["application/json"])
	.responseJSON { response in 
  	switch response.result {
      case .success:
      	print("Validation successful")
      case .failure(let error):
      	print("error")
  	}
}
```



### 2.6 响应处理（Response Handling）

Alamofire有6种默认响应处理：

```swift
// 1. 未序列化的响应
func response(
	queue: DispatchQueue = .main,
	completionHandler: @escaping (AFDataResponse<Data?>) -> Void 
) -> Self


// 2. 响应序列化handler - 使用传递的序列器进行序列化
func response<Serializer: DataResponseSerializerProtocol>(
	queue: DispatchQueue = .main,
	responseSerializer: Serializer,
	completionHandler: @escaping (AFDataResponse<Serializer.SerializedObject>) -> Void
) -> Self

// 3. 响应数据handler -> 序列化为Data
func responseData(
	queue: DispatchQueue = .main,
	completionHandler: @escaping (AFDataResponse<Data>) -> Void
) -> Self

// 4. 响应字符串handler - 序列化为字符串
func responseString(
	queue: DispatchQueue = .main,
	encoding: String.Encoding? = nil,
	completionHandler: @escaping (AFDataResponse<String>) -> Void
) -> Self

// 5. 响应JSON handler - 使用JSONSerialization序列化为Any
func responseJSON(
	queue: DispatchQueue = .main,
	option: JSONSerialization.ReadingOptions = .allowFragments,
	completionHandler: @escaping (AFDataResponse<Any>) -> Void
) -> Self

// 6. 响应可解码handler - 序列化为可解码类型
func responseDecodable<T: Decodable>(
	of type: T.Type = T.self,
	queue: DispatchQueue = .main,
	decoder: DataDecoder = JSONDecoder(),
	completionHandler: @escaping (AFDataResponse<T>) -> Void
) -> Self
```

上面的handlers都没有对 **`HTTPURLResponse`** 进行验证。



> 1. 响应Handler（Response Handler）

这个handler不会计算任何返回的响应数据，它仅仅转发来自 **`URLSessionDelegate`** 的信息。相当于Alamofire使用 **`cURL`** 执行一个 **`Request`**：

```swift
AF.request("https://some.api").response { response in
	debugPrint("response: \(response)")
}
```

一般推荐使用其他的响应序列化器，利用好 **`Response & Result`** 类型



> 2. Response Data handler

**`responseData`** handler 使用 **`DataResponseSerializer`** 提取和验证从服务器返回的 **`Data`**。如果没有错误，则返回的 **`Result`** 是 **`.success`**, 值为 **`Data`**

```swift
AF.request("https://some.api").responseData { response in
	debugPrint("response: \(response)")
}
```



> 3. Response String handler

**`responseString`** handler 使用 **`StringResponseSerializer`** 将服务器返回的 **`Data`** 转换为指定编码的 **`String`**。如果没有发生错误，则返回结果将被序列化为字符串。

默认字符串编码为 **`.isoLatin1`**

```swift
AF.request("https://some.api").responseString { response in
	debugPrint("response: \(response)")
}
```



> 4. **Response JSON handler**

这个用得最多了。 **`responseJSON`** 使用 **`JSONResponseSerializer`** 将返回的 **`Data`** 类型按照给定的 **`JSONSerialization.ReadingOptions`** 转换为 **`Any`** 类型. 如果没发生错误，服务端数据将转换为一个JSON对象，响应的 **`AFResult`** 将是 **`.success`**, 值为 **`Any`** 类型。

```swift
AF.request("https://some.api").responseJSON { response in
	debugPrint("response: \(response)")
}
```

序列化器使用的是iOS的 **`JSONSerialization`**



> 5. **Response Decodable Handler**

**`Decodable`** handler使用 **`DecodableResponseSerializer`** 将返回的 **`Data`** 转换为通过 `DataDecoder` 指定的 **`Decodable`** 类型。

```swift
struct HTTPBinResponse: Decodable {
  let url: String
}

AF.request("https://some.api").responseDecodable(of: HTTPBinResponse.self) { response in
	//...
}
```

**结合swift Codable 一起使用，很常见**。



> Bonus1: Chained Response Handlers

**可以用来进行调试**

```swift
AF.request("https://some.api")
	.responseString { response in
    print("Response String: \(response.value)")
	}
	.responseJSON { response in
		print("Response JSON: \(response.value)")
	}
```



> Bonus2: Response Handler Queue

传入到 response handlers 的闭包默认在 **`.main`** 队列上执行，但是可以传入一个特定的 **`DispatchQueue`** 给闭包。**实际的序列化任务（将 `Data` 类型转换为其它类型）永远都是在背景队列中执行的** 。

```swift
let utilityQueue = DispatchQueue.global(qos: .utility)

AF.request("https://some.api").responseJSON(queue: utilityQueue) { response in
	print("在 utility 队列上执行")
	debugPrint(response)
}
```



### 2.7 响应缓存（Response Cache）

缓存是通过系统提供的 **`URLCache`** 进行处理的，它提过了内存和磁盘缓存。

默认，Alamofire使用 **`URLCache.shared`**  示例进行自定义的缓存



### 2.8 验证 （Authentication）

验证使用的是系统提供的 **`URLCredential`** 和 **`URLAuthenticationChallenge`**（这些验证相关的API适用于向服务器请求授权，不使用于需要身份验证或者响应的请求头）

支持的验证架构：

1. `HTTP Basic`
2. `HTTP Digest`
3. `Kerberos`
4. `NTLM`



> 1. HTTP basic Authentication

在适当的情况下，使用 `URLAuthenticationChallenge` 质询时，请求上的 **`authenticate`** 方法将自动提供 `URLCredential`

```swift
let user = "user"
let password = "password"

AF.request("https://some.api/basic-auth/\(user)/\(password)")
	.authenticate(username: user, password: password)
	.responseJSON { response in
		// ...
	}
	
```



> 2. Authentication with URLCredential

当使用 **`URLCredential`** 进行验证时，如果第一次没有携带 **`credential`**，可能触发服务器的质询，然后发起第二次请求，因此有可能导致2次请求，底层使用的还是 **`URLSession`**

```swift
let user = "user"
let password = "password"

let credential = URLCredential(user: user, password: password, persistence: .forSession)

AF.request("https://some.api/basic-auth/\(user)/\(password)")
	.authenticate(with: credential)
	.responseJSON { response in
		// ...
	}
	
```



> 3. 手动验证（Manual Authentication）

如果请求的某个接口总是需要一个验证，则可以手动的进行添加：

```swift
let user = "user"
let password = "password"

let headers: HTTPHeaders = [.authorization(username: user, password: password)]

AF.request("https://some.api/basic-auth/\(user)/\(password)", headers: headers)
	.responseJSON { response in
		// ...
	}
```



### 2.9 下载数据到文件（Downloading Data to a File）

少量的数据一般下载到内存中，而像视频，图片等大文件，一般会下载到磁盘中。Alamofire提供了 **`Session.download & DownloadRequest & DownloadResponse<Success, Failure: Error>`** 接口，用来下载到磁盘。

```swift
AF.download("https://some.image.png").responseData { response in 
	if let data = response.value {
    let image = UIImage(data: data)
	}
}
```



#### 2.9.1 下载文件路径（Download File Destination）

一般下载的数据会存储在临时目录，它会在未来某个时候被删除，如果想要永久的保存，则需要将下载的目录设置为别的。

可以使用一个 **`Destination`** 闭包。在从临时目录移动到指定目录（**`destinationURL`**）时，可以先执行2个可选的闭包选项：

1. **`createIntermediateDirectories`**: 如果开启这个选项，则会为destinationURL 创建一个中间目录
2. **`.removePreviousFile`**: 如果开启这个选项，删除destinationURL中先前存在的文件

```swift
let destination: DownloadRequest.Destination = { _, _ in
	let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
	let fileURL = documentsURL.appendingPathComponent("image.png")
	return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
}

AF.download("https://some.image.png", to: destination).response { response in
	debugPrint(response)
	
	if response.error == nil, let imagePath = response.fileURL?.path {
    let image = UIImage(contentOfFile: imagePath)
	}
}
```

也可以使用建议的下载路径：

```swift
let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
AF.download("https://some.image.png", to: destination)
```



#### 2.9.2 下载进度（Download Progress）

**`DownloadRequest`** 有一个 **`downloadProgress`** 可用来报告下载进度：

```swift
AF.download("https://some.image.png")
	.downloadProgress { progress in
		print("Download Progress: \(progress.fractionCompleted)")
	}
	.responseData { response in
		if let data = response.value {
    	let image = UIImage(data: data)
		}
	}
```

**注意，报告进度，需要服务器返回的header中包含 `Content-Length` 属性, 没有这个属性，下载过程中，进度会一直是 `0.0`， 完成之后是 `1.0`**。

另外， **`downloadProgress`** 方法还可以接受一个 **`queue`** 作为参数：

```swift
let utilityQueue = DispatchQueue.global(qos: .utility)

AF.download("https://some.image.png")
	.downloadProgress(queue: utilityQueue) { progress in
		print("Download Progress: \(progress.fractionCompleted)")
	}
	.responseData { response in
		if let data = response.value {
    	let image = UIImage(data: data)
		}
	}
```



#### 2.9.4 取消和恢复下载（Cancelling and resuming a Download）

所有的 **`Request`** 类都有一个 **`cancel()`** 方法。 **`DownloadRequest`** 会生成可恢复性数据，这样可用于后续继续下载。有2种形式的接口定义：

1. **`cancel(producingResumeData: Bool)`**: 用于控制是否产生可恢复性数据, 只能用于 **`DownloadResponse`**
2. **`cancel(byProducingResumeData: (_ resumeData: Data?) -> Void)`**: 是可恢复性数据能在闭包中使用。

如果一个 **`DownloadRequest`** 被取消或中断，底层的 **`URLSessionDownloadTask`** 可能产生可恢复性数据。如果产生了这种数据，则该数据在DownloadRequest重启时，能够被重新使用。

```swift
var resumeData: Data!

let download = AF.download("https://some.image.png").responseData { response in
	if let data = response.value {
    let image = UIImage(data: data)
	}
}

// 下载取消 download.cancel(producingResumeData: true)
// 使 resumeData 只在response处可使用
download.cancel { data in
	resumeData = data
}

AF.download(resumingWith: resumeData).responseData { response in
	if let data = response.value {
    let image = UIImage(data: data)
	}
}
```



### 2.10 上传数据到服务器（Upload data to a server）

少量数据一般使用json或者表单的形式进行传递。文件之类或者 **`InputStream`** 一般使用 **`upload()`**



#### 2.10.1 上传Data类型数据（Uploading Data）

```swift
let data = Data("data".utf8)

AF.upload(data, to: "https://some.api/post").responseJSON { response in
	debugPrint(response)
}
```



#### 2.10.2 上传文件（Uploading a File）

```swift
let fileURL = Bundle.main.url(forResource: "video", ofExtension: "mov")

AF.upload(fileURL, to: "https://some.api/post").responseJSON { response in
	// ...
}
```



#### 2.10.3 上传多表单数据（Uploading Multipart Form Data）

```swift
AF.upload(multipartFormData: { multipartFormData in
  multipartFormData.append(Data("one".utf8), withName: "one")
  multipartFormData.append(Data("two".utf8), withName: "two")
}, to: "https://some.api/post")
	.responseJSON { response in
    //...
	}
```



#### 2.10.4 上传进度（uploading Progress）

任何 **`UploadRequest`** 都可以使用 **`uploadProgress`** 和 **`downloadProgress`** 方法报告上传和下载进度

```swift
let fileURL = Bundle.main.url(forResource: "video", ofExtension: "mov")

AF.upload(fileURL, to: "https://some.api/post")
	.uploadProgress { progress in
		print("上传进度: \(progress.fractionCompleted)")
	}
	.downloadProgress { progress in
		print("下载进度: \(progress.fractionCompleted)")
	}
	.responseJSON { response in
		// ...
	}
```



### 2.11 统计指标（Statistical Metrics）

Alamofire会对每个 **`Request`** 收集 **`URLSessionTaskMetrics`**。 **`URLSessionTaskMetrics`** 封装了一些关于底层网络连接和请求相关的一些有用信息：

```swift
AF.request("https://some.api").responseJSON { response in
	print(response.metrics)
}
```



### 2.12 cURL 命令行输出

使用 **`cURLDesciption`** 方法就可以获取这些信息，可用于调试：

```swift
AF.request("https://some.api/get")
	.cURLDescription { description in
		print(description)
	}
	.responseJSON { response in
		// ...
	}
	
// 打印
curl -v \
-X GET \
-H "Accept-Language: en;q=1.0" \
-H "Accept-Encoding: br;q=1.0, gzip;q=0.9, deflate;1=0.8" \
-H "User-Agent: Demo/1.0 (com.demo.Demo; build:1; iOS 13.0.0) Alamofire/1.0" \
"https://some.api.get"
```





  





















