//
//  ApiClient.swift
//  SimpleProject
//
//  Created by Mateusz Wojnar on 14/11/2020.
//  Copyright © 2020 Mateusz Wojnar. All rights reserved.
//

import Alamofire
import RxSwift

class ApiClient {

    static func getPosts(name: String) -> Observable<SomeItem> {
        return request(ApiRouter.getPosts(name: name))
    }

    private static func request<T: Codable> (_ urlConvertible: URLRequestConvertible) -> Observable<T> {
        return Observable<T>.create { observer in

            let request = AF.request(urlConvertible).validate().responseDecodable(of: SomeItem.self)  { response in

                switch response.result {
                case .success(let value):
                    observer.onNext(value as! T)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
