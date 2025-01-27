import UIKit

class NVActivityIndicatorAnimationSquareSpin: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let duration: CFTimeInterval = 3
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.09, 0.57, 0.49, 0.9)
        
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "transform")
        
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 0.1]
        animation.timingFunctions = [timingFunction, timingFunction, timingFunction, timingFunction]
        animation.values = [
            NSValue(caTransform3D: CATransform3DConcat(createRotateXTransform(angle: 0), createRotateYTransform(angle: 0))),
            NSValue(caTransform3D: CATransform3DConcat(createRotateXTransform(angle: CGFloat(Double.pi)), createRotateYTransform(angle: 0))),
            NSValue(caTransform3D: CATransform3DConcat(createRotateXTransform(angle: CGFloat(Double.pi)), createRotateYTransform(angle: CGFloat(Double.pi)))),
            NSValue(caTransform3D: CATransform3DConcat(createRotateXTransform(angle: 0), createRotateYTransform(angle: CGFloat(Double.pi)))),
            NSValue(caTransform3D: CATransform3DConcat(createRotateXTransform(angle: 0), createRotateYTransform(angle: 0)))
        ]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw square
        let square = NVActivityIndicatorShape.rectangle.layerWith(size: size, color: color)
        let frame = CGRect(x: (layer.bounds.size.width - size.width) / 2,
                           y: (layer.bounds.size.height - size.height) / 2,
                           width: size.width,
                           height: size.height)
        
        square.frame = frame
        square.add(animation, forKey: "animation")
        layer.addSublayer(square)
    }
    
    func createRotateXTransform(angle: CGFloat) -> CATransform3D {
        var transform = CATransform3DMakeRotation(angle, 1, 0, 0)
        
        transform.m34 = CGFloat(-1) / 100
        
        return transform
    }
    
    func createRotateYTransform(angle: CGFloat) -> CATransform3D {
        var transform = CATransform3DMakeRotation(angle, 0, 1, 0)
        
        transform.m34 = CGFloat(-1) / 100
        
        return transform
    }
}
