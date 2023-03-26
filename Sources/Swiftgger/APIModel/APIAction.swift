//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

/// Objects stores information about single API action.
public class APIAction {

    var method: APIHttpMethod
    var route: String
    var summary: String
    var description: String
    var parameters: [APIParameter]?
    var request: APIRequest?
    var responses: [APIResponse]?
    var authorization: Bool = false

    public init(
        method: APIHttpMethod,
        route: String,
        summary: String,
        description: String,
        parameters: [APIParameter]? = nil,
        request: APIRequest? = nil,
        responses: [APIResponse]? = nil,
        authorization: Bool = false
    ) {
        self.method = method
        self.route = route
        self.summary = summary
        self.description = description
        self.parameters = parameters
        self.request = request
        self.responses = responses
        self.authorization = authorization
    }
    
    public init(
        method: APIHttpMethod,
        route: String,
        summary: String,
        description: String,
        parametersObject: Any,
        request: APIRequest? = nil,
        responses: [APIResponse]? = nil,
        authorization: Bool = false
    ) {
        self.method = method
        self.route = route
        self.summary = summary
        self.description = description
        self.request = request
        self.responses = responses
        self.authorization = authorization
        self.parameters = []
        getPropertiesInfo(parametersObject).forEach { property in
            if property.isOptional, property.wrappedType != nil {
                if let valueType = APIDataType(fromSwiftType: property.wrappedType!) {
                    self.parameters!.append(
                        APIParameter(name: property.name, parameterLocation: .query, required: !property.isOptional, dataType: valueType)
                    )
                }
            } else {
                if let valueType = APIDataType(fromSwiftType: property.type) {
                    self.parameters!.append(
                        APIParameter(name: property.name, parameterLocation: .query, required: !property.isOptional, dataType: valueType)
                    )
                }
            }
        }
    }
}
