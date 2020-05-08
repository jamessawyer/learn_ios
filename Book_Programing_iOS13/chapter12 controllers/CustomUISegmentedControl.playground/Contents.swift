import UIKit
import PlaygroundSupport

// https://www.codementor.io/@kevinfarst/designing-a-button-bar-style-uisegmentedcontrol-in-swift-cg6cf0dok

extension CGRect {
    init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        self.init(x: x, y: y, width: width, height: height)
    }
}

let buttonBar = UIView()
let segmentedControl = UISegmentedControl()


let titles = ["One", "Two", "Three"]
for (idx, title) in titles.enumerated() {
    segmentedControl.insertSegment(withTitle: title, at: idx, animated: true)
}
segmentedControl.selectedSegmentIndex = 0

//segmentedControl.isMomentary = true //
segmentedControl.backgroundColor = .clear
//segmentedControl.backgroundColor = .red
// 去掉当前选中的高亮
if #available(iOS 13.0, *) {
    segmentedControl.selectedSegmentTintColor = .clear
//    segmentedControl.selectedSegmentTintColor = .red
} else {
    segmentedControl.tintColor = .clear
}


segmentedControl.setTitleTextAttributes([
    .font: UIFont(name: "DINCondensed-Bold", size: 18)!,
    .foregroundColor: UIColor.lightGray
], for: .normal)

segmentedControl.setTitleTextAttributes([
    .font: UIFont(name: "DINCondensed-Bold", size: 18)!,
    .foregroundColor: UIColor.orange
], for: .selected)


segmentedControl.translatesAutoresizingMaskIntoConstraints = false


// 去掉分隔符
segmentedControl.setDividerImage(UIImage().withTintColor(.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

class Responder: NSObject {
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.3) {
            buttonBar.frame.origin.x = (segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments)) * CGFloat(segmentedControl.selectedSegmentIndex)
        }
    }
}


let view = UIView(frame: CGRect(0, 0, 400, 100))
view.backgroundColor = .white


let responder = Responder()
segmentedControl.addTarget(responder, action: #selector(responder.segmentedControlValueChanged(_:)), for: .valueChanged)



view.addSubview(segmentedControl)
NSLayoutConstraint.activate([
    segmentedControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
    segmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor),
    segmentedControl.heightAnchor.constraint(equalToConstant: 40)
])



view.addSubview(buttonBar)
buttonBar.translatesAutoresizingMaskIntoConstraints = false
buttonBar.backgroundColor = .orange
NSLayoutConstraint.activate([
    buttonBar.bottomAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
    buttonBar.leftAnchor.constraint(equalTo: segmentedControl.leftAnchor),
    buttonBar.heightAnchor.constraint(equalToConstant: 5),
    buttonBar.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor, multiplier: 1 / CGFloat(segmentedControl.numberOfSegments))
])




PlaygroundPage.current.liveView = view
