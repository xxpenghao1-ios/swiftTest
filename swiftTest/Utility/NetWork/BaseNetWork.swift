//
//  NetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/7.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Moya
import Result
import ObjectMapper
import SwiftyJSON
/// 成功
typealias SuccessStringClosure = (_ result: String) -> Void
typealias SuccessModelClosure = (_ result: Mappable?) -> Void
typealias SuccessArrModelClosure = (_ result: [Mappable]?) -> Void
typealias SuccessJSONClosure = (_ result:JSON) -> Void
/// 失败
typealias FailClosure = (_ errorMsg: String?) -> Void

/// 网络请求
public class PHMoyaHttp{
    /// 共享实例
    static let sharedInstance = PHMoyaHttp()
    private init(){}
    
    /// 请求JSON数据(用于请求的JSON数据比较复杂)
    func requestDataWithTargetJSON<T:TargetType>(target:T,successClosure:@escaping SuccessJSONClosure,failClosure: @escaping FailClosure) {
        let requestProvider = MoyaProvider<T>()
        let _=requestProvider.request(target) { (result) -> () in
            switch result{
            case let .success(response):
                let json=JSON(data:response.data)
                successClosure(json)
            case let .failure(error):
                failClosure(error.errorDescription)
            }
        }
    }
    /// 请求数组对象JSON数据
    func requestDataWithTargetArrModelJSON<T:TargetType,M:Mappable>(target:T,model:M,successClosure:@escaping SuccessArrModelClosure,failClosure: @escaping FailClosure) {
        let requestProvider = MoyaProvider<T>()
        let _=requestProvider.request(target) { (result) -> () in
            switch result{
            case let .success(response):
                let json=JSON(data:response.data)
                let arr=Mapper<M>().mapArray(JSONObject:json.object)
                successClosure(arr)
            case let .failure(error):
                failClosure(error.errorDescription)
            }
        }
    }
    /// 请求对象JSON数据
    func requestDataWithTargetModelJSON<T:TargetType,M:Mappable>(target:T,model:M,successClosure:@escaping SuccessModelClosure,failClosure: @escaping FailClosure) {
        let requestProvider = MoyaProvider<T>()
        let _=requestProvider.request(target) { (result) -> () in
            switch result{
            case let .success(response):
                let json=JSON(response.data)
                let model=Mapper<M>().map(JSONObject:json.object)
                successClosure(model)
            case let .failure(error):
                failClosure(error.errorDescription)
            }
        }
    }
    ///请求String数据
    func requestDataWithTargetString<T:TargetType>(target:T,successClosure:@escaping SuccessStringClosure,failClosure: @escaping FailClosure) {
        let requestProvider = MoyaProvider<T>()
        let _=requestProvider.request(target) { (result) -> () in
            switch result{
            case let .success(response):
                do {
                    let str = try response.mapString()
                    successClosure(str)
                } catch {
                    failClosure("数据解析失败")
                }
            case let .failure(error):
                failClosure(error.errorDescription)
            }

        }
    }
    ///下载
    func DownloadAssets(asset:Asset, completion: ((Result<URL, MoyaError>) -> Void)? = nil) {
        let provider = MoyaProvider<Asset>()
        if FileManager.default.fileExists(atPath: asset.localLocation.path) {
            completion?(.success(asset.localLocation))
            return
        }
        provider.request(asset) { result in
            switch result {
            case .success:
                completion?(.success(asset.localLocation))
            case let .failure(error):
                return (completion?(.failure(error)))!
            }
        }
    }
}

///网络请求API(请求注册登录信息等)
public enum RequestAPI{
    case mobileAdvertisingPromotion
    case uploadsheadportrait(filePath:String,name:String,memberId:Int)
}
extension RequestAPI:TargetType{
    ///请求URL
    public var baseURL:URL{
        return URL(string:"http://www.cxh777.com/")!
    }
    ///URL详细路径
    public var path:String{
        switch self {
        case .mobileAdvertisingPromotion:
            return "mobileAdvertisingPromotion.xhtml"
        case .uploadsheadportrait(_,_,_):
            return "upload/uploadsheadportrait"
        }
    }
    ///请求方式
    public var method:Moya.Method{
        switch  self {
        case .mobileAdvertisingPromotion:
            return .get
        case .uploadsheadportrait(_,_,_):
            return .post
        }
    }
    ///请求参数
    public var parameters: [String:Any]? {
        switch self {
        case .mobileAdvertisingPromotion:
            return nil
        case .uploadsheadportrait(_,_,_):
            return nil
        }
    }
    ///参数编码
    public var parameterEncoding:ParameterEncoding{
            return JSONEncoding.default
        
    }
    //单元测试用
    public var sampleData:Data{
        return "".data(using:.utf8)!
    }
    //任务
    public var task: Task {
        switch self {
        case let .uploadsheadportrait(filePath,name,memberId):
            let imgData = MultipartFormData(provider: MultipartFormData.FormDataProvider.file(URL(fileURLWithPath:filePath)), name:name)
            let descriptionData = MultipartFormData(provider: .data("\(memberId)".data(using: .utf8)!), name:"memberId")
            return .upload(.multipart([imgData,descriptionData]))
        default:
            return .request
        }
    }
}

