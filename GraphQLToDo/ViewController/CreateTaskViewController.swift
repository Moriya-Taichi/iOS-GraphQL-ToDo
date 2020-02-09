//
//  CreateTaskViewController.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/03.
//  Copyright © 2020 Mori. All rights reserved.
//

import RxOptional
import ReactorKit
import RxSwift
import UIKit

final class CreateTaskViewController: UIViewController, StoryboardInstantiate {

    static var storyboardName: StoryboardName = .createTask

    var disposeBag = DisposeBag()

    var callback: Callback?

    struct Callback {
        let close: (() -> Void)
    }

    @IBOutlet private var inputDatePicker: UIDatePicker!
    
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
        setupView()
        setupRx()
    }

    private func setupView() {
        dueTextView.inputView = inputDatePicker
    }

    private func setupRx() {
        backgroundCloseButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] _ in
                self?.callback?.close()
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] _ in
                self?.callback?.close()
            })
            .disposed(by: disposeBag)
    }
}

extension CreateTaskViewController: StoryboardView {
    func bind(reactor: CreateTaskViewReactor) {

        titleTextField.rx.text
            .distinctUntilChanged()
            .filterNil()
            .map(Reactor.Action.setTitle)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        noteTextView.rx.text
            .distinctUntilChanged()
            .filterNil()
            .map(Reactor.Action.setNotes)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        completedButton.rx.tap
            .map {[weak self] _ in self?.completedButton.isSelected }
            .filterNil()
            .map { !$0 }
            .do(onNext: {[weak self] in
                self?.completedButton.isSelected = $0
            })
            .map(Reactor.Action.setIsCompleted)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        inputDatePicker.rx.date
            .do(onNext: {[weak self] in
                self?.dueTextView.text = DateFormatters.rfc3339.string(from: $0)
            })
            .map(Reactor.Action.setDue)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        createTaskButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .map { _ in Reactor.Action.createTask }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state.map { $0.isCreated }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: {[weak self] _ in
                self?.callback?.close()
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isCreatable }
            .distinctUntilChanged()
            .bind(to: createTaskButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

