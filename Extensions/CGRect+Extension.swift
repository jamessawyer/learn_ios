/// 获取视图的中心点
/// 示例 比如将子视图v2 居中到 父视图v1中
/// v2.center = v1.bounds.center
extension CGRect {
    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}