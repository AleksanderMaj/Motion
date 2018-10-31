//
//  UIButton+Convenience.swift
//  MotionFramework
//
//  Created by Aleksander Maj on 29/10/2018.
//  Copyright © 2018 HTD. All rights reserved.
//

import UIKit

extension UIButton {
    var normalTitle: String? {
        get { return title(for: .normal) }
        set { setTitle(newValue, for: .normal) }
    }
}

