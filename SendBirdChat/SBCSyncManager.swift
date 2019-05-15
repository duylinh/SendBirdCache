//
//  SyncManager.swift
//  SendBirdChat
//
//  Created by Muhammad Zahid Imran on 11/22/18.
//  Copyright © 2018 Jirah. All rights reserved.
//

import Foundation
import SendBirdSDK
import AudioToolbox

@objcMembers
class SBCSyncManager:NSObject {
    
    let delegateIdentifier:String = "SyncManager"
    
    static let shared = SBCSyncManager()
    
    var messageInMemoryCache:[SBDBaseMessage] = []
    var isSyncingChannels: Bool = false
    @objc dynamic var isSyncingMessages:Bool = false
    var mediumImpactFeedbackGenerator: UIImpactFeedbackGenerator? = nil
    
    private var groupChannelListQuery: SBDGroupChannelListQuery?
    
    lazy var syncQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "SyncQueue"
        queue.maxConcurrentOperationCount = 4
        return queue
    }()
    
    private override init() {
        super.init()
        let _ = SBCCoreDataSource.shared
        SBDMain.add(self, identifier: delegateIdentifier)
        if UIDevice.current.hasHapticFeedback {
            mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        }
    }
    
    
    
    
    public func prepareSync ()
    {
        mediumImpactFeedbackGenerator?.prepare()
        messageInMemoryCache = []
        isSyncingMessages = true
        syncQueue.cancelAllOperations()
        syncQueue.isSuspended = false
    }
    
    
    public func startSync()
    {
        
        
        let saveChannels = { ( channels: [SBDGroupChannel]) in
            SBCCoreDataSource.shared.perform(block: {
                for channel in channels {
                    let _ = channel.createCoreDataModel()
                }
            }, completion: { (success, error) in
                
            })
        }
        
        
        isSyncingChannels = true
        if self.groupChannelListQuery == nil
        {
            self.groupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
            self.groupChannelListQuery?.limit = 30
            self.groupChannelListQuery?.order = SBDGroupChannelListOrder.latestLastMessage
        }
        
        
        self.groupChannelListQuery?.loadNextPage(completionHandler: {[weak self] (channels, error) in
            
            if let err = error {
                self?.syncFailed(error: err)
                self?.isSyncingChannels = false
                
                return
            }
            
            if let chs = channels
            {
                for channel in chs {
                    self?.syncQueue.addOperation(SyncOperation(channel: channel, failedBlock: { (error) in
                        self?.syncFailed(error: error)
                    }))
                }
                saveChannels(chs)
            }
            
            if self?.groupChannelListQuery?.hasNext == true
            {
                self?.startSync()
            }
            else
            {
                self?.groupChannelListQuery = nil
                self?.isSyncingChannels = false
                
                
                if let ops = self?.syncQueue.operations, ops.count > 0
                {
                    let finishOperation = BlockOperation(block: {
                        DispatchQueue.main.async {
                            self?.syncFinishedSuccessfuly()
                        }
                    })
                    for op in ops {
                        finishOperation.addDependency(op)
                    }
                    self?.syncQueue.addOperation(finishOperation)
                }
                else {
                    self?.syncFinishedSuccessfuly()
                }
                
            }
        })
    }
    
    
    func syncFinishedSuccessfuly() -> Void {
        // add in memory cached to store
        isSyncingMessages = false
        SBCCoreDataSource.shared.perform(block: {
            for message in self.messageInMemoryCache {
                let _ = message.createCoreDataModel()
            }
        }) { (success, error) in
            
        }
        messageInMemoryCache = []
        syncQueue.cancelAllOperations()
        syncQueue.isSuspended = true
    }
    
    func syncFailed(error: Error) -> Void {
        messageInMemoryCache = []
        syncQueue.cancelAllOperations()
        syncQueue.isSuspended = true
    }
    
    
}





extension SBCSyncManager: SBDChannelDelegate
{
    
    
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        SBCCoreDataSource.shared.perform(block: {
            let _ = sender.createCoreDataModel()
        }) { (success, error) in
            
        }
        NotificationCenter.default.post(name: .groupChannelReadReceiptUpdated, object: sender)
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        if let groupChannel = sender as? SBDGroupChannel
        {
            SBCCoreDataSource.shared.perform(block: {
                let _ = groupChannel.createCoreDataModel()
            }) { (success, error) in
                
            }
        }
        
        NotificationCenter.default.post(name: .channelWasChanged, object: sender)
        
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        NotificationCenter.default.post(name: .groupChannelTypingStatusChanged, object: sender)
    }
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        if isSyncingMessages == true {
            messageInMemoryCache.append(message)
        }
        else{
            SBCCoreDataSource.shared.perform(block: {
                let _ = message.createCoreDataModel()
            }) { (success, error) in
                
            }
        }
        NotificationCenter.default.post(name: .didReceiveMessage, object: message)
        if UIDevice.current.hasHapticFeedback {
            mediumImpactFeedbackGenerator?.impactOccurred()
        } else if UIDevice.current.hasTapticEngine {
            // Fallback for older devices
            let peek = SystemSoundID(1519)
            AudioServicesPlaySystemSound(peek)
        } else {
            // Can't play haptic signal...
        }
    }
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {// new channel received
        SBCCoreDataSource.shared.perform(block: {
            let _ = sender.createCoreDataModel()
        }) { (success, error) in
            
        }
    }
    
    
    
}



extension SBDGroupChannel {
    
    
    
    func loadUnreadMessages() -> Void {
        self.getPreviousMessages(byMessageId: (self.lastMessage?.messageId)!, limit: Int(self.unreadMessageCount), reverse: true, messageType: .all, customType: nil) { (messages, error) in
            
            var messagesArray:[SBDBaseMessage] = []
            messagesArray.append(contentsOf: messages ?? [])
            messagesArray.append(self.lastMessage!)
            SBCCoreDataSource.shared.perform(block: {
                for message in messagesArray {
                    let _ = message.createCoreDataModel()
                }
            }, completion: { (success, error) in
                
            })
        }
    }
    
}
