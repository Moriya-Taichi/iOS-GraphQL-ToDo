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

final class CreateTaskViewController: UIViewController {

    static func create()  -> Self {
        let storyboard = UIStoryboard(name: "CreateTask", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "CreateTaskViewController") as! Self
        return viewController
    }

    var disposeBag = DisposeBag()

    weak var delegate: TaskDelegate?

    @IBOutlet private var inputDatePicker: UIDatePicker!
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var backgroundCloseButton: UIButton!
    @IBOutlet private weak var createTaskButton: UIButton! {
        didSet {
            createTaskButton.layer.borderWidth = 1
            createTaskButton.layer.borderColor = UIColor.black.cgColor
            createTaskButton.layer.cornerRadius = 20
        }
    }

    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var dueTextView: UITextView!
    @IBOutlet private weak var completedButton: UIButton! {
        didSet {
            completedButton.setImage(#imageLiteral(resourceName: "CheckedImage").withRenderingMode(.alwaysOriginal),
                                     for: .selected)
            completedButton.setImage(#imageLiteral(resourceName: "CheckImage").withRenderingMode(.alwaysOriginal),
                                     for: .normal)
        }
    }
    @IBOutlet private weak var notesTextView: UITextView!

    @IBOutlet private weak var contentView: UIView! {
        didSet {
            contentView.layer.cornerRadius = 15
        }
    }

    @IBOutlet weak var contentScrolView: UIScrollView! {
        didSet {
            contentScrolView.layer.cornerRadius = 15
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupRx()
    }

    private func setupView() {
        dueTextView.inputView = inputDatePicker
        self.view.backgroundColor = UIColor(red: 0,
                                            green: 0,
                                            blue: 0,
                                            alpha: 0.3)
    }

    private func setupRx() {
        backgroundCloseButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else {
                    return
                }
                self.delegate?.close(vc: self)
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else {
                    return
                }
                self.delegate?.close(vc: self)
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

        notesTextView.rx.text
            .distinctUntilChanged()
            .filterNil()
            .map(Reactor.Action.setNotes)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        completedButton.rx.tap
            .map {[weak self] _ in self?.completedButton.isSelected }
            .filterNil()
            .map { !$0 }
            .map(Reactor.Action.setIsCompleted)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        inputDatePicker.rx.date
            .skip(1)
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
                guard let self = self else {
                    return
                }
                self.delegate?.close(vc: self)
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isCreatable }
            .distinctUntilChanged()
            .bind(to: createTaskButton.rx.isEnabled)
            .disposed(by: disposeBag)

        reactor.state.map { $0.isCompleted }
            .distinctUntilChanged()
            .filterNil()
            .subscribe(onNext: { [weak self] in
                self?.completedButton.isSelected = $0
            }).disposed(by: disposeBag)

        reactor.state.map { $0.due }
            .distinctUntilChanged()
            .filterNil()
            .subscribe(onNext: {[weak self] in
                let dateString = ISO8601DateFormatter.string(from: $0,
                                                             timeZone: .current,
                                                             formatOptions: [.withFullDate,
                                                                             .withTime,
                                                                             .withDashSeparatorInDate,
                                                                             .withColonSeparatorInTime,
                                                                             .withSpaceBetweenDateAndTime])
                self?.dueTextView.text = dateString
            }).disposed(by: disposeBag)
    }
}

extension CreateTaskViewController: UITextViewDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
