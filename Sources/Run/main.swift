import Foundation
import App

// you should use a proper health-check, but for the demo this is fine
if
    let param = ProcessInfo.processInfo.environment["SLEEP_LENGTH"],
    let duration = UInt32(param), duration > 0
{
    sleep(duration)
}
try app(.detect()).run()