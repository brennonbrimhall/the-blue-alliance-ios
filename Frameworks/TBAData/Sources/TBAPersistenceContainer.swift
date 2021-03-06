import Foundation
import CoreData

public class TBAPersistenceContainer: NSPersistentContainer {

    private static let managedObjectModel: NSManagedObjectModel? = {
        let modelBundle = Bundle(for: TBAPersistenceContainer.self)
        return NSManagedObjectModel.mergedModel(from: [modelBundle])
    } ()

    override public init(name: String, managedObjectModel model: NSManagedObjectModel) {
        super.init(name: name, managedObjectModel: model)
    }

    public init() {
        guard let managedObjectModel = TBAPersistenceContainer.managedObjectModel else {
            fatalError("Could not load model")
        }
        super.init(name: "TBA", managedObjectModel: managedObjectModel)
    }

    override public func newBackgroundContext() -> NSManagedObjectContext {
        let context = super.newBackgroundContext()
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        return context
    }

}
