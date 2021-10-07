//
//  LAlertViewLite.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/9/30.
//

import SnapKit
import UIKit

private typealias _LAlertVoidBlock = () -> Void

extension CGSize {
    public func rounded(_ rule: FloatingPointRoundingRule) -> Self {
        CGSize(width: width.rounded(rule), height: height.rounded(rule))
    }
}

private class _LAlertViewMain: UIView {
    private struct _Size {
        static let topPadding: CGFloat = 34
        static var titleHeight: CGFloat = 22
        static var viewPadding: CGFloat = 5
        static var subtitleHeight: CGFloat = 17
        static let bottomPadding: CGFloat = 20
        static let actionHeight: CGFloat = 44

        public static var height: CGFloat {
            topPadding + titleHeight + viewPadding + subtitleHeight + bottomPadding + actionHeight
        }

        public static var width: CGFloat = 270
        public static var value: CGSize {
            CGSize(width: width, height: height)
        }

        public static var titleWidth: CGFloat {
            width - 2 * 8
        }
    }

    private var title: String?
    private var subtitle: String?
    private var cancelTitle: String?
    private var setTitle: String?

    private var titleText: UILabel?
    private var subtitleText: UILabel?
    private var cancelButton: UIButton?
    private var setButton: UIButton?

    private var cancelCallback: _LAlertVoidBlock?
    private var setCallback: _LAlertVoidBlock?

    public static var csize: CGSize {
        _Size.value
    }

    init(ti: String?, subti: String?, cancelTi: String?, setTi: String?) {
        title = ti
        subtitle = subti
        cancelTitle = cancelTi
        setTitle = setTi

        func size(of string: String, width: CGFloat, font: UIFont) -> CGSize {
            let rect = (string as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
            return rect.size.rounded(.up)
        }

        // 只有两个都不为空时，才需要两个视图中间的padding
        if ti == nil || subti == nil {
            _Size.viewPadding = .zero
        }

        if let title = ti {
            let newH = size(of: title, width: _Size.titleWidth, font: .systemFont(ofSize: 14)).height
            if newH > _Size.titleHeight {
                _Size.titleHeight = newH
            }
        } else {
            _Size.titleHeight = .zero
        }

        if let subtitle = subti {
            let newH = size(of: subtitle, width: _Size.titleWidth, font: .systemFont(ofSize: 12)).height
            if newH > _Size.subtitleHeight {
                _Size.subtitleHeight = newH
            }
        } else {
            _Size.subtitleHeight = .zero
        }

        super.init(frame: CGRect(origin: .zero, size: _Size.value))
        _addChildViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setEventCallback(cancel: _LAlertVoidBlock?, set: _LAlertVoidBlock?) {
        cancelCallback = cancel
        setCallback = set
    }

    private func _addChildViews() {
        var topCons = snp.top
        if title != nil {
            titleText = UILabel()
            titleText?.numberOfLines = 0
            titleText?.textAlignment = .center
            titleText?.font = .systemFont(ofSize: 14)
            titleText?.textColor = UIColor(red: 35 / 255.0, green: 41 / 255.0, blue: 52 / 255.0, alpha: 1)
            titleText?.text = title
            addSubview(titleText!)
            titleText?.snp.makeConstraints({ make in
                make.top.equalTo(topCons).inset(_Size.topPadding)
                make.left.right.equalToSuperview().inset(8)
                make.height.equalTo(_Size.titleHeight)
            })
            topCons = titleText!.snp.bottom
        }
        if subtitle != nil {
            // rgba(123, 126, 133, 1)
            subtitleText = UILabel()
            subtitleText?.numberOfLines = 0
            subtitleText?.textAlignment = .center
            subtitleText?.font = .systemFont(ofSize: 12)
            subtitleText?.textColor = UIColor(red: 123 / 255.0, green: 126 / 255.0, blue: 133 / 255.0, alpha: 1)
            subtitleText?.text = subtitle
            addSubview(subtitleText!)

            subtitleText?.snp.makeConstraints({ make in
                make.top.equalTo(topCons).offset(_Size.viewPadding)
                make.left.right.equalToSuperview().inset(8)
                make.height.equalTo(_Size.subtitleHeight)
            })
        }

        // 按钮宽度
        let buttonWidth: CGFloat
        // 是否要添加竖直分隔线
        let needAddVLine: Bool
        if setTitle != nil && cancelTitle != nil {
            buttonWidth = _Size.width / 2.0
            needAddVLine = true
        } else {
            buttonWidth = _Size.width
            needAddVLine = false
        }

        if cancelTitle != nil {
            cancelButton = UIButton()
            cancelButton?.setTitle(cancelTitle, for: .normal)
            cancelButton?.titleLabel?.font = .systemFont(ofSize: 16)
            cancelButton?.setTitleColor(UIColor(red: 123 / 255.0, green: 126 / 255.0, blue: 133 / 255.0, alpha: 1), for: .normal)
            addSubview(cancelButton!)
            cancelButton?.addTarget(self, action: #selector(_cancelEvent(_:)), for: .touchUpInside)

            cancelButton?.snp.makeConstraints({ make in
                make.bottom.equalToSuperview()
                make.left.equalToSuperview()
                make.width.equalTo(buttonWidth)
                make.height.equalTo(_Size.actionHeight)
            })
        }
        if setTitle != nil {
            setButton = UIButton()
            setButton?.setTitle(setTitle, for: .normal)
            setButton?.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            setButton?.setTitleColor(UIColor(red: 35 / 255.0, green: 41 / 255.0, blue: 52 / 255.0, alpha: 1), for: .normal)
            addSubview(setButton!)
            setButton?.addTarget(self, action: #selector(_setEvent(_:)), for: .touchUpInside)

            setButton?.snp.makeConstraints({ make in
                make.bottom.equalToSuperview()
                make.right.equalToSuperview()
                make.width.equalTo(buttonWidth)
                make.height.equalTo(_Size.actionHeight)
            })
        }

        let hline = UIView()
        hline.backgroundColor = UIColor(red: 238 / 255.0, green: 238 / 255.0, blue: 238 / 255.0, alpha: 1)
        addSubview(hline)
        hline.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview().inset(_Size.actionHeight)
        }

        if needAddVLine {
            let vline = UIView()
            vline.backgroundColor = UIColor(red: 238 / 255.0, green: 238 / 255.0, blue: 238 / 255.0, alpha: 1)
            addSubview(vline)
            vline.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview()
                make.width.equalTo(1)
                make.height.equalTo(_Size.actionHeight)
            }
        }
    }

    @objc private func _cancelEvent(_ sender: UIButton?) {
        cancelCallback?()
    }

    @objc private func _setEvent(_ sender: UIButton?) {
        setCallback?()
    }
}

/**
 简易版的警告视图。

 分上下两部分，上部分有标题和副标题；下部分左边取消按钮，右边去往具体的业务界面，
 标题可自定义。

 上部分如无副标题，标题会在标题视图的中央。

 下部分如只有一个按钮，则占用整个底部空间。具体回调看使用哪个回调。
 如下部分不传任何按钮标题，则仍会有一个默认的取消按钮。
 */
final class LAlertViewLite: UIView {
    private var _alertView: _LAlertViewMain?
    private var _bgView: UIView?
    private var _contentView: UIView?

    private var _cancelCallback: _LAlertVoidBlock?
    private var _setCallback: _LAlertVoidBlock?

    init(title: String?, subtitle: String?, cancelTitle: String?, setTitle: String?) {
        let bigRect = UIScreen.main.bounds
        super.init(frame: bigRect)

        _bgView = UIView(frame: bigRect)
        _bgView?.backgroundColor = UIColor(red: 149 / 255.0, green: 149 / 255.0, blue: 149 / 255.0, alpha: 1)
        _bgView?.alpha = 0
        addSubview(_bgView!)

        _contentView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: bigRect.maxY), size: bigRect.size))
        addSubview(_contentView!)

        _alertView = _LAlertViewMain(ti: title, subti: subtitle, cancelTi: cancelTitle, setTi: setTitle)
        _alertView?.backgroundColor = .white
        _alertView?.layer.cornerRadius = 12
        _contentView?.addSubview(_alertView!)

        _alertView?.snp.makeConstraints({ make in
            make.center.equalToSuperview()
            make.size.equalTo(_LAlertViewMain.csize)
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func showOnKeyWindow(with cancelCallback: (() -> Void)?, setCallback: (() -> Void)?) {
        var keyWindow: UIWindow?
        for window in UIApplication.shared.windows where window.isKeyWindow {
            keyWindow = window
        }
        guard let keyWindow = keyWindow else {
            return
        }
        keyWindow.addSubview(self)
        _alertView?.setEventCallback(cancel: { [weak self] in
            self?.dismiss()
            cancelCallback?()
        }, set: { [weak self] in
            self?.dismiss()
            setCallback?()
        })
        let animationOption: UIView.AnimationOptions = .init(rawValue: 7 << 16)
        let bigRect = UIScreen.main.bounds

        UIView.animate(withDuration: 0.5, delay: 0, options: animationOption) { [unowned self] in

            _contentView?.frame = bigRect
            _bgView?.alpha = 1.0

        } completion: { _ in
        }
    }

    public func dismiss() {
        let animationOption: UIView.AnimationOptions = .init(rawValue: 7 << 16)
        let bigRect = UIScreen.main.bounds

        UIView.animate(withDuration: 0.5, delay: 0, options: animationOption) { [unowned self] in

            _contentView?.frame = CGRect(origin: CGPoint(x: 0, y: bigRect.maxY), size: bigRect.size)
            _bgView?.alpha = 0

        } completion: { [unowned self] _ in
            removeFromSuperview()
        }
    }

    deinit {
        debugPrint("deinit - \(Self.self)")
    }
}
