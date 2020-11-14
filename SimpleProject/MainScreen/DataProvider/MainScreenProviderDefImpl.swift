//
//  MainScreenProviderDefImpl.swift
//  SimpleProject
//
//  Created by Mateusz Wojnar on 14/11/2020.
//  Copyright © 2020 Mateusz Wojnar. All rights reserved.
//

import Foundation
import RxSwift

class MainScreenProviderDefImpl: MainScreenDataProvider {
    var imageURL = PublishSubject<String>()
    var retrySearching = PublishSubject<String>()

      private let disposeBag: DisposeBag = DisposeBag()

    init() {
        bindSearchingAction()
    }

    private func bindSearchingAction() {
        retrySearching.subscribe(onNext: { text in
            self.fetchData(text: text)
        }).disposed(by: disposeBag)
    }

    private func fetchData(text : String){
        ApiClient.getPosts(name: text)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { data in
                self.someItem.onNext(data.data.items)
                self.imageURL.onNext(data.data.baseURL)
            }, onError: { error in
                self.someItem.onNext([Item]())
                print("Unknown error:", error)
            })
            .disposed(by: disposeBag)
    }

    lazy var someItem: BehaviorSubject<[Item]> = {
        let someItem = [Item]()
        return BehaviorSubject<[Item]>(value: someItem)
    }()
}

