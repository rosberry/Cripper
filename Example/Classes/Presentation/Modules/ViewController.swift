//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import Cripper
import Framezilla
import Base
import Routes
import CollectionViewTools

class ViewController: UIViewController {

    var factory: ViewFactory = .init()

    // MARK: - Subviews

    private(set) lazy var collectionViewManager: CollectionViewManager = .init(collectionView: collectionView)
    var initialStates: [Any] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.insetsLayoutMarginsFromSafeArea = true
        return collectionView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.backgroundColor = .white
        view.add(collectionView)
        updateInitialState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    func updateInitialState() {
        collectionViewManager.update(with: factory.makeSectionItems(viewStates: initialStates), animated: false)
    }
}

// MARK: - UINavigationControllerDelegate

extension ViewController: UINavigationControllerDelegate {

}
