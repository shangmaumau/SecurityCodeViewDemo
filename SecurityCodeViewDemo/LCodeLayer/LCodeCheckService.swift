//
//  LCodeCheckService.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/10/18.
//

import Foundation

enum LCheckError: Error {
    case wrongInput
    case networkTimeout
    case other
}

protocol LCodeCheckService {
    /// 检查结果的闭包。
    typealias CheckResult = (_ isCorrect: Bool) -> Void
    /// 正确的密码。
    var correctCode: String? { get set }
    /// 检查输入的 code 正确性。
    func checkCode(_ code: String, completionHandler: CheckResult) throws
}
