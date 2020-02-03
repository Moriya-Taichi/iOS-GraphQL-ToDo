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

    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var backgroundCloseButton: UIButton!
    @IBOutlet private weak var createTaskButton: UIButton!

    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var dueTextView: UITextView!
    @IBOutlet private weak var completedButton: UIButton!
    @IBOutlet private weak var noteTextView: UITextView!

    @IBOutlet private weak var contentView: UIView! {
        didSet {
            contentView.layer.cornerRadius = 15
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension CreateTaskViewController: StoryboardView {
    func bind(reactor: CreateTaskViewReactor) {

    }
}

