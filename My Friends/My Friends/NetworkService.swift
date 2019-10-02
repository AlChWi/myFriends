//
//  NetworkService.swift
//  My Friends
//
//  Created by Алексей Перов on 26.09.2019.
//  Copyright © 2019 Алексей Перов. All rights reserved.
//

import Foundation
import SwiftyJSON

class NetworkService {
    //MARK: - BASE URL -
    private let baseURL = "https://randomuser.me/api/"
    
    //MARK: - METHODS -
    func getUsers(_ completionHandler: @escaping (Result<[User], Error>) -> Void) {
        guard let url = URL(string: baseURL) else { return }
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [URLQueryItem(name: "format", value: "json"), URLQueryItem(name: "results", value: "50")]
        guard let resultingURL = urlComponents?.url else { return }
        URLSession.shared.dataTask(with: resultingURL) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(error))
                print(error.localizedDescription)
            } else if let resp = response as? HTTPURLResponse, (200..<300).contains(resp.statusCode), let responseData = data {
                if let json = try? JSON(data: responseData) {
                    var people: [User] = []
                    let amountOfPeople = json["results"].arrayValue.count
                    for element in 0..<amountOfPeople {
                        let user = User(json: json["results"][element])
                        guard let aUser = user else { return }
                        people.append(aUser)
                    }
                    completionHandler(.success(people))
                }

            }
        }.resume()
    }
}
