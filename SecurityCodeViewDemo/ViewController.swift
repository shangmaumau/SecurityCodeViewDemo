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
    private var alertView: LAlertViewLite?

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
        mainView?.showOnKeyWindow(with: { [weak self] event in

            switch event {
            case .wrongInputTimeout:
                self?._showAlert(title: NSLocalizedString("安全码验证已达上限", comment: ""), subtitle: NSLocalizedString("请稍后再试", comment: ""), cancel: NSLocalizedString("得了", comment: ""), set: NSLocalizedString("知道了", comment: ""))
            default:
                break
            }
        })
    }

    private func _showAlert(title: String?, subtitle: String?, cancel: String?, set: String?) {
        let alertView = LAlertViewLite(title: title, subtitle: subtitle, cancelTitle: cancel, setTitle: set)
        alertView.showOnKeyWindow {
            // cancel
        } setCallback: {
            // done
        }
    }
}
