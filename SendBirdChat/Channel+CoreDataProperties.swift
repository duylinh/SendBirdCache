//
//  Channel+CoreDataProperties.swift
//  SendBirdChat
//
//  Created by Muhammad Zahid Imran on 12/10/18.
//  Copyright © 2018 AppsGenii Technologies PVT Limited. All rights reserved.
//
//

import Foundation
import CoreData


extension Channel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Channel> {
        return NSFetchRequest<Channel>(entityName: "Channel")
    }

    @NSManaged public var channel_url: String?
    @NSManaged public var created_at: Int64
    @NSManaged public var last_message_ts: Int64
    @NSManaged public var serialized_data: Data?

}
