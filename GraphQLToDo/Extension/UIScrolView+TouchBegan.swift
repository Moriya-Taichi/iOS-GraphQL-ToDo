//
//  UIScrolView+TouchBegan.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/10.
//  Copyright © 2020 Mori. All rights reserved.
//

import UIKit

extension UIScrollView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
    }
}
