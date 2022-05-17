//
//  ViewController.swift
//  Leaf Disease Classifier
//
//  Created by Manish Patel on 17/05/2022.
//

import UIKit
import CoreML
class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var label: UILabel!
    
    @IBAction func didTapChoosePhoto(_ sender: Any) {
        
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @IBAction func didTapPredict(_ sender: Any) {
        
//        guard let predictImage = imageView?.image else {
//            label.text = "Please choose an image from library!"
//            return
//        }
        let predictImage = imageView?.image
        analyseImage(image: predictImage)
        
    }
    
    private func analyseImage(image: UIImage?) {
        guard let buffer = image?.resize(size: CGSize(width: 256, height: 256))?
        .getCVPixelBuffer() else {
                return
            }
        do{
//            print(buffer)
            let config = MLModelConfiguration()
            let model = try plant_disease_model(configuration: config)
            let input = plant_disease_modelInput(conv2d_input: buffer)
            let output = try model.prediction(input: input)
            let text = output.classLabel
            label.text = text
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

