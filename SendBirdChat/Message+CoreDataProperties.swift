//
//  Message+CoreDataProperties.swift
//  SendBirdChat
//
//  Created by Muhammad Zahid Imran on 12/10/18.
//  Copyright © 2018 Jirah. All rights reserved.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var channel_url: String?
    @NSManaged public var message_id: Int64
    @NSManaged public var message_ts: Int64
    @NSManaged public var payload: Data?
    @NSManaged public var request_id: String?
    @NSManaged public var status: String?

}
