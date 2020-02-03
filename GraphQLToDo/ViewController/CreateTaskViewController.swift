//
//  CreateTaskViewController.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/03.
//  Copyright © 2020 Mori. All rights reserved.
//

import ReactorKit
import RxSwift
import UIKit

final class CreateTaskViewController: UIViewController, StoryboardInstantiate {

    static var storyboardName: StoryboardName = .createTask

    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension CreateTaskViewController: StoryboardView {
    func bind(reactor: CreateTaskViewReactor) {

    }
}

