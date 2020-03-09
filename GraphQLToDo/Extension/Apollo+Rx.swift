//
//  Apollo+Rx.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/01/30.
//  Copyright © 2020 Mori. All rights reserved.
//

import Apollo
import RxSwift

enum RxGraphQLError: Error {
    case graphQLErrors([GraphQLError])
    case parseError
}

protocol ReactiveGQLApiType {
    func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy,
        queue: DispatchQueue)
        -> Single<Query.Data>

    func watch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy,
        queue: DispatchQueue)
        -> Observable<Query.Data>

    func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        queue: DispatchQueue)
        -> Single<Mutation.Data>

    func subscription<Subscription: GraphQLSubscription>(
        subscription: Subscription,
        queue: DispatchQueue)
        -> Single<Subscription.Data>
}

final class ReactiveExtensionApolloClient: ReactiveGQLApiType {

    private let provider: GraphQLApiType

    init(_ client: GraphQLApiType) {
        self.provider = client
    }

    func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch,
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<Query.Data>
    {
        return Single.create { single in
            let cancellable = self.provider.client.fetch(
                query: query,
                cachePolicy: cachePolicy,
                queue: queue)
            { result in
                switch result {
                case let .failure(error):
                    single(.error(error))
                case let .success(response):
                    if let errors = response.errors {
                        single(.error(RxGraphQLError.graphQLErrors(errors)))
                    }
                    else if let data = response.data {
                        single(.success(data))
                    }
                }
            }
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }

    func watch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch,
        queue: DispatchQueue = DispatchQueue.main)
        -> Observable<Query.Data>
    {
        return Observable.create { observer in
            let watcher = self.provider.client.watch(
                query: query,
                cachePolicy: cachePolicy,
                queue: queue)
            { result in
                switch result {
                case let .failure(error):
                    observer.onError(error)
                case let .success(response):
                    if let errors = response.errors {
                        observer.onError(RxGraphQLError.graphQLErrors(errors))
                    }
                    else if let data = response.data {
                        observer.onNext(data)
                    }
                }
            }
            return Disposables.create {
                watcher.cancel()
            }
        }
    }

    func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<Mutation.Data>
    {
        return Single.create { single in
            let cancellable = self.provider.client.perform(
                mutation: mutation,
                queue: queue)
            { result in
                switch result {
                case let .failure(error):
                    single(.error(error))
                case let .success(response):
                    if let errors = response.errors {
                        single(.error(RxGraphQLError.graphQLErrors(errors)))
                    }
                    else if let data = response.data {
                        single(.success(data))
                    }
                }
            }
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }

    func subscription<Subscription: GraphQLSubscription>(
        subscription: Subscription,
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<Subscription.Data>
    {
        return Single.create { single in
            let cancellable = self.provider.client.subscribe(
                subscription: subscription)
            { result in
                switch result {
                case let .failure(error):
                    single(.error(error))
                case let .success(response):
                    if let errors = response.errors {
                        single(.error(RxGraphQLError.graphQLErrors(errors)))
                    }
                    else if let data = response.data {
                        single(.success(data))
                    }
                }
            }
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
}
