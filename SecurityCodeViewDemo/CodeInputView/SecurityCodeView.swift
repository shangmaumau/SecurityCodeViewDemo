//
//  SecurityCodeView.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/9/23.
//

import SnapKit
import UIKit

public typealias BooleanBlock = (_ isDone: Bool) -> Void
public typealias VoidBlock = () -> Void

/// 安全码全流程处理视图。
final class SecurityCodeView: UIView {
    public enum Event {
        case wrongInputTimeout
        case forgetCode
        case dismiss
        case success
    }

    public typealias EventBlock = (_ event: Event) -> Void

    private var contentView = UIView()
    private var bgView = UIView()
    private var codeInputView: SecurityCodeInputView?
    private var eventCallback: EventBlock?

    override init(frame: CGRect) {
        super.init(frame: frame)
        _addChildViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setEventCallback(_ callback: @escaping EventBlock) {
        eventCallback = callback
    }

    private func _addChildViews() {
        let bigRect = UIScreen.main.bounds

        bgView.backgroundColor = UIColor(red: 149 / 255.0, green: 149 / 255.0, blue: 149 / 255.0, alpha: 1)
        bgView.alpha = 0
        bgView.frame = bigRect

        contentView.frame = CGRect(origin: CGPoint(x: 0, y: bigRect.maxY), size: bigRect.size)
        addSubview(bgView)
        addSubview(contentView)

        codeInputView = SecurityCodeInputView(codeCount: 6, frame: CGRect(origin: .zero, size: CGSize(width: 270, height: 172)))
        codeInputView?.backgroundColor = .white
        codeInputView?.layer.cornerRadius = 12.0
        contentView.addSubview(codeInputView!)

        codeInputView?.snp.makeConstraints({ make in
            make.size.equalTo(CGSize(width: 270, height: 172))
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-120)
        })

        codeInputView?.setEventCallback({ [weak self] event in
            self?._handleInputViewEvent(event)
        })
    }

    private func _handleInputViewEvent(_ event: SecurityCodeInputView.Event) {
        switch event {
        // 关闭
        case .dismiss:
            eventCallback?(.dismiss)
            dismiss()
        // 输入完成
        case let .done(isOkay):
            // 输入正确
            if isOkay {
                eventCallback?(.success)
                dismiss()
            } // else 输入失败
        // 忘记安全码
        case .forgetCode:
            eventCallback?(.forgetCode)
            dismiss()
        // 输错次数超标
        case .wrongTimeout:
            eventCallback?(.wrongInputTimeout)
            dismiss()
        }
    }

    public func showOnKeyWindow(with eventCallback: @escaping EventBlock) {
        var keyWindow: UIWindow?
        for window in UIApplication.shared.windows where window.isKeyWindow {
            keyWindow = window
        }
        guard let keyWindow = keyWindow else {
            return
        }
        keyWindow.addSubview(self)
        self.eventCallback = eventCallback

        let animationOption: UIView.AnimationOptions = .init(rawValue: 7 << 16)
        let bigRect = UIScreen.main.bounds

        UIView.animate(withDuration: 0.5, delay: 0, options: animationOption) { [unowned self] in

            contentView.frame = bigRect
            bgView.alpha = 1.0
            codeInputView?.getUp()

        } completion: { _ in
        }
    }

    public func dismiss() {
        let animationOption: UIView.AnimationOptions = .init(rawValue: 7 << 16)
        let bigRect = UIScreen.main.bounds

        UIView.animate(withDuration: 0.5, delay: 0, options: animationOption) { [unowned self] in

            contentView.frame = CGRect(origin: CGPoint(x: 0, y: bigRect.maxY), size: bigRect.size)
            bgView.alpha = 0

            codeInputView?.getDown()

        } completion: { [unowned self] _ in
            removeFromSuperview()
        }
    }
}
