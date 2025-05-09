//
//  AppCoordinator.swift
//  BilyonerCaseStudy
//
//  Created by baran kutlu on 7.05.2025.
//


import UIKit
import FirebaseAuth

final class AppCoordinator {
    private var window: UIWindow?
    let betBulletinViewModel = BetBulletinViewModel()
    
    init(window: UIWindow? = nil) {
        self.window = window
    }
    
    func start() -> UIViewController {
        let rootVC = BetBulletinViewController(viewModel: betBulletinViewModel)
        let nav = UINavigationController(rootViewController: rootVC)
        return nav
    }
    
    func showBasket(from nav: UINavigationController) {
        let basketVM = BetBasketViewModel(selectedMatches: betBulletinViewModel.selectedMatches)
        let basketVC = BetBasketViewController(viewModel: basketVM)
        nav.pushViewController(basketVC, animated: true)
    }
    
    func authenticateIfNeeded() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    print("Auth error: \(error.localizedDescription)")
                } else {
                    print("Anonymous login successful: \(result?.user.uid ?? "")")
                }
            }
        }
    }
}
