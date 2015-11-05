import CoreGraphics

extension CGPoint {
    init(_ vector: CGVector) {
        self = CGPoint(x: vector.dx, y: vector.dy)
    }
}

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func +=(inout left: CGPoint, right: CGPoint) {
    left = left + right
}

extension CGVector {
    static var zero: CGVector {
        return CGVector(dx: 0, dy: 0)
    }

    var length: CGFloat {
        return sqrt(dx * dx + dy * dy)
    }

    var normalize: CGVector {
        let length = self.length
        if length == 0 {
            return CGVector.zero
        } else {
            return CGVectorMake(dx / length, dy / length)
        }
    }
}

func ==(left: CGVector, right: CGVector) -> Bool {
    return left.dx == right.dx && left.dy == right.dy
}

func +(left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
}

func +=(inout left: CGVector, right: CGVector) {
    left = left + right
}

func -(left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx - right.dx, dy: left.dy - right.dy)
}

func -=(inout left: CGVector, right: CGVector) {
    left = left - right
}

func *(left: CGVector, right: CGFloat) -> CGVector {
    return CGVector(dx: left.dx * right, dy: left.dy * right)
}

func *=(inout left: CGVector, right: CGFloat) {
    left = left * right
}

func /(left: CGVector, right: CGFloat) -> CGVector {
    return CGVector(dx: left.dx / right, dy: left.dy / right)
}

func /=(inout left: CGVector, right: CGFloat) {
    left = left / right
}