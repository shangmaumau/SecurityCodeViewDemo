//
//  SecurityCodeCheckService.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/10/18.
//

import Foundation

public struct SecurityCodeCheckService: LCodeCheckService {
    var correctCode: String?
    func checkCode(_ code: String, completionHandler: (Bool) -> Void) throws {
        if code == correctCode {
            completionHandler(true)
        } else {
            completionHandler(false)
        }
    }
}
