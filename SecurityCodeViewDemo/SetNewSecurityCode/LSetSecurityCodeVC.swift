//
//  LSetSecurityCodeVC.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/10/9.
//

import UIKit
import SnapKit

/// 设置安全码
final class LSetSecurityCodeVC: UIViewController {
    private var titleText: UILabel?
    private var subtitleText: UILabel?
    private var promptText: UILabel?
    private var dotsView: SecurityCodeLayerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        _addChildViews()
    }

    private func _addChildViews() {
        titleText = UILabel()
        // rgba(35, 41, 52, 1)
        titleText?.font = .systemFont(ofSize: 24, weight: .medium)
        titleText?.textColor = UIColor(red: 35 / 255.0, green: 41 / 255.0, blue: 52 / 255.0, alpha: 1)

        titleText?.text = NSLocalizedString("安全码设置", comment: "")

        view.addSubview(titleText!)
        titleText?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(33)
            make.top.equalToSuperview().offset(naviTopPadding + 57)
        })

        subtitleText = UILabel()
        subtitleText?.font = .systemFont(ofSize: 14, weight: .light)
        // rgba(79, 84, 93, 1)
        subtitleText?.textColor = UIColor(red: 79 / 255.0, green: 84 / 255.0, blue: 52 / 255.0, alpha: 1)
        subtitleText?.text = NSLocalizedString("请输入6位数字密码", comment: "")
        view.addSubview(subtitleText!)
        subtitleText?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(20)
            make.top.equalTo(titleText!.snp.bottom).offset(10)
        })

        let layerConfig = SecurityCodeLayerView.Configuration(count: 6, innerSpace: 15, bottomLineHeight: 1, dotSize: CGSize(width: 15, height: 15), isShowCodeBlinkly: true)
        dotsView = SecurityCodeLayerView(frame: .zero, config: layerConfig)

        dotsView?.setEventCallback({ [weak self] event in
            switch event {
            case .done:
                debugPrint("输入完成")
                self?.dotsView?.getDown()
                self?.navigationController?.popToRootViewController(animated: true)
                break
            default:
                break
            }
        })

        view.addSubview(dotsView!)
        dotsView?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(60)
            make.top.equalTo(subtitleText!.snp.bottom).offset(40)
        })

        dotsView?.getUp()
    }
}

/// 验证手机号
final class LVerifyMobilePhoneNumberVC: UIViewController {
    private var titleText: UILabel?
    private var subtitleText: UILabel?
    private var promptText: UILabel?
    private var resendButton: UIButton?
    private var dotsView: SecurityCodeLayerView?

    private var keyboardHeight: CGFloat = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        _addChildViews()
        NotificationCenter.default.addObserver(self, selector: #selector(_keyboardWillChangeFrame(_:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
        _restoreCountdownTimer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc private func _keyboardWillChangeFrame(_ notif: Notification) {
        if let endFrameValue = notif.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? NSValue {
            let endFrame = endFrameValue.cgRectValue
            debugPrint("keyboard end frame: \(endFrame)")
        }
    }

    private func _addChildViews() {
        titleText = UILabel()
        // rgba(35, 41, 52, 1)
        titleText?.font = .systemFont(ofSize: 24, weight: .medium)
        titleText?.textColor = UIColor(red: 35 / 255.0, green: 41 / 255.0, blue: 52 / 255.0, alpha: 1)

        titleText?.text = NSLocalizedString("请输入手机验证码", comment: "")

        view.addSubview(titleText!)
        titleText?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(33)
            make.top.equalToSuperview().offset(naviTopPadding + 57)
        })

        subtitleText = UILabel()
        subtitleText?.font = .systemFont(ofSize: 14, weight: .light)
        // rgba(79, 84, 93, 1)
        subtitleText?.textColor = UIColor(red: 79 / 255.0, green: 84 / 255.0, blue: 52 / 255.0, alpha: 1)
        subtitleText?.text = NSLocalizedString("已发送验证码到手机 1xx xxxx xxxx", comment: "")
        view.addSubview(subtitleText!)
        subtitleText?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(20)
            make.top.equalTo(titleText!.snp.bottom).offset(10)
        })

        let layerConfig = SecurityCodeLayerView.Configuration(count: 6, innerSpace: 15, bottomLineHeight: 1, dotSize: CGSize(width: 15, height: 15), isShowCodeBlinkly: false, isNeedCheck: true, correctCode: "961030")
        dotsView = SecurityCodeLayerView(frame: .zero, config: layerConfig)

        dotsView?.setEventCallback({ [weak self] event in
            switch event {
            case let .done(isCorrect):
                if isCorrect == true {
                    self?.dotsView?.getDown()
                    self?._pushToSetSecurityCodeVC()
                    SharedCountdownTimer.shared.shutdown()
                }

            default:
                break
            }
        })

        view.addSubview(dotsView!)
        dotsView?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(60)
            make.top.equalTo(subtitleText!.snp.bottom).offset(40)
        })

        dotsView?.getUp()

        // rgba(229, 115, 73, 1) 14pt medium
        // rgba(168, 171, 179, 1) 14pt regular
        resendButton = UIButton()
        resendButton?.addTarget(self, action: #selector(_resendEvent(_:)), for: .touchUpInside)

        view.addSubview(resendButton!)
        resendButton?.snp.makeConstraints({ make in
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        })
    }

    @objc private func _resendEvent(_ sender: UIButton?) {
        _requestCaptcha()
    }

    /// Request for the CAPTCHA.
    private func _requestCaptcha() {
        // Network reqeust for the captcha.
        dotsView?.config.correctCode = "961030"
        _fireCountdownTimer()
    }

    private func _restoreCountdownTimer() {
        if SharedCountdownTimer.shared.isRunning {
            _fireCountdownTimer()
        } else {
            _updateResendButtonTitle(toSend: true, leftTime: nil)
        }
    }

    /// Fire 60s countdown timer.
    private func _fireCountdownTimer() {
        SharedCountdownTimer.shared.fire { [weak self] isTimeup, leftSeconds in
            self?._updateResendButtonTitle(toSend: isTimeup, leftTime: leftSeconds)
        }
    }

    private func _updateResendButtonTitle(toSend: Bool, leftTime: TimeInterval?) {
        // rgba(229, 115, 73, 1) 14pt medium
        // rgba(168, 171, 179, 1) 14pt regular
        if toSend {
            resendButton?.isEnabled = true
            resendButton?.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            resendButton?.setTitle(NSLocalizedString("重新发送", comment: ""), for: .normal)
            resendButton?.setTitleColor(UIColor(red: 229 / 255.0, green: 115 / 255.0, blue: 73 / 255.0, alpha: 1), for: .normal)
        } else {
            resendButton?.isEnabled = false
            resendButton?.titleLabel?.font = .systemFont(ofSize: 14)
            let title = "\(Int(leftTime!))" + NSLocalizedString("秒后重新发送", comment: "")
            resendButton?.setTitle(title, for: .normal)
            resendButton?.setTitleColor(UIColor(red: 168 / 255.0, green: 171 / 255.0, blue: 179 / 255.0, alpha: 1), for: .normal)
        }
    }

    private func _pushToSetSecurityCodeVC() {
        navigationController?.pushViewController(LSetSecurityCodeVC(), animated: true)
    }

    deinit {
        #if DEBUG
            debugPrint("deinit - \(Self.self)")
        #endif
    }
}
