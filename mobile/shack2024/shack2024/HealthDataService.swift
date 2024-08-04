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
    
    // Obtiene datos de HealthKit
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
                    var data = [Any]()
                    for sample in samples {
                        if let quantitySample = sample as? HKQuantitySample {
                            data.append(quantitySample.quantity)
                        } else if let categorySample = sample as? HKCategorySample {
                            data.append(categorySample.value)
                        }
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
}
