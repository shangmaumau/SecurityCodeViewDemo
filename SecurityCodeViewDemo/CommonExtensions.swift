//
//  CommonExtensions.swift
//  SecurityCodeViewDemo
//
//  Created by suxiangnan on 2021/10/11.
//

import UIKit

extension UIApplication {
    /// Height of status bar.
    public class var statusBarHeight: CGFloat {
        var height: CGFloat = .zero
        var opHeight: CGFloat?
        if #available(iOS 13.0, *) {
            opHeight = self.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height
        } else {
            opHeight = shared.statusBarFrame.height
        }
        if let opHeight = opHeight {
            height = opHeight
        }
        return height
    }
}

extension UIViewController {
    /// MaxY of the navigation bar. Use this value to make constraints.
    public var naviTopPadding: CGFloat {
        var topPadding: CGFloat = .zero
        if let maxY = navigationController?.navigationBar.frame.maxY {
            topPadding = maxY
        }
        return topPadding
    }

    /// Height of navigation bar.
    public var naviBarHeight: CGFloat {
        var height: CGFloat = .zero
        if let barHeight = navigationController?.navigationBar.frame.height {
            height = barHeight
        }
        return height
    }

    /// Height of status bar.
    public var statusBarHeight: CGFloat {
        UIApplication.statusBarHeight
    }
}

extension UIWindow {
    /// The safe padding of window's top side.
    public class var topSafePadding: CGFloat {
        var tsp: CGFloat = .zero
        if #available(iOS 11.0, *),
           let minY = UIApplication.shared.windows.first?.safeAreaLayoutGuide.layoutFrame.minY {
            tsp = minY
        }
        return tsp
    }

    /// The safe padding of window's bottom side.
    public class var bottomSafePadding: CGFloat {
        var bsp: CGFloat = .zero
        if #available(iOS 11.0, *),
           let window = UIApplication.shared.windows.first {
            let safeFrame = window.safeAreaLayoutGuide.layoutFrame
            bsp = window.frame.maxY - safeFrame.maxY
        }
        return bsp
    }
}
