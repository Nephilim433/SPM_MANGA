import UIKit

extension UIView {
    var width: CGFloat {
        return frame.size.width
    }
    var height: CGFloat {
        return frame.size.height
    }
    var left: CGFloat {
        return frame.origin.x
    }
    var right: CGFloat {
        return left + width
    }
    var top: CGFloat {
        return frame.origin.y
    }
    var bottom: CGFloat {
        return top + height
    }
}


enum HexColor: String {
    case pinkishColor = "#FA6B77"
    case customGray = "324148"
}
class ColorHex {
static func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
    }
}

class DynamicLableSize {

    static func heightForZeroLines(text: String?,font: UIFont, width: CGFloat) -> CGFloat {
        var currentHeight: CGFloat!
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.text = text
        label.numberOfLines = 0
        label.font = font
        label.sizeToFit()
        label.lineBreakMode = .byTruncatingTail

        currentHeight = label.frame.height
        label.removeFromSuperview()

        return currentHeight
    }
}


extension UIColor {
    public static var myPink: UIColor {
            return ColorHex.hexStringToUIColor(hex: HexColor.pinkishColor.rawValue)
    }
    public static var myGray: UIColor {
        return ColorHex.hexStringToUIColor(hex: HexColor.customGray.rawValue)
    }
}
