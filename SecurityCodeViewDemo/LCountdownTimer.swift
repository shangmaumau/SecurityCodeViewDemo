//
//  LCountdownTimer.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/10/11.
//

import Foundation

public class LCountdownTimer {
    static let shared = LCountdownTimer()
    private init() {
        decreaseSeconds = countdownSeconds
        realInit()
    }

    public var countdownSeconds: TimeInterval = 10 {
        didSet {
            if !isRunning {
                _resetLeftSeconds()
            }
        }
    }

    public var isRunning: Bool {
        decreaseSeconds > .zero
    }

    private var decreaseSeconds: TimeInterval = .zero

    private var timer: Timer?
    private var timerCallback: ((_ isEnd: Bool, _ leftSeconds: TimeInterval) -> Void)?

    private func realInit() {
        let timerProxy = TimerProxy(with: self, selector: #selector(_timerSelector))
        timer = Timer(timeInterval: 1, target: timerProxy, selector: #selector(timerProxy.executeSelector), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }

    public func fire(callback: @escaping (_ isTimeup: Bool, _ leftSeconds: TimeInterval) -> Void) {
        if timer == nil {
            realInit()
        }
        // new fire, reset left seconds.
        if !isRunning {
            _resetLeftSeconds()
        }
        timer?.fire()
        timerCallback = callback
    }

    public func shutdown() {
        timer?.invalidate()
        timer = nil
        decreaseSeconds = .zero
    }

    @objc private func _timerSelector() {
        let isTimeup = decreaseSeconds == .zero
        timerCallback?(isTimeup, decreaseSeconds)
        decreaseSeconds -= 1

        if isTimeup {
            timer?.invalidate()
            timer = nil
        }
    }

    private func _resetLeftSeconds() {
        decreaseSeconds = countdownSeconds
    }
}

public class TimerProxy {
    private weak var target: AnyObject?
    private var selector: Selector

    init(with target: AnyObject, selector: Selector) {
        self.target = target
        self.selector = selector
    }

    @objc public func executeSelector() {
        if let target = target, target.responds(to: selector) {
            _ = target.perform(selector)
        }
    }

    deinit {
        debugPrint("deinit - \(Self.self)")
    }
}
