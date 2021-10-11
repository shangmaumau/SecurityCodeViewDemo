//
//  PasswordAlertView.swift
//  LappTest
//
//  Created by better me on 2021/7/14.
//

import UIKit
import SnapKit

protocol PasswordAlertViewDelegate: NSObjectProtocol {
    func passwordCompleteInAlertView(alertView: PasswordAlertView, password: NSString)
}

class PasswordAlertView: UIView, UITextFieldDelegate {
    let screenH = UIScreen.main.bounds.size.height
    let screenW = UIScreen.main.bounds.size.width
    let buttonH = 49
    let borderH = 45
    let pointSize = CGSize(width: 10, height: 10)
    let pointCount = 6
    var pointViewArray = NSMutableArray()
    var BGView = UIView()
    var textFiled = UITextField()

    weak var delegate: PasswordAlertViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    func setupUI() {
        // 背景颜色
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        // 弹框背景
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: screenW - 30, height: 200))
        bgView.center = self.center
        bgView.backgroundColor = UIColor.white
        bgView.layer.cornerRadius = 5
        bgView.layer.masksToBounds = true
        BGView = bgView
        self.addSubview(bgView)
        let bgViewW = bgView.frame.size.width

//        grayCloseIcon@2x
        let closeButton = UIButton(type: .custom)
        closeButton.backgroundColor = .cyan
        closeButton.setBackgroundImage(UIImage(named: "grayCloseIcon"), for: .normal)
        closeButton.addTarget(self, action: #selector(cancel(sender:)), for: .touchUpInside)
        bgView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.left.top.equalToSuperview().offset(5)
        }

        // tipsLabel
        let tipLabel = UILabel(frame: CGRect(x: 0, y: 30, width: bgViewW, height: 25))
        tipLabel.text = "请输入安全验证码"
        tipLabel.textAlignment = NSTextAlignment.center
        bgView.addSubview(tipLabel)

        // 密码框
        for i in 0..<pointCount {
            let pswLabel = UILabel(frame: CGRect(x: (Int(bgViewW) - Int(borderH * pointCount))/2 + borderH * i, y: Int(tipLabel.frame.origin.y + 40), width: borderH, height: borderH))
            pswLabel.layer.borderWidth = 0.5
            pswLabel.layer.borderColor = UIColor.gray.cgColor
            let pointView = UIView(frame: CGRect(x: 0, y: 0, width: pointSize.width, height: pointSize.height))
            pointView.center = pswLabel.center
            pointView.backgroundColor = UIColor.black
            pointView.layer.cornerRadius = pointSize.width/2
            pointView.layer.masksToBounds = true
            pointView.isHidden = true
            bgView.addSubview(pointView)
            pointViewArray.add(pointView)
            bgView.addSubview(pswLabel)
        }

        let textFiled = UITextField(frame: CGRect(x: 0, y: Int(tipLabel.frame.origin.y) + 80, width: Int(bgViewW), height: borderH))
        textFiled.backgroundColor = UIColor.clear
        // 设置代理
        textFiled.delegate = self
        // 监听编辑状态的变化
        textFiled.addTarget(self, action: #selector(textFiledValueChanged(textFiled:)), for: .editingChanged)
        textFiled.tintColor = UIColor.clear
        textFiled.textColor = UIColor.clear
        textFiled.becomeFirstResponder()
        // 设置键盘类型为数字键盘
        textFiled.keyboardType = .numberPad
        self.textFiled = textFiled
        bgView.addSubview(self.textFiled)

        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(info:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(info:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        // 忘记密码
        let forgateBtn = UIButton(type: .custom)
        forgateBtn.setTitle("忘记密码?", for: .normal)
        forgateBtn.setTitleColor(UIColor.black.withAlphaComponent(0.7), for: .normal)
        forgateBtn.addTarget(self, action: #selector(cancel(sender:)), for: .touchUpInside)
        bgView.addSubview(forgateBtn)
        forgateBtn.snp.makeConstraints { make in

            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(30)
            make.centerX.equalTo(bgView)
        }
    }

    @objc func cancel(sender: UIButton) {
        self.removeFromSuperview()
    }

    @objc func sure(sender: UIButton) {
        print("确定")
        delegate?.passwordCompleteInAlertView(alertView: self, password: self.textFiled.text! as NSString)
    }

    @objc func textFiledValueChanged(textFiled: UITextField) {
        for pointView in self.pointViewArray {
            (pointView as! UIView).isHidden = true
        }

        for i in 0..<Int((textFiled.text?.count)!) {
            (self.pointViewArray.object(at: i) as! UIView).isHidden = false
        }

        if textFiled.text?.count == pointCount {
            print("输入完成,进行校验")
            self.endEditing(true)
            delegate?.passwordCompleteInAlertView(alertView: self, password: self.textFiled.text! as NSString)
        }
    }

    @objc func keyBoardWillShow(info: NSNotification) {
        let userInfos = info.userInfo![UIResponder.keyboardFrameEndUserInfoKey]
        let heigh = (userInfos as AnyObject).cgRectValue.size.height
        self.BGView.center = CGPoint(x: self.BGView.center.x, y: screenH - heigh - self.BGView.frame.size.height/2 - 40)
    }

    @objc func keyBoardWillHide(info: NSNotification) {
        self.BGView.center = self.center
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.endEditing(true)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0 { // 判断是是否为删除键
            return true
        } else if (textField.text?.count)! >= pointCount {
            // 当输入的密码大于等于6位后就忽略
            return false
        } else {
            return true
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
