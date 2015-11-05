import CoreGraphics
import simd

extension float2 {
    init(_ point: CGPoint) {
        self.init(x: Float(point.x), y: Float(point.y))
    }

    init(_ vector: CGVector) {
        self.init(x: Float(vector.dx), y: Float(vector.dy))
    }
}

extension CGPoint {
    init(_ vector: CGVector) {
        self = CGPoint(x: vector.dx, y: vector.dy)
    }

    init(_ float: float2) {
        self.init(x: CGFloat(float.x), y: CGFloat(float.y))
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

    init(_ float: float2) {
        self.init(dx: CGFloat(float.x), dy: CGFloat(float.y))
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