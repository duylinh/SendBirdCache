

# SendBirdChatCache Framework

SendBirdChat framework seamlessly implements CoreData cache to sendbird chat so user can read conversation history when offline. 

It provides limited but easy to use interface for app to start sendbird services.

# How to add to existing project

SendBirdChat framework requires 

	'SendBirdSDK', '~> 3.0.122'
	
To add to project using pods use pod

`pod 'SendBirdChat', :git => 'git@github.com:mzahidimran/SendBirdChat.git', :branch => 'master'`



`import SendBirdChat` in your swift files and you can access classes `SendBirdSDK` classes as well


# How to use

Init sendbird in app delegates

`SBDMain.initWithApplicationId(kAppId)`

Login and start chat services

` SendBirdChat.startChatWith(username: "userid", name: "Name", avatarUrl: user.sitterProfile?.avatarUrl)`

Framework exports collection models which responds reactively 

To list conversations 

`let _collection = SBCChannelCollection.newCollection(query: SBCChannelQuery.allChannelQuery())`
        
which initializes a collection model which works exactly like **NSFetchedResultsController**

Add delegates for **SBCChannelCollection** implement

`SBCChannelCollectionDelegate`




    func collection(_ collection: SBCChannelCollection, 
    
    					didChange anObject: SBDGroupChannel, 
    					at indexPath: IndexPath?, 
    					for type: SBCChannelCollectionModificationType, 
    					newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .none)
            break
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .none)
            break
        case .update:
        
            break
        case .move:
            self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
            break
        default: break
            
        }
    }
    
    func collection(_ collection: SBCChannelCollection, didChange sectionInfo: SBCChannelCollectionSectionInfo, atSectionIndex sectionIndex: Int, for type: SBCChannelCollectionModificationType) {
        switch type {
        case .insert:
            self.tableView.insertSections([sectionIndex], with: .none)
            break
        case .delete:
            self.tableView.deleteSections([sectionIndex], with: .none)
            break
        case .update:
            self.tableView.reloadSections([sectionIndex], with: .none)
            break
        case .move:
            
            break
        default: break
            
        }
    }
    
    func collectionWillChangeContent(_ collection: SBCChannelCollection) {
        UIView.setAnimationsEnabled(false)
        CATransaction.begin()
        self.tableView.beginUpdates()
        CATransaction.setCompletionBlock { () -> Void in
            // of the animation.
            UIView.setAnimationsEnabled(true)
        }
    }
    
    func collectionDidChangeContent(_ collection: SBCChannelCollection) {
        self.tableView.endUpdates()
        CATransaction.commit()
        
    }
}


    
    
For messages use **SBCMessageCollection** it requires channelURL

`let _collection = SBCMessageCollection.newCollection(query: SBCMessageQuery.messageQuery(channelURL: channel.channelUrl))`


and implements its delegates to get updates



    
    func collection(_ collection: SBCMessageCollection, didChange anObject: SBDBaseMessage, at indexPath: IndexPath?, for type: SBCMessageCollectionModificationType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
            break
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .none)
            break
        case .update:
            
            
            break
        case .move:
            self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
            break
        default: break
            
        }
    }
    
    func collection(_ collection: SBCMessageCollection, didChange sectionInfo: SBCMessageCollectionSectionInfo, atSectionIndex sectionIndex: Int, for type: SBCMessageCollectionModificationType) {
        switch type {
        case .insert:
            self.tableView.insertSections([sectionIndex], with: .none)
            break
        case .delete:
            self.tableView.deleteSections([sectionIndex], with: .none)
            break
        case .update:
            self.tableView.reloadSections([sectionIndex], with: .none)
            break
        case .move:
            
            break
        default: break
            
        }
    }
    
    func collectionWillChangeContent(_ collection: SBCMessageCollection)  {
  
        self.tableView.beginUpdates()
        
    }
    
    func collectionDidChangeContent(_ collection: SBCMessageCollection) {
        self.tableView.endUpdates()
        
    }



# How to Send Text Message 

To send message you have to save preview message to cache to make it appear on screen then update cached message with results. 


`
func send(text tx:String) -> Void  {
        
        let theParams: SBDUserMessageParams? = SBDUserMessageParams.init(message: tx)
        
        guard let params: SBDUserMessageParams = theParams else {
            return
        }
        
        // post message to sendbird
        var previewMessage: SBDUserMessage?
        previewMessage = self.channel.sendUserMessage(with: params, completionHandler: { (theMessage, theError) in
            
            if theError != nil {
                //update cached message with status
                SendBirdChat.saveMessage(message: theMessage ?? previewMessage!
                    , status: .failed)
                return
            }
            
            guard let message: SBDUserMessage = theMessage else {
                
                return
            }
            //update cached message with status
            SendBirdChat.saveMessage(message: message, status: .sent)
            previewMessage = nil
        })
        //save message to cache
        SendBirdChat.saveMessage(message: previewMessage!)
        
    }`
