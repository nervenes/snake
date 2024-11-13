import Foundation

let terminal = Terminal()

signal(SIGINT) { _ in
    Terminal.shutdown()
}

Game(terminal: terminal).run()

Terminal.shutdown()
