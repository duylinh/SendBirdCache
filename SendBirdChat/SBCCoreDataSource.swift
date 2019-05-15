//
//  CoreDataSource.swift
//  SendBirdChat
//
//  Created by Muhammad Zahid Imran on 11/22/18.
//  Copyright © 2018 Jirah. All rights reserved.
//

import Foundation
import CoreData
import SendBirdSDK

class SBCCoreDataSource {
    
    static let shared = SBCCoreDataSource()
    
    
    private init() {
        let _ = persistentContainer
    }
    
    fileprivate var viewContext: NSManagedObjectContext {
        get{
            
            persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return persistentContainer.viewContext
        }
    }
    
    fileprivate lazy var newBackgroundContext: NSManagedObjectContext = {
        let privateCtx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateCtx.parent = viewContext
        privateCtx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return privateCtx
    }()
    
    
    // MARK: - Core Data stack
    
    fileprivate lazy var persistentContainer: NSPersistentContainer = loadCreateStore()
    
    func clearCoreData() -> Void {
        guard let storeURL = persistentContainer.persistentStoreCoordinator.persistentStores.first?.url else {
            
            return
        }
        
        viewContext.reset()
        newBackgroundContext.reset()
        
        do {
            try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
        } catch {
            print(error)
        }
        
        persistentContainer = loadCreateStore()
        
        let privateCtx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateCtx.parent = viewContext
        privateCtx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.newBackgroundContext = privateCtx
    }
    
    
    
    let loadCreateStore:(() -> NSPersistentContainer) = {
        
        let podBundle = Bundle(for: SBCCoreDataSource.self)
        
        guard let bundleURL = podBundle.url(forResource: "SendBirdChat", withExtension: "bundle") else {
            fatalError("Error loading bundle")
        }
        
        guard let modelURL = Bundle(url: bundleURL)?.url(forResource: "SendBirdChat", withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }

        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "SendBirdChat", managedObjectModel: mom)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }
    
    // MARK: - Core Data Saving support
    
    fileprivate func saveContext (completion:(Bool, Error?)->Void) {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                completion(false, error)
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            completion(true, nil)
        }
    }
    
    func saveBacgroundContext (completion:(Bool, Error?)->Void) {
        let context = newBackgroundContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                completion(false, error)
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            completion(true, nil)
        }
    }
    
    
    func createNewRecord<T: NSManagedObject>() -> T {
        let entityName = NSStringFromClass(T.self)
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: newBackgroundContext)
        let object:T = NSManagedObject(entity: entity!, insertInto: newBackgroundContext) as! T
        return object
    }
    
    func deleteRecord(object: NSManagedObject) -> Void {
        newBackgroundContext.delete(object)
    }
    
    
    func perform(block:@escaping () -> Void, completion:@escaping ( Bool, Error?) -> Void ){
        newBackgroundContext.perform {
            block()
            do {
                if self.newBackgroundContext.hasChanges {
                    try self.newBackgroundContext.save()
                }
            } catch {
                completion(false, error)
                let saveError = error as NSError
                print("Unable to Save Changes of Private Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
                fatalError("Unresolved error \(saveError), \(saveError.userInfo)")
//                abort()
            }
            
            self.viewContext.performAndWait {
                do {
                    if self.viewContext.hasChanges {
                        try self.viewContext.save()
                    }
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    completion(false, error)
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//                    abort()
                }
                completion(true, nil)
            }
        }
    }
    
}


extension SBCCoreDataSource
{
    
    class func newChannelCollection<T:NSFetchRequest<NSFetchRequestResult>>(query: T , sectionName:String? = nil) -> SBCChannelCollection
    {
        let channelCollection = SBCChannelCollection(fetchRequest: query, managedObjectContext: shared.viewContext, sectionNameKeyPath: sectionName, cacheName: nil)
        
        return channelCollection
    }
    
    class func newMessageCollection<T:NSFetchRequest<NSFetchRequestResult>>(query: T , sectionName:String? = nil) -> SBCMessageCollection
    {
        let messageCollection = SBCMessageCollection(fetchRequest: query, managedObjectContext: shared.viewContext, sectionNameKeyPath: sectionName, cacheName: nil)
        
        return messageCollection
    }
    
    class func performFetch<T:NSManagedObject>(fetchRequest request:NSFetchRequest<NSFetchRequestResult>) -> [T] {
        do {
            let result:[T] = try shared.newBackgroundContext.fetch(request) as! [T]
            return result
        }
        catch {
            return []
        }
        
    }
    
}


extension SBDGroupChannel
{
    
    func createCoreDataModel () -> Channel {
        let channel:Channel = SBCCoreDataSource.shared.createNewRecord()
        channel.created_at = Int64(self.createdAt)
        channel.last_message_ts = self.lastMessage?.createdAt ?? 0
        channel.channel_url = self.channelUrl
        channel.serialized_data = self.serialize()
        return channel
    }
    
}

extension SBDBaseMessage
{
    
    func createCoreDataModel (additionalKeyMapping:[String:Any] = [:]) -> Message {
        
        
        let message:Message!
        if let userMessage = self as? SBDUserMessage, let id = userMessage.requestId, id.count > 0, let msg = Message.getMessageWith(request_id: id)
        {
            message = msg
        }
        else
        {
            message = SBCCoreDataSource.shared.createNewRecord()
        }
        
        message.message_id = messageId
        message.message_ts = createdAt
        message.channel_url = channelUrl
        if let userMessage = self as? SBDUserMessage
        {
            message.request_id = userMessage.requestId
        }
        
        for (key,value) in additionalKeyMapping {
            message.setValue(value, forKey: key)
        }
        message.payload = self.serialize()
        return message
    }
    
    func deleteCoreDataModel() -> Void {
        if let userMessage = self as? SBDUserMessage,
            let msg = Message.getMessageWith(request_id: userMessage.requestId, andMessageID: userMessage.messageId)
        {
            SBCCoreDataSource.shared.deleteRecord(object: msg)
        }
        
    }
    
}

extension Channel {
    
    class func getChannelWith(channel_url: String) -> Channel? {
        let query = SBCChannelQuery.channel(channel_url: channel_url)
        let result:[Channel] = SBCCoreDataSource.performFetch(fetchRequest: query)
        if result.count > 0
        {
            return result.first!
        }
        else
        {
            return nil
        }
        
    }
    
}


extension Message {
    
    class func getMessageWith(request_id: String) -> Message? {
        let query = SBCMessageQuery.messageQuery(requestId: request_id)
        let result:[Message] = SBCCoreDataSource.performFetch(fetchRequest: query)
        if result.count > 0
        {
            return result.first!
        }
        else
        {
            return nil
        }
        
    }
    
    
    class func getMessageWith(request_id: String? = nil, andMessageID id:Int64) -> Message? {
        let query = SBCMessageQuery.messageQuery(message_id: id, requestId: request_id)
        let result:[Message] = SBCCoreDataSource.performFetch(fetchRequest: query)
        if result.count > 0
        {
            return result.first!
        }
        else
        {
            return nil
        }
        
    }
    
    class func getLastMessageWith(channelURL: String) -> Message? {
        let query = SBCMessageQuery.messageQuery(channelURL: channelURL, limit: 1, ascending:false)
        let result:[Message] = SBCCoreDataSource.performFetch(fetchRequest: query)
        if result.count > 0
        {
            return result.first!
        }
        else
        {
            return nil
        }
        
    }
    
}
