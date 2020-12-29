//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import Cripper

final class ViewController: UIViewController {

    // MARK: - Subviews

    private lazy var teakePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Take a photo", for: .normal)
        button.addTarget(self, action: #selector(takePhotoButtonPressed), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(teakePhotoButton)
        navigationItem.title = "Crop a photo"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        teakePhotoButton.frame = .init(origin: .zero, size: .init(width: 200, height: 56))
        teakePhotoButton.center = .init(x: view.center.x, y: 100 + view.safeAreaInsets.top)
    }

    // MARK: - Actions

    @objc private func takePhotoButtonPressed() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        present(vc, animated: true)
    }

    @objc private func panGestureRecognized() {
    }

    @objc private func pinchGestureRecognized() {
    }
}

// MARK: - UINavigationControllerDelegate

extension ViewController: UINavigationControllerDelegate {

}

// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
           return AppRouter(viewController: self).showAlert(title: "No image found",
                                                            message: nil,
                                                            preferredStyle: .alert,
                                                            actions: [.init(title: "OK",
                                                                            style: .cancel,
                                                                            handler: nil)])

        }
        let viewController = CropperViewController(image: image)
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: false, completion: nil)
    }
}
