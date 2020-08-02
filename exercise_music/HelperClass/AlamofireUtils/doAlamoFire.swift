//
//  File.swift
//  Util_Classes
//
//  Created by Adite Technologies on 12/09/17.
//  Copyright © 2017 Adite Technologies. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class doAlamoFire
{
    static let sharedInstance = doAlamoFire()
    let sessionManager: SessionManager
    let sessionManagerBackground: SessionManager
     init() {
        // let requestAdapter = Adapter()
        let configuration = URLSessionConfiguration.default
        let configurationBackground = URLSessionConfiguration.background(withIdentifier: "background")
        //  configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        self.sessionManager = Alamofire.SessionManager(configuration: configuration)
        self.sessionManagerBackground = Alamofire.SessionManager(configuration: configurationBackground)
       
    }
    @discardableResult
    public func request(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> DataRequest {
            return sessionManager.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }
    @discardableResult
    public func request(_ urlRequest: URLRequestConvertible) -> DataRequest {
        return sessionManager.request(urlRequest)
    }
    
    // MARK: - Download Request
    @discardableResult
    public func download(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        to destination: DownloadRequest.DownloadFileDestination? = nil)
        -> DownloadRequest
    {
        return sessionManager.download(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers,
            to: destination
        )
    }

    @discardableResult
    public func download(
        _ urlRequest: URLRequestConvertible,
        to destination: DownloadRequest.DownloadFileDestination? = nil)
        -> DownloadRequest
    {
        return sessionManager.download(urlRequest, to: destination)
    }
    
    // MARK: Resume Data
  
    @discardableResult
    public func download(
        resumingWith resumeData: Data,
        to destination: DownloadRequest.DownloadFileDestination? = nil)
        -> DownloadRequest
    {
        return sessionManager.download(resumingWith: resumeData, to: destination)
    }

    @discardableResult
    public func upload(
        _ fileURL: URL,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil)
        -> UploadRequest
    {
        return sessionManager.upload(fileURL, to: url, method: method, headers: headers)
    }
    
    @discardableResult
    public func upload(_ fileURL: URL, with urlRequest: URLRequestConvertible) -> UploadRequest {
        return sessionManager.upload(fileURL, with: urlRequest)
    }
    
    // MARK: Data

    @discardableResult
    public func upload(
        _ data: Data,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil)
        -> UploadRequest
    {
        return sessionManager.upload(data, to: url, method: method, headers: headers)
    }

    @discardableResult
    public func upload(_ data: Data, with urlRequest: URLRequestConvertible) -> UploadRequest {
        return sessionManager.upload(data, with: urlRequest)
    }

    @discardableResult
    public func upload(
        _ stream: InputStream,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil)
        -> UploadRequest
    {
        return sessionManager.upload(stream, to: url, method: method, headers: headers)
    }

    @discardableResult
    public func upload(_ stream: InputStream, with urlRequest: URLRequestConvertible) -> UploadRequest {
        return sessionManager.upload(stream, with: urlRequest)
    }
    public func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        usingThreshold encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil,
        encodingCompletion: ((SessionManager.MultipartFormDataEncodingResult) -> Void)?)
    {
        return sessionManager.upload(
            multipartFormData: multipartFormData,
            usingThreshold: encodingMemoryThreshold,
            to: url,
            method: method,
            headers: headers,
            encodingCompletion: encodingCompletion
        )
    }
    public func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        usingThreshold encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold,
        with urlRequest: URLRequestConvertible,
        encodingCompletion: ((SessionManager.MultipartFormDataEncodingResult) -> Void)?)
    {
        return sessionManager.upload(
            multipartFormData: multipartFormData,
            usingThreshold: encodingMemoryThreshold,
            with: urlRequest,
            encodingCompletion: encodingCompletion
        )
    }
    
    #if !os(watchOS)

    @discardableResult
    @available(iOS 9.0, macOS 10.11, tvOS 9.0, *)
    public func stream(withHostName hostName: String, port: Int) -> StreamRequest {
        return sessionManager.stream(withHostName: hostName, port: port)
    }
    @discardableResult
    @available(iOS 9.0, macOS 10.11, tvOS 9.0, *)
    public func stream(with netService: NetService) -> StreamRequest {
        return sessionManager.stream(with: netService)
    }
    #endif
}
