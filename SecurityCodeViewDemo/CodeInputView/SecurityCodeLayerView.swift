//
//  SecurityCodeLayerView.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/9/27.
//

import SnapKit
import UIKit

/// 安全码线点视图。
final class SecurityCodeLayerView: UIView, UITextFieldDelegate {
    public enum Event {
        case done(Bool)
        case beginEditing
    }

    public typealias EventBlock = (_ event: Event) -> Void

    /// 线图层的数组
    private var sublayers: [CAShapeLayer] = []
    /// 输入框，不显示，在最底层，响应输入专用
    private var textField: UITextField?
    /// 点视图
    private var dotsView: SecurityCodeDotsView?
    /// 线图层是否已添加
    private var isAdd = false
    /// 当前是否输入错误，红色代表错误
    private var isRed = false
    /// 冻结一会儿 不让用户持续输入
    private var isNeedFreeze = false
    /// 事件回调
    private var eventCallback: EventBlock?
    /// 安全码数字的个数。一般为 6 个或 4 个。
    public private(set) var codeCount: Int

    init(frame: CGRect, codeCount: Int) {
        self.codeCount = codeCount
        super.init(frame: frame)
        _addChildViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !isAdd {
            _gimmeLayers(of: codeCount).forEach { self.layer.addSublayer($0) }
            isAdd = true
        }
    }

    /// 变红，输入错误时会调用
    public func turnRed() {
        sublayers.forEach { layer in
            layer.strokeColor = UIColor(red: 245 / 255.0, green: 95 / 255.0, blue: 78 / 255.0, alpha: 1).cgColor
        }
        isRed = true
    }

    /// 变默认，重新输入时恢复使用
    public func turnDefault() {
        sublayers.forEach { layer in
            // rgba(168, 171, 179, 1)
            layer.strokeColor = UIColor(red: 168 / 255.0, green: 171 / 255.0, blue: 179 / 255.0, alpha: 1).cgColor
        }
        isRed = false
    }

    /// 唤起键盘输入
    public func getUp() {
        // UIView.setAnimationsEnabled(false)
        textField?.becomeFirstResponder()
        // UIView.setAnimationsEnabled(true)
    }

    /// 降下键盘
    public func getDown() {
        textField?.resignFirstResponder()
    }

    /// 设置完成（输入正确）的回调
    public func setEventCallback(_ callback: @escaping EventBlock) {
        eventCallback = callback
    }

    private func _addChildViews() {
        textField = UITextField(frame: bounds)
        textField?.backgroundColor = .clear
        textField?.delegate = self
        textField?.keyboardType = .numberPad
        textField?.tintColor = .clear
        textField?.defaultTextAttributes = [.foregroundColor: UIColor.clear]

        textField?.addTarget(self, action: #selector(_textFieldDidChangeValue(_:)), for: .editingChanged)

        addSubview(textField!)

        dotsView = SecurityCodeDotsView(count: codeCount, frame: bounds)
        addSubview(dotsView!)

        textField?.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })

        dotsView?.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }

    @objc private func _textFieldDidChangeValue(_ textField: UITextField?) {
        // 拿到六位数字后
        // 1.与正确的安全码比较，安全匹配则隐藏
        // 2.不匹配则显示输入错误，清空textfield
        if let textCount = textField?.text?.count,
           textCount == codeCount {
            // 输入正确
            if textField?.text! == LCodeManager.shared.securityCode {
                // 隐藏键盘
                textField?.resignFirstResponder()
                // 回调告诉父视图我输入正确了
                eventCallback?(.done(true))
            }
            // 输入错误
            else {
                self.textField?.text = ""
                turnRed()

                isNeedFreeze = true
                // 延时清除，否则会导致最后一位输入的无法显示
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.dotsView?.deleteAll()
                }
                // 冷冻一会儿，可以防止用户快速点击
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    [weak self] in
                    self?.isNeedFreeze = false
                }
                // 回调告诉父视图我输入错误了
                eventCallback?(.done(false))
            }
        }
    }

    private func _gimmeLayers(of count: Int) -> [CAShapeLayer] {
        var layers: [CAShapeLayer] = []

        let width = bounds.width / CGFloat(count)
        let padding: CGFloat = 10
        for index in 0..<codeCount {

            let linePath = UIBezierPath()
            let startX = 0.5 * padding + CGFloat(index) * width

            linePath.move(to: CGPoint(x: startX, y: bounds.maxY))
            linePath.addLine(to: CGPoint(x: startX + width - padding, y: bounds.maxY))

            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.lineWidth = 1
            lineLayer.fillColor = nil
            // rgba(168, 171, 179, 1)
            lineLayer.strokeColor = UIColor(red: 168 / 255.0, green: 171 / 255.0, blue: 179 / 255.0, alpha: 1).cgColor

            layers.append(lineLayer)
        }

        sublayers = layers

        return layers
    }

    private func _gimmeLayersWith(codeCount: Int) -> [CAShapeLayer] {
        var layers: [CAShapeLayer] = []

        // 外围一圈的线
        let surroundPath = UIBezierPath()
        surroundPath.move(to: bounds.origin)
        surroundPath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        surroundPath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        surroundPath.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        surroundPath.close()

        let surroundLayer = CAShapeLayer()
        surroundLayer.path = surroundPath.cgPath
        surroundLayer.lineWidth = 1
        surroundLayer.fillColor = nil
        surroundLayer.strokeColor = UIColor(red: 151 / 255.0, green: 151 / 255.0, blue: 151 / 255.0, alpha: 1).cgColor

        layers.append(surroundLayer)

        // 中间的几条竖线
        let lineCount = codeCount - 1
        let linePadding = bounds.width / CGFloat(codeCount)
        for num in 1 ... lineCount {
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: CGFloat(num) * linePadding, y: bounds.minY))
            linePath.addLine(to: CGPoint(x: CGFloat(num) * linePadding, y: bounds.maxY))

            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.lineWidth = 1
            lineLayer.fillColor = nil
            lineLayer.strokeColor = UIColor(red: 151 / 255.0, green: 151 / 255.0, blue: 151 / 255.0, alpha: 1).cgColor

            layers.append(lineLayer)
        }

        sublayers = layers

        return layers
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 冷冻期间，不让输入
        if isNeedFreeze {
            return false
        }

        if isRed {
            // 变回默认色调
            turnDefault()
            // 变红意味着上次输入错误
            // 开始新的输入后，通过此回调，告诉上层视图，
            // 输入错误多少次的文本框需要隐藏
            eventCallback?(.beginEditing)
        }

        // 删除键也会走这里，传入空字符串来替换已有的字符串
        if string.isEmpty {
            dotsView?.deleteDot()
            return true
        }
        // 输入超过限制时，不再让输入
        if let textCount = textField.text?.count, textCount >= codeCount {
            return false
        }

        dotsView?.addDot()
        return true
    }
}
