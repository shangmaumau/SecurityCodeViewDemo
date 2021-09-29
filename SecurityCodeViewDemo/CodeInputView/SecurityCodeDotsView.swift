//
//  SecurityCodeDotsView.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/9/27.
//

import UIKit

/// 安全码点视图。
final class SecurityCodeDotsView: UIView {
    /// 点的数量
    public private(set) var count: Int
    /// 点图层数组
    private var dotLayers: [CALayer] = []
    /// 当前索引位置，-1 表示未输入任何数。
    private var currentIndex: Int = -1
    /// 标记位，图层是否已经添加
    private var isAdd: Bool = false

    init(count: Int, frame: CGRect) {
        self.count = count
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
        let width = frame.width / CGFloat(count)
        let height = frame.height
        let size = CGSize(width: 10, height: 10)
        for index in 0 ..< count {
            let dotLayer = CALayer()
            dotLayer.bounds = CGRect(origin: .zero, size: size)
            // rgba(35, 41, 52, 1)
            dotLayer.backgroundColor = UIColor(red: 35 / 255.0, green: 41 / 255.0, blue: 52 / 255.0, alpha: 1).cgColor
            dotLayer.position = CGPoint(x: 0.5 * width + CGFloat(index) * width, y: 0.5 * height)
            dotLayer.cornerRadius = size.height / 2.0
            dotLayer.opacity = 0
            dotLayers.append(dotLayer)
            layer.addSublayer(dotLayer)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 添加一个点
    public func addDot() {
        guard _isInRange(currentIndex) else {
            return
        }
        // 先加index，再变对应的为不透明
        currentIndex += 1
        UIView.animate(withDuration: 0.2) { [unowned self] in
            dotLayers[currentIndex].opacity = 1.0
        }
    }

    /// 删除一个点
    public func deleteDot() {
        guard _isInRange(currentIndex) else {
            return
        }
        // 先将当前变透明，再减index
        UIView.animate(withDuration: 0.2) { [unowned self] in
            dotLayers[currentIndex].opacity = 0
        }
        currentIndex -= 1
    }

    /// 删除所有点
    public func deleteAll() {
        UIView.animate(withDuration: 0.2) { [unowned self] in
            dotLayers.forEach { $0.opacity = 0 }
        }
        // 重置当前索引
        currentIndex = -1
    }

    private func _isInRange(_ index: Int) -> Bool {
        if index >= -1 && index < count {
            return true
        }
        return false
    }
}
