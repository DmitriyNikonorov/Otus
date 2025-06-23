//
//  Screen4ViewModel.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import Foundation
import Combine

final class Screen4ViewModel: ViewModel, ObservableObject {

    enum Link {
        case details(DetailsViewModel)
    }

    enum Action {
        case openDetails(String)
    }

    private var cancellables = Set<AnyCancellable>()

    @Published var link: Link? {
        didSet {
            isLinkActive = link != nil
        }
    }
    @Published var isLinkActive = false
    @Published var isLoading = false
    var action = PassthroughSubject<Action, Never>()

    override init() {
        super.init()
        bind()
    }

    func startTimer() {
        Just(())
            .delay(for: .seconds(3), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
}

private extension Screen4ViewModel {
    func bind() {
        action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                guard let self else { return }

                switch action {
                case .openDetails(let text):
                    self.link = .details(DefaultAssembler.shared.resolve(text: text))
                }
            }
            .store(in: &cancellables)
    }
}

extension Screen4ViewModel {
    func formattedSpeed(_ speedKmH: Double) -> String {
        let value = NSMeasurement(doubleValue: speedKmH, unit: UnitSpeed.kilometersPerHour)
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 2
        return formatter.string(from: value as Measurement<Unit>)
    }

    func formattedDistance(_ meters: Int) -> String {
        let value = NSMeasurement(doubleValue: Double(meters), unit: UnitLength.meters)
        let formatter = MeasurementFormatter()

        formatter.unitStyle = .long
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.unitOptions = [.providedUnit] // Сохранть установленные единицы измерения
        // .naturalScale - переводить еденицы(1000 м будет 1 км)
        return formatter.string(from: value as Measurement<Unit>)
    }

    func formattedDistanceInParrots(_ meters: Int) -> String {
        let parrotsCount = Int(round(Double(meters) / 0.3))
        return String(format: NSLocalizedString("%@ parrots", comment: ""), parrotsCount)
    }

    func formattedTime(_ seconds: Int) -> String {
        let value = NSMeasurement(doubleValue: Double(seconds), unit: UnitDuration.seconds)
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .long
        formatter.unitOptions = [.naturalScale]
        return formatter.string(from: value as Measurement<Unit>)
    }
}
