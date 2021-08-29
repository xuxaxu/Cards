//
//  PlayingCardsDeck.swift
//  PlayingCards
//
//  Created by Ксения Каштанкина on 08.03.2020.
//  Copyright © 2020 Ксения Каштанкина. All rights reserved.
//

import Foundation

struct Deck {
    private(set) var cards = [Card]()
    
    init() {
        for suit in Card.Suit.all {
            for rank in Card.Rank.all {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
    }
    
    mutating func draw() -> Card? {
        if cards.count > 0 {
            let randomIndex = cards.count.arc4random
            return cards.remove(at: randomIndex)
        } else {
            return nil
        }
    }
}

extension Int {
    var arc4random : Int {
        if self < 0 {
            return Int(arc4random_uniform(UInt32(abs(self))))
        }
        if self == 0 {
            return 0
        } else {
            return Int(arc4random_uniform(UInt32(self)))
        }
    }
}
