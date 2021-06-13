//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

extension Encodable {
    fileprivate func openedEncode(to container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
}

struct APIObjectEncodable : Encodable {
    var value: Encodable
    
    init(_ value: Encodable) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.openedEncode(to: &container)
    }
}
