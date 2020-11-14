//
//  MainScreenViewModel.swift
//  SimpleProject
//
//  Created by Mateusz Wojnar on 14/11/2020.
//  Copyright © 2020 Mateusz Wojnar. All rights reserved.
//

import Foundation
import RxSwift

protocol MainScreenViewModel {
    var searchButtonTapped: PublishSubject<String> { get }
    var sortButtonTapped: PublishSubject<Void> { get }
    var nameButtonTapped: PublishSubject<Void> { get }
    var someItems: BehaviorSubject<[Item]> { get }
    var deleteItem: PublishSubject<Int> { get }
    var nameButtonColor: PublishSubject<UIColor> { get }
    var showDialog: PublishSubject<Void> { get }
    var dismissDialog: PublishSubject<Void> { get }
    var progressValue: PublishSubject<Float> { get }
    var isProgressViewHidden: PublishSubject<Bool> { get }
    var isSortButtonEnabled: PublishSubject<Bool> { get }
    var progressViewCountDownValue: PublishSubject<Int> { get }

    func getImageUrl(index : Int) -> URL?
    func getCellColor(index : Int) -> UIColor
    func getTextWithStyle(index : Int) -> String
    func isCellClickable(index : Int) -> Bool
}

class MainScreenViewModelDefImpl: MainScreenViewModel {

     // MARK: - Properties

    var imageUrl = ""
    private let disposeBag = DisposeBag()
    var dataProvider : MainScreenDataProvider

    init(dataProvider : MainScreenDataProvider){
        self.dataProvider = dataProvider
        setupAction()
    }

    private func setupAction(){
        searchButtonTapped.subscribe(onNext: { text in
            self.dataProvider.retrySearching.onNext(text)
            self.isProgressViewHidden.onNext(false)
            self.fireCountDownProgressSimulation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.isProgressViewHidden.onNext(true)
                let someItem = try? self.dataProvider.someItem.asObserver().value()
                self.someItems.onNext(someItem ?? [Item]())
                if let someItem = someItem {
                    self.isSortButtonEnabled.onNext(!someItem.isEmpty)
                }
            }
        }).disposed(by: disposeBag)

        deleteItem.subscribe(onNext: { index in
            self.removeElement(index: index)
        }).disposed(by: disposeBag)

        nameButtonTapped.subscribe(onNext: { [weak self] in
            self?.fireChangeColorProgressSimulation()
        }).disposed(by: disposeBag)

        sortButtonTapped.subscribe(onNext: { [weak self] in
            self?.sortItems()
        }).disposed(by: disposeBag)

        dataProvider.imageURL.subscribe(onNext: { url in
            self.imageUrl = url
        }).disposed(by: disposeBag)
    }

    private func sortItems(){
        var items = try? someItems.value()
        items?.sort{
            if $0.id != nil && $1.id != nil {
                return $0.id! < $1.id!
            }
            else {
                return $0.title < $1.title
            }
        }
        if let items = items {
            someItems.onNext(items)
        }
    }

    private func fireChangeColorProgressSimulation(){
        self.showDialog.onNext(())
        DispatchQueue.global(qos: .background).async {
            var progress : Float = 0
            repeat {
                Thread.sleep(forTimeInterval: 1)
                self.progressValue.onNext(progress)
                progress += 0.2
            } while progress <= 1.0
            self.dismissDialog.onNext(())
            self.nameButtonColor.onNext(.green)
        }
    }

    private func fireCountDownProgressSimulation(){
        DispatchQueue.global(qos: .background).async {
            var progress : Int = 5
            repeat {
                self.progressViewCountDownValue.onNext(progress)
                Thread.sleep(forTimeInterval: 1)
                progress -= 1
            } while progress > 0
        }
    }

    private func removeElement(index : Int) {
        let itemId = try? someItems.value()[index].id
        someItems.onNext(try! someItems.value().filter { $0.id != itemId } )
    }

    public func getCellColor(index : Int) -> UIColor {
        return index % 2 == 0 ? .blue : .white
    }

    public func getTextWithStyle(index : Int) -> String {
        let text = try? someItems.value()[index]
        if let text = text {
            return ((index % 2 == 0 ? text.title.uppercased() as String? : text.title.lowercased() as String?) ?? "")
        }
        else {
            return ""
        }
    }

    public func getImageUrl(index : Int) -> URL? {
        let imageUrlForIndex = try? someItems.value()[index].url
        if let imageUrlForIndex = imageUrlForIndex {
            let url = URL(string: "\(imageUrl)\(imageUrlForIndex )")
            return url
        }
        return URL(string: "")
    }

    public func isCellClickable(index : Int) -> Bool {
        return index % 2 == 0 ? true : false
    }

    // MARK: - Observables

    var someItems: BehaviorSubject<[Item]>  {
        return dataProvider.someItem
    }

    // MARK: - Actions
    var progressValue = PublishSubject<Float>()
    var nameButtonColor = PublishSubject<UIColor>()
    var searchButtonTapped = PublishSubject<String>()
    var sortButtonTapped = PublishSubject<Void>()
    var nameButtonTapped = PublishSubject<Void>()
    var showDialog = PublishSubject<Void>()
    var dismissDialog = PublishSubject<Void>()
    var deleteItem = PublishSubject<Int>()
    var isProgressViewHidden = PublishSubject<Bool>()
    var isSortButtonEnabled = PublishSubject<Bool>()
    var progressViewCountDownValue = PublishSubject<Int>()
}
