//
//  AccessibleApolloStore.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/06.
//  Copyright © 2020 Mori. All rights reserved.
//

import RxSwift
import Apollo

protocol AccessibleApolloStoreType {

    func load <T: GraphQLSelectionSet>(
        identifier: String,
        fragmentType: T.Type
    )
        -> Observable<T>

    func update<T: GraphQLSelectionSet>(
        identifier: String,
        fragmentType: T.Type,
        newItem: T
    )
        -> Observable<Bool>
}

final class AccessibleApolloStore: AccessibleApolloStoreType {

    let provider: GraphQLApiType

    enum ApolloStoreError: Error {
        case failedUpdate
    }

    init (provider: GraphQLApiType) {
        self.provider = provider
    }

    func load <T: GraphQLSelectionSet>(
        identifier: String,
        fragmentType: T.Type
    )
        -> Observable<T>
    {
        return .create { observable in
            self.provider.client.store.withinReadTransaction(
                { transaction -> T in
                    let data = try transaction.readObject(ofType: fragmentType,
                                                          withKey: identifier)
                    return data
            },
                callbackQueue: .global(),
                completion: { result in
                    switch result {
                    case let .success(data):
                        observable.onNext(data)
                    case let .failure(error):
                        observable.onError(error)
                    }
            })
            return Disposables.create()
        }
    }

    func update<T: GraphQLSelectionSet>(
        identifier: String,
        fragmentType: T.Type,
        newItem: T
    )
        -> Observable<Bool>
    {
        return .create { observable in
            self.provider.client.store.withinReadWriteTransaction(
                { transaction -> T in
                    try transaction.updateObject(
                        ofType: fragmentType,
                        withKey: identifier,
                        { cache in
                            cache = newItem
                    })
                    let data = try transaction.readObject(ofType: fragmentType,
                                                          withKey: identifier)
                    return data
            },
                callbackQueue: .global(),
                completion: { result in
                    switch result {
                    case .success(_):
                        observable.onNext(true)
                    case let .failure(error):
                        observable.onError(error)
                    }
            })
            return Disposables.create()
        }
    }
}
