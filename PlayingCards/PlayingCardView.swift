//
//  PlayingCardView.swift
//  PlayingCards
//
//  Created by Ксения Каштанкина on 11.03.2020.
//  Copyright © 2020 Ксения Каштанкина. All rights reserved.
//

import UIKit

@IBDesignable
class PlayingCardView: UIView, CAAnimationDelegate {
    
    @IBInspectable
    var rank : Int  = 10 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    @IBInspectable
    var suit : String = "♠️" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    @IBInspectable
    var isFacedUp = true { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    private var stringInCorner : NSAttributedString {
        return centeredAttributedString(rankString+"\n"+suit, fontSize: cornerFontSize)
    }
    
    private func centeredAttributedString(_ text: String, fontSize size : CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(size)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle : paragraphStyle, .font : font])
    }
    
    var faceCardScale: CGFloat = cardRatio.fontSizeRatioToBounds {
        didSet {
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    @objc func adjustFaceCardScale(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .ended, .changed:
            faceCardScale *= CGFloat(recognizer.scale)
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    private lazy var upperLeftCornerLabel = createCornerLabel()
    private lazy var downRightCornerLabel = createCornerLabel()
    
    private func createCornerLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    func animSmth() {
        if self.isFacedUp {
            
            var p = upperLeftCornerLabel.frame.origin
            let dur = 0.25
            var start = 0.0
            let dx = CGFloat(100)
            let dy : CGFloat = 30
            var dir = CGFloat(1)
            UIView.animateKeyframes(withDuration: 10, delay: 3, options: .autoreverse, animations: {
                UIView.addKeyframe(withRelativeStartTime: start, relativeDuration: dur, animations: {
                    p.x += dx * dir
                    p.y += dy
                    self.upperLeftCornerLabel.frame.origin = p
                })
                dir *= -1
                start += dur
                UIView.addKeyframe(withRelativeStartTime: start, relativeDuration: dur, animations: {
                    p.x += dx * dir
                    p.y += dy
                    self.upperLeftCornerLabel.frame.origin = p
                })
                dir *= -1
                start += dur
                UIView.addKeyframe(withRelativeStartTime: start, relativeDuration: dur, animations: {
                    p.x += dx * dir
                    p.y += dy
                    self.upperLeftCornerLabel.frame.origin = p
                })
                start += dur
                dir *= -1
                UIView.addKeyframe(withRelativeStartTime: start, relativeDuration: dur, animations: {
                    p.x += dx * dir
                    p.y += dy
                    self.upperLeftCornerLabel.frame.origin = p
                })
            }, completion: nil)
            
        }
    }
    
    var animF : UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 2, curve: .easeInOut)
    
    var makeAnim = false {
        didSet {
            frame.origin.x = makeAnim ? frame.origin.x + 50 : frame.origin.x - 50
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    private func configureCornerLabel(_ label: UILabel) {
        label.attributedText = stringInCorner
        label.frame.size = CGSize.zero
        label.sizeToFit()
        label.isHidden = !isFacedUp
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureCornerLabel(upperLeftCornerLabel)
        upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
        configureCornerLabel(downRightCornerLabel)
        downRightCornerLabel.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi)
        downRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY).offsetBy(dx: -cornerOffset, dy: -cornerOffset).offsetBy(dx: -downRightCornerLabel.frame.size.width, dy: -downRightCornerLabel.frame.size.height)
        
    }
    
    private func drawPips() {
        let pipsPerRowByRank = [[0], [1], [1,1], [1,1,1], [2,2], [2,1,2], [2,2,2], [2,1,2,2], [2,2,2,2], [2,2,1,2,2], [2,2,2,2,2]]
        
        func createPipsString (fitTo pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowByRank.reduce(0) {max($1.count, $0)})
            let maxHorizontalPipCount = CGFloat(pipsPerRowByRank.reduce(0) {max($1.max() ?? 0, $0)})
            let verticalRowPipSpace = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalRowPipSpace)
            let probablyOkPipFontSize = verticalRowPipSpace / (attemptedPipString.size().height / verticalRowPipSpace)
            let probablyOkPipString = centeredAttributedString(suit, fontSize: probablyOkPipFontSize)
            if probablyOkPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(suit, fontSize: probablyOkPipFontSize / (probablyOkPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            }
            else { return probablyOkPipString}
        }
        
        if pipsPerRowByRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowByRank[rank]
            var pipRect = bounds.insetBy(dx: cardRatio.cornerOffsetToBounds, dy: cardRatio.cornerOffsetToBounds).insetBy(dx: stringInCorner.size().width , dy: stringInCorner.size().height / 2)
            let pipsString = createPipsString(fitTo: pipRect)
            let pipRowSpace = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipsString.size().height
            pipRect.origin.y += (pipRowSpace - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                case 1:
                    pipsString.draw(in: pipRect)
                case 2:
                    pipsString.draw(in: pipRect.leftHalf)
                    pipsString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpace
            }
        }
    }
    
     override func draw(_ rect: CGRect) {
        // Drawing code
        
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: radiusCorner)
        UIColor.white.setFill()
        roundedRect.fill()
        roundedRect.addClip()
        
        if isFacedUp {
            if let cardImage = UIImage(named: rankString+suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                
                cardImage.draw(in: bounds.insetBy(dx: 40, dy: 70))
                
                
            }
            else {
                drawPips()
            }
        } else {
            if let cardBack = UIImage(named: "cardBack", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                
                cardBack.draw(in: bounds)
                
                
                
            }
            
            
            
        }
    }

}


extension PlayingCardView {
    private struct cardRatio {
        static var fontSizeRatioToBounds : CGFloat = 0.08
        static var cornerRadiusToBounds : CGFloat = 0.06
        static var cornerOffsetToBounds : CGFloat = 0.06
        static var faceSizeToBounds : CGFloat = 0.75
    }
    
    private var radiusCorner : CGFloat {
        return bounds.height * cardRatio.cornerRadiusToBounds    }
    
    private var cornerOffset : CGFloat {
        return bounds.size.height * cardRatio.cornerOffsetToBounds
    }
    
    private var cornerFontSize : CGFloat {
        return bounds.size.height * cardRatio.fontSizeRatioToBounds
    }
    
    private var rankString : String {
        switch rank {
        case 1: return "A"
        case 2...10 : return String(rank)
        case 11 : return "J"
        case 12 : return "Q"
        case 13 : return "K"
        default: return ""
        }
    }
}

extension CGPoint {
    func offsetBy (dx: CGFloat, dy : CGFloat) -> CGPoint {
        return CGPoint(x : x + dx, y : y + dy)
    }
}

extension CGRect {
    var leftHalf : CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var rightHalf : CGRect {
        return CGRect(x : midX, y : minY, width: width/2, height: height)
    }
    func inset(by size : CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(to size : CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    func zoom(by scale : CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth)/2, dy: (height - newHeight)/2)
    }
}
