//
//  ViewController.swift
//  PlayingCards
//
//  Created by Ксения Каштанкина on 08.03.2020.
//  Copyright © 2020 Ксения Каштанкина. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var playingDeck = Deck()
    
    private var anim = UIDynamicAnimator()
    
    @IBOutlet private var cardViews: [PlayingCardView]!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var cardBihavior = CardBihavior.init(in: animator)
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cards = [Card]()
        for _ in 1...((cardViews.count + 1) / 2) {
            let card = playingDeck.draw()!
            cards += [card, card]
        }
        
        for cardView in cardViews {
            let card = cards.remove(at: cards.count.arc4random)
            cardView.isFacedUp = false
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            cardBihavior.addItem(cardView)
            
        }
        
        self.view.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        let anim = UIViewPropertyAnimator(duration: 3, curve: .linear, animations: { self.view.backgroundColor = #colorLiteral(red: 1, green: 0.793825984, blue: 0, alpha: 1)})
        anim.startAnimation()
        }
        
    
    private var facedUpCardViews : [PlayingCardView] {
        return cardViews.filter({$0.isFacedUp && !$0.isHidden && $0.alpha == 1 && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)})
    }
    
    @IBAction func PushButton(_ sender: UIButton) {
        if cardViews.count >= 0 {
        cardViews[0].animSmth()
        self.anim = UIDynamicAnimator(referenceView: self.view)
            let push = UIPushBehavior(items: cardViews, mode: .continuous)
            push.pushDirection = CGVector(dx: 1, dy: 0)
            self.anim.addBehavior(push)
        let behav = UIGravityBehavior()
            behav.magnitude = 0.1
        self.anim.addBehavior(behav)
        behav.addItem(cardViews[0])
            let col = UICollisionBehavior()
            col.collisionMode = .boundaries
            //col.collisionDelegate = self.view
            col.addBoundary(withIdentifier: "floor" as NSString, from: CGPoint(x: self.view.bounds.minX, y:  self.view.bounds.maxY), to: CGPoint(x: self.view.bounds.maxX, y: self.view.bounds.maxY))
            col.addBoundary(withIdentifier: "wallR" as NSString, from: CGPoint(x: self.view.bounds.maxX, y: self.view.bounds.minY), to: CGPoint(x: self.view.bounds.maxX, y: self.view.bounds.maxY))
            col.addBoundary(withIdentifier: "wallL" as NSString, from: CGPoint(x: self.view.bounds.minX, y: self.view.bounds.minY), to: CGPoint(x: self.view.bounds.minX, y: self.view.bounds.maxY))
            self.anim.addBehavior(col)
            col.addItem(cardViews[0])
            
            let bounce = UIDynamicItemBehavior()
            bounce.elasticity = 0.9
            self.anim.addBehavior(bounce)
            bounce.addItem(cardViews[0])
    
            
        behav.action = {
            let items = self.anim.views(in: self.view.bounds)
            let indx = items.firstIndex(of: self.cardViews[0])
            if indx == nil {
                self.anim.removeAllBehaviors()
                self.cardViews[0].removeFromSuperview()
                self.cardViews.remove(at: 0)
                }
            }
        }
    }
    
    @IBAction func moveSlider(_ sender: UISlider) {
        cardViews[0].animF.fractionComplete = CGFloat(sender.value)
    }
    
    private var facedUpCardsMatch : Bool {
        return facedUpCardViews.count == 2 &&
            facedUpCardViews[0].rank == facedUpCardViews[1].rank &&
            facedUpCardViews[0].suit == facedUpCardViews[1].suit
    }
    
    private var lastChoosenCard : PlayingCardView?
    
    @objc func flipCard(_ recognaizer : UITapGestureRecognizer) {
        switch recognaizer.state {
        case .ended:
            if let choosenCardView = recognaizer.view as? PlayingCardView, facedUpCardViews.count < 2 {
                lastChoosenCard = choosenCardView
                cardBihavior.removeItem(choosenCardView)
                
                UIView.transition(with: choosenCardView, duration: 1, options: [.allowUserInteraction, .transitionFlipFromLeft, .curveEaseIn], animations: {choosenCardView.isFacedUp = !choosenCardView.isFacedUp},
                                  completion: {finished in
                                    let cardsToAnimate = self.facedUpCardViews
                                    if self.facedUpCardsMatch {
                                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 3.0, delay: 0, options: [], animations: { cardsToAnimate.forEach{
                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                            }
                                        }, completion: {position in
                                            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 3.0, delay: 0, options: [], animations: {
                                                cardsToAnimate.forEach {
                                                    $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                                    $0.alpha = 0
                                                }
                                            }, completion: {position in
                                                cardsToAnimate.forEach {
                                                    $0.isHidden = true
                                                    $0.transform = .identity
                                                    $0.alpha = 1
                                                }
                                            })
                                        })
                                    } else
                    if cardsToAnimate.count == 2 {
                        if self.lastChoosenCard == choosenCardView {
                            cardsToAnimate.forEach {
                                cardView in
                                UIView.transition(with: cardView, duration: 2, options: .transitionFlipFromLeft, animations: {cardView.isFacedUp = false},
                                          completion: { finished in self.cardBihavior.addItem(cardView)})
                            }
                        }
                    } else if !choosenCardView.isFacedUp {
                        self.cardBihavior.addItem(choosenCardView)
                                    }
                                    
                }
                )
            }
        default:
            break
        }
    }
    
    func flipCards(_ cardView : PlayingCardView) -> Void {
        if facedUpCardViews.count == 1 && facedUpCardViews[0].suit == cardView.suit && facedUpCardViews[0].rank == cardView.rank && facedUpCardViews[0] != cardView {
            cardViews.remove(at: cardViews!.firstIndex(of: facedUpCardViews[0])!)
            cardViews.remove(at: cardViews!.firstIndex(of: cardView)!)
        } else if facedUpCardViews.count > 1 {
            for eachCard in cardViews {
                eachCard.isFacedUp = false
            }
        }
    }
    
    }

extension UIDynamicAnimator {
    func views(in rect: CGRect) -> [UIView] {
        let nsitem = self.items(in: rect) as NSArray
        return nsitem.compactMap {$0 as? UIView}
    }
}
