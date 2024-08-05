//
//  HealthDataService.swift
//  shack2024
//
//  Created by mgarciate on 5/8/24.
//

import HealthKit

class HealthDataService {
    private let healthStore = HKHealthStore()
    
    // Solicita permisos de HealthKit
    func requestHealthKitPermissions(completion: @escaping (Bool, Error?) -> Void) {
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .vo2Max)!,
            HKObjectType.categoryType(forIdentifier: .menstrualFlow)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            completion(success, error)
        }
    }
    
    // Obtiene y formatea datos de HealthKit
    func fetchHealthData(completion: @escaping ([String: Any]?, Error?) -> Void) {
        let dataTypes: [HKSampleType] = [
            HKSampleType.quantityType(forIdentifier: .heartRate)!,
            HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKSampleType.quantityType(forIdentifier: .stepCount)!,
            HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKSampleType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKSampleType.quantityType(forIdentifier: .vo2Max)!,
            HKSampleType.categoryType(forIdentifier: .menstrualFlow)!
        ]
        
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        var healthData = [String: Any]()
        let dispatchGroup = DispatchGroup()
        
        for dataType in dataTypes {
            dispatchGroup.enter()
            let query = HKSampleQuery(sampleType: dataType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                defer { dispatchGroup.leave() }
                
                if let error = error {
                    print("Error fetching \(dataType.identifier): \(error.localizedDescription)")
                    return
                }
                
                if let samples = samples {
                    var data = [[String: Any]]()
                    for sample in samples {
                        var sampleData = [String: Any]()
                        if let quantitySample = sample as? HKQuantitySample {
                            sampleData["value"] = self.formatQuantitySample(quantitySample)
                        } else if let categorySample = sample as? HKCategorySample {
                            sampleData["value"] = self.formatCategorySample(categorySample)
                        }
                        sampleData["startDate"] = sample.startDate
                        sampleData["endDate"] = sample.endDate
                        data.append(sampleData)
                    }
                    healthData[dataType.identifier] = data
                }
            }
            healthStore.execute(query)
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(healthData, nil)
        }
    }
    
    private func formatQuantitySample(_ sample: HKQuantitySample) -> String {
        let quantityType = sample.quantityType
        let quantity = sample.quantity
        var unit: HKUnit
        var formattedValue = ""
        
        switch quantityType {
        case HKObjectType.quantityType(forIdentifier: .heartRate):
            unit = HKUnit.count().unitDivided(by: HKUnit.minute())
            formattedValue = String(format: "%.0f BPM", quantity.doubleValue(for: unit))
        case HKObjectType.quantityType(forIdentifier: .activeEnergyBurned):
            unit = HKUnit.kilocalorie()
            formattedValue = String(format: "%.2f kcal", quantity.doubleValue(for: unit))
        case HKObjectType.quantityType(forIdentifier: .stepCount):
            unit = HKUnit.count()
            formattedValue = String(format: "%.0f steps", quantity.doubleValue(for: unit))
        case HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning):
            unit = HKUnit.meterUnit(with: .kilo)
            formattedValue = String(format: "%.2f km", quantity.doubleValue(for: unit))
        case HKObjectType.quantityType(forIdentifier: .oxygenSaturation):
            unit = HKUnit.percent()
            formattedValue = String(format: "%.2f%%", quantity.doubleValue(for: unit) * 100)
        case HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN):
            unit = HKUnit.secondUnit(with: .milli)
            formattedValue = String(format: "%.2f ms", quantity.doubleValue(for: unit))
        case HKObjectType.quantityType(forIdentifier: .vo2Max):
            unit = HKUnit(from: "ml/kg*min")
            formattedValue = String(format: "%.2f ml/kg*min", quantity.doubleValue(for: unit))
        default:
            formattedValue = "\(quantity)"
        }
        
        return formattedValue
    }
    
    private func formatCategorySample(_ sample: HKCategorySample) -> String {
        let categoryType = sample.categoryType
        var formattedValue = ""
        
        switch categoryType {
        case HKObjectType.categoryType(forIdentifier: .sleepAnalysis):
            let value = HKCategoryValueSleepAnalysis(rawValue: sample.value)
            formattedValue = value == .inBed ? "In Bed" : "Asleep"
        case HKObjectType.categoryType(forIdentifier: .menstrualFlow):
            let value = HKCategoryValueMenstrualFlow(rawValue: sample.value)
            switch value {
            case .unspecified:
                formattedValue = "Unspecified"
            case .light:
                formattedValue = "Light"
            case .medium:
                formattedValue = "Medium"
            case .heavy:
                formattedValue = "Heavy"
            case .none:
                formattedValue = "None"
            @unknown default:
                formattedValue = "Unknown"
            }
        default:
            formattedValue = "\(sample.value)"
        }
        
        return formattedValue
    }
}
