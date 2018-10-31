//
//  App.swift
//  MotionFramework
//
//  Created by Aleksander Maj on 25/10/2018.
//  Copyright © 2018 HTD. All rights reserved.
//

import Foundation

var Current = Environment()

public class App {
    private let window: UIWindow

    public init(window: UIWindow) {
        self.window = window
    }

    public func didFinishLaunching(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        return true
    }
}
