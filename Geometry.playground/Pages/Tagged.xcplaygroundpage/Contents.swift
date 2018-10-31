import Foundation
@testable import MotionFramework

let usersJson = """
[
    {
        "id": 1,
        "name": "Brandon",
        "email": "brandon@pointfree.co",
        "subscriptionId": 1
    },
    {
        "id": 2,
        "name": "Stephen",
        "email": "stephen@pointfree.co",
        "subscriptionId": null
    },
    {
        "id": 3,
        "name": "Blob",
        "email": "blob@pointfree.co",
        "subscriptionId": 1
    }
]
"""

let subscriptionsJson = """
[
    {
        "id": 1,
        "ownerId": 1
    }
]
"""

enum EmailTag {}
typealias Email = Tagged<EmailTag, String>

struct Subscription: Decodable {
    typealias Id = Tagged<Subscription, Int>
    let id: Id
    let ownerId: User.Id
}

struct User: Decodable {
    typealias Id = Tagged<User, Int>
    let id: Id
    let name: String
    let email: Email
    let subscriptionId: Subscription.Id?
}

let decoder = JSONDecoder()
let users = try! decoder.decode([User].self, from: Data(usersJson.utf8))
let subscriptions = try! decoder.decode([Subscription].self, from: Data(subscriptionsJson.utf8))

let user = users[0]

subscriptions
    .first(where: { $0.id == user.subscriptionId })

User(
    id: 1,
    name: "Blob",
    email: "blob@pointfree.co",
    subscriptionId: 2
)
