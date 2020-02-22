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

final class TasksViewController: UIViewController, StoryboardInstantiate {

    static var storyboardName: StoryboardName = .tasks

    var disposeBag = DisposeBag()
    private let refleshControl = UIRefreshControl()

    var callback: Callback?

    struct Callback {
        let showTask:((_ identifier: String) -> Void)
        let showCreateTask: (() -> Void)
    }

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
    @IBOutlet weak var menuButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupRx()
        navigationItem.title = "Tasks"
    }

    private func SetupRx() {
        guard let reactor = self.reactor else { return }
        tasksTableView.rx.itemSelected
            .filter { $0.row < reactor.currentState.tasks.pageElements.count }
            .map { reactor.currentState.tasks.pageElements[$0.row] }
            .subscribe(onNext: {[weak self] item in
                switch item {
                case let .task(task):
                    self?.callback?.showTask(task.identifier)
                }
            }).disposed(by: disposeBag)

        createTaskButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                self?.callback?.showCreateTask()
            })
            .disposed(by: disposeBag)
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

        reactor.state.map { [$0.taskCellItemSection] }
            .bind(to: self.tasksTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        refleshControl.rx.controlEvent(.valueChanged)
            .map { _ in Reactor.Action.load }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .filter { !$0 }
            .subscribe(onNext: {[weak self] _ in
                self?.refleshControl.endRefreshing()
            }).disposed(by: disposeBag)

    }
}
