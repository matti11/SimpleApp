//
//  MainScreenViewController.swift
//  SimpleProject
//
//  Created by Mateusz Wojnar on 14/11/2020.
//  Copyright © 2020 Mateusz Wojnar. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import Kingfisher

class MainScreenViewController: UIViewController, Storyboarded {
    static var storyboard = AppStoryboard.mainScreen

    private struct Constants {
        static let cellHeight: CGFloat = 60.0
        static let progressBarWidth: CGFloat = 250.0
        static let progressBarX: CGFloat = 10.0
        static let progressBarY: CGFloat = 20.0
    }

    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var progressCountLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var progressView: ProgressView!
    var coordinator: MainCoordinator?
    private let disposeBag = DisposeBag()
    var viewModel : MainScreenViewModel?
    var progressBar : UIProgressView?
    var alert : UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindAction()
    }

    private func bindAction(){
        bindButtons()
        bindCollectionView()
        bindViewModel()
    }

    private func setupView(){
        prepareDialog()
        self.progressView.isHidden = true
        self.progressCountLabel.isHidden = true
        self.sortButton.isEnabled = false
        collectionView.register(UINib(nibName: MainScreenCell.identifier, bundle: nil), forCellWithReuseIdentifier: MainScreenCell.identifier)
    }

    private func bindViewModel(){
        viewModel?.showDialog.subscribe(onNext: { [weak self] in
            self?.showDialog()
        }).disposed(by: disposeBag)

        viewModel?.progressValue.subscribe(onNext: { value in
            self.updateProgressOnAlert(progress: value)
        }).disposed(by: disposeBag)

        viewModel?.dismissDialog.subscribe(onNext: { _ in
            self.closeDialog()
        }).disposed(by: disposeBag)

        viewModel?.nameButtonColor.observeOn(MainScheduler.asyncInstance).subscribe(onNext: { color in
            self.changeButtonColor(color: color)
        }).disposed(by: disposeBag)

        viewModel?.isProgressViewHidden.observeOn(MainScheduler.asyncInstance).subscribe(onNext: { isHidden in
            self.progressView.isHidden = isHidden
            self.progressCountLabel.isHidden = isHidden
            self.collectionView.isHidden = !isHidden
        }).disposed(by: disposeBag)

        viewModel?.progressViewCountDownValue.observeOn(MainScheduler.asyncInstance).subscribe(onNext: { progress in
            self.updateProgressViewLabel(progress: progress)
        }).disposed(by: disposeBag)

        viewModel?.isSortButtonEnabled.distinctUntilChanged().subscribe(onNext: { isEnabled in
            self.sortButton.isEnabled = isEnabled
        }).disposed(by: disposeBag)
    }

    private func prepareDialog(){
        alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        progressBar = UIProgressView(progressViewStyle: .default)

        if let progressBar = self.progressBar {
            progressBar.setProgress(0.0, animated: true)
            progressBar.frame = CGRect(x: Constants.progressBarX, y: Constants.progressBarY, width: Constants.progressBarWidth, height: 0)

            if let alert = self.alert {
                alert.view.addSubview(progressBar)
            }
        }
    }

    private func showDialog(){
        if let alert = self.alert {
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    private func updateProgressOnAlert(progress : Float){
        if let progressBar = self.progressBar {
            DispatchQueue.main.async {
                progressBar.setProgress(progress, animated: true)
            }
        }
    }

    private func closeDialog(){
        if let alert = self.alert {
            DispatchQueue.main.async {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }

    private func changeButtonColor(color : UIColor){
        DispatchQueue.main.async {
            self.nameButton.titleLabel?.textColor = color
        }
    }

    private func updateProgressViewLabel(progress : Int){
        self.progressCountLabel.text = String(progress)
    }

    private func bindCollectionView(){
        viewModel?.someItems.asObservable().bind(to: self.collectionView.rx.items(cellIdentifier: MainScreenCell.identifier, cellType: MainScreenCell.self)) { row, data, cell in
            cell.titleLabel.text = self.viewModel?.getTextWithStyle(index: row)
            cell.mainImageView.contentMode = .scaleAspectFit
            cell.contentColorView.backgroundColor = self.viewModel?.getCellColor(index: row)

            let url = self.viewModel?.getImageUrl(index: row)
            if let url = url {
                cell.setupImage(url: url)
            }
        }.disposed(by: disposeBag)
    }

    private func bindButtons() {
        if let viewModel = viewModel{
            searchButton.rx.tap.asObservable()
                .filter({ (_) -> Bool in
                    guard !(self.searchTextField.text ?? "").isEmpty else {
                        return false
                    }
                    return true
                })
                .subscribe { _ in
                    viewModel.searchButtonTapped.onNext(self.searchTextField.text ?? "")
            }.disposed(by: disposeBag)

            nameButton.rx
                .controlEvent(.touchUpInside)
                .bind(to: viewModel.nameButtonTapped)
                .disposed(by: disposeBag)

            sortButton.rx
                .controlEvent(.touchUpInside)
                .bind(to: viewModel.sortButtonTapped)
                .disposed(by: disposeBag)

            collectionView
                .rx
                .modelAndIndexSelected(Item.self)
                .filter({ (arg0 ) -> Bool in
                    let (_, index) = arg0
                    return viewModel.isCellClickable(index: index.row) ?? false
                })
                .subscribe(onNext: { (model, index) in
                    self.showAlertOnTapToDelete(index: index.row, imageName: model.title)
                }).disposed(by: disposeBag)
        }
    }

    private func showAlertOnTapToDelete(index : Int, imageName : String){
        let alert = UIAlertController(title: "Czy na pewno usunąć \(imageName)?", message: "", preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)

        alert.addAction(UIAlertAction(title: "TAK", style: .default, handler: { action in
            self.viewModel?.deleteItem.onNext(index)
        }))
        alert.addAction(UIAlertAction(title: "NIE", style: .cancel, handler: nil))
    }
}

extension MainScreenViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: UIScreen.main.bounds.width, height: Constants.cellHeight)
    }
}

