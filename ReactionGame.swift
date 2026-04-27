cat > /tmp/touchid_game.swift << 'SWIFTEOF'
import Foundation
import LocalAuthentication

// ANSI Colors
let reset = "\u{1B}[0m"
let bold = "\u{1B}[1m"
let red = "\u{1B}[31m"
let green = "\u{1B}[32m"
let yellow = "\u{1B}[33m"
let cyan = "\u{1B}[36m"
let magenta = "\u{1B}[35m"
let white = "\u{1B}[97m"

func clearLine() { print("\r\u{1B}[K", terminator: "") }

func printBanner() {
    print("\u{1B}[2J\u{1B}[H") // clear screen
    print(cyan + bold + """
 ██████╗ ███████╗ █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗
 ██╔══██╗██╔════╝██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║
 ██████╔╝█████╗  ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║
 ██╔══██╗██╔══╝  ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║
 ██║  ██║███████╗██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║
 ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
""" + reset)
    print(magenta + bold + "        ⚡  T O U C H  I D  R E A C T I O N  G A M E  ⚡" + reset)
    print(yellow + "          👁️  scan fast. be faster. become the scan. 👁️" + reset)
    print()
}

func getRating(ms: Double) -> String {
    switch ms {
    case ..<475:  return green + bold + "❤️‍🔥 GODLIKE" + reset
    case ..<500:  return green + "⚡ LIGHTNING" + reset
    case ..<600:  return cyan + "💨 SPEEDY" + reset
    case ..<900:  return yellow + "👍 DECENT" + reset
    case ..<1200: return yellow + "😐 MEH" + reset
    default:      return red + "🐢 SLOWPOKE" + reset
    }
}

func authenticate(round: Int, total: Int) -> Double? {
    let context = LAContext()
    context.localizedCancelTitle = "Skip"
    var error: NSError?

    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
        print(red + "❌ Touch ID not available: \(error?.localizedDescription ?? "unknown")" + reset)
        exit(1)
    }

    // Random delay between 2-5 seconds
    let delay = Double.random(in: 2.0...5.0)
    
    print(white + bold + "\n  Round \(round)/\(total)" + reset)
    print(cyan + "  Get your finger ready..." + reset)
    
    // Countdown dots
    var elapsed = 0.0
    let interval = 0.1
    while elapsed < delay {
        Thread.sleep(forTimeInterval: interval)
        elapsed += interval
        let dots = String(repeating: ".", count: Int(elapsed * 2) % 4)
        print("\r  \u{1B}[33mWaiting\(dots)   \u{1B}[0m", terminator: "")
        fflush(stdout)
    }

    print("\r" + red + bold + "  ⚡ GO GO GO!! SCAN NOW!! 🔥🔥🔥" + reset + "     ")
    fflush(stdout)

    let sema = DispatchSemaphore(value: 0)
    var success = false
    var authError: Error? = nil
    let startTime = Date()
    var endTime = Date()

    context.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: "test your reaction time for round \(round) SCAN FAST!! ⚡"
    ) { result, err in
        endTime = Date()
        success = result
        authError = err
        sema.signal()
    }

    sema.wait()

    if success {
        let ms = endTime.timeIntervalSince(startTime) * 1000
        return ms
    } else {
        if let e = authError as? LAError, e.code == .userCancel {
            print(yellow + "\n  ⏭️  Round skipped." + reset)
            return nil
        }
        print(red + "\n  ❌ Auth failed: \(authError?.localizedDescription ?? "unknown")" + reset)
        return nil
    }
}

// ─── MAIN ───────────────────────────────────────────────────────────────────

printBanner()

let totalRounds = 10
var times: [Double] = []
var skipped = 0

print(yellow + "  Press ENTER to start the game..." + reset)
_ = readLine()

for round in 1...totalRounds {
    if round == totalRounds {
        // ─── FINAL ROUND HANDOFF ─────────────────────────────────────────────
        print(white + bold + "\n Round 10/10" + reset)
        print(magenta + bold + "  ╔══════════════════════════════════════╗" + reset)
        print(magenta + bold + "  ║        🏁  FINAL REACTION TEST       ║" + reset)
        print(magenta + bold + "  ╚══════════════════════════════════════╝" + reset)
        print()
        // ✏️ EDIT THIS MESSAGE BELOW ─────────────────────────────────────────
        print(white + bold + "Welcome to the final reaction test. This final round will really challenge your reflexes! To continue, you must ask Seabass for his Rubber Ducky USB to plug into your computer that will send commands to your laptop to open a couple random websites (don't worry, not weird ones) in Google as a distraction. At a random point, you will be asked for your final fingerprint scan. Make sure to be quick and don't get distracted! Same rules still apply, make sure to not press any other buttons except the fingerprint button or else the game will likely break lol." + reset)
        // ✏️ EDIT THIS MESSAGE ABOVE ─────────────────────────────────────────
        print()
        print(yellow + "Waiting for USB connection to start the final round..." + reset)
        _ = readLine()
        exit(0)
    }

    if let ms = authenticate(round: round, total: totalRounds) {
        times.append(ms)
        let rating = getRating(ms: ms)
        print(green + "  ✅ Scanned in " + bold + String(format: "%.0f ms", ms) + reset + "  →  \(rating)")
        Thread.sleep(forTimeInterval: 1.2)
    } else {
        skipped += 1
        Thread.sleep(forTimeInterval: 0.8)
    }
}
SWIFTEOF
clear
echo "🍑 Compiling your game... hang tight bestie (This could take up to a minute)..."
swiftc /tmp/touchid_game.swift -framework LocalAuthentication -o /tmp/touchid_game 2>&1 && echo "✅ Done compiling! Launching NOW 🔥" && /tmp/touchid_game
