//
//  QueryBuilder.swift
//  20220824-TadreikCampbell-NYCSchools
//
//  Created by Tadreik Campbell on 8/25/22.
//

import Foundation

class SchoolQuery: Query {
    var queryItems: Set<URLQueryItem>?
    var endpoint = Endpoints.schoolEndpoint
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = APIDefaults.NYCSchoolAPIBaseDomain
        components.path = endpoint.rawValue
        if let queryItems = queryItems {
            components.queryItems = Array(queryItems)
        }
        return components.url!
    }
    
    func fetchSchools() -> Self {
        endpoint = Endpoints.schoolEndpoint
        return self
    }
    
    func fetchScores() -> Self {
        endpoint = Endpoints.scoresEndpoint
        return self
    }
    
    // Started building an API for fetching data,
    // then realized the standalone json dataset doesn't support the queries
    
    // This makes it extremely easy to build queries
    // SchoolQuery().fetchSchools().offset(array.count).limit(10)
    // and of course I could add functions for more params
    
    func withDBN(_ value: String) -> Self {
        if self.queryItems == nil {
            self.queryItems = []
        }
        let item = URLQueryItem(name: "dbn", value: value)
        self.queryItems?.insert(item)
        return self
    }
    
    func limitTo(_ value: Int) -> Self {
        if self.queryItems == nil {
            self.queryItems = []
        }
        let item = URLQueryItem(name: "limit", value: String(value))
        self.queryItems?.insert(item)
        return self
    }
    
    func withOffset(_ value: Int) -> Self {
        if self.queryItems == nil {
            self.queryItems = []
        }
        let item = URLQueryItem(name: "offset", value: String(value))
        self.queryItems?.insert(item)
        return self
    }
    
}

