//
//  ClassifierViewModel.swift
//  CarLicensePlateApp
//
//  Created by Илья Малахов on 02.05.2023.
//

import Vision
import CoreImage
import UIKit

final class ClassifierViewModel: ObservableObject {
    private var image: UIImage!
    @Published var rect: CGRect?
    
    init() {}
    
    func classifyImage(_ image: UIImage) {
        self.image = image
        guard let model = makeImageClassifierModel(), let ciImage = CIImage(image: image) else {
            return
        }
        makeClassifierRequest(for: model, ciImage: ciImage)
    }
    
    private func makeImageClassifierModel() -> VNCoreMLModel? {
        return try? VNCoreMLModel(for: CarLicensePlatesExperiment_1().model)
    }
    
    private func makeClassifierRequest(for model: VNCoreMLModel, ciImage: CIImage) {
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            self?.handleClassifierResults(request.results)
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print("Shit")
            }
        }
    }
    
    private func handleClassifierResults(_ results: [Any]?) {
        guard
            let results = results as? [VNObservation],
            let firstResult = results.first as? VNRecognizedObjectObservation
        else {
            return
        }
        
        let bbBox = firstResult.boundingBox
        let bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        let rect = bbBox.applying(bottomToTopTransform)
        
        DispatchQueue.main.async {
            self.rect = VNImageRectForNormalizedRect(rect, Int(self.image.size.width), Int(self.image.size.height))
        }
    }
}
