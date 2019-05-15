//
//  SBCMessageQuery.swift
//  SendBirdChat
//
//  Created by Muhammad Zahid Imran on 11/24/18.
//  Copyright © 2018 AppsGenii Technologies PVT LTD. All rights reserved.
//

import Foundation
import CoreData

public class SBCMessageQuery: NSFetchRequest<NSFetchRequestResult> {
    
    public class func messageQuery(channelURL channel: String, limit:Int? = nil, ascending:Bool = false) -> SBCMessageQuery
    {
        let fetchedRequest = SBCMessageQuery(entityName: NSStringFromClass(Message.self))
        fetchedRequest.predicate = NSPredicate(format: "channel_url == %@", channel)
        fetchedRequest.sortDescriptors = [NSSortDescriptor(key: "message_ts", ascending: ascending),NSSortDescriptor(key: "message_id", ascending: ascending)]
        if let limitRecord = limit
        {
            fetchedRequest.fetchLimit = limitRecord
        }
        return fetchedRequest
    }
    
    public class func messageQuery(requestId request: String) -> SBCMessageQuery
    {
        let fetchedRequest = SBCMessageQuery(entityName: NSStringFromClass(Message.self))
        fetchedRequest.predicate = NSPredicate(format: "request_id == %@", request)
        return fetchedRequest
    }
    
    public class func messageQuery( message_id: Int64, requestId request: String? = nil) -> SBCMessageQuery
    {
        let fetchedRequest = SBCMessageQuery(entityName: NSStringFromClass(Message.self))
        if let req = request
        {
            fetchedRequest.predicate = NSPredicate(format: "request_id == %@ AND message_id == %d", req, message_id)
        }
        else
        {
            fetchedRequest.predicate = NSPredicate(format: "message_id == %d", message_id)
        }
        return fetchedRequest
    }
    
}
