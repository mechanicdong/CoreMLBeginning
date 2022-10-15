//
//  ViewController.swift
//  CoreMLBeginning
//
//  Created by 이동희 on 2022/10/15.
//

import CoreML
import UIKit

class ViewController: UIViewController {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "이미지 선택"
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(label)
        view.addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(tap)
    }
    
    @objc func didTapImage() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate   = self
        present(picker, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 20,
                                 y: view.safeAreaInsets.top,
                                 width: view.frame.size.width-40,
                                 height: view.frame.size.width-40)
        label.frame = CGRect(x: 20,
                             y: view.safeAreaInsets.top+(view.frame.size.width-40)+10,
                             width: view.frame.size.width-40,
                             height: 100)
        
    }
    
    private func analyzeImage(image: UIImage?) {
        //이미지 리사이즈
        guard let buffer = image?.resize(size: CGSize(width: 224, height: 224))?.getCVPixelBuffer() else { return }
        
        do {
            let config  = MLModelConfiguration()
            let mlModel = try GoogLeNetPlaces(configuration: config)
            let input   = GoogLeNetPlacesInput(sceneImage: buffer)
            
            let output = try mlModel.prediction(input: input)
            let text   = output.sceneLabel
            label.text = text
        }
        catch {
            print(error.localizedDescription)
        }
    }


}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //취소
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageView.image = image
        analyzeImage(image: image)
    }
}

