//
//  Screen1ViewModel+CoreML.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 27.08.2025.
//

import CoreML
import Vision
import SwiftUI
import Combine

final class MLViewModel: ObservableObject {
    enum ClassifierEnum: String {
        case apple = "яблоко"
        case banana = "банан"
        case grape = "виноград"
        case kiwi = "киви"
        case lemon = "лемон"
        case orange = "апельсин"
        case unknown = "что-то непонятное"

        init(rawValue: String) {
            switch rawValue {
            case "Apple":
                self = .apple

            case "Banana":
                self = .banana

            case "Grape":
                self = .grape

            case "Kiwi":
                self = .kiwi

            case "Lemon":
                self = .lemon

            case "Orange":
                self = .orange

            default:
                self = .unknown
            }
        }
    }

    // input
    @Published var isRecognizering = false
    @Published var selectedImage: UIImage?

    // output
    @Published var fruitName = "Выберите картинку"

    private var cancellables: Set<AnyCancellable> = []
    init() {
        bind()
    }

    func createImageArray() async -> [UIImage] {
        let appImages = ["orange", "apple", "banana", "grape", "kiwi", "lemon"]

        return appImages.compactMap { imageName -> UIImage? in
            guard
                let url = Bundle.main.url(forResource: imageName, withExtension: "jpg"),
                let image = try? UIImage(data: Data(contentsOf: url))
            else {
                return nil
            }

            return image
        }
    }

    private func bind() {
        $isRecognizering
            .map { Bool($0) }
            .sink { [weak self] result in
                guard let self else { return }

                self.fruitName = result ? "Идет распознавание..." : "Выберите картинку"
            }
            .store(in: &cancellables)

        $selectedImage
            .compactMap { $0 }
            .sink { [weak self] image in
                guard let self else { return }

                self.excecuteRequest(image: image)

            }
            .store(in: &cancellables)
    }
}

// MARK: - ML Logic

private extension MLViewModel {
    /// Произвести запрос к нейросети
    ///
    /// - Метод подготавливает выбранное изображение для распознавания. Делает request с изображением и запускает его принимая функцию mlrequest в качестве логики запроса
    func excecuteRequest(image: UIImage) {
        /// Мы должны преобразовать UIImage в CIImage (CI:CoreImage), чтобы его можно было использовать в качестве входных данных для нашей Core ML модели
        guard let ciImage = CIImage(image: image) else {
            return
        }

        do {
            let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage)
            /// Запрос может быть выполнен с помощью вызова метода perform() и передачи в качестве параметра VNCoreMLRequest
            try imageRequestHandler.perform([self.mlrequest()])
        } catch {
            print("Ошибка выполнения запроса: \(error.localizedDescription)")
            self.fruitName = "Я вижу \(ClassifierEnum.unknown.rawValue)"
        }
    }

    /// Создание запроса в Vision
    ///
    /// - Чтобы заставить Core ML произвести классификацию, мы должны сначала сформировать запрос типа VNCoreMLRequest (VN обозначает Vision)
    /// Внутри происходит:
    /// 1.  Создаём экземпляр нашего класса Core ML модели
    /// 2.  Создаём экземпляр VNCoreMLModel
    /// 3. Создает экземпляр VNCoreMLRequest
    /// 4. В completion VNCoreMLRequest передается метод, который будет вызван после отработки запроса
    func mlrequest() -> VNCoreMLRequest {
        do {
            let modelobj: MLModel = try MyImageClassifier_1(configuration: MLModelConfiguration()).model
            let fruitmodel: VNCoreMLModel = try VNCoreMLModel(for: modelobj)
            let myrequest = VNCoreMLRequest(model: fruitmodel) { (request, error) in
                self.handleResult(request: request, error: error)
            }
            myrequest.imageCropAndScaleOption = .centerCrop

            #if targetEnvironment(simulator)
            // MARK: - Для работы на симуляторе
            myrequest.usesCPUOnly = true
            #endif

            return myrequest
        } catch {
            fatalError("⚠️ Не удалось создать VNCoreMLRequest: \(error.localizedDescription)")
        }
    }

    /// Обработка результата VNCoreMLRequest
    ///
    /// - Эта функция будет вызываться после завершения VNCoreMLRequest
    func handleResult(request: VNRequest, error: Error? ) {
        guard error == nil else {
            print("Ошибка обработки: \(String(describing: error?.localizedDescription))")
            return
        }

        guard let results = request.results else {
            print("Нет результатов")
            return
        }

        guard let classificationresult = results as? [VNClassificationObservation] else {
            print("Unable to get the results")
            return
        }

        DispatchQueue.main.async {
            if let observation = results.first as? VNClassificationObservation {
                let classifier = ClassifierEnum(rawValue: observation.identifier)
                self.fruitName = "Я вижу \(classifier.rawValue)"
                print("Результат: \(observation.identifier)")
            } else {
                print("Не удалось получить классификацию")
            }
        }
    }
}
