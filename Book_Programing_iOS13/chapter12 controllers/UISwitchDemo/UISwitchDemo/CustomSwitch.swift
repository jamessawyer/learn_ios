/// [CustomUISwitch](https://github.com/factoryhr/CustomUISwitch)
/// [自定义UISwitch - part1](https://medium.com/@factoryhr/making-custom-uiswitch-part-1-cc3ab9c0b05b)
/// [自定义UISwitch - part2](https://factory.hr/blog/uiswitch-part-2)
/// [layoutSubviews、layoutIfNeeded、setNeedsLayout、setNeedsDisplay、drawRect](https://www.jianshu.com/p/be89e2f9be21)

/// 功能
/// 1. 自定义背景色颜色 onTintColor & offTintColor
/// 2. 自定义尺寸 和 cornerRadius
/// 3. 自定义滑块颜色 thumbTintColor
/// 4. 自定义滑块尺寸和形状
/// 5. 是否显示文字labels: areLabelsShown
/// 6. 滑块on & off 时 使用图片的形式：onImage & offImage


import UIKit

@IBDesignable
class CustomSwitch: UIControl {
    
    // MARK: Public properties
    public var animationDelay: Double = 0
    public var animationSpriteWithDamping = CGFloat(0.7)
    public var initialSpringVelocity = CGFloat(0.5)
    public var animationOptions: UIView.AnimationOptions = [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction]
    
    
    @IBInspectable public var isOn: Bool = true // 是否是开启的
    public var animationDuration: Double = 0.5  // 动画时长
    
    // 内边距
    @IBInspectable public var padding: CGFloat = 2 {
        didSet {
            self.layoutSubviews()
        }
    }
    
    // on 时背景色
    // 如果要使用 @IBInspectable 则需要显式的将属性类型写出来
    @IBInspectable public var onTintColor: UIColor = UIColor(red: 144/255, green: 202/255, blue: 119/255, alpha: 1) {
        didSet {
            self.setupUI()
        }
    }
    // off 时的背景色
    public var offTintColor: UIColor = UIColor.lightGray {
        didSet {
            self.setupUI()
        }
    }
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return self.privateCornerRadius
        }
        set {
            if newValue > 0.5 || newValue < 0.0 {
                privateCornerRadius = 0.5
            } else {
                privateCornerRadius = newValue
            }
        }
        
    }
    private var privateCornerRadius: CGFloat = 0.5 {
        didSet {
            self.layoutSubviews()
        }
    }
    
    // thumb 是 UISwitch ⭕️部分
    public var thumbTintColor = UIColor.white {
        didSet {
            self.thumbView.backgroundColor = self.thumbTintColor
        }
    }
    
    @IBInspectable public var thumbCornerRadius: CGFloat {
        get {
            return self.privateThumbCornerRadius
        }
        set {
            if newValue > 0.5 || newValue < 0.0 {
                privateThumbCornerRadius = 0.5
            } else {
                privateThumbCornerRadius = newValue
            }
        }
        
    }
    private var privateThumbCornerRadius: CGFloat = 0.5 {
        didSet {
            self.layoutSubviews()
            
        }
    }
    
    @IBInspectable public var thumbSize = CGSize.zero {
        didSet {
            self.layoutSubviews()
        }
    }
    
    @IBInspectable public var thumbImage: UIImage? = nil {
        didSet {
            guard let image = thumbImage else {
                return
            }
            thumbView.thumbImageView.image = image
        }
    }
    
    public var onImage: UIImage? {
        didSet {
            self.onImageView.image = onImage
            self.layoutSubviews()
            
        }
        
    }
    public var offImage: UIImage? {
        didSet {
            self.offImageView.image = offImage
            self.layoutSubviews()
        }
    }
    /// 滑块阴影
    @IBInspectable public var thumbShadowColor: UIColor = UIColor.black {
        didSet {
            self.thumbView.layer.shadowColor = self.thumbShadowColor.cgColor
        }
    }
    @IBInspectable public var thumbShadowOffset: CGSize = CGSize(width: 0.75, height: 2) {
        didSet {
            self.thumbView.layer.shadowOffset = self.thumbShadowOffset
        }
    }
    @IBInspectable public var thumbShadowRadius: CGFloat = 1.5 {
        didSet {
            self.thumbView.layer.shadowRadius = self.thumbShadowRadius
        }
    }
    @IBInspectable public var thumbShadowOpacity: Float = 0.4 {
        didSet {
            self.thumbView.layer.shadowOpacity = self.thumbShadowOpacity
        }
    }
    
    
    // labels
    public var labelOff: UILabel = UILabel()
    public var labelOn: UILabel = UILabel()
    // 是否显示labels 默认为false
    public var areLabelsShown: Bool = false {
        didSet {
            self.setupUI()
        }
    }
    
    // UISwitch ⭕️部分的属性
    public var thumbView = CustomThumbView(frame: CGRect.zero)
    public var onImageView = UIImageView(frame: CGRect.zero)
    public var offImageView = UIImageView(frame: CGRect.zero)
    public var onPoint = CGPoint.zero  // on 时滑块的位置
    public var offPoint = CGPoint.zero // off 时滑块的位置
    public var isAnimating = false     // 是否正在动画
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
}

extension CustomSwitch {
    func setupUI(){
        self.clear()
        self.clipsToBounds = false
        self.thumbView.backgroundColor = self.thumbTintColor
        self.thumbView.isUserInteractionEnabled = false
        self.thumbView.layer.shadowColor = self.thumbShadowColor.cgColor
        self.thumbView.layer.shadowRadius = self.thumbShadowRadius
        self.thumbView.layer.shadowOpacity = self.thumbShadowOpacity
        self.thumbView.layer.shadowOffset = self.thumbShadowOffset

        self.addSubview(self.thumbView)
        
        self.addSubview(self.onImageView)
        self.addSubview(self.offImageView)
        
        self.setupLabels()
    }
    
    // 移除所有子视图 以防我们需要重制UI
    private func clear() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    // UIControl 提供的方法
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        self.animate()
        return true
    }
    
    fileprivate func animate(on: Bool? = nil) {
        self.isOn = on ?? !self.isOn
        self.isAnimating = true
        
        UIView.animate(withDuration: self.animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseOut, .beginFromCurrentState], animations: {
            self.setupViewsOnAction()
        }) { (_) in
            self.isAnimating = false
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    private func setupViewsOnAction() {
        self.thumbView.frame.origin.x = self.isOn ? self.onPoint.x : self.offPoint.x
        self.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
        self.setOnOffImageFrame()
    }
}


extension CustomSwitch {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isAnimating {
            self.layer.cornerRadius = self.bounds.size.height * self.cornerRadius
            self.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
            
            //            let thumbSize = self.thumbSize != CGSize.zero ? self.thumbSize : CGSize(width: self.bounds.size.height - 2, height: self.bounds.height - 2)
            // 滑块的尺寸 高度 = 总高度 - padding * 2; 宽度 = (总宽度 - padding * 2) / 2 即一半
            let thumbSize = self.thumbSize != CGSize.zero ? self.thumbSize : CGSize(width: (self.bounds.size.width - self.padding * 2) / 2, height: self.bounds.height - self.padding * 2)
            
            let yPostition = (bounds.size.height - thumbSize.height) / 2
            
            self.onPoint = CGPoint(x: self.bounds.size.width - thumbSize.width - self.padding, y: yPostition)
            self.offPoint = CGPoint(x: self.padding, y: yPostition)
            
            self.thumbView.frame = CGRect(origin: self.isOn ? self.onPoint : self.offPoint, size: thumbSize)
            
            self.thumbView.layer.cornerRadius = thumbSize.height * self.thumbCornerRadius
        }
        
        if self.areLabelsShown {
            let labelWidth = self.bounds.width / 2 - self.padding * 2
            self.labelOn.frame = CGRect(x: 0, y: 0, width: labelWidth, height: self.frame.height)
            self.labelOff.frame = CGRect(x: self.frame.width - labelWidth, y: 0, width: labelWidth, height: self.frame.height)
        }
        
        guard onImage != nil && offImage != nil else {
            return
        }
        let frameSize = thumbSize.width > thumbSize.height ? thumbSize.height * 0.7 : thumbSize.width * 0.7
        let onOffImageSize = CGSize(width: frameSize, height: frameSize)
        self.onImageView.center = CGPoint(x: self.onPoint.x + self.thumbSize.width / 2, y: self.onPoint.y + self.thumbSize.height / 2)
        self.offImageView.center = CGPoint(x: self.onPoint.x + self.thumbSize.width / 2, y: self.onPoint.y + self.thumbSize.height / 2)
        self.onImageView.frame.size = onOffImageSize
        self.offImageView.frame.size = onOffImageSize
        self.onImageView.alpha = self.isOn ? 1.0 : 0.0
        self.offImageView.alpha = self.isOn ? 0.0 : 1.0
    }
}

extension CustomSwitch {
    // 添加文字
    fileprivate func setupLabels() {
        guard self.areLabelsShown else {
            self.labelOff.alpha = 0.0
            self.labelOn.alpha = 0.0
            return
        }
        self.labelOff.alpha = 1.0
        self.labelOn.alpha = 1.0
        
        let labelWidth = self.bounds.width / 2 - self.padding * 2
        
        self.labelOn.frame = CGRect(x: 0, y: 0, width: labelWidth, height: self.frame.height)
        self.labelOn.font = UIFont.boldSystemFont(ofSize: 12)
        self.labelOn.textColor = UIColor.white
        self.labelOn.sizeToFit()
        self.labelOn.text = "On"
        self.labelOn.textAlignment = .center
        
        self.labelOff.frame = CGRect(x: self.frame.width - labelWidth, y: 0, width: labelWidth, height: self.frame.height)
        self.labelOff.font = UIFont.boldSystemFont(ofSize: 12)
        self.labelOff.textColor = UIColor.white
        self.labelOff.sizeToFit()
        self.labelOff.text = "Off"
        self.labelOff.textAlignment = .center
        
        self.insertSubview(self.labelOn, belowSubview: self.thumbView)
        self.insertSubview(self.labelOff, belowSubview: self.thumbView)
        
    }
}

// MARK - Animating on/off images
extension CustomSwitch {
    fileprivate func setOnOffImageFrame() {
        self.onImageView.center.x = self.isOn ? self.onPoint.x + self.thumbSize.width / 2 : self.frame.width
        self.offImageView.center.x = !self.isOn ? self.offPoint.x + self.thumbSize.width / 2 : 0
        self.onImageView.alpha = self.isOn ? 1.0 : 0.0
        self.offImageView.alpha = self.isOn ? 0.0 : 1.0
    }
}

//class CustomSwitch: UIControl {
//
//    var onTintColor = UIColor(red: 144/255, green: 202/255, blue: 119/255, alpha: 1)
//    var offTintColor = UIColor.lightGray
//    var cornerRadius: CGFloat = 0.5
//
//    // thumb 是 UISwitch ⭕️部分
//    var thumbTintColor = UIColor.white
//    var thumbCornerRadius: CGFloat = 0.5
//    var thumbSize = CGSize.zero
//
//    var padding:CGFloat = 1
//
//    var isOn = true
//    var animationDuration: Double = 0.5
//
//    // UISwitch ⭕️部分的属性
//    fileprivate var thumbView = UIView(frame: CGRect.zero)
//    fileprivate var onPoint = CGPoint.zero
//    fileprivate var offPoint = CGPoint.zero
//    fileprivate var isAnimating = false
//
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupUI()
//    }
//
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        if !isAnimating {
//            self.layer.cornerRadius = self.bounds.size.height * self.cornerRadius
//            self.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
//
//            let thumbSize = self.thumbSize != CGSize.zero ? self.thumbSize : CGSize(width: self.bounds.size.height - 2, height: self.bounds.height - 2)
//            let yPostition = (bounds.size.height - thumbSize.height) / 2
//
//            self.onPoint = CGPoint(x: self.bounds.size.width - thumbSize.width - self.padding, y: yPostition)
//            self.offPoint = CGPoint(x: self.padding, y: yPostition)
//
//            self.thumbView.frame = CGRect(origin: self.isOn ? self.onPoint : self.offPoint, size: thumbSize)
//
//            self.thumbView.layer.cornerRadius = thumbSize.height * self.thumbCornerRadius
//        }
//    }
//
//
//
//    func setupUI(){
//        self.clear()
//        self.clipsToBounds = false
//        self.thumbView.backgroundColor = self.thumbTintColor
//        self.thumbView.isUserInteractionEnabled = false
//        self.thumbView.layer.shadowColor = UIColor.black.cgColor
//        self.thumbView.layer.shadowRadius = 1.5
//        self.thumbView.layer.shadowOpacity = 0.4
//        self.thumbView.layer.shadowOffset = CGSize(width: 0.75, height: 2)
//        self.addSubview(self.thumbView)
//    }
//
//    // 移除所有子视图 以防我们需要重制UI
//    private func clear() {
//        for view in self.subviews {
//            view.removeFromSuperview()
//        }
//    }
//
//    private func animate() {
//        self.isOn = !self.isOn
//        self.isAnimating = true
//
//        UIView.animate(withDuration: self.animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseOut, .beginFromCurrentState], animations: {
//            self.thumbView.frame.origin.x = self.isOn ? self.onPoint.x : self.offPoint.x
//            self.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
//        }) { (_) in
//            self.isAnimating = false
//            self.sendActions(for: UIControl.Event.valueChanged)
//        }
//    }
//
//    // UIControl 提供的方法
//    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
//        super.beginTracking(touch, with: event)
//
//        self.animate()
//        return true
//    }
//
//}
