//
//  Storyboarded.swift
//  SimpleProject
//
//  Created by Mateusz Wojnar on 14/11/2020.
//  Copyright © 2020 Mateusz Wojnar. All rights reserved.
//

import Foundation
import UIKit

enum AppStoryboard: String {
    case mainScreen = "Main"
}

protocol Storyboarded {
    static var storyboard: AppStoryboard { get }
    static func instantiate() -> Self
}

extension Storyboarded {
    static func instantiate() -> Self {
        let identifier = String(describing: self)
        let uiStoryboard = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        let viewController = uiStoryboard.instantiateViewController(withIdentifier: identifier) as! Self

        return viewController
    }
}
