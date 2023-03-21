//
//  CoreDataManager.swift
//  UserLocationApp
//
//  Created by Bhagwan Rajput on 21/03/23.
//

import Foundation
import CoreData

class CoreDataManager {
    
    let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "RideDataModel")
        persistentContainer.loadPersistentStores{(description, error) in
            if let error = error {
                fatalError("Core Data store failed \(error.localizedDescription)")
            }
        }
    }
    
    func saveRide(date:Date, distance:Double, duration:Double) {
        let ride = Ride(context: persistentContainer.viewContext)
        ride.date = date
        ride.duration = duration
        ride.distance = distance
        do {
            try persistentContainer.viewContext.save()
        }catch {
            print("Failed to save ride \(error)")
        }
        
    }
    
    func getAllRide() -> [Ride] {
        let fetchRequest: NSFetchRequest<Ride> = Ride.fetchRequest()
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
}
