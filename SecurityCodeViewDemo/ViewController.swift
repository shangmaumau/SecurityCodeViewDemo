//
//  ViewController.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/9/23.
//

import UIKit
import SnapKit

final class LCodeManager {
    static let shared = LCodeManager()
    private init() { }
    public var securityCode: String = ""
}

public enum TestPart {
    case popSecurityCode
    case presentSecurityCode
    case pushSecurityCode
}

class ViewController: UIViewController {
    var tapButton = UIButton()
    private var mainView: SecurityCodeView?
    private var alertView: LAlertViewLite?

    private var testPart: TestPart = .popSecurityCode

    override func viewDidLoad() {
        super.viewDidLoad()
        _addChildViews()
        title = NSLocalizedString("Main View", comment: "")
        view.backgroundColor = .white

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
        switch testPart {
        case .popSecurityCode:
            mainView?.showOnKeyWindow(with: { [weak self] event in
                switch event {
                case .wrongInputTimeout:
                    self?._showAlert(title: NSLocalizedString("安全码验证已达上限", comment: ""), subtitle: NSLocalizedString("请稍后再试", comment: ""), cancel: nil, set: NSLocalizedString("知道了", comment: ""))
                default:
                    break
                }
            })

        case .presentSecurityCode:
            present(LVerifyMobilePhoneNumberVC(), animated: true, completion: nil)

        case .pushSecurityCode:
            navigationController?.pushViewController(LVerifyMobilePhoneNumberVC(), animated: true)
        }
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
