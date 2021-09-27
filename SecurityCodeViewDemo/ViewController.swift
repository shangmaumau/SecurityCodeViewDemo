//
//  ViewController.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/9/23.
//

import SnapKit
import UIKit

final class LCodeManager {
    static let shared = LCodeManager()
    private init() { }
    public var securityCode: String = ""
}

class ViewController: UIViewController {
    var tapButton = UIButton()
    private var mainView: SecurityCodeView?

    override func viewDidLoad() {
        super.viewDidLoad()
        _addChildViews()

        LCodeManager.shared.securityCode = "961030"
    }

    private func _addChildViews() {
        tapButton.backgroundColor = .green
        view.addSubview(tapButton)
        tapButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 60, height: 30))
            make.center.equalToSuperview()
        }

        tapButton.addTarget(self, action: #selector(_tapEvent(_:)), for: .touchUpInside)

        mainView = SecurityCodeView(frame: UIScreen.main.bounds)
    }

    @objc private func _tapEvent(_ sender: UIButton) {
        mainView?.showOnView(view, doneCallback: { _ in

        })
    }
}
