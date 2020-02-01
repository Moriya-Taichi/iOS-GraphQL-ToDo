//
//  GraphQLProviderType.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/01/30.
//  Copyright © 2020 Mori. All rights reserved.
//

import Foundation

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

    var header: [String : String] {
        var header: [String: String] = [:]

        return header
    }

    var rx: ReactiveGQLApiType { return ReactiveExtensionApolloClient(self) }

    init() { }
}
