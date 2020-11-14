//
//  MainScreenDataProvider.swift
//  SimpleProject
//
//  Created by Mateusz Wojnar on 14/11/2020.
//  Copyright © 2020 Mateusz Wojnar. All rights reserved.
//

import Foundation
import RxSwift

protocol MainScreenDataProvider {
    var someItem: BehaviorSubject<[Item]>  { get }
    var retrySearching: PublishSubject<String> { get }
    var imageURL: PublishSubject<String> { get }
}

