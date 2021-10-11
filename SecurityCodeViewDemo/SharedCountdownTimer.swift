//
//  SharedCountdownTimer.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/10/11.
//

import Foundation

public class SharedCountdownTimer {
    static let shared = SharedCountdownTimer()
    private init() {
        decreaseSeconds = countdownSeconds
        realInit()
    }

    public var countdownSeconds: TimeInterval = 10 {
        didSet {
            decreaseSeconds = countdownSeconds
        }
    }

    public var isRunning: Bool {
        decreaseSeconds > .zero
    }

    private var decreaseSeconds: TimeInterval = .zero

    private var timer: Timer?
    private var timerProxy: TimerProxy?
    private var timerCallback: ((_ isEnd: Bool, _ leftSeconds: TimeInterval) -> Void)?

    private func realInit() {
        timerProxy = TimerProxy(with: self, selector: #selector(_timerSelector))
        timer = Timer(timeInterval: 1, target: timerProxy!, selector: #selector(timerProxy!.executeSelector), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }

    public func fire(callback: @escaping (_ isTimeup: Bool, _ leftSeconds: TimeInterval) -> Void) {
        if timer == nil {
            realInit()
        }
        // 新跑起来，时间重置
        if !isRunning {
            decreaseSeconds = countdownSeconds
        }
        timer?.fire()
        timerCallback = callback
    }

    @objc private func _timerSelector() {
        let isTimeup = decreaseSeconds == .zero
        timerCallback?(isTimeup, decreaseSeconds)
        if isTimeup {
            timer?.invalidate()
            timer = nil
            timerProxy = nil
        }
        decreaseSeconds -= 1
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
