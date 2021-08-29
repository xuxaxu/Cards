//
//  CardBihavior.swift
//  PlayingCards
//
//  Created by Ксения Каштанкина on 08.06.2020.
//  Copyright © 2020 Ксения Каштанкина. All rights reserved.
//

import UIKit

class CardBihavior: UIDynamicBehavior {
    
    lazy var collisionBehavor : UICollisionBehavior = {
       let behavor = UICollisionBehavior()
        behavor.translatesReferenceBoundsIntoBoundary = true
        return behavor
    }()
    
    lazy var itemBehavior : UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = 1.0
        behavior.resistance = 0
        return behavior
    }()
    
    private func pushBihavior(_ item : UIDynamicItem) {
        let pushBehavior = UIPushBehavior(items: [item], mode: .instantaneous)
        
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y < center.y :
                pushBehavior.angle = CGFloat.random(in: 0...(CGFloat.pi/2))
            case let (x, y) where x > center.x && y < center.y :
                pushBehavior.angle = CGFloat.pi - CGFloat.random(in: 0...(CGFloat.pi/2))
            case let (x, y) where x < center.x && y > center.y :
                pushBehavior.angle = CGFloat(-1) * CGFloat.random(in: 0...(CGFloat.pi/2))
            case let (x, y) where x > center.x && y > center.y :
                pushBehavior.angle = CGFloat.pi + CGFloat.random(in: 0...(CGFloat.pi / 2))
            default:
                pushBehavior.angle = CGFloat.random(in: 0...(2*CGFloat.pi))
            }
        }
        
        pushBehavior.magnitude = 1.0 + CGFloat.random(in: 0...2.0)
        pushBehavior.action = { [unowned pushBehavior,  weak self] in
            self?.removeChildBehavior(pushBehavior)
        }
        addChildBehavior(pushBehavior)
    }

    func addItem(_ item: UIDynamicItem){
        collisionBehavor.addItem(item)
        itemBehavior.addItem(item)
        pushBihavior(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavor.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavor)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
