//
//  File.swift
//  snake
//
//  Created by Evren Sen on 2024-11-13.
//

import Foundation

enum Direction {
    case right, left, up, down
}

class Game {
    let terminal: Terminal
    
    init(terminal: Terminal) {
        self.terminal = terminal
    }
    
    func run() {
        var pos = (x: 0, y: 0)
        var prePos = (x: 0, y: 0)
        var direction: Direction = .right
        let size = Terminal.getSize()
        
        while true {
            terminal.clear(at: prePos)
            prePos = pos
            
            switch direction {
            case .right: pos.x = (pos.x + 1) % size.width
            case .left: pos.x = (pos.x > 0) ? pos.x - 1 : size.width - 1
            case .up: pos.y = (pos.y > 0) ? pos.y - 1 : size.height - 1
            case .down: pos.y = (pos.y + 1) % size.height
            }
            
            terminal.draw("█", at: pos)
            
            if let input = Terminal.getInput() {
                switch input {
                case "w": direction = .up
                case "a": direction = .left
                case "s": direction = .down
                case "d": direction = .right
                default: break
                }
            }
            
            usleep(75000)
        }
    }
}
