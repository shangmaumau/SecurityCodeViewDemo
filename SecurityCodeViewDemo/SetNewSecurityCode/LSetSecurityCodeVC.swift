//
//  LSetSecurityCodeVC.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/10/9.
//

import UIKit
import SnapKit

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
            make.top.equalToSuperview().offset(57)
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

        view.addSubview(dotsView!)
        dotsView?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(60)
            make.top.equalTo(subtitleText!.snp.bottom).offset(40)
        })

        dotsView?.getUp()
    }
}
