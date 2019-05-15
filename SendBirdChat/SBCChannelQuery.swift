//
//  SBCChannelQuery.swift
//  SendBirdChat
//
//  Created by Muhammad Zahid Imran on 11/23/18.
//  Copyright © 2018 AppsGenii Technologies PVT LTD. All rights reserved.
//

import Foundation
import CoreData

public class SBCChannelQuery: NSFetchRequest<NSFetchRequestResult> {
    
    public class func allChannelQuery() -> SBCChannelQuery
    {
        let fetchedRequest = SBCChannelQuery(entityName: NSStringFromClass(Channel.self))
        fetchedRequest.sortDescriptors = [NSSortDescriptor(key: "last_message_ts", ascending: false),NSSortDescriptor(key: "last_message_ts", ascending: false)]
        return fetchedRequest
    }
    
    
    public class func channel(channel_url: String) -> SBCChannelQuery
    {
        let fetchedRequest = SBCChannelQuery(entityName: NSStringFromClass(Channel.self))
        fetchedRequest.predicate = NSPredicate(format: "channel_url == %@", channel_url)
        fetchedRequest.fetchLimit = 1
        return fetchedRequest
    }
    
}




