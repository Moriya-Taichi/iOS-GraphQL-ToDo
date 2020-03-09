//
//  GraphQLProviderType.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/01/30.
//  Copyright © 2020 Mori. All rights reserved.
//

import Foundation
import Apollo

final class GraphQLApiProvider: GraphQLApiType {

    var baseURL: URL {
        guard
            let baseApiString = Bundle.main.object(forInfoDictionaryKey: "BaseAPI") as? String,
            let apiURL = URL(string: baseApiString)
            else {
                fatalError("BaseAPI is unavailable")
        }
        return apiURL
    }

    lazy var client: ApolloClient = {
        let networkTransport = HTTPNetworkTransport(url: baseURL)
        let client = ApolloClient(networkTransport: networkTransport)
        client.cacheKeyForObject = { $0["id"] }
        return client
    }()

    var header: [String : String] {
        var header: [String: String] = [:]

        return header
    }

    var rx: ReactiveGQLApiType { return ReactiveExtensionApolloClient(self) }

    init() { }
}
