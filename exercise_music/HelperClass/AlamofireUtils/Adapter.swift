////  Wash4SureRequestAdapter.swift
////  Wash4Sure
////
////  Created by Narendra Satpute on 10/04/17.
////  Copyright © 2017 Wash4Sure. All rights reserved.
////
//
//import Foundation
//import Alamofire
//
//class Adapter : RequestAdapter {
//
//    private var apiToken: String?
//
//    init() {
//        apiToken = nil
//    }
//
//    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
//
//        var urlRequest = urlRequest
//
//        urlRequest.setValue(HTTPHeaderConstants.MobileIdentifierHeaderValue, forHTTPHeaderField:HTTPHeaderConstants.MobileIdentifierHeaderName)
//
//        setAuthorizationHeader(urlRequest: &urlRequest)
//
//        return urlRequest
//    }
//
//
//    /// This methods sets the authorization header and its value.
//    ///
//    /// This method checks whether the member variable apiToken has value or not.
//    ///
//    /// If it has value then it will use it to set header else it will fetch from the LoginData object.
//    ///
//    /// - Parameter urlRequest: The URL request to adapt.
//
//    private func setAuthorizationHeader(urlRequest: inout URLRequest) -> Void {
//        //SEt Auhtorise Token
//        /*
//         if let token = apiToken, !token.isEmpty {
//         urlRequest.setValue(token, forHTTPHeaderField: HTTPHeaderConstants.AuthorizationHeaderName)
//         return
//         }
//
//         if let token = fetchAPIToken() {
//         apiToken = token
//         urlRequest.setValue(apiToken, forHTTPHeaderField: HTTPHeaderConstants.AuthorizationHeaderName)
//         }
//         */
//    }
//
//    private func fetchAPIToken() -> String? {
//
//        /* guard let loginData: LoginData = FileUtil.loginData() else {
//         print("Token is nil")
//         return nil
//         }
//         */
//
//        return ""
//    }
//}

