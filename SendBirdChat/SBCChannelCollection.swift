//
//  SBCChannelResultsController.swift
//  SendBirdChat
//
//  Created by Muhammad Zahid Imran on 11/23/18.
//  Copyright © 2018 Jirah. All rights reserved.
//

import Foundation
import CoreData
import SendBirdSDK

public typealias SBCChannelCollectionSectionInfo = NSFetchedResultsSectionInfo

public typealias SBCChannelCollectionModificationType = NSFetchedResultsChangeType

public protocol SBCChannelCollectionDelegate : NSObjectProtocol {

    
    func collection(_ collection: SBCChannelCollection, didChange anObject: SBDGroupChannel, at indexPath: IndexPath?, for type: SBCChannelCollectionModificationType, newIndexPath: IndexPath?)
    


    func collection(_ collection: SBCChannelCollection, didChange sectionInfo: SBCChannelCollectionSectionInfo, atSectionIndex sectionIndex: Int, for type: SBCChannelCollectionModificationType)
    
    func collectionWillChangeContent(_ collection: SBCChannelCollection)
    

    func collectionDidChangeContent(_ collection: SBCChannelCollection)
    
    
    
}

public class SBCChannelCollection: NSFetchedResultsController<NSFetchRequestResult> {
    
    public weak var collectionDelegate: SBCChannelCollectionDelegate?
    
    
    public class func newCollection(query qry: SBCChannelQuery) -> SBCChannelCollection {
        let collection = SBCCoreDataSource.newChannelCollection(query: qry)
        collection.delegate = collection
        return collection
    }
    

    
    public func channel(at indexPath: IndexPath) -> SBDGroupChannel {
        let channel = self.object(at: indexPath)
        return SBDGroupChannel.build(fromSerializedData: (channel as! Channel).serialized_data!)!
    }
}

extension SBCChannelCollection: NSFetchedResultsControllerDelegate
{
    
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        
        self.collectionDelegate?.collection(self, didChange: SBDGroupChannel.build(fromSerializedData: (anObject as! Channel).serialized_data!)!, at: indexPath, for: type, newIndexPath: newIndexPath)
    }
    
   
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
    {
        self.collectionDelegate?.collection(self, didChange: sectionInfo, atSectionIndex: sectionIndex, for: type)
    }
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        self.collectionDelegate?.collectionWillChangeContent(self)
    }
    
   
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        self.collectionDelegate?.collectionDidChangeContent(self)
    }
    
   
//    private func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String?
//    {
//        return self.collectionDelegate?.collection(self, sectionIndexTitleForSectionName: sectionName)
//    }
}
