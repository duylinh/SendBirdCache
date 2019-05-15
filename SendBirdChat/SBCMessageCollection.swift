//
//  SBCMessageCollection.swift
//  SendBirdChat
//
//  Created by Muhammad Zahid Imran on 11/24/18.
//  Copyright © 2018 Jirah. All rights reserved.
//

import Foundation
import CoreData
import SendBirdSDK

public typealias SBCMessageCollectionSectionInfo = NSFetchedResultsSectionInfo

public typealias SBCMessageCollectionModificationType = NSFetchedResultsChangeType

public protocol SBCMessageCollectionDelegate : NSObjectProtocol {
    
    
    func collection(_ collection: SBCMessageCollection, didChange anObject: SBDBaseMessage, at indexPath: IndexPath?, for type: SBCMessageCollectionModificationType, newIndexPath: IndexPath?)
    
    
    
    func collection(_ collection: SBCMessageCollection, didChange sectionInfo: SBCMessageCollectionSectionInfo, atSectionIndex sectionIndex: Int, for type: SBCMessageCollectionModificationType)
    
    func collectionWillChangeContent(_ collection: SBCMessageCollection)
    
    
    func collectionDidChangeContent(_ collection: SBCMessageCollection)
    
    
    
}

public class SBCMessageCollection: NSFetchedResultsController<NSFetchRequestResult> {
    
    public weak var collectionDelegate: SBCMessageCollectionDelegate?
    
    
    public class func newCollection(query qry: SBCMessageQuery) -> SBCMessageCollection {
        let collection = SBCCoreDataSource.newMessageCollection(query: qry)
        collection.delegate = collection
        return collection
    }
    
    
    
    public func message(at indexPath: IndexPath) -> SBDBaseMessage {
        let message = self.object(at: indexPath)
        return SBDBaseMessage.build(fromSerializedData: (message as! Message).payload!)!
    }
    
    public func status(at indexPath: IndexPath) -> OutgoingMessageStatus? {
        if let messageStatus = (self.object(at: indexPath) as? Message)?.status, let status:OutgoingMessageStatus = OutgoingMessageStatus(rawValue: messageStatus)
        {
            return status
        }
        return nil
    }
}

extension SBCMessageCollection: NSFetchedResultsControllerDelegate
{
    
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        
        self.collectionDelegate?.collection(self, didChange: SBDBaseMessage.build(fromSerializedData: (anObject as! Message).payload!)!, at: indexPath, for: type, newIndexPath: newIndexPath)
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
