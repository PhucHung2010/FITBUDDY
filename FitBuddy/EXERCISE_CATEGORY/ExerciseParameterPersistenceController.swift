//
//  PersistenceController.swift
//  FitBuddy
//
//  Created by tai nguyen huu on 7/11/25.
//
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
//        for i in 1...10 {
//            let item = SummaryExerciseParameterStorage(context: viewContext)
//            item.categoryName = "Category \(i)" // phân chia 3 loại
////            item.dateAdded = Calendar.current.date(byAdding: .day, value: i, to: Date())
//            item.dateAdded = Date()
//            item.totalCorrect = Int32(Int.random(in: 5...40))
//            item.totalIncorrect = Int32(Int.random(in: 5...30))
//            item.targetCount = Int32(Int.random(in: 0...30))
//            
//            item.totalTime = Int32(Int.random(in: 5...90))
//            item.targetTime = Int32(Int.random(in: 5...120))
//            item.feedbackText = "Great work on item \(i)"
//        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ExerciseParameterStorage")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}



extension TargetExerciseParameterStorage {
    static func loadTargetParameter(for name: String, in context: NSManagedObjectContext) -> TargetExerciseParameterStorage {
        let request: NSFetchRequest<TargetExerciseParameterStorage> = TargetExerciseParameterStorage.fetchRequest()
        request.predicate = NSPredicate(format: "categoryName == %@", name)
        request.fetchLimit = 1

        if let available = try? context.fetch(request).first {
            return available
        } else {
            let newObject = TargetExerciseParameterStorage(context: context)
            newObject.categoryName = name
            newObject.targetCount = -1
            newObject.targetTime = -1
            newObject.camera = true
            newObject.arc = true
            newObject.frameRate = 60
            try? context.save()
            return newObject
        }
    }
}

extension SummaryExerciseParameterStorage {
    static func loadSummaryParameter(for name: String, in context: NSManagedObjectContext) -> [SummaryExerciseParameterStorage] {
        let request: NSFetchRequest<SummaryExerciseParameterStorage> = SummaryExerciseParameterStorage.fetchRequest()
        request.predicate = NSPredicate(format: "categoryName == %@", name)
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]

//        deleteAll(in: context)
        if let available = try? context.fetch(request) {
            return available
        } else {
            print("cannot fetch")
            return []
        }
    }
    
    static func fetchBatch(in context: NSManagedObjectContext,
                               limit: Int,
                               offset: Int) -> [SummaryExerciseParameterStorage] {
        let request: NSFetchRequest<SummaryExerciseParameterStorage> = SummaryExerciseParameterStorage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        request.fetchLimit = limit
        request.fetchOffset = offset
        
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }
    
    
    static func loadSummaryParameterForTimeUnit(for name: String, timeUnit: String, in context: NSManagedObjectContext) -> SummaryExerciseParameterStorage? {
        let request: NSFetchRequest<SummaryExerciseParameterStorage> = SummaryExerciseParameterStorage.fetchRequest()
        request.predicate = NSPredicate(format: "categoryName == %@ AND timeUnit == %@", name, timeUnit)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]

        do {
            return try context.fetch(request).first
        } catch {
            print("cannot fetch: \(error.localizedDescription)")
            return nil
        }
    }

    
    static func deleteAll(in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = SummaryExerciseParameterStorage.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("All SummaryExerciseParameterStorage records deleted.")
        } catch {
//                print("Failed to delete all SummaryExerciseParameterStorage records: \(error.localizedDescription)")
            print("Failed to delete all SummaryExerciseParameterStorage records")
        }
    }
    
    static func encodeFeedbackStrings(_ strings: [String]) -> String {
        return strings.joined(separator: "|||")
    }

    static func decodeFeedbackStrings(_ encodedString: String) -> [String] {
        return encodedString.components(separatedBy: "|||")
    }
}

extension RoutineExerciseStorage {
    static func loadRoutineParameter(for date: Date, in context: NSManagedObjectContext) -> [RoutineExerciseStorage] {
        let request: NSFetchRequest<RoutineExerciseStorage> = RoutineExerciseStorage.fetchRequest()

        // Lấy khoảng từ đầu ngày đến cuối ngày
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            print("Cannot calculate end of day")
            return []
        }
        
        // So sánh plannedDate nằm trong khoảng đó
        request.predicate = NSPredicate(format: "plannedDate >= %@ AND plannedDate < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "plannedDate", ascending: true)]

        do {
            return try context.fetch(request)
        } catch {
            print("Cannot fetch")
//            print("Cannot fetch: \(error)")
            return []
        }
    }
    
 

    
    static func loadRoutineParameter(forMonth month: Date, in context: NSManagedObjectContext) -> [RoutineExerciseStorage] {
        let request: NSFetchRequest<RoutineExerciseStorage> = RoutineExerciseStorage.fetchRequest()

        let calendar = Calendar.current
        // Tính ngày đầu tháng: dựa vào năm và tháng của 'month'
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) ?? month
        // Tính ngày đầu tháng kế tiếp, đây sẽ là "end" của tháng hiện tại
        guard let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            print("Cannot calculate end of month")
            return []
        }
        
        let deleteRequest: NSFetchRequest<RoutineExerciseStorage> = RoutineExerciseStorage.fetchRequest()
        let today = Date.now.startOfDay
//        deleteRequest.predicate = NSPredicate(format: "plannedDate < %@", today as NSDate)
        deleteRequest.predicate = NSPredicate(format: "plannedDate != nil AND plannedDate < %@", today as NSDate)


        do {
            let oldObjects = try context.fetch(deleteRequest)
            for object in oldObjects {
                context.delete(object)
            }
            if context.hasChanges {
                try context.save()
            }
        } catch {
//            print("Error deleting old entries: \(error)")
            print("Error deleting old entries")
        }

        // Predicate lấy các đối tượng có plannedDate nằm trong khoảng [startOfMonth, endOfMonth)
        request.predicate = NSPredicate(format: "plannedDate >= %@ AND plannedDate < %@", startOfMonth as NSDate, endOfMonth as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "plannedDate", ascending: true)]

        do {
            return try context.fetch(request)
        } catch {
//            print("Cannot fetch routines for month: \(error)")
            print("Cannot fetch routines for month")
            return []
        }
    }
    
    static func loadAllRoutineParameters(in context: NSManagedObjectContext) -> [RoutineExerciseStorage] {
        let request: NSFetchRequest<RoutineExerciseStorage> = RoutineExerciseStorage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "plannedDate", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
//            print("Cannot fetch all routines: \(error)")
            print("Cannot fetch all routines")
            return []
        }
    }
    
    static func deleteRoutineParameter(for date: Date, in context: NSManagedObjectContext) {
        let request: NSFetchRequest<NSFetchRequestResult> = RoutineExerciseStorage.fetchRequest()
        
        // Tính khoảng từ đầu ngày đến cuối ngày
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            print("Cannot calculate end of day")
            return
        }
        
        // Lọc theo plannedDate trong khoảng đó
        request.predicate = NSPredicate(format: "plannedDate >= %@ AND plannedDate < %@", startOfDay as NSDate, endOfDay as NSDate)

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs

        do {
            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            if let objectIDs = result?.result as? [NSManagedObjectID] {
                // Merge để UI SwiftUI hoặc FetchRequest nhận biết thay đổi
                let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            }
        } catch {
//            print("Failed to delete records for date: \(error)")
            print("Failed to delete records for date")
        }
    }
}

