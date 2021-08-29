//
//  Card.swift
//  PlayingCards
//
//  Created by Ксения Каштанкина on 08.03.2020.
//  Copyright © 2020 Ксения Каштанкина. All rights reserved.
//

import Foundation

struct Card : CustomStringConvertible {
    var suit : Suit
    var rank : Rank
    
    var description: String { return "\(rank)\(suit)" }
    
    enum Suit : String, CustomStringConvertible {
        
        var description: String {
            let suit = self
            return suit.rawValue
        }
        case hearts = "♥️"
        case diamonds = "♦️"
        case clubs = "♣️"
        case spades = "♠️"
        
        static var all = [Suit.spades, .hearts, .clubs, .diamonds]
    }
    
    enum Rank : CustomStringConvertible {
        case numeric(Int)
        case faces(Faces)
        case ace
        
        var description: String {
            switch self {
            case .ace : return "A"
            case .faces(let face) : return String(face)
            case .numeric(let pips) : return String(pips)
            }
        }
        
        enum Faces : LosslessStringConvertible {
            init?(_ description: String) {
                switch description {
                case "J":
                    self = .jack
                case "K" : self = .king
                case "Q" : self = .queen
                default:
                    self = .jack
                }
            }
            
            var description: String {
                switch  self {
                case .jack : return "J"
                case .king : return "K"
                case .queen : return "Q"
                }
            }
            
               case jack
               case queen
               case king
           }
        
        var order : Int {
            switch self {
            case .ace : return 1
            case .numeric(let count) : return count
            case .faces(let face) where face == Faces.jack : return 12
            case .faces(let face) where face == Faces.queen : return 13
            case .faces(let face) where face == Faces.king : return 14
            default : return 0
            }
        }
        
        static var all : [Rank] {
            var allRank : [Rank] = [.ace]
            for index in 2...10 {
                allRank.append(.numeric(index))
            }
            allRank += [.faces(.jack), .faces(.queen), .faces(.king)]
            return allRank
        }

        
    }
    
}
