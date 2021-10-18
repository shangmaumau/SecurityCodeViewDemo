//
//  LCodeLayerView.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/9/27.
//

import UIKit
import SnapKit

/// 安全码线点视图。
final class LCodeLayerView: UIView, UITextFieldDelegate {
    /// 配置项。
    public struct Configuration {
        /// 安全码数字个数，默认 6 个。
        public var count: Int = 6
        /// 底线的间距（底线宽度会自适应：
        /// `(width - (count - 1) * innerSpace) / count)`）。
        public var innerSpace: CGFloat
        /// 底线的高度，默认为 1.
        public var bottomLineHeight: CGFloat = 1.0
        /// 黑圆点的尺寸，默认长宽为 10.
        public var dotSize: CGSize = CGSize(width: 10, height: 10)
        /// 短暂展示输入的数字，默认不展示。
        public var isShowCodeBlinkly: Bool = false
        /// 是否需要检查输入的正确性，默认不需要。
        public var isNeedCheck: Bool = false
        /// 检查密码正确与否的服务。
        public var checkService: LCodeCheckService?
    }

    public enum Event {
        case done(Bool?)
        case beginEditing
    }

    public typealias EventBlock = (_ event: Event) -> Void

    /// 线图层的数组。
    private var sublayers: [CAShapeLayer] = []
    /// 输入框，不显示，在最底层，响应输入专用。
    private var textField: UITextField?
    /// 点视图。
    private var dotsView: LCodeDotsView?
    /// 线图层是否已添加。
    private var isAdd = false
    /// 当前是否输入错误，红色代表错误。
    private var isRed = false
    /// 冻结一会儿 不让用户持续输入。
    private var isNeedFreeze = false
    /// 事件回调。
    private var eventCallback: EventBlock?
    /// 配置项。
    public var config: Configuration
    /// 密码位数。
    private var codeCount: CGFloat {
        CGFloat(config.count)
    }

    init(frame: CGRect, config: Configuration) {
        self.config = config
        super.init(frame: frame)
        _addChildViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !isAdd {
            _gimmeLayers().forEach { self.layer.addSublayer($0) }
            isAdd = true
        }
    }

    /// 变红，输入错误时会调用。
    public func turnRed() {
        sublayers.forEach { layer in
            layer.strokeColor = UIColor(red: 245 / 255.0, green: 95 / 255.0, blue: 78 / 255.0, alpha: 1).cgColor
        }
        isRed = true
    }

    /// 变默认，重新输入时恢复使用。
    public func turnDefault() {
        sublayers.forEach { layer in
            // rgba(168, 171, 179, 1)
            layer.strokeColor = UIColor(red: 168 / 255.0, green: 171 / 255.0, blue: 179 / 255.0, alpha: 1).cgColor
        }
        isRed = false
    }

    /// 唤起键盘输入。
    public func getUp() {
        // UIView.setAnimationsEnabled(false)
        textField?.becomeFirstResponder()
        turnDefault()
        dotsView?.deleteAll()
        textField?.text = ""
        // UIView.setAnimationsEnabled(true)
    }

    /// 降下键盘。
    public func getDown() {
        textField?.resignFirstResponder()
    }

    /// 设置完成（输入正确）的回调。
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

        let dotConfig = LCodeDotsView.Configuration(count: config.count, innerSpace: config.innerSpace, dotSize: config.dotSize, isShowCodeBlinkly: config.isShowCodeBlinkly)
        dotsView = LCodeDotsView(frame: bounds, config: dotConfig)
        addSubview(dotsView!)

        textField?.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })

        dotsView?.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }

    @objc private func _textFieldDidChangeValue(_ textField: UITextField?) {
        if let textCount = textField?.text?.count,
           textCount == config.count {
            if config.isNeedCheck, let inText = textField?.text {
                // 拿到足够的数字后：
                // 1. 与正确的密码比较，完全匹配则隐藏；
                // 2. 不匹配则显示输入错误，清空textfield。
                do {
                    try config.checkService?.checkCode(inText, completionHandler: { isCorrect in
                        // 输入正确
                        if isCorrect {
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
                            // 延时清除，否则会导致最后一位输入的无法显示。
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                                self?.dotsView?.deleteAll()
                            }
                            // 冷冻一会儿，防止用户输入过快，导致错误提醒出现的时候，
                            // 又出现了输入一两位的情况。
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                [weak self] in
                                self?.isNeedFreeze = false
                            }
                            // 回调告诉父视图我输入错误了
                            eventCallback?(.done(false))
                        }
                    })
                } catch {
                    if let checkError = error as? LCheckError {
                        switch checkError {
                        default:
                            break
                        }
                    }
                }
            } else {
                // textField?.resignFirstResponder()
                eventCallback?(.done(nil))
            }
        }
    }

    private func _gimmeLayers() -> [CAShapeLayer] {
        var layers: [CAShapeLayer] = []

        let lineWidth = (bounds.width - (codeCount - 1) * config.innerSpace) / codeCount
        let padding = config.innerSpace
        for index in 0 ..< config.count {
            let linePath = UIBezierPath()
            let startX = CGFloat(index) * (lineWidth + padding)

            linePath.move(to: CGPoint(x: startX, y: bounds.maxY))
            linePath.addLine(to: CGPoint(x: startX + lineWidth, y: bounds.maxY))

            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.lineWidth = config.bottomLineHeight
            lineLayer.fillColor = nil
            // rgba(168, 171, 179, 1)
            lineLayer.strokeColor = UIColor(red: 168 / 255.0, green: 171 / 255.0, blue: 179 / 255.0, alpha: 1).cgColor

            layers.append(lineLayer)
        }

        sublayers = layers

        return layers
    }

    /**
     下面方法的代码无用了
     本来是圈线
     */
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
        if let textCount = textField.text?.count, textCount >= config.count {
            return false
        }

        dotsView?.addDot(string)
        return true
    }
}
