//
//  UIScrolView+ReachBottom.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/18.
//  Copyright © 2020 Mori. All rights reserved.
//

import RxSwift
import UIKit

extension Reactive where Base: UIScrollView {

    var isReachedBottom: Observable<Void> {
        return contentOffset
            .filter { [weak base = self.base] _ in
                guard let base = base else { return false }
                return base.isReachedBottom(tolerance: base.bounds.height / 2)
            }
            .map { _ in }
    }
}

extension UIScrollView {

    var isOverflowVertical: Bool {
        return self.contentSize.height > self.bounds.height && self.bounds.height > 0
    }

    func isReachedBottom(tolerance: CGFloat = 0) -> Bool {
        guard isOverflowVertical else { return false }
        let contentOffsetBottom = self.contentOffset.y + self.bounds.height
        return contentOffsetBottom >= self.contentSize.height - tolerance
    }
}
