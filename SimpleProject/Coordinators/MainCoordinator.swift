//
//  MainCoordinator.swift
//  SimpleProject
//
//  Created by Mateusz Wojnar on 14/11/2020.
//  Copyright © 2020 Mateusz Wojnar. All rights reserved.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.isNavigationBarHidden = true
    }

    func start() {
        goToMainScreen()
    }

    func goToMainScreen(){
        let dataProvider = MainScreenProviderDefImpl()
        let viewModel = MainScreenViewModelDefImpl(dataProvider: dataProvider)
        let vc = MainScreenViewController.instantiate()
        vc.coordinator = self
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: false)
    }
}
