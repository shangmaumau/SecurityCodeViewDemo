//
//  SecurityCodeInputView.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/9/27.
//

import SnapKit
import UIKit

/// 安全码输入界面。
final class SecurityCodeInputView: UIView {
    /// 视图交互事件
    public enum Event {
        /// 输入完成（似乎不再需要）
        case done(Bool)
        /// 关闭页面
        case dismiss
        /// 忘记安全码
        case forgetCode
        /// 错误超过次数
        case wrongTimeout
    }

    public typealias EventBlock = (_ event: Event) -> Void

    /// 关闭按钮
    private var closeButton: UIButton?
    /// 标题
    private var titleText: UILabel?
    /// 输入错误时提示文本
    private var alertText: UILabel?
    /// 忘记安全码按钮
    private var forgetCodeButton: UIButton?
    /// 安全码视图
    private var codeView: SecurityCodeLayerView?
    /// 事件回调
    private var eventCallback: EventBlock?
    /// 安全码位数
    private var count: Int
    /// 最大的输入次数，超过五次输入错误，则展示达到上限界面
    private let maxInputTime = 5
    /// 输入错误次数
    private var inputWrongTime: Int = 5

    init(codeCount: Int, frame: CGRect) {
        count = codeCount
        super.init(frame: frame)
        _addChildViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func _addChildViews() {
        // 安全码输入
        codeView = SecurityCodeLayerView(frame: .zero, codeCount: 6)
        addSubview(codeView!)
        codeView?.snp.makeConstraints({ make in
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(25)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        })

        codeView?.setEventCallback({ [weak self] event in
            guard let self = self else { return }

            switch event {
            case let .done(isDone):
                // 输入错误
                if !isDone {
                    self.inputWrongTime -= 1
                    if self.inputWrongTime == .zero {
                        self.eventCallback?(.wrongTimeout)
                        // 处理存疑
                        self.alertText?.isHidden = true

                    } else {
                        let key = NSLocalizedString("安全码错误，你还可以输入", comment: "") + "\(self.inputWrongTime)" + NSLocalizedString("次", comment: "")
                        self.alertText?.text = key

                        self.alertText?.isHidden = false
                    }
                }
                self.eventCallback?(.done(isDone))

            case .beginEditing:
                self.alertText?.isHidden = true
            }
        })

        // 关闭按钮
        closeButton = UIButton()
        closeButton?.setBackgroundImage(UIImage(named: "veh_seccode_close_btn"), for: .normal)
        closeButton?.addTarget(self, action: #selector(_dismissEvent(_:)), for: .touchUpInside)

        addSubview(closeButton!)

        closeButton?.snp.makeConstraints({ make in
            make.size.equalTo(CGSize(width: 22, height: 22))
            make.top.right.equalToSuperview().inset(8)
        })

        // 错误提示文本
        alertText = UILabel()
        alertText?.font = .systemFont(ofSize: 12, weight: .medium)
        // rgba(245, 95, 78, 1)
        alertText?.textColor = UIColor(red: 245 / 255.0, green: 95 / 255.0, blue: 78 / 255.0, alpha: 1)
        alertText?.textAlignment = .center
        alertText?.text = NSLocalizedString("安全码错误，你还可以输入", comment: "")
        alertText?.isHidden = true
        addSubview(alertText!)

        alertText?.snp.makeConstraints({ make in
            make.height.equalTo(17)
            make.left.right.equalToSuperview().inset(30)
            make.bottom.equalTo(codeView!.snp.top).offset(-4)
        })

        // 标题
        titleText = UILabel()
        titleText?.textColor = UIColor(red: 35 / 255.0, green: 41 / 255.0, blue: 52 / 255.0, alpha: 1)
        titleText?.font = .systemFont(ofSize: 18, weight: .medium)
        titleText?.textAlignment = .center
        titleText?.text = NSLocalizedString("请输入安全码", comment: "")

        addSubview(titleText!)

        titleText?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(25)
            make.bottom.equalTo(alertText!.snp.top).offset(-5)
        })

        // 忘记密码按钮
        forgetCodeButton = UIButton()
        // rgba(79, 84, 93, 1)
        forgetCodeButton?.setTitleColor(UIColor(red: 153 / 255.0, green: 153 / 255.0, blue: 153 / 255.0, alpha: 1), for: .normal)
        forgetCodeButton?.titleLabel?.font = .systemFont(ofSize: 14)
        forgetCodeButton?.setTitle(NSLocalizedString("忘记密码？", comment: ""), for: .normal)

        addSubview(forgetCodeButton!)

        forgetCodeButton?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
            make.top.equalTo(codeView!.snp.bottom).offset(20)
        })

        forgetCodeButton?.addTarget(self, action: #selector(_forgetCodeEvent(_:)), for: .touchUpInside)
    }

    public func getUp() {
        codeView?.getUp()
        codeView?.turnDefault()
        inputWrongTime = 5
    }

    public func getDown() {
        codeView?.getDown()
    }

    public func setEventCallback(_ callback: @escaping EventBlock) {
        eventCallback = callback
    }

    @objc private func _forgetCodeEvent(_ sender: UIButton?) {
        eventCallback?(.forgetCode)
    }

    @objc private func _dismissEvent(_ sender: UIButton?) {
        eventCallback?(.dismiss)
    }
}
