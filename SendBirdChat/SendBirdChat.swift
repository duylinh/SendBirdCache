//
//  SendBirdChat.swift
//  SendBirdChat
//
//  Created by Muhammad Zahid Imran on 11/23/18.
//  Copyright © 2018 Jirah. All rights reserved.
//

import Foundation
import SendBirdSDK

public enum OutgoingMessageStatus: String {
    case sent
    case failed
}


@objcMembers
public class SendBirdChat:NSObject {
    
    public static let shared = SendBirdChat()
    
    var isSyncingChannels: Bool {
        get {
            return SBCSyncManager.shared.isSyncingChannels
        }
    }
    @objc dynamic public var isSyncingMessages:Bool
    
    var  syncingObservation: NSKeyValueObservation!
    private override init() {
        isSyncingMessages = SBCSyncManager.shared.isSyncingMessages
        super.init()
        SBDMain.add(self, identifier: "SendBirdChat")
        syncingObservation = SBCSyncManager.shared.observe(\.isSyncingMessages, changeHandler: {[weak self] (manager, value) in
            self?.isSyncingMessages = SBCSyncManager.shared.isSyncingMessages
        })
        
    }
    
    public class func startChatWith(username userid:String, name nick:String, avatarUrl url:String?)
    {
        let _ = SendBirdChat.shared
        if let current = SBDMain.getCurrentUser(), current.userId == userid
        {
            return
        }
        else {
            
            SBCSyncManager.shared.prepareSync()
            SBDMain.connect(withUserId: userid) { (user, error) in
                SBDMain.updateCurrentUserInfo(withNickname: nick, profileUrl: url, completionHandler: { (error) in
                    SBCSyncManager.shared.startSync()
                })
                if let pendingToken = SBDMain.getPendingPushToken()
                {
                    registerPushDeviceToken(data: pendingToken, completion: { (status, error) in
                        
                    })
                }
                
            }
        }
    }
    
    
    public class func registerPushDeviceToken(data: Data, completion:(SBDPushTokenRegistrationStatus, SBDError) -> Void)
    {
        SBDMain.registerDevicePushToken(data, unique: true) { (status, error) in
            if error == nil {
                if status == SBDPushTokenRegistrationStatus.pending {
                    // Registration is pending.
                    // If you get this status, invoke `+ registerDevicePushToken:unique:completionHandler:` with `[SBDMain getPendingPushToken]` after connection.
                }
                else {
                    // Registration succeeded.
                }
            }
            else {
                // Registration failed.
            }
        }
    }
    
    
    
    public class func saveMessage(message: SBDBaseMessage, status: OutgoingMessageStatus? = nil)
    {
        SBCCoreDataSource.shared.perform(block: {
            var keyMapping:[String:Any] = [:]
            if let st = status
            {
                keyMapping["status"] = st.rawValue
            }
            let _ = message.createCoreDataModel(additionalKeyMapping: keyMapping)
        }) { (success, error) in
            
        }
    }
    
    public class func loadHistory(timestamp: Int64, channel: SBDBaseChannel, completion:@escaping ([SBDBaseMessage]?, SBDError?)->Void)
    {
        channel.getPreviousMessages(byTimestamp: timestamp, limit: 30, reverse: true, messageType: .all, customType: nil, senderUserIds: nil, includeMetaArray: true) { (messages, error) in
            if let err = error {
                completion(nil, err)
            }
            else {
                for message in messages ?? [] {
                    SBCCoreDataSource.shared.perform(block: {
                        let _ = message.createCoreDataModel()
                    }) { (success, error) in
                        
                    }
                }
                completion(messages, nil)
            }
            
        }
    }
    
    
    public class func channel(channelURL: String) -> SBDGroupChannel?
    {
        if let channel = Channel.getChannelWith(channel_url: channelURL), let data = channel.serialized_data
        {
            return SBDGroupChannel.build(fromSerializedData: data)
        }
        else {
            return nil
        }
    }
    
    
    public class func delete(message: SBDBaseMessage)
    {
        SBCCoreDataSource.shared.perform(block: {
            message.deleteCoreDataModel()
        }) { (success, error) in
            
        }
    }
    
    public class func logout()
    {
        SBCCoreDataSource.shared.clearCoreData()
        SBDMain.disconnect {
            
        }
    }
    
    
    
    
    
}

extension SendBirdChat: SBDConnectionDelegate
{
   
    public func didSucceedReconnection() {
        NotificationCenter.default.post(name: .didSucceedReconnection, object: nil)
        SBCSyncManager.shared.startSync()
    }
    
    public func didFailReconnection() {
        
    }
    
    public func didStartReconnection() {
        SBCSyncManager.shared.prepareSync()
    }
    
    public func didCancelReconnection() {
        
    }
    
  
}



extension Notification.Name {
    public static let didSucceedReconnection = Notification.Name("didSucceedReconnection")
    public static let didReceiveMessage = Notification.Name("didReceiveMessage")
    public static let channelWasChanged = Notification.Name("channelWasChanged")
    public static let groupChannelTypingStatusChanged = Notification.Name("groupChannelTypingStatusChanged")
    public static let groupChannelReadReceiptUpdated = Notification.Name("groupChannelReadReceiptUpdated")
}
