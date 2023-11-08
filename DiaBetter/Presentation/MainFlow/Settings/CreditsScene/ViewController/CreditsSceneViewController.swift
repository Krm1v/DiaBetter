//
//  CreditsSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.06.2023.
//

import UIKit
import Combine

final class CreditsSceneViewController: BaseViewController<CreditsSceneViewModel> {
    // MARK: - Properties
    private let contentView = CreditsSceneView()
    
    // MARK: - UIView lifecycle methods
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDiffableDatasourceSnapshot()
    }
    
    // MARK: - Overriden methods
    override func setupNavBar() {
        super.setupNavBar()
        title = Localization.credits
    }
}

// MARK: - Private extension
private extension CreditsSceneViewController {
    func updateDiffableDatasourceSnapshot() {
        viewModel.$sections
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] sections in
                self.contentView.setupSnapshot(sections: sections)
            }
            .store(in: &cancellables)
    }
    
    func setupBindings() {
        contentView.actionPublisher
            .sink { action in
                switch action {
                case .cellDidTapped(let model):
                    switch model.item {
                    case .website:
                        guard let url = URL(string: CreditsListCellItems.website.link) else {
                            return
                        }
                        UIApplication.shared.open(url)
                        
                    case .instagram:
                        guard let url = URL(string: CreditsListCellItems.instagram.link) else {
                            return
                        }
                        UIApplication.shared.open(url)
                        
                    case .twitter:
                        guard let url = URL(string: CreditsListCellItems.twitter.link) else {
                            return
                        }
                        
                        UIApplication.shared.open(url)
                        
                    case .fb:
                        guard let url = URL(string: CreditsListCellItems.fb.link) else {
                            return
                        }
                        UIApplication.shared.open(url)
                        
                    case .linkedIn:
                        guard let url = URL(string: CreditsListCellItems.linkedIn.link) else {
                            return
                        }
                        UIApplication.shared.open(url)
                        
                    case .termsAndConditions:
#warning("TODO: Add terms and conditions URL")
                        
                    case .privacyPolicy:
                        guard let url = URL(string: CreditsListCellItems.privacyPolicy.link) else {
                            return
                        }
                        UIApplication.shared.open(url)
                    }
                }
            }
            .store(in: &cancellables)
    }
}
