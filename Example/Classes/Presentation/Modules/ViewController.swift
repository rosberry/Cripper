//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import Cripper

final class ViewController: UIViewController {

    // MARK: - Subviews

    private lazy var takePhotoButton: UIButton = {
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
        view.addSubview(takePhotoButton)
        view.addSubview(imageView)
        navigationItem.title = "Crop a photo"
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .gray
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        takePhotoButton.bounds = .init(origin: .zero, size: .init(width: 200, height: 56))
        takePhotoButton.center = .init(x: view.center.x, y: 100 + view.safeAreaInsets.top)
        imageView.frame = .init(x: 16, y: takePhotoButton.frame.maxY + 50,
                        width: view.bounds.width - 32, height: view.bounds.height - 300)
    }

    // MARK: - Actions

    @objc private func takePhotoButtonPressed() {
        let viewController = UIImagePickerController()
        viewController.sourceType = .camera
        viewController.delegate = self
        present(viewController, animated: true)
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
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
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

        let viewController = CropperViewController()
        viewController.image = image
        viewController.mode = .path
        viewController.cropOptions = [
            .square(title: "☐"),
            .rect(title: "☐ 3:4", width: 3, height: 4),
            .circle(title: "○"),
            .ellipse(title: "○ 16:9", width: 16, height: 9)
        ]
        viewController.completionHandler = { [weak self] image in
            self?.imageView.image = image
        }
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: false, completion: nil)
    }
}
