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

    private lazy var imageView: UIImageView = .init()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(teakePhotoButton)
        view.addSubview(imageView)
        navigationItem.title = "Crop a photo"
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .gray
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        teakePhotoButton.bounds = .init(origin: .zero, size: .init(width: 200, height: 56))
        teakePhotoButton.center = .init(x: view.center.x, y: 100 + view.safeAreaInsets.top)
        imageView.frame = .init(x: 16, y: teakePhotoButton.frame.maxY + 50,
                                width: view.bounds.width - 32, height: view.bounds.height - 300)
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
        let viewController = CropperViewController(image: image) { croppedImage in
            self.imageView.image = croppedImage
        }
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: false, completion: nil)
    }
}
