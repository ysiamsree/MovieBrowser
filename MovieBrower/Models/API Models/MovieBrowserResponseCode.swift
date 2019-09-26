//
//  MovieBrowserResponseCode.swift
//  MovieBrower
//
//  Created by sreejith on 25/09/19.
//  Copyright © 2019 sreejith. All rights reserved.
//

import Foundation

enum MovieBrowserResponseCode: Int {
    case success = 200
    case validationError = 400
    case serverError = 500
    case notFound = 404
    case unAutherisedAccess = 401
    case forbidden = 403
    case failure = 0
    
    var code: Int { return self.rawValue }
}

class ErrorResponse: Codable {
    var statusCode: Int?
    var message: String?
    private enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case message = "status_message"
    }
    
}
