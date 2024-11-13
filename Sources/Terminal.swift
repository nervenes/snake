import Foundation

class Terminal {
    typealias Size = (height: Int, width: Int)
    typealias Position = (x: Int, y: Int)

    private var buffer: [[Character]]

    init() {
        let size = Terminal.getSize()
        buffer = Array(repeating: Array(repeating: " ", count: size.width), count: size.height)

        var oldt = termios()
        tcgetattr(STDIN_FILENO, &oldt)

        var newt = oldt
        newt.c_lflag &= ~(UInt(ICANON) | UInt(ECHO))
        tcsetattr(STDIN_FILENO, TCSANOW, &newt)

        let status = fcntl(STDIN_FILENO, F_SETFL, O_NONBLOCK)
        if status != 0 {
            fatalError("fcntl failed with status \(status)")
        }

        Self.execute(command: .enterAlternateScreen)
        fflush(stdout)
        Self.execute(command: .clearScreen)
        fflush(stdout)
        Self.execute(command: .hideCursor)
        fflush(stdout)
    }

    func draw(_ char: Character, at pos: Position) {
        buffer[pos.y][pos.x] = char
        Self.execute(command: ANSIEscapeCode.moveCursor(x: pos.x, y: pos.y))
        fflush(stdout)
        print(char, terminator: "")
    }

    func clear(at pos: Position) {
        draw(" ", at: pos)
    }

    deinit {
        Self.execute(command: .showCursor)
        fflush(stdout)
        Self.execute(command: .leaveAlternateScreen)
        fflush(stdout)

        var term = termios()
        tcgetattr(STDIN_FILENO, &term)
        term.c_lflag |= (UInt(ICANON) | UInt(ECHO))
        tcsetattr(STDIN_FILENO, TCSANOW, &term)
    }

    static func getSize() -> Size {
        var ws = winsize()
        let status = ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws)
        if status == 0 {
            return (height: Int(ws.ws_row), width: Int(ws.ws_col))
        } else {
            fatalError("ioctl failed with status \(status)")
        }
    }

    static func getInput() -> Character? {
        var buffer = [0 as UInt8]
        let readBytes = read(STDIN_FILENO, &buffer, 1)
        return readBytes > 0 ? Character(UnicodeScalar(buffer[0])) : nil
    }

    static func execute(command: ANSIEscapeCode) {
        print(command.rawValue, terminator: "")
    }

    static func execute(command: String) {
        print(command, terminator: "")
    }

    enum ANSIEscapeCode: String {
        case enterAlternateScreen = "\u{001B}[?1049h"
        case leaveAlternateScreen = "\u{001B}[?1049l"
        case clearScreen = "\u{001B}[2J"
        case hideCursor = "\u{001B}[?25l"
        case showCursor = "\u{001B}[?25h"

        static func moveCursor(x: Int, y: Int) -> String {
            return "\u{001B}[\(y+1);\(x+1)H"
        }
    }
}
