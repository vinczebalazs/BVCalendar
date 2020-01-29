//
//  UIView+Extension.swift
//  BVCalendar
//
//  Created by Balazs Vincze on 2020. 01. 28..
//  Copyright © 2020. Balazs Vincze. All rights reserved.
//

import UIKit

extension UIView {

    func loadFromNib() -> Self? {
        if subviews.isEmpty {
            return UINib(nibName: String(describing: Self.self), bundle: nil).instantiate(withOwner: nil, options: nil).first as? Self
        }
        return self
    }
    
}
