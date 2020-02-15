//
//  UIViewControllerLifecycle+Rx.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/16.
//  Copyright © 2020 Mori. All rights reserved.
//

import RxSwift
import UIKit

extension Reactive where Base: UIViewController {

    var viewDidLoad: Observable<Void> {
        return self.sentMessage(#selector(Base.viewDidLoad))
            .map { _ in }
            .share(replay: 1, scope: .forever)
    }

    var viewWillApper: Observable<Void> {
        return self.sentMessage(#selector(Base.viewDidLoad))
            .map { _ in }
            .share(replay: 1, scope: .forever)
    }

    var viewDidApper: Observable<Void> {
        return self.sentMessage(#selector(Base.viewDidAppear))
            .map { _ in }
            .share(replay: 1, scope: .forever)
    }

    var viewWillDisApper: Observable<Void> {
        return self.sentMessage(#selector(Base.viewWillDisappear))
            .map { _ in }
            .share(replay: 1, scope: .forever)
    }

    var viewDidDisApper: Observable<Void> {
        return self.sentMessage(#selector(Base.viewDidDisappear))
            .map { _ in }
            .share(replay: 1, scope: .forever)
    }
}

