//
//  ApiRouter.swift
//  SimpleProject
//
//  Created by Mateusz Wojnar on 14/11/2020.
//  Copyright © 2020 Mateusz Wojnar. All rights reserved.
//

import Foundation
import Alamofire

enum ApiRouter: URLRequestConvertible {

    case getPosts(name: String)

    func asURLRequest() throws -> URLRequest {
        let url = try ApiConstants.baseUrl.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        urlRequest.setValue(ApiConstants.ContentType.json.rawValue, forHTTPHeaderField: ApiConstants.HttpHeaderField.acceptType.rawValue)
        urlRequest.setValue(ApiConstants.ContentType.json.rawValue, forHTTPHeaderField: ApiConstants.HttpHeaderField.contentType.rawValue)

        let encoding: ParameterEncoding = {
            switch method {
            case .get:
                return URLEncoding.default
            default:
                return JSONEncoding.default
            }
        }()

        return try encoding.encode(urlRequest, with: parameters)
    }

    private var method: HTTPMethod {
        switch self {
        case .getPosts:
            return .get
        }
    }

    private var path: String {
        switch self {
        case .getPosts(let name):
            return "guestftp/\(name).json"
        }
    }

    private var parameters: Parameters? {
        switch self {
        case .getPosts(let name):
            return [ApiConstants.Parameters.name : name]
        }
    }
}
