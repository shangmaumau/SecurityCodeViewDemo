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
/// 安全码输入视图。
final class SecurityCodeView: UIView {
    private var contentView = UIView()
    private var bgView = UIView()
    private var codeInputView: SecurityCodeInputView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        _addChildViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func _addChildViews() {
        let bigRect = UIScreen.main.bounds

        bgView.backgroundColor = UIColor(red: 149 / 255.0, green: 149 / 255.0, blue: 149 / 255.0, alpha: 1)
        bgView.alpha = 0
        bgView.frame = bigRect

        contentView.frame = CGRect(origin: CGPoint(x: 0, y: bigRect.maxY), size: bigRect.size)
        addSubview(bgView)
        addSubview(contentView)

        codeInputView = SecurityCodeInputView(codeCount: 6, frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 215)))
        codeInputView?.backgroundColor = .white
        codeInputView?.layer.cornerRadius = 5.0
        contentView.addSubview(codeInputView!)

        codeInputView?.snp.makeConstraints({ make in
            make.size.equalTo(CGSize(width: 300, height: 215))
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-120)
        })

        codeInputView?.setEventCallback({ [weak self] event in
            switch event {
            case .dismiss:
                self?.dismiss()
            case .done:
                break
            case .forgetCode:
                // 跳转页面
                break
            case .wrongTimeout:
                // 展示输入错误过多的提示
                break
            }
        })
    }

    public func showOnView(_ view: UIView, doneCallback: @escaping BooleanBlock) {
        guard let window = view.window else {
            return
        }
        window.addSubview(self)

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
