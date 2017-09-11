//
//  IndexNetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/8.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Moya

/// 首页数据请求
public enum IndexAPI{
    case mobileAdvertisingPromotion
}
extension IndexAPI:TargetType{
    ///请求URL
    public var baseURL:URL{
        return URL(string:url)!
    }
    ///URL详细路径
    public var path:String{
        switch self {
        case .mobileAdvertisingPromotion:
            return "mobileAdvertisingPromotion.xhtml"
        }
    }
    ///请求方式
    public var method:Moya.Method{
        switch  self {
        case .mobileAdvertisingPromotion:
            return .get
        }
    }
    ///请求参数
    public var parameters: [String:Any]? {
        switch self {
        case .mobileAdvertisingPromotion:
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
        return .request
    }
}
