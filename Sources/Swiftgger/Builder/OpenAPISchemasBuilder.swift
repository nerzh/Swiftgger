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

protocol OptionalProtocol {
    func wrappedType() -> Any.Type
}

extension Optional: OptionalProtocol {
     func wrappedType() -> Any.Type {
       return Wrapped.self
     }
}

public func getRequired(_ n: Any) -> [String] {
    var result: [String] = .init()
    let mi = Mirror.init(reflecting: n)
    mi.children.forEach { child in
        if !isOptional(child.value) && child.label != nil {
            result.append(child.label!)
        }
    }
    
    return result
}

public func isOptional(_ instance: Any) -> Bool {
    let mirror = Mirror(reflecting: instance)
    return mirror.displayStyle == .optional
}

public func getPropertiesInfo(_ instance: Any) -> [(name: String, value: Any, type: Any.Type, isOptional: Bool, wrappedType: Any.Type?)] {
    let mirror = Mirror(reflecting: instance)
    var result: [(name: String, value: Any, type: Any.Type, isOptional: Bool, wrappedType: Any.Type?)] = .init()
    mirror.children.forEach { child in
        if let name = child.label {
            let isOptional: Bool = isOptional(child.value)
            result.append((name: name,
                           value: child.value,
                           type: type(of: child.value).self,
                           isOptional: isOptional,
                           wrappedType: isOptional ? (child.value as! OptionalProtocol).wrappedType() : nil))
        }
    }
    return result
}
