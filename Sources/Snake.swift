import Foundation

@main
struct Snake {
    static func main() {
        var terminal: Terminal! = Terminal()
        let queue = DispatchQueue(label: "signal")

        signal(SIGINT, SIG_IGN)

        let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: queue)
        source.setEventHandler {
            terminal = nil
            exit(0)
        }
        source.resume()

        Game(terminal: terminal).run()

        source.cancel()
        terminal = nil
    }
}
