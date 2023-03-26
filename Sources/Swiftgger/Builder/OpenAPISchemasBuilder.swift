//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import AnyCodable

/// Builder for object information stored in `components/schemas` part of OpenAPI.
class OpenAPISchemasBuilder {

    let objects: [APIObjectProtocol]
    let keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy

    private var nestedObjects: [Any] = []

    init(objects: [APIObjectProtocol], keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy) {
        self.objects = objects
        self.keyEncodingStrategy = keyEncodingStrategy
    }

    func built() -> [String: OpenAPISchema] {

        var schemas: [String: OpenAPISchema] = [:]
        let objectsNames = self.objects.map { object in String(describing: type(of: object.anyObject)) }
        
        for object in self.objects {
            guard let anyEncodable = object.anyObject as? Encodable else {
                continue
            }
            
            let openAPISchemaConverter = OpenAPISchemaConverter(keyEncodingStrategy: self.keyEncodingStrategy)
            let objectSchema = openAPISchemaConverter.convert(APIObjectEncodable(anyEncodable), referencedObjects: objectsNames)

            let requestMirror: Mirror = Mirror(reflecting: object.anyObject)
            let mirrorObjectType = object.customName ?? String(describing: requestMirror.subjectType)

            if schemas[mirrorObjectType] == nil {
                let requestSchema = OpenAPISchema(type: "object", required: getRequired(anyEncodable), properties: objectSchema)
                schemas[mirrorObjectType] = requestSchema
            }
        }

        return schemas
    }
}


func getRequired(_ n: Any) -> [String] {
    func isOptional(_ instance: Any) -> Bool {
        let mirror = Mirror(reflecting: instance)
        let style = mirror.displayStyle
        return style == .optional
    }
    var result: [String] = .init()
    let mi = Mirror.init(reflecting: n)
    mi.children.forEach { child in
        if !isOptional(child.value) && child.label != nil {
            result.append(child.label!)
        }
    }
    
    return result
}
