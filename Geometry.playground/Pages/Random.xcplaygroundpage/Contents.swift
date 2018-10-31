import PlaygroundSupport
@testable import MotionFramework
import Overture

func uint8(in range: ClosedRange<UInt8>) -> Gen<UInt8> {
    return int(in: Int(range.lowerBound)...Int(range.upperBound))
        .map(UInt8.init)
}

let uint8: UInt8 = 240
let anInt = Int(uint8)

let string = uint8(in: .min ... .max)
    .map(pipe(UnicodeScalar.init, String.init))
    .array(count: int(in: 0...280))
    .map { $0.joined() }

struct User {
    typealias Id = Tagged<User, UUID>
    var id: Id
    var name: String
    var email: String
}

let alpha = element(of: Array("abcdefghijklmnopqrstuvxcyz")).map { $0! }

let namePart = alpha.string(count: int(in: 4...8))
let capitalNamePart = namePart.map { $0.capitalized }
let randomName = Gen<String> { capitalNamePart.run() + " " + capitalNamePart.run() }

let randomEmail = namePart.map { $0 + "@pointfree.co" }

let randomId = int(in: 1 ... 1_000)

let hex = element(of: Array("0123456789ABCDEF")).map { $0! }

let uuidString = Gen {
    hex.string(count: .init { 8 }).run()
        + "-" + hex.string(count: .init { 4 }).run()
        + "-" + hex.string(count: .init { 4 }).run()
        + "-" + hex.string(count: .init { 4 }).run()
        + "-" + hex.string(count: .init { 12 }).run()
}

let randomUuid = uuidString.map(UUID.init).map { $0! }
randomUuid.run()


let randomUser = zip3(with: User.init)(
    randomUuid.map(User.Id.init),
    randomName,
    randomEmail
)

let result = randomUser
    .array(count: .init { 4 })
    .run()
    .forEach { print($0) }
