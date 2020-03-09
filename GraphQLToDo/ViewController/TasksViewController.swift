//
//  TasksViewController.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/03.
//  Copyright © 2020 Mori. All rights reserved.
//

import RxDataSources
import ReactorKit
import RxSwift
import UIKit

final class TasksViewController: UIViewController {
    
    static func create() -> Self {
        let storyboard = UIStoryboard(name: "Tasks", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "TasksViewController") as! Self
        return viewController
    }
    
    var disposeBag = DisposeBag()
    private let refleshControl = UIRefreshControl()
    
    weak var delegate: TaskDelegate?
    
    @IBOutlet weak var tasksTableView: UITableView! {
        didSet {
            tasksTableView.register(UINib(nibName: "TaskCell", bundle: nil),
                                    forCellReuseIdentifier: "TaskCell")
            tasksTableView.refreshControl = refleshControl
        }
    }
    @IBOutlet private weak var createTaskButton: UIButton! {
        didSet {
            createTaskButton.layer.cornerRadius = createTaskButton.frame.width / 2
            createTaskButton.setImage(#imageLiteral(resourceName: "CreateTaskImage").withRenderingMode(.alwaysTemplate), for: .normal)
            createTaskButton.tintColor = .white
            createTaskButton.backgroundColor = .systemPink
        }
    }
    @IBOutlet private weak var menuButton: UIButton! {
        didSet {
            menuButton.layer.cornerRadius = menuButton.frame.width / 2
            menuButton.setImage(#imageLiteral(resourceName: "MenuImage").withRenderingMode(.alwaysTemplate), for: .normal)
            menuButton.tintColor = .white
            menuButton.backgroundColor = .systemPink
        }
    }
    private let menuPickerView = UIPickerView()
    private let pickerToolBar = UIToolbar()
    private let pickerWithToolBar = UIView()
    private let toolBarDoneButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupRx()
        navigationItem.title = "Tasks"
    }
    
    private func setupView() {
        menuPickerView.frame = CGRect(x: 0,
                                      y: 0,
                                      width: self.view.frame.width,
                                      height: self.view.frame.height / 3)
        pickerWithToolBar.frame = menuPickerView.frame
        pickerWithToolBar.frame.origin = CGPoint(x: 0,
                                                 y: self.view.frame.height)
        pickerToolBar.barStyle = .default
        pickerToolBar.frame = CGRect(x: 0,
                                     y: 0,
                                     width: self.menuPickerView.frame.width,
                                     height: 40)
        toolBarDoneButton.title = "Done"
        pickerToolBar.setItems([toolBarDoneButton], animated: true)
        pickerWithToolBar.backgroundColor = .white
        pickerWithToolBar.addSubview(menuPickerView)
        pickerWithToolBar.addSubview(pickerToolBar)
    }
    
    private func setupRx() {
        guard let reactor = self.reactor else { return }
        tasksTableView.rx.itemSelected
            .filter { $0.row < reactor.currentState.tasks.pageElements.count }
            .map { reactor.currentState.tasks.pageElements[$0.row] }
            .subscribe(onNext: {[weak self] item in
                guard let self = self else {
                    return
                }
                switch item {
                case let .task(task):
                    self.delegate?.showTask(identifier: task.identifier, vc: self)
                }
            }).disposed(by: disposeBag)
        
        createTaskButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                guard let self = self else {
                    return
                }
                self.delegate?.showCreateTask(vc: self)
            })
            .disposed(by: disposeBag)
        
        menuButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.view.addSubview(self.pickerWithToolBar)
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3) {
                        self.pickerWithToolBar.frame.origin.y = self.view.frame.height - self.pickerWithToolBar.frame.height
                    }
                }
            }).disposed(by: disposeBag)
        
        toolBarDoneButton.rx.tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    UIView.animate(
                        withDuration: 0.3,
                        animations: {
                            self.pickerWithToolBar.frame.origin.y = self.view.frame.height + self.pickerWithToolBar.frame.height
                    })
                    { _ in
                        self.pickerWithToolBar.removeFromSuperview()
                    }
                }
            }).disposed(by: disposeBag)
    }
}

extension TasksViewController: StoryboardView {
    func bind(reactor: TasksViewReactor) {
        
        Observable<Void>.just(())
            .map{ _ in Reactor.Action.load }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tasksTableView.rx.isReachedBottom
            .map { _ in Reactor.Action.paginate }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<CellItemSection>(
            animationConfiguration: AnimationConfiguration(insertAnimation: .fade,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .fade),
            configureCell: { [weak self] _, _, indexPath, item in
                let defaultCell = UITableViewCell()
                switch item {
                case let .task(task):
                    guard
                        let cell = self?.tasksTableView.dequeueReusableCell(withIdentifier: "TaskCell",
                                                                            for: indexPath) as? TaskCell
                        else { return defaultCell }
                    cell.reactor = task
                    return cell
                default:
                    return defaultCell
                }
        })
        
        let pickerViewAdapter = RxPickerViewStringAdapter<[[String]]>(
            components: [],
            numberOfComponents: { _, _, components in return components.count },
            numberOfRowsInComponent: { _, _, components, component in return components[component].count },
            titleForRow: { _, _, components, row, component in return components[component][row] }
        )
        
        reactor.state.map { [$0.taskCellItemSection] }
            .bind(to: self.tasksTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        refleshControl.rx.controlEvent(.valueChanged)
            .map { _ in Reactor.Action.reload }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .filter { !$0 }
            .subscribe(onNext: {[weak self] _ in
                self?.refleshControl.endRefreshing()
            }).disposed(by: disposeBag)

        reactor.state.map { $0.menuOrderOptions }
            .bind(to: menuPickerView.rx.items(adapter: pickerViewAdapter))
            .disposed(by: disposeBag)

        menuPickerView.rx.itemSelected
            .map(Reactor.Action.selectCompletedAndOrder)
            .debug()
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state.map { $0.taskOrder }
            .distinctUntilChanged()
            .map { _ in Reactor.Action.load }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state.map { $0.isCompleted }
            .distinctUntilChanged()
            .map { _ in Reactor.Action.load }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
