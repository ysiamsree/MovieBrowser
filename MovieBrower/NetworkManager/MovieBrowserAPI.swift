//
//  MovieBrowserAPI.swift
//  MovieBrower
//
//  Created by sreejith on 24/09/19.
//  Copyright © 2019 sreejith. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

enum MovieBrowser {
    case search(Int, String)
    case discover(Int, String)
    case find
    case downloadImage(Int)
}
let accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0ZmUxNGU5ZTkyYTJlNmQwZDQwN2NkODNlZjUxZGY2YyIsInN1YiI6IjVkOGE0NDY1YzU4YWNkMDAyOTJmNjIxZiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.YhsrPXIv85yLqupnCAHyNI9uMBiQDwPmAn62HNsb-SU"
let apiKey = "4fe14e9e92a2e6d0d407cd83ef51df6c"
extension MovieBrowser {
    public var baseURL: URL { return URL(string: "https://api.themoviedb.org/3/")!}
    
    public var path: String {
        switch self {
        case .search(let page, let query):
            if query.isEmpty {
                return "search/movie?api_key=\(apiKey)&page=\(page)"
            } else {
                let trimmedQuery = query.replacingOccurrences(of: " ", with: "%20")
                print("trimmed", trimmedQuery)
                return "search/movie?api_key=\(apiKey)&page=\(page)&query=\(trimmedQuery)"
            }
        case .discover(let page, let sortOrder):
            return "discover/movie?api_key=\(apiKey)&page=\(page)&sort_by=\(sortOrder)"
        case .find:
            return "find"
        case .downloadImage(let id):
            return "movie/\(id)/image?api_key=\(apiKey)"
        }
    }
    
    public func url() -> String {
        print(self.baseURL.appendingPathComponent(self.path).absoluteString.removingPercentEncoding!)
        return self.baseURL.appendingPathComponent(self.path).absoluteString.removingPercentEncoding!
    }
    
    public var headers: HTTPHeaders {
        
        switch self {
        case .search, .find, .discover, .downloadImage:
            return ["Authorization" : "Bearer \(accessToken)", "Content-Type": "application/json;charset=utf-8"]
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .discover, .find ,.search, .downloadImage :
            return .get
        }
    }
    public var parameterEncoding: ParameterEncoding {
        switch self {
        case .discover, .find ,.search, .downloadImage :
            return JSONEncoding.default
        }
    }
}
    class MovieBrowserAPI {
        //This is standard Alamofire Request Builder
        class func request(route: MovieBrowser, body: Parameters?) -> DataRequest {
            print("route.headers = \(route.headers)")
            let sessionManager = Alamofire.SessionManager.default
            sessionManager.session.configuration.timeoutIntervalForRequest = 30
            return Alamofire.request (route.url(),
                               method: route.method,
                               parameters: body,
                               encoding: route.parameterEncoding,
                               headers: route.headers)
        }
        
        // MARK: - ApiManager Base methods
        class func isApiCallSuccess(statusCode: Int?) -> (Int?) {
            if let code = statusCode {
                switch code {
                case 200..<299:
                    return (MovieBrowserResponseCode.success.code)
                case 400:
                    return (MovieBrowserResponseCode.validationError.code)
                case 401:
                    return (MovieBrowserResponseCode.unAutherisedAccess.code)
                case 403:
                    return (MovieBrowserResponseCode.forbidden.code)
                case 500:
                    return (MovieBrowserResponseCode.serverError.code)
                case -1001:
                    return (MovieBrowserResponseCode.serverError.code)
                default: return (MovieBrowserResponseCode.failure.code)
                }
            }
            return (MovieBrowserResponseCode.failure.code)
        }
    
        /// Call this func to get Full movie list
        /// parameters: - pageNumber - get current page number
        ///               sortOrder - sortby string
        ///               completionHandler -
        /// return: - completionHandler
        class func getDiscoverMovie(pageNumber: Int, sortOrder: String,completionHandler: @escaping (AnyObject?, AnyObject?, _ error: String?) -> Void) {
        request(route: .discover(pageNumber, sortOrder), body: nil).responseJSON(completionHandler: { (responseJson) in
            responseJson.result.ifSuccess {
                let responseCode = isApiCallSuccess(statusCode: responseJson.response?.statusCode)
                print("responseAPI", responseJson)
                switch responseCode {
                case MovieBrowserResponseCode.success.code:
                    let decoder = try? JSONDecoder().decode(MovieListModel.self, from: responseJson.data!)
                    completionHandler(decoder as AnyObject, nil, nil)
                    
                case MovieBrowserResponseCode.validationError.code,
                     MovieBrowserResponseCode.unAutherisedAccess.code,
                     MovieBrowserResponseCode.notFound.code,
                     MovieBrowserResponseCode.forbidden.code:
                    let decoder = try? JSONDecoder().decode(ErrorResponse.self, from: responseJson.data!)
                    completionHandler(nil, decoder, nil)
                case MovieBrowserResponseCode.serverError.code:
                    let decoder = try? JSONDecoder().decode(ErrorResponse.self, from: responseJson.data!)
                    completionHandler(nil, nil, decoder?.message ?? NetworkErrorHandler.getErrorMessage(witherrorCode: MovieBrowserResponseCode.serverError.code))
                default:
                    let decoder = try? JSONDecoder().decode(ErrorResponse.self, from: responseJson.data!)
                    completionHandler(nil, nil, decoder?.message ?? "")
                }
            }
            responseJson.result.ifFailure {
                let errorMessage = responseJson.result.value ?? NetworkErrorHandler.getErrorMessage(witherrorCode: responseJson.response?.statusCode)
                completionHandler(nil, nil, errorMessage as? String)
            }
        })
    }
        /// Call this func to get search movie list
        /// parameters: - query - get current page number
        ///               pageNumber - pageNumber string
        ///               completionHandler -
        /// return: - completionHandler
        class func getSearchMovie(query: String,pageNumber: Int,completionHandler: @escaping (AnyObject?, AnyObject?, _ error: String?) -> Void) {
            request(route: .search(pageNumber, query), body: nil).responseJSON(completionHandler: { (responseJson) in
                responseJson.result.ifSuccess {
                    let responseCode = isApiCallSuccess(statusCode: responseJson.response?.statusCode)
                    switch responseCode {
                    case MovieBrowserResponseCode.success.code:
                        let decoder = try? JSONDecoder().decode(MovieListModel.self, from: responseJson.data!)
                        completionHandler(decoder as AnyObject, nil, nil)
                    case MovieBrowserResponseCode.validationError.code,
                         MovieBrowserResponseCode.unAutherisedAccess.code,
                         MovieBrowserResponseCode.notFound.code,
                         MovieBrowserResponseCode.forbidden.code:
                        let decoder = try? JSONDecoder().decode(ErrorResponse.self, from: responseJson.data!)
                        completionHandler(nil, decoder, nil)
                    case MovieBrowserResponseCode.serverError.code:
                        let decoder = try? JSONDecoder().decode(ErrorResponse.self, from: responseJson.data!)
                        completionHandler(nil, nil, decoder?.message ?? NetworkErrorHandler.getErrorMessage(witherrorCode: MovieBrowserResponseCode.serverError.code))
                    default:
                        let decoder = try? JSONDecoder().decode(ErrorResponse.self, from: responseJson.data!)
                        completionHandler(nil, nil, decoder?.message ?? "")
                    }
                }
                responseJson.result.ifFailure {
                    let errorMessage = responseJson.result.value ?? NetworkErrorHandler.getErrorMessage(witherrorCode: responseJson.response?.statusCode)
                    completionHandler(nil, nil, errorMessage as? String)
                }
            })
        }
}
