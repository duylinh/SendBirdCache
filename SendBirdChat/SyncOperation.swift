//
//  SyncOperation.swift
//  SendBirdChat
//
//  Created by Muhammad Zahid Imran on 11/27/18.
//  Copyright © 2018 Jirah. All rights reserved.
//

import Foundation
import SendBirdSDK

class SyncOperation: AsyncOperation {
    
    let channel: SBDBaseChannel
    let limit:Int = 100

    let failedBlock:((Error)->Void)
    
    init(channel ch: SBDBaseChannel, failedBlock block:@escaping ((Error)->Void)) {
        self.channel = ch
        self.failedBlock = block
    }
    
    override func main() {
        self.state = .executing
        
        performSync()
        
        
    }
    
    func performSync() -> Void {
        if let lastMessage:Message = Message.getLastMessageWith(channelURL: self.channel.channelUrl)
        {
            channel.getNextMessages(byTimestamp: lastMessage.message_ts, limit: limit, reverse: false, messageType: .all, customType: nil, senderUserIds: nil, includeMetaArray: true, completionHandler: {[weak self] (messages, error) in
                if let err = error {
                    self?.failedBlock(err)
                    self?.state = .finished
                }
                
                if let messagesArray = messages {
                    for message in messagesArray {
                        SBCCoreDataSource.shared.perform(block: {
                            let _ = message.createCoreDataModel()
                        }) { (success, error) in
                            
                        }
                    }
                    
                    if messagesArray.count == self?.limit
                    {
                        self?.performSync()
                    }
                    else{
                        self?.state = .finished
                    }
                    
                }
                else {
                    self?.state = .finished
                }
            
                
            })
        }
        else
        {
            channel.getPreviousMessages(byTimestamp: Int64(Date().timeIntervalSince1970 * 1000), limit: 20, reverse: true, messageType: .all, customType: nil, completionHandler: {[weak self] (messages, error) in
                
                
                if let err = error {
                    self?.failedBlock(err)
                    self?.state = .finished
                }
                
                if let messagesArray = messages {
                    for message in messagesArray {
                        SBCCoreDataSource.shared.perform(block: {
                            let _ = message.createCoreDataModel()
                        }) { (success, error) in
                            
                        }
                    }
                    
                    self?.state = .finished
                    
                }
                else {
                    self?.state = .finished
                }
                
                
            })
        }
    }
}
