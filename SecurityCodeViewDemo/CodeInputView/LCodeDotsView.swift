//
//  LCodeDotsView.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/9/27.
//

import UIKit

/// 安全码点视图。
final class LCodeDotsView: UIView {
    public struct Configuration {
        public var count: Int
        public var innerSpace: CGFloat
        public var dotSize: CGSize
        public var isShowCodeBlinkly: Bool = false
    }

    /// 点图层数组。
    private var dotLayers: [CALayer] = []
    /// 底下的数字。
    private var dotLabels: [UILabel] = []
    /// 当前索引位置，-1 表示未输入任何数。
    private var currentIndex: Int = -1
    /// 标记位，图层是否已经添加。
    private var isAdd: Bool = false
    /// 配置项。
    private var config: Configuration
    /// 密码位数。
    private var codeCount: CGFloat {
        CGFloat(config.count)
    }

    private var lastWorkItem: DispatchWorkItem?

    init(frame: CGRect, config: Configuration) {
        self.config = config
        super.init(frame: frame)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !isAdd {
            _addChildLayers()
            isAdd = true
        }
    }

    private func _addChildLayers() {
        var size = config.dotSize
        let unitWidth = (bounds.width - (codeCount - 1) * config.innerSpace) / codeCount
        let biggerWidth = unitWidth + config.innerSpace
        let unitHeight = bounds.height
        // 如果设定的size大于每个dot占据的长宽，则削足适履。
        if size.width > unitWidth.rounded(.down) {
            size.width = unitWidth.rounded(.down)
        }
        if size.height > unitHeight.rounded(.down) {
            size.height = unitHeight.rounded(.down)
        }
        for index in 0 ..< config.count {
            let dotLayer = CALayer()
            dotLayer.bounds = CGRect(origin: .zero, size: size)
            // rgba(35, 41, 52, 1)
            dotLayer.backgroundColor = UIColor(red: 35 / 255.0, green: 41 / 255.0, blue: 52 / 255.0, alpha: 1).cgColor
            dotLayer.position = CGPoint(x: 0.5 * unitWidth + CGFloat(index) * biggerWidth, y: 0.5 * unitHeight)
            dotLayer.cornerRadius = size.height / 2.0
            dotLayer.opacity = 0

            layer.addSublayer(dotLayer)
            dotLayers.append(dotLayer)

            if config.isShowCodeBlinkly {
                let label = UILabel()
                label.font = .systemFont(ofSize: 36, weight: .bold)
                label.textColor = UIColor(red: 24 / 255.0, green: 24 / 255.0, blue: 24 / 255.0, alpha: 1)
                label.textAlignment = .center
                label.bounds = CGRect(origin: .zero, size: CGSize(width: unitWidth, height: unitHeight))
                label.center = dotLayer.position

                addSubview(label)
                dotLabels.append(label)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 添加一个点。
    public func addDot(_ text: String) {
        guard _isInRange(currentIndex) else {
            return
        }
        // 先加index，再变对应的为不透明。
        currentIndex += 1

        // block中捕获的值，如果此处不另复制值，则会跟随currentIndex的值而变化，
        // 这样在延时之后，获得到的就成了新值而非期望的旧值。
        let cindex = currentIndex
        if config.isShowCodeBlinkly {
            dotLabels[cindex].alpha = 1.0
            dotLabels[cindex].text = text

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                UIView.animate(withDuration: 0.2, delay: 0, options: .init(rawValue: 7 << 16)) { [unowned self] in

                    dotLabels[cindex].alpha = 0.0
                    dotLabels[cindex].text = ""
                    dotLayers[cindex].opacity = 1.0

                } completion: { _ in
                }
            }

        } else {
            UIView.animate(withDuration: 0.2) { [unowned self] in
                dotLayers[cindex].opacity = 1.0
            }
        }
    }

    /// 删除一个点。
    public func deleteDot() {
        guard _isInRange(currentIndex) else {
            return
        }
        // 先将当前变透明，再减index。
        UIView.animate(withDuration: 0.2) { [unowned self] in
            dotLayers[currentIndex].opacity = 0
        }
        currentIndex -= 1
    }

    /// 删除所有点。
    public func deleteAll() {
        UIView.animate(withDuration: 0.2) { [unowned self] in
            dotLayers.forEach { $0.opacity = 0 }
        }
        // 重置当前索引。
        currentIndex = -1
    }

    private func _isInRange(_ index: Int) -> Bool {
        if index >= -1 && index < config.count {
            return true
        }
        return false
    }
}
