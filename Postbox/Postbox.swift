import Foundation

#if os(macOS)
    import SwiftSignalKitMac
#else
    import SwiftSignalKit
#endif

public protocol PeerChatState: PostboxCoding {
    func equals(_ other: PeerChatState) -> Bool
}

public enum PostboxUpdateMessage {
    case update(StoreMessage)
    case skip
}

public enum ScanMessageEntry {
    case message(Message)
    case hole(MessageHistoryHole)
}

public final class Modifier {
    private weak var postbox: Postbox?
    var disposed = false
    
    fileprivate init(postbox: Postbox) {
        self.postbox = postbox
    }
    
    public func addMessages(_ messages: [StoreMessage], location: AddMessagesLocation) -> [Int64: MessageId] {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.addMessages(modifier: self, messages: messages, location: location)
        } else {
            return [:]
        }
    }
    
    public func addHole(_ messageId: MessageId) {
        assert(!self.disposed)
        self.postbox?.addHole(messageId)
    }
    
    public func fillHole(_ hole: MessageHistoryHole, fillType: HoleFill, tagMask: MessageTags?, messages: [StoreMessage]) {
        assert(!self.disposed)
        self.postbox?.fillHole(hole, fillType: fillType, tagMask: tagMask, messages: messages)
    }
    
    public func fillMultipleHoles(_ hole: MessageHistoryHole, fillType: HoleFill, tagMask: MessageTags?, messages: [StoreMessage]) {
        assert(!self.disposed)
        self.postbox?.fillMultipleHoles(hole, fillType: fillType, tagMask: tagMask, messages: messages)
    }
    
    public func replaceChatListHole(_ index: MessageIndex, hole: ChatListHole?) {
        assert(!self.disposed)
        self.postbox?.replaceChatListHole(index, hole: hole)
    }
    
    public func resetChatList(keepPeerNamespaces: Set<PeerId.Namespace>, replacementHole: ChatListHole?) {
        assert(!self.disposed)
        self.postbox?.resetChatList(keepPeerNamespaces: keepPeerNamespaces, replacementHole: replacementHole)
    }
    
    public func deleteMessages(_ messageIds: [MessageId]) {
        assert(!self.disposed)
        self.postbox?.deleteMessages(messageIds)
    }
    
    public func deleteMessagesInRange(peerId: PeerId, namespace: MessageId.Namespace, minId: MessageId.Id, maxId: MessageId.Id) {
        assert(!self.disposed)
        self.postbox?.deleteMessagesInRange(peerId: peerId, namespace: namespace, minId: minId, maxId: maxId)
    }
    
    public func clearHistory(_ peerId: PeerId) {
        assert(!self.disposed)
        self.postbox?.clearHistory(peerId)
    }
    
    public func removeAllMessagesWithAuthor(_ peerId: PeerId, authorId: PeerId) {
        assert(!self.disposed)
        self.postbox?.removeAllMessagesWithAuthor(peerId, authorId: authorId)
    }
    
    public func messageIdsForGlobalIds(_ ids: [Int32]) -> [MessageId] {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.messageIdsForGlobalIds(ids)
        } else {
            return []
        }
    }
    
    public func deleteMessagesWithGlobalIds(_ ids: [Int32]) {
        assert(!self.disposed)
        if let postbox = self.postbox {
            let messageIds = postbox.messageIdsForGlobalIds(ids)
            postbox.deleteMessages(messageIds)
        }
    }
    
    public func messageIdForGloballyUniqueMessageId(peerId: PeerId, id: Int64) -> MessageId? {
        assert(!self.disposed)
        return self.postbox?.messageIdForGloballyUniqueMessageId(peerId: peerId, id: id)
    }
    
    public func resetIncomingReadStates(_ states: [PeerId: [MessageId.Namespace: PeerReadState]]) {
        assert(!self.disposed)
        self.postbox?.resetIncomingReadStates(states)
    }
    
    public func confirmSynchronizedIncomingReadState(_ peerId: PeerId) {
        assert(!self.disposed)
        self.postbox?.confirmSynchronizedIncomingReadState(peerId)
    }
    
    public func applyIncomingReadMaxId(_ messageId: MessageId) {
        assert(!self.disposed)
        self.postbox?.applyIncomingReadMaxId(messageId)
    }
    
    public func applyOutgoingReadMaxId(_ messageId: MessageId) {
        assert(!self.disposed)
        self.postbox?.applyOutgoingReadMaxId(messageId)
    }
    
    public func applyInteractiveReadMaxIndex(_ messageIndex: MessageIndex) -> [MessageId] {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.applyInteractiveReadMaxIndex(messageIndex)
        } else {
            return []
        }
    }
    
    public func applyOutgoingReadMaxIndex(_ messageIndex: MessageIndex) -> [MessageId] {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.applyOutgoingReadMaxIndex(messageIndex)
        } else {
            return []
        }
    }
    
    public func getState() -> PostboxCoding? {
        assert(!self.disposed)
        return self.postbox?.getState()
    }
    
    public func setState(_ state: PostboxCoding) {
        assert(!self.disposed)
        self.postbox?.setState(state)
    }
    
    public func getPeerChatState(_ id: PeerId) -> PeerChatState? {
        assert(!self.disposed)
        return self.postbox?.peerChatStateTable.get(id) as? PeerChatState
    }
    
    public func setPeerChatState(_ id: PeerId, state: PeerChatState) {
        assert(!self.disposed)
        self.postbox?.setPeerChatState(id, state: state)
    }
    
    public func getPeerChatInterfaceState(_ id: PeerId) -> PeerChatInterfaceState? {
        assert(!self.disposed)
        return self.postbox?.peerChatInterfaceStateTable.get(id)
    }
    
    public func updatePeerChatInterfaceState(_ id: PeerId, update: (PeerChatInterfaceState?) -> (PeerChatInterfaceState?)) {
        assert(!self.disposed)
        self.postbox?.updatePeerChatInterfaceState(id, update: update)
    }
    
    public func getPeer(_ id: PeerId) -> Peer? {
        assert(!self.disposed)
        return self.postbox?.peerTable.get(id)
    }
    
    public func getPeerReadStates(_ id: PeerId) -> [(MessageId.Namespace, PeerReadState)]? {
        assert(!self.disposed)
        return self.postbox?.readStateTable.getCombinedState(id)?.states
    }
    
    public func getCombinedPeerReadState(_ id: PeerId) -> CombinedPeerReadState? {
        assert(!self.disposed)
        return self.postbox?.readStateTable.getCombinedState(id)
    }
    
    public func getPeerNotificationSettings(_ id: PeerId) -> PeerNotificationSettings? {
        assert(!self.disposed)
        return self.postbox?.peerNotificationSettingsTable.getEffective(id)
    }
    
    public func getPendingPeerNotificationSettings(_ id: PeerId) -> PeerNotificationSettings? {
        assert(!self.disposed)
        return self.postbox?.peerNotificationSettingsTable.getPending(id)
    }
    
    public func updatePeersInternal(_ peers: [Peer], update: (Peer?, Peer) -> Peer?) {
        assert(!self.disposed)
        self.postbox?.updatePeers(peers, update: update)
    }
    
    public func getPeerChatListInclusion(_ id: PeerId) -> PeerChatListInclusion {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.getPeerChatListInclusion(id)
        }
        return .never
    }
    
    public func getAssociatedPeerIds(_ id: PeerId) -> Set<PeerId> {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.reverseAssociatedPeerTable.get(peerId: id)
        }
        return []
    }
    
    public func getTopPeerMessageId(peerId: PeerId, namespace: MessageId.Namespace) -> MessageId? {
        assert(!self.disposed)
        return self.postbox?.messageHistoryIndexTable.top(peerId, namespace: namespace)?.index.id
    }
    
    public func getTopPeerMessageIndex(peerId: PeerId, namespace: MessageId.Namespace) -> MessageIndex? {
        return self.postbox?.messageHistoryIndexTable.top(peerId, namespace: namespace)?.index
    }
    
    public func getPeerChatListIndex(_ peerId: PeerId) -> ChatListIndex? {
        return self.postbox?.chatListTable.getPeerChatListIndex(peerId)
    }
    
    public func updatePeerChatListInclusion(_ id: PeerId, inclusion: PeerChatListInclusion) {
        assert(!self.disposed)
        self.postbox?.updatePeerChatListInclusion(id, inclusion: inclusion)
    }
    
    public func updateCurrentPeerNotificationSettings(_ notificationSettings: [PeerId: PeerNotificationSettings]) {
        assert(!self.disposed)
        self.postbox?.updateCurrentPeerNotificationSettings(notificationSettings)
    }
    
    public func updatePendingPeerNotificationSettings(peerId: PeerId, settings: PeerNotificationSettings?) {
        assert(!self.disposed)
        self.postbox?.updatePendingPeerNotificationSettings(peerId: peerId, settings: settings)
    }
    
    public func resetAllPeerNotificationSettings(_ notificationSettings: PeerNotificationSettings) {
        assert(!self.disposed)
        self.postbox?.resetAllPeerNotificationSettings(notificationSettings)
    }
    
    public func updatePeerCachedData(peerIds: Set<PeerId>, update: (PeerId, CachedPeerData?) -> CachedPeerData?) {
        assert(!self.disposed)
        self.postbox?.updatePeerCachedData(peerIds: peerIds, update: update)
    }
    
    public func getPeerCachedData(peerId: PeerId) -> CachedPeerData? {
        assert(!self.disposed)
        return self.postbox?.cachedPeerDataTable.get(peerId)
    }
    
    public func updatePeerPresences(_ peerPresences: [PeerId: PeerPresence]) {
        assert(!self.disposed)
        self.postbox?.updatePeerPresences(peerPresences)
    }
    
    public func getContactPeerIds() -> Set<PeerId> {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.contactsTable.get()
        } else {
            return Set()
        }
    }
    
    public func isPeerContact(peerId: PeerId) -> Bool {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.contactsTable.isContact(peerId: peerId)
        } else {
            return false
        }
    }
    
    public func replaceRemoteContactCount(_ count: Int32) {
        assert(!self.disposed)
        self.postbox?.replaceRemoteContactCount(count)
    }
    
    public func replaceContactPeerIds(_ peerIds: Set<PeerId>) {
        assert(!self.disposed)
        self.postbox?.replaceContactPeerIds(peerIds)
    }
    
    public func replaceRecentPeerIds(_ peerIds: [PeerId]) {
        assert(!self.disposed)
        self.postbox?.replaceRecentPeerIds(peerIds)
    }
    
    public func getRecentPeerIds() -> [PeerId] {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.peerRatingTable.get()
        } else {
            return []
        }
    }
    
    public func updateMessage(_ id: MessageId, update: (Message) -> PostboxUpdateMessage) {
        assert(!self.disposed)
        self.postbox?.updateMessage(id, update: update)
    }
    
    public func offsetPendingMessagesTimestamps(lowerBound: MessageId, timestamp: Int32) {
        assert(!self.disposed)
        self.postbox?.offsetPendingMessagesTimestamps(lowerBound: lowerBound, timestamp: timestamp)
    }
    
    public func updateMessageGroupingKeysAtomically(_ ids: [MessageId], groupingKey: Int64) {
        assert(!self.disposed)
        self.postbox?.updateMessageGroupingKeysAtomically(ids, groupingKey: groupingKey)
    }
    
    public func updateMedia(_ id: MediaId, update: Media?) {
        assert(!self.disposed)
        self.postbox?.updateMedia(id, update: update)
    }
    
    public func replaceItemCollections(namespace: ItemCollectionId.Namespace, itemCollections: [(ItemCollectionId, ItemCollectionInfo, [ItemCollectionItem])]) {
        assert(!self.disposed)
        self.postbox?.replaceItemCollections(namespace: namespace, itemCollections: itemCollections)
    }
    
    public func replaceItemCollectionInfos(namespace: ItemCollectionId.Namespace, itemCollectionInfos: [(ItemCollectionId, ItemCollectionInfo)]) {
        assert(!self.disposed)
        self.postbox?.replaceItemCollectionInfos(namespace: namespace, itemCollectionInfos: itemCollectionInfos)
    }
    
    public func replaceItemCollectionItems(collectionId: ItemCollectionId, items: [ItemCollectionItem]) {
        assert(!self.disposed)
        self.postbox?.replaceItemCollectionItems(collectionId: collectionId, items: items)
    }
    
    public func removeItemCollection(collectionId: ItemCollectionId) {
        assert(!self.disposed)
        self.postbox?.removeItemCollection(collectionId: collectionId)
    }
    
    public func getItemCollectionsInfos(namespace: ItemCollectionId.Namespace) -> [(ItemCollectionId, ItemCollectionInfo)] {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.itemCollectionInfoTable.getInfos(namespace: namespace).map { ($0.1, $0.2) }
        } else {
            return []
        }
    }
    
    public func getItemCollectionInfo(collectionId: ItemCollectionId) -> ItemCollectionInfo? {
        assert(!self.disposed)
        return self.postbox?.itemCollectionInfoTable.getInfo(id: collectionId)
    }
    
    public func getItemCollectionItems(collectionId: ItemCollectionId) -> [ItemCollectionItem] {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.itemCollectionItemTable.collectionItems(collectionId: collectionId)
        } else {
            return []
        }
    }
    
    public func getCollectionsItems(namespace: ItemCollectionId.Namespace) -> [(ItemCollectionId, ItemCollectionInfo, [ItemCollectionItem])] {
        assert(!self.disposed)
        if let postbox = postbox {
            let infos = postbox.itemCollectionInfoTable.getInfos(namespace: namespace)
            var result: [(ItemCollectionId, ItemCollectionInfo, [ItemCollectionItem])] = []
            for info in infos {
                let items = getItemCollectionItems(collectionId: info.1)
                result.append((info.1, info.2, items))
            }
            return result
        } else {
            return []
        }
    }
    
    public func getItemCollectionInfoItems(namespace: ItemCollectionId.Namespace, id: ItemCollectionId) -> (ItemCollectionInfo, [ItemCollectionItem])? {
        assert(!self.disposed)
        if let postbox = postbox {
            let infos = postbox.itemCollectionInfoTable.getInfos(namespace: namespace)
            for info in infos {
                if info.1 == id {
                    return (info.2, getItemCollectionItems(collectionId: id))
                }
            }
        }
        
        return nil
    }
    
    public func searchItemCollection(namespace: ItemCollectionId.Namespace, key: MemoryBuffer) -> [ItemCollectionItem] {
        assert(!self.disposed)
        if let postbox = self.postbox {
            let itemsByCollectionId = postbox.itemCollectionItemTable.exactIndexedItems(namespace: namespace, key: ValueBoxKey(key))
            let infoIds = postbox.itemCollectionInfoTable.getIds(namespace: namespace)
            var infoIndices: [ItemCollectionId: Int] = [:]
            for i in 0 ..< infoIds.count {
                infoIndices[infoIds[i]] = i
            }
            let sortedKeys = itemsByCollectionId.keys.sorted(by: { lhs, rhs in
                if let lhsIndex = infoIndices[lhs], let rhsIndex = infoIndices[rhs] {
                    return lhsIndex < rhsIndex
                } else if let _ = infoIndices[lhs] {
                    return true
                } else {
                    return false
                }
            })
            var result: [ItemCollectionItem] = []
            for key in sortedKeys {
                result.append(contentsOf: itemsByCollectionId[key]!)
            }
            return result
        } else {
            return []
        }
    }
    
    public func replaceOrderedItemListItems(collectionId: Int32, items: [OrderedItemListEntry]) {
        assert(!self.disposed)
        self.postbox?.replaceOrderedItemListItems(collectionId: collectionId, items: items)
    }
    
    public func addOrMoveToFirstPositionOrderedItemListItem(collectionId: Int32, item: OrderedItemListEntry, removeTailIfCountExceeds: Int?) {
        assert(!self.disposed)
        self.postbox?.addOrMoveToFirstPositionOrderedItemListItem(collectionId: collectionId, item: item, removeTailIfCountExceeds: removeTailIfCountExceeds)
    }
    
    public func getOrderedListItemIds(collectionId: Int32) -> [MemoryBuffer] {
        assert(!self.disposed)
        if let postbox = postbox {
            return postbox.getOrderedListItemIds(collectionId: collectionId)
        } else {
            return []
        }
    }
    
    public func getOrderedListItems(collectionId: Int32) -> [OrderedItemListEntry] {
        assert(!self.disposed)
        if let postbox = postbox {
            return postbox.orderedItemListTable.getItems(collectionId: collectionId)
        } else {
            return []
        }
    }
    
    public func getOrderedItemListItem(collectionId: Int32, itemId: MemoryBuffer) -> OrderedItemListEntry? {
        assert(!self.disposed)
        return self.postbox?.getOrderedItemListItem(collectionId: collectionId, itemId: itemId)
    }
    
    public func removeOrderedItemListItem(collectionId: Int32, itemId: MemoryBuffer) {
        assert(!self.disposed)
        self.postbox?.removeOrderedItemListItem(collectionId: collectionId, itemId: itemId)
    }
    
    public func getMessage(_ id: MessageId) -> Message? {
        assert(!self.disposed)
        return self.postbox?.getMessage(id)
    }
    
    public func getMessageGroup(_ id: MessageId) -> [Message]? {
        assert(!self.disposed)
        return self.postbox?.getMessageGroup(id)
    }
    
    public func getTopMesssageIndex(peerId: PeerId, namespace: MessageId.Namespace) -> MessageIndex? {
        assert(!self.disposed)
        if let postbox = self.postbox {
            if let entry = postbox.messageHistoryIndexTable.top(peerId, namespace: namespace), case let .Message(index) = entry {
                return index
            }
        }
        return nil
    }
    
    public func getMedia(_ id: MediaId) -> Media? {
        assert(!self.disposed)
        return self.postbox?.messageHistoryTable.getMedia(id)
    }
    
    public func findMessageIdByTimestamp(peerId: PeerId, timestamp: Int32) -> MessageId? {
        assert(!self.disposed)
        return self.postbox?.messageHistoryTable.findMessageId(peerId: peerId, timestamp: timestamp)
    }
    
    public func findClosestMessageIdByTimestamp(peerId: PeerId, timestamp: Int32) -> MessageId? {
        assert(!self.disposed)
        return self.postbox?.messageHistoryTable.findClosestMessageId(peerId: peerId, timestamp: timestamp)
    }
    
    public func filterStoredMessageIds(_ messageIds: Set<MessageId>) -> Set<MessageId> {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.filterStoredMessageIds(messageIds)
        }
        return Set()
    }
    
    public func storedMessageId(peerId: PeerId, namespace: MessageId.Namespace, timestamp: Int32) -> MessageId? {
        assert(!self.disposed)
        return self.postbox?.storedMessageId(peerId: peerId, namespace: namespace, timestamp: timestamp)
    }
    
    public func putItemCacheEntry(id: ItemCacheEntryId, entry: PostboxCoding, collectionSpec: ItemCacheCollectionSpec) {
        assert(!self.disposed)
        self.postbox?.putItemCacheEntry(id: id, entry: entry, collectionSpec: collectionSpec)
    }
    
    public func removeItemCacheEntry(id: ItemCacheEntryId) {
        assert(!self.disposed)
        self.postbox?.removeItemCacheEntry(id: id)
    }
    
    public func retrieveItemCacheEntry(id: ItemCacheEntryId) -> PostboxCoding? {
        assert(!self.disposed)
        return self.postbox?.retrieveItemCacheEntry(id: id)
    }
    
    public func operationLogGetNextEntryLocalIndex(peerId: PeerId, tag: PeerOperationLogTag) -> Int32 {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.operationLogGetNextEntryLocalIndex(peerId: peerId, tag: tag)
        } else {
            return 0
        }
    }
    
    public func operationLogAddEntry(peerId: PeerId, tag: PeerOperationLogTag, tagLocalIndex: StorePeerOperationLogEntryTagLocalIndex, tagMergedIndex: StorePeerOperationLogEntryTagMergedIndex, contents: PostboxCoding) {
        assert(!self.disposed)
        self.postbox?.operationLogAddEntry(peerId: peerId, tag: tag, tagLocalIndex: tagLocalIndex, tagMergedIndex: tagMergedIndex, contents: contents)
    }
    
    public func operationLogRemoveEntry(peerId: PeerId, tag: PeerOperationLogTag, tagLocalIndex: Int32) -> Bool {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.operationLogRemoveEntry(peerId: peerId, tag: tag, tagLocalIndex: tagLocalIndex)
        } else {
            return false
        }
    }
    
    public func operationLogRemoveAllEntries(peerId: PeerId, tag: PeerOperationLogTag) {
        assert(!self.disposed)
        self.postbox?.operationLogRemoveAllEntries(peerId: peerId, tag: tag)
    }
    
    public func operationLogRemoveEntries(peerId: PeerId, tag: PeerOperationLogTag, withTagLocalIndicesEqualToOrLowerThan maxTagLocalIndex: Int32) {
        assert(!self.disposed)
        self.postbox?.operationLogRemoveEntries(peerId: peerId, tag: tag, withTagLocalIndicesEqualToOrLowerThan: maxTagLocalIndex)
    }
    
    public func operationLogUpdateEntry(peerId: PeerId, tag: PeerOperationLogTag, tagLocalIndex: Int32, _ f: (PeerOperationLogEntry?) -> PeerOperationLogEntryUpdate) {
        assert(!self.disposed)
        self.postbox?.operationLogUpdateEntry(peerId: peerId, tag: tag, tagLocalIndex: tagLocalIndex, f)
    }
    
    public func operationLogEnumerateEntries(peerId: PeerId, tag: PeerOperationLogTag, _ f: (PeerOperationLogEntry) -> Bool) {
        assert(!self.disposed)
        self.postbox?.operationLogEnumerateEntries(peerId: peerId, tag: tag, f)
    }
    
    public func addTimestampBasedMessageAttribute(tag: UInt16, timestamp: Int32, messageId: MessageId) {
        assert(!self.disposed)
        self.postbox?.addTimestampBasedMessageAttribute(tag: tag, timestamp: timestamp, messageId: messageId)
    }
    
    public func removeTimestampBasedMessageAttribute(tag: UInt16, messageId: MessageId) {
        assert(!self.disposed)
        self.postbox?.removeTimestampBasedMessageAttribute(tag: tag, messageId: messageId)
    }
    
    public func getPreferencesEntry(key: ValueBoxKey) -> PreferencesEntry? {
        assert(!self.disposed)
        return self.postbox?.getPreferencesEntry(key: key)
    }
    
    public func setPreferencesEntry(key: ValueBoxKey, value: PreferencesEntry?) {
        assert(!self.disposed)
        self.postbox?.setPreferencesEntry(key: key, value: value)
    }
    
    public func updatePreferencesEntry(key: ValueBoxKey, _ f: (PreferencesEntry?) -> PreferencesEntry?) {
        assert(!self.disposed)
        self.postbox?.setPreferencesEntry(key: key, value: f(self.postbox?.getPreferencesEntry(key: key)))
    }
    
    public func getPinnedPeerIds() -> [PeerId] {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.chatListTable.getPinnedPeerIds()
        } else {
            return []
        }
    }
    
    public func setPinnedPeerIds(_ peerIds: [PeerId]) {
        assert(!self.disposed)
        self.postbox?.setPinnedPeerIds(peerIds)
    }
    
    public func getTotalUnreadCount() -> Int32 {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.messageHistoryMetadataTable.getChatListTotalUnreadCount()
        } else {
            return 0
        }
    }
    
    public func getAccessChallengeData() -> PostboxAccessChallengeData {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.metadataTable.accessChallengeData()
        } else {
            return .none
        }
    }
    
    public func setAccessChallengeData(_ data: PostboxAccessChallengeData) {
        assert(!self.disposed)
        self.postbox?.setAccessChallengeData(data)
    }
    
    public func enumerateMedia(lowerBound: MessageIndex?, limit: Int) -> ([PeerId: Set<MediaId>], [MediaId: Media], MessageIndex?) {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.messageHistoryTable.enumerateMedia(lowerBound: lowerBound, limit: limit)
        } else {
            return ([:], [:], nil)
        }
    }
    
    public func replaceGlobalMessageTagsHole(globalTags: GlobalMessageTags, index: MessageIndex, with updatedIndex: MessageIndex?, messages: [StoreMessage]) {
        assert(!self.disposed)
        self.postbox?.replaceGlobalMessageTagsHole(modifier: self, globalTags: globalTags, index: index, with: updatedIndex, messages: messages)
    }
    
    public func searchMessages(peerId: PeerId?, query: String, tags: MessageTags?) -> [Message] {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.searchMessages(peerId: peerId, query: query, tags: tags)
        } else {
            return []
        }
    }
    
    public func unorderedItemListScan(tag: UnorderedItemListEntryTag, _ f: (UnorderedItemListEntry) -> Void) {
        if let postbox = self.postbox {
            postbox.unorderedItemListTable.scan(tag: tag, f)
        }
    }
    
    public func unorderedItemListDifference(tag: UnorderedItemListEntryTag, updatedEntryInfos: [ValueBoxKey: UnorderedItemListEntryInfo]) -> (metaInfo: UnorderedItemListTagMetaInfo?, added: [ValueBoxKey], removed: [UnorderedItemListEntry], updated: [UnorderedItemListEntry]) {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.unorderedItemListTable.difference(tag: tag, updatedEntryInfos: updatedEntryInfos)
        } else {
            return (nil, [], [], [])
        }
    }
    
    public func unorderedItemListApplyDifference(tag: UnorderedItemListEntryTag, previousInfo: UnorderedItemListTagMetaInfo?, updatedInfo: UnorderedItemListTagMetaInfo, setItems: [UnorderedItemListEntry], removeItemIds: [ValueBoxKey]) -> Bool {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.unorderedItemListTable.applyDifference(tag: tag, previousInfo: previousInfo, updatedInfo: updatedInfo, setItems: setItems, removeItemIds: removeItemIds)
        } else {
            return false
        }
    }
    
    public func getNoticeEntry(key: NoticeEntryKey) -> PostboxCoding? {
        assert(!self.disposed)
        if let postbox = self.postbox {
            return postbox.noticeTable.get(key: key)
        } else {
            return nil
        }
    }
    
    public func setNoticeEntry(key: NoticeEntryKey, value: PostboxCoding?) {
        assert(!self.disposed)
        self.postbox?.noticeTable.set(key: key, value: value)
    }
    
    public func setPendingMessageAction(type: PendingMessageActionType, id: MessageId, action: PendingMessageActionData?) {
        assert(!self.disposed)
        self.postbox?.setPendingMessageAction(type: type, id: id, action: action)
    }
    
    public func getPendingMessageAction(type: PendingMessageActionType, id: MessageId) -> PendingMessageActionData? {
        assert(!self.disposed)
        return self.postbox?.getPendingMessageAction(type: type, id: id)
    }
    
    public func getMessageTagSummary(peerId: PeerId, tagMask: MessageTags, namespace: MessageId.Namespace) -> MessageHistoryTagNamespaceSummary? {
        assert(!self.disposed)
        return self.postbox?.messageHistoryTagsSummaryTable.get(MessageHistoryTagsSummaryKey(tag: tagMask, peerId: peerId, namespace: namespace))
    }
    
    public func replaceMessageTagSummary(peerId: PeerId, tagMask: MessageTags, namespace: MessageId.Namespace, count: Int32, maxId: MessageId.Id) {
        assert(!self.disposed)
        self.postbox?.replaceMessageTagSummary(peerId: peerId, tagMask: tagMask, namespace: namespace, count: count, maxId: maxId)
    }
    
    public func scanMessages(peerId: PeerId, tagMask: MessageTags, _ f: (ScanMessageEntry) -> Bool) {
        assert(!self.disposed)
        self.postbox?.scanMessages(peerId: peerId, tagMask: tagMask, f)
    }
    
    public func invalidateMessageHistoryTagsSummary(peerId: PeerId, namespace: MessageId.Namespace, tagMask: MessageTags) {
        assert(!self.disposed)
        self.postbox?.invalidateMessageHistoryTagsSummary(peerId: peerId, namespace: namespace, tagMask: tagMask)
    }
    
    public func removeInvalidatedMessageHistoryTagsSummaryEntry(_ entry: InvalidatedMessageHistoryTagsSummaryEntry) {
        assert(!self.disposed)
        self.postbox?.removeInvalidatedMessageHistoryTagsSummaryEntry(entry)
    }
    
    public func getChatListIndices() {
        assert(!self.disposed)
    }
}

fileprivate class PipeNotifier: NSObject {
    let notifier: RLMNotifier
    let thread: Thread
    
    fileprivate init(basePath: String, notify: @escaping () -> Void) {
        self.notifier = RLMNotifier(basePath: basePath, notify: notify)
        self.thread = Thread(target: PipeNotifier.self, selector: #selector(PipeNotifier.threadEntry(_:)), object: self.notifier)
        self.thread.start()
    }
    
    @objc static func threadEntry(_ notifier: RLMNotifier!) {
        notifier.listen()
    }
    
    func notify() {
        notifier.notifyOtherRealms()
    }
}

public enum PostboxResult {
    case upgrading
    case postbox(Postbox)
}

func debugSaveState(basePath:String, name: String) {
    let path = basePath + name
    let _ = try? FileManager.default.removeItem(atPath: path)
    do {
        try FileManager.default.copyItem(atPath: basePath, toPath: path)
    } catch (let e) {
        print("(Postbox debugSaveState: error \(e))")
    }
}

func debugRestoreState(basePath:String, name: String) {
    let path = basePath + name
    let _ = try? FileManager.default.removeItem(atPath: basePath)
    do {
        try FileManager.default.copyItem(atPath: path, toPath: basePath)
    } catch (let e) {
        print("(Postbox debugRestoreState: error \(e))")
    }
}

public func openPostbox(basePath: String, globalMessageIdsNamespace: MessageId.Namespace, seedConfiguration: SeedConfiguration) -> Signal<PostboxResult, NoError> {
    let queue = Queue(name: "org.telegram.postbox.Postbox")
    return Signal { subscriber in
        queue.async {
            let _ = try? FileManager.default.createDirectory(atPath: basePath, withIntermediateDirectories: true, attributes: nil)
            
            #if DEBUG
            //debugSaveState(basePath: basePath, name: "beforeHoles1")
            //debugRestoreState(basePath: basePath, name: "beforeHoles1")
            #endif
            
            loop: while true {
                let valueBox = SqliteValueBox(basePath: basePath + "/db", queue: queue)
                
                let metadataTable = MetadataTable(valueBox: valueBox, table: MetadataTable.tableSpec(0))
                
                let userVersion: Int32? = metadataTable.userVersion()
                let currentUserVersion: Int32 = 14
                
                if let userVersion = userVersion {
                    if userVersion != currentUserVersion {
                        if let operation = registeredUpgrades()[userVersion] {
                            switch operation {
                                case let .inplace(f):
                                    valueBox.begin()
                                    f(metadataTable, valueBox)
                                    valueBox.commit()
                            }
                            continue loop
                        } else {
                            assertionFailure()
                            valueBox.drop()
                        }
                    }
                } else {
                    metadataTable.setUserVersion(currentUserVersion)
                }
                
                subscriber.putNext(.postbox(Postbox(queue: queue, basePath: basePath, globalMessageIdsNamespace: globalMessageIdsNamespace, seedConfiguration: seedConfiguration, valueBox: valueBox)))
                subscriber.putCompletion()
                break
            }
        }
        
        return EmptyDisposable
    }
}

public final class Postbox {
    private let queue: Queue
    private let seedConfiguration: SeedConfiguration
    private let basePath: String
    private let globalMessageIdsNamespace: MessageId.Namespace
    private let valueBox: ValueBox
    
    private let ipcNotificationsDisposable = MetaDisposable()
    //private var pipeNotifier: PipeNotifier!
    
    private var transactionStateVersion: Int64 = 0
    
    private var viewTracker: ViewTracker!
    private var nextViewId = 0
    
    private var currentUpdatedState: PostboxCoding?
    private var currentOperationsByPeerId: [PeerId: [MessageHistoryOperation]] = [:]
    private var currentUpdatedChatListInclusions: [PeerId: PeerChatListInclusion] = [:]
    private var currentUnsentOperations: [IntermediateMessageHistoryUnsentOperation] = []
    private var currentUpdatedSynchronizeReadStateOperations: [PeerId: PeerReadStateSynchronizationOperation?] = [:]
    private var currentUpdatedMedia: [MediaId: Media?] = [:]
    private var currentGlobalTagsOperations: [GlobalMessageHistoryTagsOperation] = []
    
    private var currentRemovedHolesByPeerId: [PeerId: [MessageIndex: HoleFillDirection]] = [:]
    private var currentFilledHolesByPeerId: [PeerId: [MessageIndex: HoleFillDirection]] = [:]
    private var currentUpdatedPeers: [PeerId: Peer] = [:]
    private var currentUpdatedPeerNotificationSettings: [PeerId: PeerNotificationSettings] = [:]
    private var currentUpdatedCachedPeerData: [PeerId: CachedPeerData] = [:]
    private var currentUpdatedPeerPresences: [PeerId: PeerPresence] = [:]
    private var currentUpdatedPeerChatListEmbeddedStates: [PeerId: PeerChatListEmbeddedInterfaceState?] = [:]
    private var currentUpdatedTotalUnreadCount: Int32?
    private var currentPeerMergedOperationLogOperations: [PeerMergedOperationLogOperation] = []
    private var currentTimestampBasedMessageAttributesOperations: [TimestampBasedMessageAttributesOperation] = []
    private var currentPreferencesOperations: [PreferencesOperation] = []
    private var currentOrderedItemListOperations: [Int32: [OrderedItemListOperation]] = [:]
    private var currentItemCollectionItemsOperations: [ItemCollectionId: [ItemCollectionItemsOperation]] = [:]
    private var currentItemCollectionInfosOperations: [ItemCollectionInfosOperation] = []
    private var currentUpdatedPeerChatStates = Set<PeerId>()
    private var currentUpdatedAccessChallengeData: PostboxAccessChallengeData?
    private var currentPendingMessageActionsOperations: [PendingMessageActionsOperation] = []
    private var currentUpdatedMessageActionsSummaries: [PendingMessageActionsSummaryKey: Int32] = [:]
    private var currentUpdatedMessageTagSummaries: [MessageHistoryTagsSummaryKey : MessageHistoryTagNamespaceSummary] = [:]
    private var currentInvalidateMessageTagSummaries: [InvalidatedMessageHistoryTagsSummaryEntryOperation] = []
    private var currentUpdatedPendingPeerNotificationSettings = Set<PeerId>()
    
    private var currentChatListOperations: [ChatListOperation] = []
    private var currentReplaceRemoteContactCount: Int32?
    private var currentReplacedContactPeerIds: Set<PeerId>?
    private var currentUpdatedMasterClientId: Int64?
    
    private let statePipe: ValuePipe<PostboxCoding> = ValuePipe()
    private var masterClientId = Promise<Int64>()
    
    private var sessionClientId: Int64 = {
        var value: Int64 = 0
        arc4random_buf(&value, 8)
        return value
    }()
    
    public let mediaBox: MediaBox
    
    let tables: [Table]
    
    let metadataTable: MetadataTable
    let keychainTable: KeychainTable
    let peerTable: PeerTable
    let peerNotificationSettingsTable: PeerNotificationSettingsTable
    let pendingPeerNotificationSettingsIndexTable: PendingPeerNotificationSettingsIndexTable
    let cachedPeerDataTable: CachedPeerDataTable
    let peerPresenceTable: PeerPresenceTable
    let globalMessageIdsTable: GlobalMessageIdsTable
    let globallyUniqueMessageIdsTable: MessageGloballyUniqueIdTable
    let messageHistoryIndexTable: MessageHistoryIndexTable
    let messageHistoryTable: MessageHistoryTable
    let mediaTable: MessageMediaTable
    let chatListIndexTable: ChatListIndexTable
    let chatListTable: ChatListTable
    let messageHistoryMetadataTable: MessageHistoryMetadataTable
    let messageHistoryUnsentTable: MessageHistoryUnsentTable
    let messageHistoryTagsTable: MessageHistoryTagsTable
    let globalMessageHistoryTagsTable: GlobalMessageHistoryTagsTable
    let peerChatStateTable: PeerChatStateTable
    let readStateTable: MessageHistoryReadStateTable
    let synchronizeReadStateTable: MessageHistorySynchronizeReadStateTable
    let contactsTable: ContactTable
    let itemCollectionInfoTable: ItemCollectionInfoTable
    let itemCollectionItemTable: ItemCollectionItemTable
    let itemCollectionReverseIndexTable: ReverseIndexReferenceTable<ItemCollectionItemReverseIndexReference>
    let peerChatInterfaceStateTable: PeerChatInterfaceStateTable
    let itemCacheMetaTable: ItemCacheMetaTable
    let itemCacheTable: ItemCacheTable
    let peerNameTokenIndexTable: ReverseIndexReferenceTable<PeerIdReverseIndexReference>
    let peerNameIndexTable: PeerNameIndexTable
    let reverseAssociatedPeerTable: ReverseAssociatedPeerTable
    let peerChatTopTaggedMessageIdsTable: PeerChatTopTaggedMessageIdsTable
    let peerOperationLogMetadataTable: PeerOperationLogMetadataTable
    let peerMergedOperationLogIndexTable: PeerMergedOperationLogIndexTable
    let peerOperationLogTable: PeerOperationLogTable
    let timestampBasedMessageAttributesTable: TimestampBasedMessageAttributesTable
    let timestampBasedMessageAttributesIndexTable: TimestampBasedMessageAttributesIndexTable
    let preferencesTable: PreferencesTable
    let orderedItemListTable: OrderedItemListTable
    let orderedItemListIndexTable: OrderedItemListIndexTable
    let textIndexTable: MessageHistoryTextIndexTable
    let unorderedItemListTable: UnorderedItemListTable
    let noticeTable: NoticeTable
    let messageHistoryTagsSummaryTable: MessageHistoryTagsSummaryTable
    let invalidatedMessageHistoryTagsSummaryTable: InvalidatedMessageHistoryTagsSummaryTable
    let pendingMessageActionsTable: PendingMessageActionsTable
    let pendingMessageActionsMetadataTable: PendingMessageActionsMetadataTable
    
    //temporary
    let peerRatingTable: RatingTable<PeerId>
    
    var installedMessageActionsByPeerId: [PeerId: Bag<([StoreMessage], Modifier) -> Void>] = [:]
    
    fileprivate init(queue: Queue, basePath: String, globalMessageIdsNamespace: MessageId.Namespace, seedConfiguration: SeedConfiguration, valueBox: ValueBox) {
        assert(queue.isCurrent())
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        self.queue = queue
        self.basePath = basePath
        self.globalMessageIdsNamespace = globalMessageIdsNamespace
        self.seedConfiguration = seedConfiguration
        
        print("MediaBox path: \(self.basePath + "/media")")
        
        self.mediaBox = MediaBox(basePath: self.basePath + "/media")
        self.valueBox = valueBox
        
        /*self.pipeNotifier = PipeNotifier(basePath: basePath, notify: { [weak self] in
            //if let strongSelf = self {
                /*strongSelf.queue.async {
                    if strongSelf.valueBox != nil {
                        let _ = strongSelf.modify({ _ -> Void in
                        }).start()
                    }
                }*/
            //}
        })*/
        
        self.metadataTable = MetadataTable(valueBox: self.valueBox, table: MetadataTable.tableSpec(0))
        
        self.keychainTable = KeychainTable(valueBox: self.valueBox, table: KeychainTable.tableSpec(1))
        self.reverseAssociatedPeerTable = ReverseAssociatedPeerTable(valueBox: self.valueBox, table:ReverseAssociatedPeerTable.tableSpec(40))
        self.peerTable = PeerTable(valueBox: self.valueBox, table: PeerTable.tableSpec(2), reverseAssociatedTable: self.reverseAssociatedPeerTable)
        self.globalMessageIdsTable = GlobalMessageIdsTable(valueBox: self.valueBox, table: GlobalMessageIdsTable.tableSpec(3), namespace: self.globalMessageIdsNamespace)
        self.globallyUniqueMessageIdsTable = MessageGloballyUniqueIdTable(valueBox: self.valueBox, table: MessageGloballyUniqueIdTable.tableSpec(32))
        self.messageHistoryMetadataTable = MessageHistoryMetadataTable(valueBox: self.valueBox, table: MessageHistoryMetadataTable.tableSpec(10))
        self.messageHistoryUnsentTable = MessageHistoryUnsentTable(valueBox: self.valueBox, table: MessageHistoryUnsentTable.tableSpec(11))
        self.invalidatedMessageHistoryTagsSummaryTable = InvalidatedMessageHistoryTagsSummaryTable(valueBox: self.valueBox, table: InvalidatedMessageHistoryTagsSummaryTable.tableSpec(47))
        self.messageHistoryTagsSummaryTable = MessageHistoryTagsSummaryTable(valueBox: self.valueBox, table: MessageHistoryTagsSummaryTable.tableSpec(44), invalidateTable: self.invalidatedMessageHistoryTagsSummaryTable)
        self.pendingMessageActionsMetadataTable = PendingMessageActionsMetadataTable(valueBox: self.valueBox, table: PendingMessageActionsMetadataTable.tableSpec(45))
        self.pendingMessageActionsTable = PendingMessageActionsTable(valueBox: self.valueBox, table: PendingMessageActionsTable.tableSpec(46), metadataTable: self.pendingMessageActionsMetadataTable)
        self.messageHistoryTagsTable = MessageHistoryTagsTable(valueBox: self.valueBox, table: MessageHistoryTagsTable.tableSpec(12), seedConfiguration: self.seedConfiguration, summaryTable: self.messageHistoryTagsSummaryTable)
        self.globalMessageHistoryTagsTable = GlobalMessageHistoryTagsTable(valueBox: self.valueBox, table: GlobalMessageHistoryTagsTable.tableSpec(39))
        self.messageHistoryIndexTable = MessageHistoryIndexTable(valueBox: self.valueBox, table: MessageHistoryIndexTable.tableSpec(4), globalMessageIdsTable: self.globalMessageIdsTable, metadataTable: self.messageHistoryMetadataTable, seedConfiguration: self.seedConfiguration)
        self.mediaTable = MessageMediaTable(valueBox: self.valueBox, table: MessageMediaTable.tableSpec(6))
        self.readStateTable = MessageHistoryReadStateTable(valueBox: self.valueBox, table: MessageHistoryReadStateTable.tableSpec(14))
        self.synchronizeReadStateTable = MessageHistorySynchronizeReadStateTable(valueBox: self.valueBox, table: MessageHistorySynchronizeReadStateTable.tableSpec(15))
        self.timestampBasedMessageAttributesIndexTable = TimestampBasedMessageAttributesIndexTable(valueBox: self.valueBox, table: TimestampBasedMessageAttributesTable.tableSpec(33))
        self.timestampBasedMessageAttributesTable = TimestampBasedMessageAttributesTable(valueBox: self.valueBox, table: TimestampBasedMessageAttributesTable.tableSpec(34), indexTable: self.timestampBasedMessageAttributesIndexTable)
        self.textIndexTable = MessageHistoryTextIndexTable(valueBox: self.valueBox, table: MessageHistoryTextIndexTable.tableSpec(41))
        self.messageHistoryTable = MessageHistoryTable(valueBox: self.valueBox, table: MessageHistoryTable.tableSpec(7), messageHistoryIndexTable: self.messageHistoryIndexTable, messageMediaTable: self.mediaTable, historyMetadataTable: self.messageHistoryMetadataTable, globallyUniqueMessageIdsTable: self.globallyUniqueMessageIdsTable, unsentTable: self.messageHistoryUnsentTable, tagsTable: self.messageHistoryTagsTable, globalTagsTable: self.globalMessageHistoryTagsTable, readStateTable: self.readStateTable, synchronizeReadStateTable: self.synchronizeReadStateTable, textIndexTable: self.textIndexTable, summaryTable: self.messageHistoryTagsSummaryTable, pendingActionsTable: self.pendingMessageActionsTable)
        self.peerChatStateTable = PeerChatStateTable(valueBox: self.valueBox, table: PeerChatStateTable.tableSpec(13))
        self.peerNameTokenIndexTable = ReverseIndexReferenceTable<PeerIdReverseIndexReference>(valueBox: self.valueBox, table: ReverseIndexReferenceTable<PeerIdReverseIndexReference>.tableSpec(26))
        self.peerNameIndexTable = PeerNameIndexTable(valueBox: self.valueBox, table: PeerNameIndexTable.tableSpec(27), peerTable: self.peerTable, peerNameTokenIndexTable: self.peerNameTokenIndexTable)
        self.contactsTable = ContactTable(valueBox: self.valueBox, table: ContactTable.tableSpec(16), peerNameIndexTable: self.peerNameIndexTable)
        self.peerRatingTable = RatingTable<PeerId>(valueBox: self.valueBox, table: RatingTable<PeerId>.tableSpec(17))
        self.cachedPeerDataTable = CachedPeerDataTable(valueBox: self.valueBox, table: CachedPeerDataTable.tableSpec(18))
        self.pendingPeerNotificationSettingsIndexTable = PendingPeerNotificationSettingsIndexTable(valueBox: self.valueBox, table: PendingPeerNotificationSettingsIndexTable.tableSpec(48))
        self.peerNotificationSettingsTable = PeerNotificationSettingsTable(valueBox: self.valueBox, table: PeerNotificationSettingsTable.tableSpec(19), pendingIndexTable: self.pendingPeerNotificationSettingsIndexTable)
        self.peerPresenceTable = PeerPresenceTable(valueBox: self.valueBox, table: PeerPresenceTable.tableSpec(20))
        self.itemCollectionInfoTable = ItemCollectionInfoTable(valueBox: self.valueBox, table: ItemCollectionInfoTable.tableSpec(21))
        self.itemCollectionReverseIndexTable = ReverseIndexReferenceTable<ItemCollectionItemReverseIndexReference>(valueBox: self.valueBox, table: ReverseIndexReferenceTable<ItemCollectionItemReverseIndexReference>.tableSpec(36))
        self.itemCollectionItemTable = ItemCollectionItemTable(valueBox: self.valueBox, table: ItemCollectionItemTable.tableSpec(22), reverseIndexTable: self.itemCollectionReverseIndexTable)
        self.peerChatInterfaceStateTable = PeerChatInterfaceStateTable(valueBox: self.valueBox, table: PeerChatInterfaceStateTable.tableSpec(23))
        self.itemCacheMetaTable = ItemCacheMetaTable(valueBox: self.valueBox, table: ItemCacheMetaTable.tableSpec(24))
        self.itemCacheTable = ItemCacheTable(valueBox: self.valueBox, table: ItemCacheTable.tableSpec(25))
        self.chatListIndexTable = ChatListIndexTable(valueBox: self.valueBox, table: ChatListIndexTable.tableSpec(8), peerNameIndexTable: self.peerNameIndexTable, metadataTable: self.messageHistoryMetadataTable, readStateTable: self.readStateTable, notificationSettingsTable: self.peerNotificationSettingsTable)
        self.chatListTable = ChatListTable(valueBox: self.valueBox, table: ChatListTable.tableSpec(9), indexTable: self.chatListIndexTable, metadataTable: self.messageHistoryMetadataTable, seedConfiguration: self.seedConfiguration)
        self.peerChatTopTaggedMessageIdsTable = PeerChatTopTaggedMessageIdsTable(valueBox: self.valueBox, table: PeerChatTopTaggedMessageIdsTable.tableSpec(28))
        self.peerOperationLogMetadataTable = PeerOperationLogMetadataTable(valueBox: self.valueBox, table: PeerOperationLogMetadataTable.tableSpec(29))
        self.peerMergedOperationLogIndexTable = PeerMergedOperationLogIndexTable(valueBox: self.valueBox, table: PeerMergedOperationLogIndexTable.tableSpec(30), metadataTable: self.peerOperationLogMetadataTable)
        self.peerOperationLogTable = PeerOperationLogTable(valueBox: self.valueBox, table: PeerOperationLogTable.tableSpec(31), metadataTable: self.peerOperationLogMetadataTable, mergedIndexTable: self.peerMergedOperationLogIndexTable)
        self.preferencesTable = PreferencesTable(valueBox: self.valueBox, table: PreferencesTable.tableSpec(35))
        self.orderedItemListIndexTable = OrderedItemListIndexTable(valueBox: self.valueBox, table: OrderedItemListIndexTable.tableSpec(37))
        self.orderedItemListTable = OrderedItemListTable(valueBox: self.valueBox, table: OrderedItemListTable.tableSpec(38), indexTable: self.orderedItemListIndexTable)
        self.unorderedItemListTable = UnorderedItemListTable(valueBox: self.valueBox, table: UnorderedItemListTable.tableSpec(42))
        self.noticeTable = NoticeTable(valueBox: self.valueBox, table: NoticeTable.tableSpec(43))
        
        var tables: [Table] = []
        tables.append(self.metadataTable)
        tables.append(self.keychainTable)
        tables.append(self.peerTable)
        tables.append(self.globalMessageIdsTable)
        tables.append(self.globallyUniqueMessageIdsTable)
        tables.append(self.messageHistoryMetadataTable)
        tables.append(self.messageHistoryUnsentTable)
        tables.append(self.messageHistoryTagsTable)
        tables.append(self.globalMessageHistoryTagsTable)
        tables.append(self.messageHistoryIndexTable)
        tables.append(self.mediaTable)
        tables.append(self.readStateTable)
        tables.append(self.synchronizeReadStateTable)
        tables.append(self.messageHistoryTable)
        tables.append(self.chatListIndexTable)
        tables.append(self.chatListTable)
        tables.append(self.peerChatStateTable)
        tables.append(self.contactsTable)
        tables.append(self.peerRatingTable)
        tables.append(self.peerNotificationSettingsTable)
        tables.append(self.cachedPeerDataTable)
        tables.append(self.peerPresenceTable)
        tables.append(self.itemCollectionInfoTable)
        tables.append(self.itemCollectionItemTable)
        tables.append(self.itemCollectionReverseIndexTable)
        tables.append(self.peerChatInterfaceStateTable)
        tables.append(self.itemCacheMetaTable)
        tables.append(self.itemCacheTable)
        tables.append(self.peerNameIndexTable)
        tables.append(self.reverseAssociatedPeerTable)
        tables.append(self.peerNameTokenIndexTable)
        tables.append(self.peerChatTopTaggedMessageIdsTable)
        tables.append(self.peerOperationLogMetadataTable)
        tables.append(self.peerMergedOperationLogIndexTable)
        tables.append(self.peerOperationLogTable)
        tables.append(self.timestampBasedMessageAttributesTable)
        tables.append(self.timestampBasedMessageAttributesIndexTable)
        tables.append(self.preferencesTable)
        tables.append(self.orderedItemListTable)
        tables.append(self.orderedItemListIndexTable)
        tables.append(self.unorderedItemListTable)
        tables.append(self.noticeTable)
        tables.append(self.messageHistoryTagsSummaryTable)
        tables.append(self.invalidatedMessageHistoryTagsSummaryTable)
        tables.append(self.pendingMessageActionsTable)
        tables.append(self.pendingMessageActionsMetadataTable)
        
        self.tables = tables
        
        self.transactionStateVersion = self.metadataTable.transactionStateVersion()
        
        self.viewTracker = ViewTracker(queue: self.queue, fetchEarlierHistoryEntries: self.fetchEarlierHistoryEntries, fetchLaterHistoryEntries: self.fetchLaterHistoryEntries, fetchEarlierChatEntries: self.fetchEarlierChatEntries, fetchLaterChatEntries: self.fetchLaterChatEntries, fetchAnchorIndex: self.fetchAnchorIndex, renderMessage: self.renderIntermediateMessage, getPeer: { peerId in
            return self.peerTable.get(peerId)
        }, getPeerNotificationSettings: { peerId in
            return self.peerNotificationSettingsTable.getEffective(peerId)
        }, getCachedPeerData: { peerId in
            return self.cachedPeerDataTable.get(peerId)
        }, getPeerPresence: { peerId in
            return self.peerPresenceTable.get(peerId)
        }, getTotalUnreadCount: {
            return self.messageHistoryMetadataTable.getChatListTotalUnreadCount()
        }, getPeerReadState: { peerId in
            return self.readStateTable.getCombinedState(peerId)
        }, operationLogGetOperations: { tag, fromIndex, limit in
            return self.peerOperationLogTable.getMergedEntries(tag: tag, fromIndex: fromIndex, limit: limit)
        }, operationLogGetTailIndex: { tag in
            return self.peerMergedOperationLogIndexTable.tailIndex(tag: tag)
        }, getTimestampBasedMessageAttributesHead: { tag in
            return self.timestampBasedMessageAttributesTable.head(tag: tag)
        }, getPreferencesEntry: { key in
            return self.preferencesTable.get(key: key)
        }, unsentMessageIds: self.messageHistoryUnsentTable.get(), synchronizePeerReadStateOperations: self.synchronizeReadStateTable.get(getCombinedPeerReadState: { peerId in
            return self.readStateTable.getCombinedState(peerId)
        }))
        
        print("(Postbox initialization took \((CFAbsoluteTimeGetCurrent() - startTime) * 1000.0) ms")
    }
    
    deinit {
        assert(true)
    }
    
   
    
    private func takeNextViewId() -> Int {
        let nextId = self.nextViewId
        self.nextViewId += 1
        return nextId
    }
    
    fileprivate func setState(_ state: PostboxCoding) {
        self.currentUpdatedState = state
        self.metadataTable.setState(state)
    }
    
    fileprivate func getState() -> PostboxCoding? {
        return self.metadataTable.state()
    }
    
    public func keychainEntryForKey(_ key: String) -> Data? {
        let metaDisposable = MetaDisposable()
        self.keychainOperationsDisposable.add(metaDisposable)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var entry: Data? = nil
        let disposable = (self.modify({ modifier -> Data? in
            return self.keychainTable.get(key)
        }) |> afterDisposed { [weak self, weak metaDisposable] in
            if let strongSelf = self, let metaDisposable = metaDisposable {
                strongSelf.keychainOperationsDisposable.remove(metaDisposable)
            }
        }).start(next: { data in
            entry = data
            semaphore.signal()
        })
        metaDisposable.set(disposable)
        
        semaphore.wait()
        return entry
    }
    
    private var keychainOperationsDisposable = DisposableSet()
    
    public func setKeychainEntryForKey(_ key: String, value: Data) {
        let metaDisposable = MetaDisposable()
        self.keychainOperationsDisposable.add(metaDisposable)
        
        let disposable = (self.modify({ modifier -> Void in
            self.keychainTable.set(key, value: value)
        }) |> afterDisposed { [weak self, weak metaDisposable] in
            if let strongSelf = self, let metaDisposable = metaDisposable {
                strongSelf.keychainOperationsDisposable.remove(metaDisposable)
            }
        }).start()
        metaDisposable.set(disposable)
    }
    
    public func removeKeychainEntryForKey(_ key: String) {
        let metaDisposable = MetaDisposable()
        self.keychainOperationsDisposable.add(metaDisposable)
        
        let disposable = (self.modify({ modifier -> Void in
            self.keychainTable.remove(key)
        }) |> afterDisposed { [weak self, weak metaDisposable] in
            if let strongSelf = self, let metaDisposable = metaDisposable {
                strongSelf.keychainOperationsDisposable.remove(metaDisposable)
            }
        }).start()
        metaDisposable.set(disposable)
    }
    
    fileprivate func addMessages(modifier: Modifier, messages: [StoreMessage], location: AddMessagesLocation) -> [Int64: MessageId] {
        var addedMessagesByPeerId: [PeerId: [StoreMessage]] = [:]
        let addResult = self.messageHistoryTable.addMessages(messages: messages, location: location, operationsByPeerId: &self.currentOperationsByPeerId, unsentMessageOperations: &currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries, processMessages: { messagesByPeerId in
            addedMessagesByPeerId = messagesByPeerId
        })
        for (peerId, peerMessages) in addedMessagesByPeerId {
            if let bag = self.installedMessageActionsByPeerId[peerId] {
                for f in bag.copyItems() {
                    f(peerMessages, modifier)
                }
            }
        }
        
        return addResult
    }
    
    fileprivate func addHole(_ id: MessageId) {
        self.messageHistoryTable.addHoles([id], operationsByPeerId: &self.currentOperationsByPeerId, unsentMessageOperations: &currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
    }
    
    fileprivate func fillHole(_ hole: MessageHistoryHole, fillType: HoleFill, tagMask: MessageTags?, messages: [StoreMessage]) {
        var operationsByPeerId: [PeerId: [MessageHistoryOperation]] = [:]
        self.messageHistoryTable.fillHole(hole.id, fillType: fillType, tagMask: tagMask, messages: messages, operationsByPeerId: &operationsByPeerId, unsentMessageOperations: &currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
        for (peerId, operations) in operationsByPeerId {
            if self.currentOperationsByPeerId[peerId] == nil {
                self.currentOperationsByPeerId[peerId] = operations
            } else {
                self.currentOperationsByPeerId[peerId]!.append(contentsOf: operations)
            }
            
            var filledMessageIndices: [MessageIndex: HoleFillDirection] = [:]
            for operation in operations {
                switch operation {
                    case let .InsertHole(hole):
                        filledMessageIndices[hole.maxIndex] = fillType.direction
                    case let .InsertMessage(message):
                        filledMessageIndices[MessageIndex(message)] = fillType.direction
                    default:
                        break
                }
            }
            
            if !filledMessageIndices.isEmpty {
                if self.currentFilledHolesByPeerId[peerId] == nil {
                    self.currentFilledHolesByPeerId[peerId] = filledMessageIndices
                } else {
                    for (messageIndex, direction) in filledMessageIndices {
                        self.currentFilledHolesByPeerId[peerId]![messageIndex] = direction
                    }
                }
            }
            
            if self.currentRemovedHolesByPeerId[peerId] == nil {
                self.currentRemovedHolesByPeerId[peerId] = [hole.maxIndex: fillType.direction]
            } else {
                self.currentRemovedHolesByPeerId[peerId]![hole.maxIndex] = fillType.direction
            }
        }
    }
    
    fileprivate func fillMultipleHoles(_ hole: MessageHistoryHole, fillType: HoleFill, tagMask: MessageTags?, messages: [StoreMessage]) {
        var operationsByPeerId: [PeerId: [MessageHistoryOperation]] = [:]
        self.messageHistoryTable.fillMultipleHoles(mainHoleId: hole.id, fillType: fillType, tagMask: tagMask, messages: messages, operationsByPeerId: &operationsByPeerId, unsentMessageOperations: &currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
        for (peerId, operations) in operationsByPeerId {
            if self.currentOperationsByPeerId[peerId] == nil {
                self.currentOperationsByPeerId[peerId] = operations
            } else {
                self.currentOperationsByPeerId[peerId]!.append(contentsOf: operations)
            }
            
            var filledMessageIndices: [MessageIndex: HoleFillDirection] = [:]
            for operation in operations {
                switch operation {
                case let .InsertHole(hole):
                    filledMessageIndices[hole.maxIndex] = fillType.direction
                case let .InsertMessage(message):
                    filledMessageIndices[MessageIndex(message)] = fillType.direction
                default:
                    break
                }
            }
            
            if !filledMessageIndices.isEmpty {
                if self.currentFilledHolesByPeerId[peerId] == nil {
                    self.currentFilledHolesByPeerId[peerId] = filledMessageIndices
                } else {
                    for (messageIndex, direction) in filledMessageIndices {
                        self.currentFilledHolesByPeerId[peerId]![messageIndex] = direction
                    }
                }
            }
            
            if self.currentRemovedHolesByPeerId[peerId] == nil {
                self.currentRemovedHolesByPeerId[peerId] = [hole.maxIndex: fillType.direction]
            } else {
                self.currentRemovedHolesByPeerId[peerId]![hole.maxIndex] = fillType.direction
            }
        }
    }
    
    fileprivate func replaceChatListHole(_ index: MessageIndex, hole: ChatListHole?) {
        self.chatListTable.replaceHole(index, hole: hole, operations: &self.currentChatListOperations)
    }
    
    fileprivate func deleteMessages(_ messageIds: [MessageId]) {
        self.messageHistoryTable.removeMessages(messageIds, operationsByPeerId: &self.currentOperationsByPeerId, unsentMessageOperations: &currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
    }
    
    fileprivate func deleteMessagesInRange(peerId: PeerId, namespace: MessageId.Namespace, minId: MessageId.Id, maxId: MessageId.Id) {
        self.messageHistoryTable.removeMessagesInRange(peerId: peerId, namespace: namespace, minId: minId, maxId: maxId, operationsByPeerId: &self.currentOperationsByPeerId, unsentMessageOperations: &currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
    }
    
    fileprivate func clearHistory(_ peerId: PeerId) {
        self.messageHistoryTable.clearHistory(peerId: peerId, operationsByPeerId: &self.currentOperationsByPeerId, unsentMessageOperations: &currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
    }
    
    fileprivate func removeAllMessagesWithAuthor(_ peerId: PeerId, authorId: PeerId) {
        self.messageHistoryTable.removeAllMessagesWithAuthor(peerId: peerId, authorId: authorId, operationsByPeerId: &self.currentOperationsByPeerId, unsentMessageOperations: &currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
    }
    
    fileprivate func resetIncomingReadStates(_ states: [PeerId: [MessageId.Namespace: PeerReadState]]) {
        self.messageHistoryTable.resetIncomingReadStates(states, operationsByPeerId: &self.currentOperationsByPeerId, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations)
    }
    
    fileprivate func confirmSynchronizedIncomingReadState(_ peerId: PeerId) {
        self.synchronizeReadStateTable.set(peerId, operation: nil, operations: &self.currentUpdatedSynchronizeReadStateOperations)
    }
    
    fileprivate func applyIncomingReadMaxId(_ messageId: MessageId) {
        self.messageHistoryTable.applyIncomingReadMaxId(messageId, operationsByPeerId: &self.currentOperationsByPeerId, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations)
    }
    
    fileprivate func applyOutgoingReadMaxId(_ messageId: MessageId) {
        self.messageHistoryTable.applyOutgoingReadMaxId(messageId, operationsByPeerId: &self.currentOperationsByPeerId, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations)
    }
    
    fileprivate func applyInteractiveReadMaxIndex(_ messageIndex: MessageIndex) -> [MessageId] {
        return self.messageHistoryTable.applyInteractiveMaxReadIndex(messageIndex, operationsByPeerId: &self.currentOperationsByPeerId, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations)
    }
    
    fileprivate func applyOutgoingReadMaxIndex(_ messageIndex: MessageIndex) -> [MessageId] {
        return self.messageHistoryTable.applyOutgoingReadMaxIndex(messageIndex, operationsByPeerId: &self.currentOperationsByPeerId, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations)
    }
    
    func fetchEarlierHistoryEntries(_ peerId: PeerId, index: MessageIndex?, count: Int, tagMask: MessageTags? = nil) -> [MutableMessageHistoryEntry] {
        let intermediateEntries: [IntermediateMessageHistoryEntry]
        if let tagMask = tagMask {
            intermediateEntries = self.messageHistoryTable.earlierEntries(tagMask, peerId: peerId, index: index, count: count, operationsByPeerId: &self.currentOperationsByPeerId, unsentMessageOperations: &self.currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
        } else {
            intermediateEntries = self.messageHistoryTable.earlierEntries(peerId, index: index, count: count, operationsByPeerId: &self.currentOperationsByPeerId, unsentMessageOperations: &self.currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
        }
        var entries: [MutableMessageHistoryEntry] = []
        for entry in intermediateEntries {
            switch entry {
                case let .Message(message):
                    entries.append(.IntermediateMessageEntry(message, nil, nil))
                case let .Hole(index):
                    entries.append(.HoleEntry(index, nil))
            }
        }
        return entries
    }
    
    func fetchAroundHistoryEntries(_ index: MessageIndex, count: Int, tagMask: MessageTags? = nil) -> (entries: [MutableMessageHistoryEntry], lower: MutableMessageHistoryEntry?, upper: MutableMessageHistoryEntry?) {
        
        let intermediateEntries: [IntermediateMessageHistoryEntry]
        let intermediateLower: IntermediateMessageHistoryEntry?
        let intermediateUpper: IntermediateMessageHistoryEntry?
        
        if let tagMask = tagMask {
            (intermediateEntries, intermediateLower, intermediateUpper) = self.messageHistoryTable.entriesAround(tagMask, index: index, count: count, operationsByPeerId: &self.currentOperationsByPeerId, unsentMessageOperations: &self.currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
        } else {
            (intermediateEntries, intermediateLower, intermediateUpper) = self.messageHistoryTable.entriesAround(index, count: count, operationsByPeerId: &self.currentOperationsByPeerId, unsentMessageOperations: &self.currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
        }
        
        var entries: [MutableMessageHistoryEntry] = []
        for entry in intermediateEntries {
            switch entry {
                case let .Message(message):
                    entries.append(.IntermediateMessageEntry(message, nil, nil))
                case let .Hole(index):
                    entries.append(.HoleEntry(index, nil))
            }
        }
        
        var lower: MutableMessageHistoryEntry?
        if let intermediateLower = intermediateLower {
            switch intermediateLower {
                case let .Message(message):
                    lower = .IntermediateMessageEntry(message, nil, nil)
                case let .Hole(index):
                    lower = .HoleEntry(index, nil)
            }
        }
        
        var upper: MutableMessageHistoryEntry?
        if let intermediateUpper = intermediateUpper {
            switch intermediateUpper {
                case let .Message(message):
                    upper = .IntermediateMessageEntry(message, nil, nil)
                case let .Hole(index):
                    upper = .HoleEntry(index, nil)
            }
        }
        
        return (entries: entries, lower: lower, upper: upper)
    }
    
    func fetchLaterHistoryEntries(_ peerId: PeerId, index: MessageIndex?, count: Int, tagMask: MessageTags? = nil) -> [MutableMessageHistoryEntry] {
        let intermediateEntries: [IntermediateMessageHistoryEntry]
        if let tagMask = tagMask {
            intermediateEntries = self.messageHistoryTable.laterEntries(tagMask, peerId: peerId, index: index, count: count, operationsByPeerId: &self.currentOperationsByPeerId, unsentMessageOperations: &self.currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
        } else {
            intermediateEntries = self.messageHistoryTable.laterEntries(peerId, index: index, count: count, operationsByPeerId: &self.currentOperationsByPeerId, unsentMessageOperations: &self.currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
        }
        var entries: [MutableMessageHistoryEntry] = []
        for entry in intermediateEntries {
            switch entry {
            case let .Message(message):
                entries.append(.IntermediateMessageEntry(message, nil, nil))
            case let .Hole(index):
                entries.append(.HoleEntry(index, nil))
            }
        }
        return entries
    }
    
    private func fetchAroundChatEntries(_ index: ChatListIndex, count: Int) -> (entries: [MutableChatListEntry], earlier: MutableChatListEntry?, later: MutableChatListEntry?) {
        let (intermediateEntries, intermediateLower, intermediateUpper) = self.chatListTable.entriesAround(index, messageHistoryTable: self.messageHistoryTable, peerChatInterfaceStateTable: self.peerChatInterfaceStateTable, count: count)
        var entries: [MutableChatListEntry] = []
        var lower: MutableChatListEntry?
        var upper: MutableChatListEntry?
        
        for entry in intermediateEntries {
            switch entry {
                case let .Message(index, message, embeddedState):
                    entries.append(.IntermediateMessageEntry(index, message, self.readStateTable.getCombinedState(index.messageIndex.id.peerId), embeddedState))
                case let .Hole(hole):
                    entries.append(.HoleEntry(hole))
            }
        }
        
        if let intermediateLower = intermediateLower {
            switch intermediateLower {
                case let .Message(index, message, embeddedState):
                    lower = .IntermediateMessageEntry(index, message, self.readStateTable.getCombinedState(index.messageIndex.id.peerId), embeddedState)
                case let .Hole(hole):
                    lower = .HoleEntry(hole)
            }
        }
        
        if let intermediateUpper = intermediateUpper {
            switch intermediateUpper {
                case let .Message(index, message, embeddedState):
                    upper = .IntermediateMessageEntry(index, message, self.readStateTable.getCombinedState(index.messageIndex.id.peerId), embeddedState)
                case let .Hole(hole):
                    upper = .HoleEntry(hole)
            }
        }
        
        return (entries, lower, upper)
    }
    
    private func fetchEarlierChatEntries(_ index: ChatListIndex?, count: Int) -> [MutableChatListEntry] {
        let intermediateEntries = self.chatListTable.earlierEntries(index, messageHistoryTable: self.messageHistoryTable, peerChatInterfaceStateTable: self.peerChatInterfaceStateTable, count: count)
        var entries: [MutableChatListEntry] = []
        for entry in intermediateEntries {
            switch entry {
                case let .Message(index, message, embeddedState):
                    entries.append(.IntermediateMessageEntry(index, message, self.readStateTable.getCombinedState(index.messageIndex.id.peerId), embeddedState))
                case let .Hole(hole):
                    entries.append(.HoleEntry(hole))
            }
        }
        return entries
    }
    
    private func fetchLaterChatEntries(_ index: ChatListIndex?, count: Int) -> [MutableChatListEntry] {
        let intermediateEntries = self.chatListTable.laterEntries(index, messageHistoryTable: self.messageHistoryTable, peerChatInterfaceStateTable: self.peerChatInterfaceStateTable, count: count)
        var entries: [MutableChatListEntry] = []
        for entry in intermediateEntries {
            switch entry {
                case let .Message(index, message, embeddedState):
                    entries.append(.IntermediateMessageEntry(index, message, self.readStateTable.getCombinedState(index.messageIndex.id.peerId), embeddedState))
                case let .Hole(index):
                    entries.append(.HoleEntry(index))
            }
        }
        return entries
    }
    
    private func fetchAnchorIndex(id: MessageId) -> InternalMessageHistoryAnchorIndex? {
        return self.messageHistoryTable.anchorIndex(id)
    }
    
    func renderIntermediateMessage(_ message: IntermediateMessage) -> Message {
        let renderedMessage = self.messageHistoryTable.renderMessage(message, peerTable: self.peerTable)
        
        return renderedMessage
    }
    
    private func afterBegin() {
        let currentTransactionStateVersion = self.metadataTable.transactionStateVersion()
        if currentTransactionStateVersion != self.transactionStateVersion {
            for table in self.tables {
                table.clearMemoryCache()
            }
            self.viewTracker.refreshViewsDueToExternalTransaction(postbox: self, fetchAroundChatEntries: self.fetchAroundChatEntries, fetchAroundHistoryEntries: self.fetchAroundHistoryEntries, fetchUnsentMessageIds: {
                return self.messageHistoryUnsentTable.get()
            }, fetchSynchronizePeerReadStateOperations: {
                return self.synchronizeReadStateTable.get(getCombinedPeerReadState: { peerId in
                    return self.readStateTable.getCombinedState(peerId)
                })
            })
            self.transactionStateVersion = currentTransactionStateVersion
            
            self.masterClientId.set(.single(self.metadataTable.masterClientId()))
        }
    }
    
    private func beforeCommit() -> (updatedTransactionStateVersion: Int64?, updatedMasterClientId: Int64?) {
        self.chatListTable.replay(historyOperationsByPeerId: self.currentOperationsByPeerId, updatedPeerChatListEmbeddedStates: self.currentUpdatedPeerChatListEmbeddedStates, updatedChatListInclusions: self.currentUpdatedChatListInclusions, messageHistoryTable: self.messageHistoryTable, peerChatInterfaceStateTable: self.peerChatInterfaceStateTable, operations: &self.currentChatListOperations)
        
        self.peerChatTopTaggedMessageIdsTable.replay(historyOperationsByPeerId: self.currentOperationsByPeerId)
        
        let transactionUnreadCountDeltas = self.readStateTable.transactionUnreadCountDeltas()
        let peerIdsWithUpdatedCombinedReadStates = self.readStateTable.transactionPeerIdsWithUpdatedCombinedReadStates()
        let transactionParticipationInTotalUnreadCountUpdates = self.peerNotificationSettingsTable.transactionParticipationInTotalUnreadCountUpdates()
        self.chatListIndexTable.commitWithTransactionUnreadCountDeltas(transactionUnreadCountDeltas, transactionParticipationInTotalUnreadCountUpdates: transactionParticipationInTotalUnreadCountUpdates, getPeer: { peerId in
            return self.peerTable.get(peerId)
        }, updatedTotalUnreadCount: &self.currentUpdatedTotalUnreadCount)
        
        let transaction = PostboxTransaction(currentUpdatedState: self.currentUpdatedState, currentOperationsByPeerId: self.currentOperationsByPeerId, peerIdsWithFilledHoles: self.currentFilledHolesByPeerId, removedHolesByPeerId: self.currentRemovedHolesByPeerId, chatListOperations: self.currentChatListOperations, currentUpdatedPeers: self.currentUpdatedPeers, currentUpdatedPeerNotificationSettings: self.currentUpdatedPeerNotificationSettings, currentUpdatedCachedPeerData: self.currentUpdatedCachedPeerData, currentUpdatedPeerPresences: currentUpdatedPeerPresences, currentUpdatedPeerChatListEmbeddedStates: self.currentUpdatedPeerChatListEmbeddedStates, currentUpdatedTotalUnreadCount: self.currentUpdatedTotalUnreadCount, peerIdsWithUpdatedUnreadCounts: Set(transactionUnreadCountDeltas.keys), peerIdsWithUpdatedCombinedReadStates: peerIdsWithUpdatedCombinedReadStates, currentPeerMergedOperationLogOperations: self.currentPeerMergedOperationLogOperations, currentTimestampBasedMessageAttributesOperations: self.currentTimestampBasedMessageAttributesOperations, unsentMessageOperations: self.currentUnsentOperations, updatedSynchronizePeerReadStateOperations: self.currentUpdatedSynchronizeReadStateOperations, currentPreferencesOperations: self.currentPreferencesOperations, currentOrderedItemListOperations: self.currentOrderedItemListOperations, currentItemCollectionItemsOperations: self.currentItemCollectionItemsOperations, currentItemCollectionInfosOperations: self.currentItemCollectionInfosOperations, currentUpdatedPeerChatStates: self.currentUpdatedPeerChatStates, updatedAccessChallengeData: self.currentUpdatedAccessChallengeData, currentGlobalTagsOperations: self.currentGlobalTagsOperations, updatedMedia: self.currentUpdatedMedia, replaceRemoteContactCount: self.currentReplaceRemoteContactCount, replaceContactPeerIds: self.currentReplacedContactPeerIds, currentPendingMessageActionsOperations: self.currentPendingMessageActionsOperations, currentUpdatedMessageActionsSummaries: self.currentUpdatedMessageActionsSummaries, currentUpdatedMessageTagSummaries: self.currentUpdatedMessageTagSummaries, currentInvalidateMessageTagSummaries: self.currentInvalidateMessageTagSummaries, currentUpdatedPendingPeerNotificationSettings: self.currentUpdatedPendingPeerNotificationSettings, currentUpdatedMasterClientId: currentUpdatedMasterClientId)
        var updatedTransactionState: Int64?
        var updatedMasterClientId: Int64?
        if !transaction.isEmpty {
            self.viewTracker.updateViews(postbox: self, transaction: transaction)
            self.transactionStateVersion = self.metadataTable.incrementTransactionStateVersion()
            updatedTransactionState = self.transactionStateVersion
            
            if let currentUpdatedMasterClientId = self.currentUpdatedMasterClientId {
                self.metadataTable.setMasterClientId(currentUpdatedMasterClientId)
                updatedMasterClientId = currentUpdatedMasterClientId
            }
        }
        
        self.currentOperationsByPeerId.removeAll()
        self.currentUpdatedChatListInclusions.removeAll()
        self.currentFilledHolesByPeerId.removeAll()
        self.currentRemovedHolesByPeerId.removeAll()
        self.currentUpdatedPeers.removeAll()
        self.currentChatListOperations.removeAll()
        self.currentUnsentOperations.removeAll()
        self.currentUpdatedSynchronizeReadStateOperations.removeAll()
        self.currentGlobalTagsOperations.removeAll()
        self.currentUpdatedMedia.removeAll()
        self.currentReplaceRemoteContactCount = nil
        self.currentReplacedContactPeerIds = nil
        self.currentUpdatedMasterClientId = nil
        self.currentUpdatedPeerNotificationSettings.removeAll()
        self.currentUpdatedCachedPeerData.removeAll()
        self.currentUpdatedPeerPresences.removeAll()
        self.currentUpdatedPeerChatListEmbeddedStates.removeAll()
        self.currentUpdatedTotalUnreadCount = nil
        self.currentPeerMergedOperationLogOperations.removeAll()
        self.currentTimestampBasedMessageAttributesOperations.removeAll()
        self.currentPreferencesOperations.removeAll()
        self.currentOrderedItemListOperations.removeAll()
        self.currentItemCollectionItemsOperations.removeAll()
        self.currentItemCollectionInfosOperations.removeAll()
        self.currentUpdatedPeerChatStates.removeAll()
        self.currentUpdatedAccessChallengeData = nil
        self.currentPendingMessageActionsOperations.removeAll()
        self.currentUpdatedMessageActionsSummaries.removeAll()
        self.currentUpdatedMessageTagSummaries.removeAll()
        self.currentInvalidateMessageTagSummaries.removeAll()
        self.currentUpdatedPendingPeerNotificationSettings.removeAll()
        
        for table in self.tables {
            table.beforeCommit()
        }
        
        if let currentUpdatedState = self.currentUpdatedState {
            self.statePipe.putNext(currentUpdatedState)
        }
        self.currentUpdatedState = nil
        
        return (updatedTransactionState, updatedMasterClientId)
    }
    
    fileprivate func messageIdsForGlobalIds(_ ids: [Int32]) -> [MessageId] {
        var result: [MessageId] = []
        for globalId in ids {
            if let id = self.globalMessageIdsTable.get(globalId) {
                result.append(id)
            }
        }
        return result
    }
    
    fileprivate func messageIdForGloballyUniqueMessageId(peerId: PeerId, id: Int64) -> MessageId? {
        return self.globallyUniqueMessageIdsTable.get(peerId: peerId, globallyUniqueId: id)
    }
    
    fileprivate func updatePeers(_ peers: [Peer], update: (Peer?, Peer) -> Peer?) {
        for peer in peers {
            let currentPeer = self.peerTable.get(peer.id)
            if let updatedPeer = update(currentPeer, peer) {
                self.peerTable.set(updatedPeer)
                self.currentUpdatedPeers[updatedPeer.id] = updatedPeer
                var previousIndexNameWasEmpty = true
                
                if let currentPeer = currentPeer {
                    if !currentPeer.indexName.isEmpty {
                        previousIndexNameWasEmpty = false
                    }
                }
                
                let indexNameIsEmpty = updatedPeer.indexName.isEmpty
                
                if !previousIndexNameWasEmpty || !indexNameIsEmpty {
                    if currentPeer?.indexName != updatedPeer.indexName {
                        self.peerNameIndexTable.markPeerNameUpdated(peerId: peer.id, name: updatedPeer.indexName)
                        for reverseAssociatedPeerId in self.reverseAssociatedPeerTable.get(peerId: peer.id) {
                            self.peerNameIndexTable.markPeerNameUpdated(peerId: reverseAssociatedPeerId, name: updatedPeer.indexName)
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func getPeerChatListInclusion(_ id: PeerId) -> PeerChatListInclusion {
        if let inclusion = self.currentUpdatedChatListInclusions[id] {
            return inclusion
        } else {
            return self.chatListIndexTable.get(id).inclusion
        }
    }
    
    fileprivate func updatePeerChatListInclusion(_ id: PeerId, inclusion: PeerChatListInclusion) {
        self.chatListTable.updateInclusion(peerId: id, updatedChatListInclusions: &self.currentUpdatedChatListInclusions, { _ in
            return inclusion
        })
    }
    
    fileprivate func setPinnedPeerIds(_ peerIds: [PeerId]) {
        self.chatListTable.setPinnedPeerIds(peerIds: peerIds, updatedChatListInclusions: &self.currentUpdatedChatListInclusions)
    }
    
    fileprivate func updateCurrentPeerNotificationSettings(_ notificationSettings: [PeerId: PeerNotificationSettings]) {
        for (peerId, settings) in notificationSettings {
            if let updated = self.peerNotificationSettingsTable.setCurrent(id: peerId, settings: settings) {
                self.currentUpdatedPeerNotificationSettings[peerId] = updated
            }
        }
    }
    
    fileprivate func updatePendingPeerNotificationSettings(peerId: PeerId, settings: PeerNotificationSettings?) {
        if let updated = self.peerNotificationSettingsTable.setPending(id: peerId, settings: settings, updatedSettings: &self.currentUpdatedPendingPeerNotificationSettings) {
            self.currentUpdatedPeerNotificationSettings[peerId] = updated
        }
    }
    
    fileprivate func resetAllPeerNotificationSettings(_ notificationSettings: PeerNotificationSettings) {
        for peerId in self.peerNotificationSettingsTable.resetAll(to: notificationSettings, updatedSettings: &self.currentUpdatedPendingPeerNotificationSettings) {
            self.currentUpdatedPeerNotificationSettings[peerId] = notificationSettings
        }
    }
    
    fileprivate func updatePeerCachedData(peerIds: Set<PeerId>, update: (PeerId, CachedPeerData?) -> CachedPeerData?) {
        for peerId in peerIds {
            let currentData = self.cachedPeerDataTable.get(peerId)
            if let updatedData = update(peerId, currentData) {
                self.cachedPeerDataTable.set(id: peerId, data: updatedData)
                self.currentUpdatedCachedPeerData[peerId] = updatedData
            }
        }
    }
    
    fileprivate func updatePeerPresences(_ peerPresences: [PeerId: PeerPresence]) {
        for (peerId, presence) in peerPresences {
            let currentPresence = self.peerPresenceTable.get(peerId)
            if currentPresence == nil || !(currentPresence!.isEqual(to: presence)) {
                self.peerPresenceTable.set(id: peerId, presence: presence)
                self.currentUpdatedPeerPresences[peerId] = presence
            }
        }
    }
    
    fileprivate func setPeerChatState(_ id: PeerId, state: PeerChatState) {
        self.peerChatStateTable.set(id, state: state)
        self.currentUpdatedPeerChatStates.insert(id)
    }
    
    fileprivate func updatePeerChatInterfaceState(_ id: PeerId, update: (PeerChatInterfaceState?) -> (PeerChatInterfaceState?)) {
        let updatedState = update(self.peerChatInterfaceStateTable.get(id))
        let (_, updatedEmbeddedState) = self.peerChatInterfaceStateTable.set(id, state: updatedState)
        if updatedEmbeddedState {
            self.currentUpdatedPeerChatListEmbeddedStates[id] = updatedState?.chatListEmbeddedState
        }
    }
    
    fileprivate func replaceRemoteContactCount(_ count: Int32) {
        self.metadataTable.setRemoteContactCount(count)
        self.currentReplaceRemoteContactCount = count
    }
    
    fileprivate func replaceContactPeerIds(_ peerIds: Set<PeerId>) {
        self.contactsTable.replace(peerIds)
        
        self.currentReplacedContactPeerIds = peerIds
    }
    
    fileprivate func replaceRecentPeerIds(_ peerIds: [PeerId]) {
        self.peerRatingTable.replace(items: peerIds)
    }
    
    fileprivate func updateMessage(_ id: MessageId, update: (Message) -> PostboxUpdateMessage) {
        if let indexEntry = self.messageHistoryIndexTable.get(id), let intermediateMessage = self.messageHistoryTable.getMessage(indexEntry.index) {
            let message = self.renderIntermediateMessage(intermediateMessage)
            if case let .update(updatedMessage) = update(message) {
                self.messageHistoryTable.updateMessage(id, message: updatedMessage, operationsByPeerId: &self.currentOperationsByPeerId, unsentMessageOperations: &self.currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
            }
        }
    }
    
    fileprivate func offsetPendingMessagesTimestamps(lowerBound: MessageId, timestamp: Int32) {
        self.messageHistoryTable.offsetPendingMessagesTimestamps(lowerBound: lowerBound, timestamp: timestamp, operationsByPeerId: &self.currentOperationsByPeerId, unsentMessageOperations: &self.currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
    }
    
    fileprivate func updateMessageGroupingKeysAtomically(_ ids: [MessageId], groupingKey: Int64) {
        self.messageHistoryTable.updateMessageGroupingKeysAtomically(ids: ids, groupingKey: groupingKey, operationsByPeerId: &self.currentOperationsByPeerId, unsentMessageOperations: &self.currentUnsentOperations, updatedPeerReadStateOperations: &self.currentUpdatedSynchronizeReadStateOperations, globalTagsOperations: &self.currentGlobalTagsOperations, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries, updatedMessageTagSummaries: &self.currentUpdatedMessageTagSummaries, invalidateMessageTagSummaries: &self.currentInvalidateMessageTagSummaries)
    }
    
    fileprivate func updateMedia(_ id: MediaId, update: Media?) {
        self.messageHistoryTable.updateMedia(id, media: update, operationsByPeerId: &self.currentOperationsByPeerId, updatedMedia: &self.currentUpdatedMedia)
    }
    
    fileprivate func replaceItemCollections(namespace: ItemCollectionId.Namespace, itemCollections: [(ItemCollectionId, ItemCollectionInfo, [ItemCollectionItem])]) {
        var infos: [(ItemCollectionId, ItemCollectionInfo)] = []
        for (id, info, items) in itemCollections {
            infos.append((id, info))
            self.itemCollectionItemTable.replaceItems(collectionId: id, items: items)
            if self.currentItemCollectionItemsOperations[id] == nil {
                self.currentItemCollectionItemsOperations[id] = []
            }
            self.currentItemCollectionItemsOperations[id]!.append(.replaceItems)
        }
        self.itemCollectionInfoTable.replaceInfos(namespace: namespace, infos: infos)
        self.currentItemCollectionInfosOperations.append(.replaceInfos(namespace))
    }
    
    fileprivate func replaceItemCollectionInfos(namespace: ItemCollectionId.Namespace, itemCollectionInfos: [(ItemCollectionId, ItemCollectionInfo)]) {
        self.itemCollectionInfoTable.replaceInfos(namespace: namespace, infos: itemCollectionInfos)
        self.currentItemCollectionInfosOperations.append(.replaceInfos(namespace))
    }
    
    fileprivate func replaceItemCollectionItems(collectionId: ItemCollectionId, items: [ItemCollectionItem]) {
        self.itemCollectionItemTable.replaceItems(collectionId: collectionId, items: items)
        if self.currentItemCollectionItemsOperations[collectionId] == nil {
            self.currentItemCollectionItemsOperations[collectionId] = []
        }
        self.currentItemCollectionItemsOperations[collectionId]!.append(.replaceItems)
    }
    
    fileprivate func removeItemCollection(collectionId: ItemCollectionId) {
        var infos = self.itemCollectionInfoTable.getInfos(namespace: collectionId.namespace)
        if let index = infos.index(where: { $0.1 == collectionId }) {
            infos.remove(at: index)
            self.replaceItemCollectionInfos(namespace: collectionId.namespace, itemCollectionInfos: infos.map { ($0.1, $0.2) })
        }
        self.replaceItemCollectionItems(collectionId: collectionId, items: [])
    }
    
    fileprivate func filterStoredMessageIds(_ messageIds: Set<MessageId>) -> Set<MessageId> {
        var filteredIds = Set<MessageId>()
        
        for id in messageIds {
            if self.messageHistoryIndexTable.exists(id) {
                filteredIds.insert(id)
            }
        }
        
        return filteredIds
    }
    
    fileprivate func storedMessageId(peerId: PeerId, namespace: MessageId.Namespace, timestamp: Int32) -> MessageId? {
        if let id = self.messageHistoryTable.findMessageId(peerId: peerId, timestamp: timestamp), id.namespace == namespace {
            return id
        } else {
            return nil
        }
    }
    
    fileprivate func putItemCacheEntry(id: ItemCacheEntryId, entry: PostboxCoding, collectionSpec: ItemCacheCollectionSpec) {
        self.itemCacheTable.put(id: id, entry: entry, metaTable: self.itemCacheMetaTable)
    }
    
    fileprivate func retrieveItemCacheEntry(id: ItemCacheEntryId) -> PostboxCoding? {
        return self.itemCacheTable.retrieve(id: id, metaTable: self.itemCacheMetaTable)
    }
    
    fileprivate func removeItemCacheEntry(id: ItemCacheEntryId) {
        self.itemCacheTable.remove(id: id, metaTable: self.itemCacheMetaTable)
    }
    
    fileprivate func replaceGlobalMessageTagsHole(modifier: Modifier, globalTags: GlobalMessageTags, index: MessageIndex, with updatedIndex: MessageIndex?, messages: [StoreMessage]) {
        var allTagsMatch = true
        for tag in globalTags {
            self.globalMessageHistoryTagsTable.ensureInitialized(tag)
            
            if let entry = self.globalMessageHistoryTagsTable.get(tag, index: index), case .hole = entry {
                
            } else {
                allTagsMatch = false
            }
        }
        if allTagsMatch {
            for tag in globalTags {
                self.globalMessageHistoryTagsTable.remove(tag, index: index)
                self.currentGlobalTagsOperations.append(.remove([(tag, index)]))
                
                if let updatedIndex = updatedIndex {
                    self.globalMessageHistoryTagsTable.addHole(tag, index: updatedIndex)
                    self.currentGlobalTagsOperations.append(.insertHole(tag, updatedIndex))
                }
            }
            
            let _ = self.addMessages(modifier: modifier, messages: messages, location: .Random)
        }
    }
    
    fileprivate func setPendingMessageAction(type: PendingMessageActionType, id: MessageId, action: PendingMessageActionData?) {
        self.messageHistoryTable.setPendingMessageAction(id: id, type: type, action: action, pendingActionsOperations: &self.currentPendingMessageActionsOperations, updatedMessageActionsSummaries: &self.currentUpdatedMessageActionsSummaries)
    }
    
    fileprivate func getPendingMessageAction(type: PendingMessageActionType, id: MessageId) -> PendingMessageActionData? {
        return self.pendingMessageActionsTable.getAction(id: id, type: type)
    }
    
    fileprivate func replaceMessageTagSummary(peerId: PeerId, tagMask: MessageTags, namespace: MessageId.Namespace, count: Int32, maxId: MessageId.Id) {
        let key = MessageHistoryTagsSummaryKey(tag: tagMask, peerId: peerId, namespace: namespace)
        self.messageHistoryTagsSummaryTable.replace(key: key, count: count, maxId: maxId, updatedSummaries: &self.currentUpdatedMessageTagSummaries)
    }
    
    fileprivate func searchMessages(peerId: PeerId?, query: String, tags: MessageTags?) -> [Message] {
        var result: [Message] = []
        for messageId in self.textIndexTable.search(peerId: peerId, text: query, tags: tags) {
            if let indexEntry = self.messageHistoryIndexTable.get(messageId), case let .Message(index) = indexEntry, let message = self.messageHistoryTable.getMessage(index) {
                result.append(self.messageHistoryTable.renderMessage(message, peerTable: self.peerTable))
            } else {
                assertionFailure()
            }
        }
        return result
    }
    
    private func internalTransaction<T>(_ f: (Modifier) -> T) -> (result: T, updatedTransactionStateVersion: Int64?, updatedMasterClientId: Int64?) {
        self.valueBox.begin()
        self.afterBegin()
        let modifier = Modifier(postbox: self)
        let result = f(modifier)
        modifier.disposed = true
        let (updatedTransactionState, updatedMasterClientId) = self.beforeCommit()
        self.valueBox.commit()
        
        return (result, updatedTransactionState, updatedMasterClientId)
    }
    
    public func transactionSignal<T, E>(userInteractive: Bool = false, _ f: @escaping(Subscriber<T, E>, Modifier) -> Disposable) -> Signal<T, E> {
        return Signal { subscriber in
            let disposable = MetaDisposable()
            
            let f: () -> Void = {
                let (_, updatedTransactionState, updatedMasterClientId) = self.internalTransaction({ modifier in
                    disposable.set(f(subscriber, modifier))
                })
                
                if updatedTransactionState != nil || updatedMasterClientId != nil {
                    //self.pipeNotifier.notify()
                }
                
                if let updatedMasterClientId = updatedMasterClientId {
                    self.masterClientId.set(.single(updatedMasterClientId))
                }
            }
            if userInteractive {
                self.queue.justDispatchWithQoS(qos: DispatchQoS.userInteractive, f)
            } else {
                self.queue.justDispatch(f)
            }
            
            return disposable
        }
    }
    
    public func modify<T>(userInteractive: Bool = false, _ f: @escaping(Modifier) -> T) -> Signal<T, NoError> {
        return Signal { subscriber in
            let f: () -> Void = {
                let (result, updatedTransactionState, updatedMasterClientId) = self.internalTransaction({ modifier in
                    return f(modifier)
                })
                
                if updatedTransactionState != nil || updatedMasterClientId != nil {
                    //self.pipeNotifier.notify()
                }
                
                if let updatedMasterClientId = updatedMasterClientId {
                    self.masterClientId.set(.single(updatedMasterClientId))
                }
                
                subscriber.putNext(result)
                subscriber.putCompletion()
            }
            if userInteractive {
                self.queue.justDispatchWithQoS(qos: DispatchQoS.userInteractive, f)
            } else {
                self.queue.justDispatch(f)
            }
            return EmptyDisposable
        }
    }
    
    public func aroundMessageOfInterestHistoryViewForPeerId(_ peerId: PeerId, count: Int, clipHoles: Bool, topTaggedMessageIdNamespaces: Set<MessageId.Namespace>, tagMask: MessageTags?, orderStatistics: MessageHistoryViewOrderStatistics, additionalData: [AdditionalMessageHistoryViewData]) -> Signal<(MessageHistoryView, ViewUpdateType, InitialMessageHistoryData?), NoError> {
        return self.transactionSignal(userInteractive: true, { subscriber, modifier in
            var peerIds: MessageHistoryViewPeerIds = .associated(peerId, nil)
            if let associatedPeerId = self.cachedPeerDataTable.get(peerId)?.associatedHistoryPeerId, associatedPeerId != peerId {
                peerIds = .associated(peerId, associatedPeerId)
            }
            
            var index: InternalMessageHistoryAnchorIndex = .upperBound
            switch peerIds {
                case let .single(peerId):
                    if let (maxReadIndex, _) = self.messageHistoryTable.maxReadIndex(peerId) {
                        index = maxReadIndex
                    } else if let scrollIndex = self.peerChatInterfaceStateTable.get(peerId)?.historyScrollMessageIndex {
                        index = .message(index: scrollIndex, exact: true)
                    }
                case .associated, .multiple:
                    var ids: [PeerId] = []
                    switch peerIds {
                        case let .single(id):
                            ids.append(id)
                        case let .associated(mainId, associatedId):
                            ids.append(mainId)
                            if let associatedId = associatedId {
                                ids.append(associatedId)
                            }
                        case let .multiple(multipleIds):
                            ids.append(contentsOf: multipleIds)
                    }
                    
                    var minIndexWithUnreadMessages: InternalMessageHistoryAnchorIndex?
                    var maxScrollIndex: InternalMessageHistoryAnchorIndex?
                    var i = 0
                    for peerId in ids {
                        if let (maxReadIndex, unreadCount) = self.messageHistoryTable.maxReadIndex(peerId) {
                            if unreadCount > 0 {
                                if let current = minIndexWithUnreadMessages {
                                    if current > maxReadIndex {
                                        minIndexWithUnreadMessages = maxReadIndex
                                    }
                                } else {
                                    minIndexWithUnreadMessages = maxReadIndex
                                }
                            }
                        }
                        if i == 0, let scrollIndex = self.peerChatInterfaceStateTable.get(peerId)?.historyScrollMessageIndex {
                            maxScrollIndex = .message(index: scrollIndex, exact: true)
                        }
                        
                        i += 1
                    }
                    if let minIndexWithUnreadMessages = minIndexWithUnreadMessages {
                        index = minIndexWithUnreadMessages
                    } else if let maxScrollIndex = maxScrollIndex {
                        index = maxScrollIndex
                    }
            }
            var unreadIndex: MessageIndex?
            if case let .message(index, _) = index {
                unreadIndex = index
            }
            return self.syncAroundMessageHistoryViewForPeerId(subscriber: subscriber, peerIds: peerIds, count: count, clipHoles: clipHoles, index: index, anchorIndex: index, unreadIndex: unreadIndex, fixedCombinedReadState: nil, topTaggedMessageIdNamespaces: topTaggedMessageIdNamespaces, tagMask: tagMask, orderStatistics: orderStatistics, additionalData: additionalData)
        })
    }
    
    public func aroundIdMessageHistoryViewForPeerId(_ peerId: PeerId, count: Int, clipHoles: Bool, messageId: MessageId, topTaggedMessageIdNamespaces: Set<MessageId.Namespace>, tagMask: MessageTags?, orderStatistics: MessageHistoryViewOrderStatistics, additionalData: [AdditionalMessageHistoryViewData] = []) -> Signal<(MessageHistoryView, ViewUpdateType, InitialMessageHistoryData?), NoError> {
        return self.transactionSignal { subscriber, modifier in
            var peerIds: MessageHistoryViewPeerIds = .associated(peerId, nil)
            if let associatedPeerId = self.cachedPeerDataTable.get(peerId)?.associatedHistoryPeerId, associatedPeerId != peerId {
                peerIds = .associated(peerId, associatedPeerId)
            }
            
            var index: InternalMessageHistoryAnchorIndex = .upperBound
            if let anchorIndex = self.messageHistoryTable.anchorIndex(messageId) {
                index = anchorIndex
            }
            var unreadIndex: MessageIndex?
            if case let .message(index, _) = index {
                unreadIndex = index
            }
            return self.syncAroundMessageHistoryViewForPeerId(subscriber: subscriber, peerIds: peerIds, count: count, clipHoles: clipHoles, index: index, anchorIndex: index, unreadIndex: unreadIndex, fixedCombinedReadState: nil, topTaggedMessageIdNamespaces: topTaggedMessageIdNamespaces, tagMask: tagMask, orderStatistics: orderStatistics, additionalData: additionalData)
        }
    }
    
    public func aroundMessageHistoryViewForPeerId(_ peerId: PeerId, index: MessageHistoryAnchorIndex, anchorIndex: MessageHistoryAnchorIndex, count: Int, clipHoles: Bool, fixedCombinedReadState: CombinedPeerReadState?, topTaggedMessageIdNamespaces: Set<MessageId.Namespace>, tagMask: MessageTags?, orderStatistics: MessageHistoryViewOrderStatistics, additionalData: [AdditionalMessageHistoryViewData] = []) -> Signal<(MessageHistoryView, ViewUpdateType, InitialMessageHistoryData?), NoError> {
        return self.transactionSignal { subscriber, modifier in
            var peerIds: MessageHistoryViewPeerIds = .associated(peerId, nil)
            if let associatedPeerId = self.cachedPeerDataTable.get(peerId)?.associatedHistoryPeerId, associatedPeerId != peerId {
                peerIds = .associated(peerId, associatedPeerId)
            }
            
            return self.syncAroundMessageHistoryViewForPeerId(subscriber: subscriber, peerIds: peerIds, count: count, clipHoles: clipHoles, index: InternalMessageHistoryAnchorIndex(index), anchorIndex: InternalMessageHistoryAnchorIndex(anchorIndex), unreadIndex: nil, fixedCombinedReadState: fixedCombinedReadState, topTaggedMessageIdNamespaces: topTaggedMessageIdNamespaces, tagMask: tagMask, orderStatistics: orderStatistics, additionalData: additionalData)
        }
    }
    
    private func syncAroundMessageHistoryViewForPeerId(subscriber: Subscriber<(MessageHistoryView, ViewUpdateType, InitialMessageHistoryData?), NoError>, peerIds: MessageHistoryViewPeerIds, count: Int, clipHoles: Bool, index: InternalMessageHistoryAnchorIndex, anchorIndex: InternalMessageHistoryAnchorIndex, unreadIndex: MessageIndex?, fixedCombinedReadState: CombinedPeerReadState?, topTaggedMessageIdNamespaces: Set<MessageId.Namespace>, tagMask: MessageTags?, orderStatistics: MessageHistoryViewOrderStatistics, additionalData: [AdditionalMessageHistoryViewData]) -> Disposable {
        var topTaggedMessages: [MessageId.Namespace: MessageHistoryTopTaggedMessage?] = [:]
        switch peerIds {
            case .single, .associated:
                let peerId = peerIds.peerIds[0]
                for namespace in topTaggedMessageIdNamespaces {
                    if let messageId = self.peerChatTopTaggedMessageIdsTable.get(peerId: peerId, namespace: namespace) {
                        if let indexEntry = self.messageHistoryIndexTable.get(messageId), case let .Message(index) = indexEntry {
                            if let message = self.messageHistoryTable.getMessage(index) {
                                topTaggedMessages[namespace] = MessageHistoryTopTaggedMessage.intermediate(message)
                            } else {
                                assertionFailure()
                            }
                        } else {
                            assertionFailure()
                        }
                    } else {
                        let item: MessageHistoryTopTaggedMessage? = nil
                        topTaggedMessages[namespace] = item
                    }
                }
            default:
                break
        }
        
        var additionalDataEntries: [AdditionalMessageHistoryViewDataEntry] = []
        for data in additionalData {
            switch data {
                case let .cachedPeerData(peerId):
                    additionalDataEntries.append(.cachedPeerData(peerId, self.cachedPeerDataTable.get(peerId)))
                case let .cachedPeerDataMessages(peerId):
                    var messages: [MessageId: Message] = [:]
                    if let messageIds = self.cachedPeerDataTable.get(peerId)?.messageIds {
                        for id in messageIds {
                            if let message = self.getMessage(id) {
                                messages[id] = message
                            }
                        }
                    }
                    additionalDataEntries.append(.cachedPeerDataMessages(peerId, messages))
                case let .peerChatState(peerId):
                    additionalDataEntries.append(.peerChatState(peerId, self.peerChatStateTable.get(peerId) as? PeerChatState))
                case .totalUnreadCount:
                    additionalDataEntries.append(.totalUnreadCount(self.messageHistoryMetadataTable.getChatListTotalUnreadCount()))
                case let .peerNotificationSettings(peerId):
                    additionalDataEntries.append(.peerNotificationSettings(self.peerNotificationSettingsTable.getEffective(peerId)))
            }
        }
        
        var readState: CombinedPeerReadState?
        if let fixedCombinedReadState = fixedCombinedReadState {
            readState = fixedCombinedReadState
        } else {
            switch peerIds {
                case let .single(peerId):
                    readState = self.readStateTable.getCombinedState(peerId)
                case let .associated(peerId, _):
                    readState = self.readStateTable.getCombinedState(peerId)
                case let .multiple(peerIds):
                    readState = self.readStateTable.getCombinedState(peerIds[0])
            }
        }
        
        let mutableView = MutableMessageHistoryView(id: MessageHistoryViewId(id: self.takeNextViewId()), postbox: self, orderStatistics: orderStatistics, peerIds: peerIds, index: index, anchorIndex: anchorIndex, combinedReadState: readState, tagMask: tagMask, count: count, clipHoles: clipHoles, topTaggedMessages: topTaggedMessages, additionalDatas: additionalDataEntries, getMessageCountInRange: { lowerBound, upperBound in
            if let tagMask = tagMask {
                return self.messageHistoryTable.getMessageCountInRange(peerId: lowerBound.id.peerId, tagMask: tagMask, lowerBound: lowerBound, upperBound: upperBound)
            } else {
                return 0
            }
        })
        mutableView.render(self.renderIntermediateMessage)
        
        let initialUpdateType: ViewUpdateType
        if let unreadIndex = unreadIndex {
            initialUpdateType = .InitialUnread(unreadIndex)
        } else {
            initialUpdateType = .Generic
        }
        
        let (index, signal) = self.viewTracker.addMessageHistoryView(mutableView)
        
        let initialData: InitialMessageHistoryData
        switch peerIds {
            case let .single(peerId):
                initialData = self.initialMessageHistoryData(peerId: peerId)
            case let .associated(peerId, _):
                initialData = self.initialMessageHistoryData(peerId: peerId)
            case let .multiple(peerIds):
                initialData = self.initialMessageHistoryData(peerId: peerIds[0])
        }
        
        subscriber.putNext((MessageHistoryView(mutableView), initialUpdateType, initialData))
        let disposable = signal.start(next: { next in
            subscriber.putNext((next.0, next.1, nil))
        })
        return ActionDisposable { [weak self] in
            disposable.dispose()
            if let strongSelf = self {
                strongSelf.queue.async {
                    strongSelf.viewTracker.removeMessageHistoryView(index: index)
                }
            }
        }
    }
    
    private func initialMessageHistoryData(peerId: PeerId) -> InitialMessageHistoryData {
        return InitialMessageHistoryData(peer: self.peerTable.get(peerId), chatInterfaceState: self.peerChatInterfaceStateTable.get(peerId))
    }
    
    public func messageIndexAtId(_ id: MessageId) -> Signal<MessageIndex?, NoError> {
        return self.modify { modifier -> Signal<MessageIndex?, NoError> in
            if let entry = self.messageHistoryIndexTable.get(id), case let .Message(index) = entry {
                return .single(index)
            } else if let _ = self.messageHistoryIndexTable.holeContainingId(id) {
                return .single(nil)
            } else {
                return .single(nil)
            }
        } |> switchToLatest
    }
    
    public func messageAtId(_ id: MessageId) -> Signal<Message?, NoError> {
        return self.modify { modifier -> Signal<Message?, NoError> in
            if let entry = self.messageHistoryIndexTable.get(id), case let .Message(index) = entry {
                if let message = self.messageHistoryTable.getMessage(index) {
                    return .single(self.renderIntermediateMessage(message))
                } else {
                    return .single(nil)
                }
            } else if let _ = self.messageHistoryIndexTable.holeContainingId(id) {
                return .single(nil)
            } else {
                return .single(nil)
            }
        } |> switchToLatest
    }
    
    public func messagesAtIds(_ ids: [MessageId]) -> Signal<[Message], NoError> {
        return self.modify { modifier -> Signal<[Message], NoError> in
            var messages: [Message] = []
            for id in ids {
                if let entry = self.messageHistoryIndexTable.get(id), case let .Message(index) = entry {
                    if let message = self.messageHistoryTable.getMessage(index) {
                        messages.append(self.renderIntermediateMessage(message))
                    }
                }
            }
            return .single(messages)
        } |> switchToLatest
    }
    
    public func tailChatListView(count: Int, summaryComponents: ChatListEntrySummaryComponents) -> Signal<(ChatListView, ViewUpdateType), NoError> {
        return self.aroundChatListView(index: ChatListIndex.absoluteUpperBound, count: count, summaryComponents: summaryComponents)
    }
    
    public func aroundChatListView(index: ChatListIndex, count: Int, summaryComponents: ChatListEntrySummaryComponents) -> Signal<(ChatListView, ViewUpdateType), NoError> {
        return self.transactionSignal { subscriber, modifier in
            let (entries, earlier, later) = self.fetchAroundChatEntries(index, count: count)
            
            let mutableView = MutableChatListView(earlier: earlier, entries: entries, later: later, count: count, summaryComponents: summaryComponents)
            mutableView.render(postbox: self, renderMessage: self.renderIntermediateMessage, getPeer: { id in
                return self.peerTable.get(id)
            }, getPeerNotificationSettings: { self.peerNotificationSettingsTable.getEffective($0) })
            
            let (index, signal) = self.viewTracker.addChatListView(mutableView)
            
            subscriber.putNext((ChatListView(mutableView), .Generic))
            let disposable = signal.start(next: { next in
                subscriber.putNext(next)
            })
            
            return ActionDisposable { [weak self] in
                disposable.dispose()
                if let strongSelf = self {
                    strongSelf.queue.async {
                        strongSelf.viewTracker.removeChatListView(index)
                    }
                }
            }
        }
    }
    
    public func contactPeerIdsView() -> Signal<ContactPeerIdsView, NoError> {
        return self.transactionSignal { subscriber, modifier in
            let view = MutableContactPeerIdsView(remoteTotalCount: self.metadataTable.getRemoteContactCount(), peerIds: self.contactsTable.get())
            let (index, signal) = self.viewTracker.addContactPeerIdsView(view)
            
            subscriber.putNext(ContactPeerIdsView(view))
            
            let disposable = signal.start(next: { next in
                subscriber.putNext(next)
            })
            
            return ActionDisposable { [weak self] in
                disposable.dispose()
                if let strongSelf = self {
                    strongSelf.queue.async {
                        strongSelf.viewTracker.removeContactPeerIdsView(index)
                    }
                }
            }
        }
    }
    
    public func contactPeersView(accountPeerId: PeerId) -> Signal<ContactPeersView, NoError> {
        return self.transactionSignal { subscriber, modifier in
            var peers: [PeerId: Peer] = [:]
            var peerPresences: [PeerId: PeerPresence] = [:]
            
            for peerId in self.contactsTable.get() {
                if let peer = self.peerTable.get(peerId) {
                    peers[peerId] = peer
                }
                if let presence = self.peerPresenceTable.get(peerId) {
                    peerPresences[peerId] = presence
                }
            }
            
            let view = MutableContactPeersView(peers: peers, peerPresences: peerPresences, accountPeer: self.peerTable.get(accountPeerId))
            let (index, signal) = self.viewTracker.addContactPeersView(view)
            
            subscriber.putNext(ContactPeersView(view))
            let disposable = signal.start(next: { next in
                subscriber.putNext(next)
            })
            
            return ActionDisposable {
                [weak self] in
                disposable.dispose()
                if let strongSelf = self {
                    strongSelf.queue.async {
                        strongSelf.viewTracker.removeContactPeersView(index)
                    }
                }
            }
        }
    }
    
    public func searchContacts(query: String) -> Signal<[Peer], NoError> {
        return self.modify { modifier -> Signal<[Peer], NoError> in
            let (_, contactPeerIds) = self.peerNameIndexTable.matchingPeerIds(tokens: (regular: stringIndexTokens(query, transliteration: .none), transliterated: stringIndexTokens(query, transliteration: .transliterated)), categories: [.contacts], chatListIndexTable: self.chatListIndexTable, contactTable: self.contactsTable, reverseAssociatedPeerTable: self.reverseAssociatedPeerTable)
            
            var contactPeers: [Peer] = []
            for peerId in contactPeerIds {
                if let peer = self.peerTable.get(peerId) {
                    contactPeers.append(peer)
                }
            }
            
            contactPeers.sort(by: { $0.indexName.indexName(.lastNameFirst) < $1.indexName.indexName(.lastNameFirst) })
            return .single(contactPeers)
        } |> switchToLatest
    }
    
    public func searchPeers(query: String) -> Signal<[RenderedPeer], NoError> {
        return self.modify { modifier -> Signal<[RenderedPeer], NoError> in
            var peerIds = Set<PeerId>()
            var chatPeers: [RenderedPeer] = []
            
            let (chatPeerIds, contactPeerIds) = self.peerNameIndexTable.matchingPeerIds(tokens: (regular: stringIndexTokens(query, transliteration: .none), transliterated: stringIndexTokens(query, transliteration: .transliterated)), categories: [.chats, .contacts], chatListIndexTable: self.chatListIndexTable, contactTable: self.contactsTable, reverseAssociatedPeerTable: self.reverseAssociatedPeerTable)
            
            for peerId in chatPeerIds {
                if let peer = self.peerTable.get(peerId) {
                    var peers = SimpleDictionary<PeerId, Peer>()
                    peers[peer.id] = peer
                    if let associatedPeerId = peer.associatedPeerId {
                        if let associatedPeer = self.peerTable.get(associatedPeerId) {
                            peers[associatedPeer.id] = associatedPeer
                        }
                    }
                    chatPeers.append(RenderedPeer(peerId: peer.id, peers: peers))
                    peerIds.insert(peerId)
                }
            }
            
            var contactPeers: [RenderedPeer] = []
            for peerId in contactPeerIds {
                if !peerIds.contains(peerId) {
                    if let peer = self.peerTable.get(peerId) {
                        var peers = SimpleDictionary<PeerId, Peer>()
                        peers[peer.id] = peer
                        contactPeers.append(RenderedPeer(peerId: peer.id, peers: peers))
                    }
                }
            }
            
            contactPeers.sort(by: { lhs, rhs in
                lhs.peers[lhs.peerId]!.indexName.indexName(.lastNameFirst) < rhs.peers[rhs.peerId]!.indexName.indexName(.lastNameFirst)
            })
            return .single(chatPeers + contactPeers)
        } |> switchToLatest
    }
    
    public func peerView(id: PeerId) -> Signal<PeerView, NoError> {
        return self.transactionSignal { subscriber, modifier in
            let view = MutablePeerView(postbox: self, peerId: id)
            let (index, signal) = self.viewTracker.addPeerView(view)
            
            subscriber.putNext(PeerView(view))
            
            let disposable = signal.start(next: { next in
                subscriber.putNext(next)
            })
            
            return ActionDisposable { [weak self] in
                disposable.dispose()
                if let strongSelf = self {
                    strongSelf.queue.async {
                        strongSelf.viewTracker.removePeerView(index)
                    }
                }
            }
        }
    }
    
    public func multiplePeersView(_ ids: [PeerId]) -> Signal<MultiplePeersView, NoError> {
        return self.transactionSignal { subscriber, modifier in
            let view = MutableMultiplePeersView(peerIds: ids, getPeer: { self.peerTable.get($0) }, getPeerPresence: { self.peerPresenceTable.get($0) })
            let (index, signal) = self.viewTracker.addMultiplePeersView(view)
            
            subscriber.putNext(MultiplePeersView(view))
            
            let disposable = signal.start(next: { next in
                subscriber.putNext(next)
            })
            
            return ActionDisposable { [weak self] in
                disposable.dispose()
                if let strongSelf = self {
                    strongSelf.queue.async {
                        strongSelf.viewTracker.removeMultiplePeersView(index)
                    }
                }
            }
        }
    }
    
    public func loadedPeerWithId(_ id: PeerId) -> Signal<Peer, NoError> {
        return self.modify { modifier -> Signal<Peer, NoError> in
            if let peer = self.peerTable.get(id) {
                return .single(peer)
            } else {
                return .never()
            }
        } |> switchToLatest
    }
    
    public func unreadMessageCountsView(items: [UnreadMessageCountsItem]) -> Signal<UnreadMessageCountsView, NoError> {
        return self.transactionSignal { subscriber, modifier in
            let view = MutableUnreadMessageCountsView(postbox: self, items: items)
            let (index, signal) = self.viewTracker.addUnreadMessageCountsView(view)
            
            subscriber.putNext(UnreadMessageCountsView(view))
            
            let disposable = signal.start(next: { next in
                subscriber.putNext(next)
            })
            
            return ActionDisposable { [weak self] in
                disposable.dispose()
                if let strongSelf = self {
                    strongSelf.queue.async {
                        strongSelf.viewTracker.removeUnreadMessageCountsView(index)
                    }
                }
            }
        }
    }
    
    public func updateMessageHistoryViewVisibleRange(_ id: MessageHistoryViewId, earliestVisibleIndex: MessageIndex, latestVisibleIndex: MessageIndex) {
        let _ = self.modify({ modifier -> Void in
            self.viewTracker.updateMessageHistoryViewVisibleRange(postbox: self, id: id, earliestVisibleIndex: earliestVisibleIndex, latestVisibleIndex: latestVisibleIndex)
        }).start()
    }
    
    public func recentPeers() -> Signal<[Peer], NoError> {
        return self.modify { modifier -> Signal<[Peer], NoError> in
            let peerIds = self.peerRatingTable.get()
            var peers: [Peer] = []
            for peerId in peerIds {
                if let peer: Peer = self.peerTable.get(peerId) {
                    peers.append(peer)
                }
            }
            return .single(peers)
        } |> switchToLatest
    }
    
    public func stateView() -> Signal<PostboxStateView, NoError> {
        return self.transactionSignal { subscriber, modifier in
            let mutableView = MutablePostboxStateView(state: self.getState())
            
            subscriber.putNext(PostboxStateView(mutableView))
            
            let (index, signal) = self.viewTracker.addPostboxStateView(mutableView)
            
            let disposable = signal.start(next: { next in
                subscriber.putNext(next)
            })
            
            return ActionDisposable { [weak self] in
                disposable.dispose()
                if let strongSelf = self {
                    strongSelf.queue.async {
                        strongSelf.viewTracker.removePostboxStateView(index)
                    }
                }
            }
        }
    }
    
    public func messageHistoryHolesView() -> Signal<MessageHistoryHolesView, NoError> {
        return Signal { subscriber in
            let disposable = MetaDisposable()
            self.queue.async {
                disposable.set(self.viewTracker.messageHistoryHolesViewSignal().start(next: { view in
                    subscriber.putNext(view)
                }))
            }
            return disposable
        }
    }
    
    public func chatListHolesView() -> Signal<ChatListHolesView, NoError> {
        return Signal { subscriber in
            let disposable = MetaDisposable()
            self.queue.async {
                disposable.set(self.viewTracker.chatListHolesViewSignal().start(next: { view in
                    subscriber.putNext(view)
                }))
            }
            return disposable
        }
    }
    
    public func unsentMessageIdsView() -> Signal<UnsentMessageIdsView, NoError> {
        return Signal { subscriber in
            let disposable = MetaDisposable()
            self.queue.async {
                disposable.set(self.viewTracker.unsentMessageIdsViewSignal().start(next: { view in
                    subscriber.putNext(view)
                }))
            }
            return disposable
        }
    }
    
    public func synchronizePeerReadStatesView() -> Signal<SynchronizePeerReadStatesView, NoError> {
        return Signal { subscriber in
            let disposable = MetaDisposable()
            self.queue.async {
                disposable.set(self.viewTracker.synchronizePeerReadStatesViewSignal().start(next: { view in
                    subscriber.putNext(view)
                }))
            }
            return disposable
        }
    }
    
    public func itemCollectionsView(orderedItemListCollectionIds: [Int32], namespaces: [ItemCollectionId.Namespace], aroundIndex: ItemCollectionViewEntryIndex?, count: Int) -> Signal<ItemCollectionsView, NoError> {
        return self.transactionSignal { subscriber, modifier in
            let itemListViews = orderedItemListCollectionIds.map { collectionId -> MutableOrderedItemListView in
                return MutableOrderedItemListView(postbox: self, collectionId: collectionId)
            }
            
            let mutableView = MutableItemCollectionsView(postbox: self, orderedItemListsViews: itemListViews, namespaces: namespaces, aroundIndex: aroundIndex, count: count)
            
            subscriber.putNext(ItemCollectionsView(mutableView))
            
            let (index, signal) = self.viewTracker.addItemCollectionView(mutableView)
            
            let disposable = signal.start(next: { next in
                subscriber.putNext(next)
            })
            
            return ActionDisposable { [weak self] in
                disposable.dispose()
                if let strongSelf = self {
                    strongSelf.queue.async {
                        strongSelf.viewTracker.removeItemCollectionView(index)
                    }
                }
            }
        }
    }
    
    public func mergedOperationLogView(tag: PeerOperationLogTag, limit: Int) -> Signal<PeerMergedOperationLogView, NoError> {
        return self.transactionSignal { subscriber, modifier in
            let view = MutablePeerMergedOperationLogView(tag: tag, limit: limit, getOperations: { tag, fromIndex, limit in
                return self.peerOperationLogTable.getMergedEntries(tag: tag, fromIndex: fromIndex, limit: limit)
            }, getTailIndex: { tag in
                return self.peerMergedOperationLogIndexTable.tailIndex(tag: tag)
            })
            
            subscriber.putNext(PeerMergedOperationLogView(view))
            
            let (index, signal) = self.viewTracker.addPeerMergedOperationLogView(view)
            
            let disposable = signal.start(next: { next in
                subscriber.putNext(next)
            })
            
            return ActionDisposable { [weak self] in
                disposable.dispose()
                if let strongSelf = self {
                    strongSelf.queue.async {
                        strongSelf.viewTracker.removePeerMergedOperationLogView(index)
                    }
                }
            }
        }
    }
    
    public func timestampBasedMessageAttributesView(tag: UInt16) -> Signal<TimestampBasedMessageAttributesView, NoError> {
        return self.transactionSignal { subscriber, modifier in
            let view = MutableTimestampBasedMessageAttributesView(tag: tag, getHead: { tag in
                return self.timestampBasedMessageAttributesTable.head(tag: tag)
            })
            let (index, signal) = self.viewTracker.addTimestampBasedMessageAttributesView(view)
            
            subscriber.putNext(TimestampBasedMessageAttributesView(view))
            
            let disposable = signal.start(next: { next in
                subscriber.putNext(next)
            })
            
            return ActionDisposable { [weak self] in
                disposable.dispose()
                if let strongSelf = self {
                    strongSelf.queue.async {
                        strongSelf.viewTracker.removeTimestampBasedMessageAttributesView(index)
                    }
                }
            }
        }
    }
    
    fileprivate func operationLogGetNextEntryLocalIndex(peerId: PeerId, tag: PeerOperationLogTag) -> Int32 {
        return self.peerOperationLogTable.getNextEntryLocalIndex(peerId: peerId, tag: tag)
    }
    
    fileprivate func operationLogAddEntry(peerId: PeerId, tag: PeerOperationLogTag, tagLocalIndex: StorePeerOperationLogEntryTagLocalIndex, tagMergedIndex: StorePeerOperationLogEntryTagMergedIndex, contents: PostboxCoding) {
        self.peerOperationLogTable.addEntry(peerId: peerId, tag: tag, tagLocalIndex: tagLocalIndex, tagMergedIndex: tagMergedIndex, contents: contents, operations: &self.currentPeerMergedOperationLogOperations)
    }
    
    fileprivate func operationLogRemoveEntry(peerId: PeerId, tag: PeerOperationLogTag, tagLocalIndex: Int32) -> Bool {
        return self.peerOperationLogTable.removeEntry(peerId: peerId, tag: tag, tagLocalIndex: tagLocalIndex, operations: &self.currentPeerMergedOperationLogOperations)
    }
    
    fileprivate func operationLogRemoveAllEntries(peerId: PeerId, tag: PeerOperationLogTag) {
        self.peerOperationLogTable.removeAllEntries(peerId: peerId, tag: tag, operations: &self.currentPeerMergedOperationLogOperations)
    }
    
    fileprivate func operationLogRemoveEntries(peerId: PeerId, tag: PeerOperationLogTag, withTagLocalIndicesEqualToOrLowerThan maxTagLocalIndex: Int32) {
        self.peerOperationLogTable.removeEntries(peerId: peerId, tag: tag, withTagLocalIndicesEqualToOrLowerThan: maxTagLocalIndex, operations: &self.currentPeerMergedOperationLogOperations)
    }
    
    fileprivate func operationLogUpdateEntry(peerId: PeerId, tag: PeerOperationLogTag, tagLocalIndex: Int32, _ f: (PeerOperationLogEntry?) -> PeerOperationLogEntryUpdate) {
        self.peerOperationLogTable.updateEntry(peerId: peerId, tag: tag, tagLocalIndex: tagLocalIndex, f: f, operations: &self.currentPeerMergedOperationLogOperations)
    }
    
    fileprivate func operationLogEnumerateEntries(peerId: PeerId, tag: PeerOperationLogTag, _ f: (PeerOperationLogEntry) -> Bool) {
        self.peerOperationLogTable.enumerateEntries(peerId: peerId, tag: tag, f)
    }
    
    fileprivate func addTimestampBasedMessageAttribute(tag: UInt16, timestamp: Int32, messageId: MessageId) {
        self.timestampBasedMessageAttributesTable.set(tag: tag, id: messageId, timestamp: timestamp, operations: &self.currentTimestampBasedMessageAttributesOperations)
    }
    
    fileprivate func removeTimestampBasedMessageAttribute(tag: UInt16, messageId: MessageId) {
        self.timestampBasedMessageAttributesTable.remove(tag: tag, id: messageId, operations: &self.currentTimestampBasedMessageAttributesOperations)
    }
    
    public func messageView(_ messageId: MessageId) -> Signal<MessageView, NoError> {
        return self.transactionSignal { subscriber, modifier in
            let view = MutableMessageView(messageId: messageId, message: modifier.getMessage(messageId))
            
            subscriber.putNext(MessageView(view))
            
            let (index, signal) = self.viewTracker.addMessageView(view)
            
            let disposable = signal.start(next: { next in
                subscriber.putNext(next)
            })
            
            return ActionDisposable { [weak self] in
                disposable.dispose()
                if let strongSelf = self {
                    strongSelf.queue.async {
                        strongSelf.viewTracker.removeMessageView(index)
                    }
                }
            }
        }
    }
    
    public func preferencesView(keys: [ValueBoxKey]) -> Signal<PreferencesView, NoError> {
        return self.transactionSignal { subscriber, modifier in
            let view = MutablePreferencesView(postbox: self, keys: Set(keys))
            let (index, signal) = self.viewTracker.addPreferencesView(view)
            
            subscriber.putNext(PreferencesView(view))
            
            let disposable = signal.start(next: { next in
                subscriber.putNext(next)
            })
            
            return ActionDisposable { [weak self] in
                disposable.dispose()
                if let strongSelf = self {
                    strongSelf.queue.async {
                        strongSelf.viewTracker.removePreferencesView(index)
                    }
                }
            }
        }
    }
    
    public func combinedView(keys: [PostboxViewKey]) -> Signal<CombinedView, NoError> {
        return self.transactionSignal { subscriber, modifier in
            var views: [PostboxViewKey: MutablePostboxView] = [:]
            for key in keys {
                views[key] = postboxViewForKey(postbox: self, key: key)
            }
            let view = CombinedMutableView(views: views)
            let (index, signal) = self.viewTracker.addCombinedView(view)
            
            subscriber.putNext(view.immutableView())
            
            let disposable = signal.start(next: { next in
                subscriber.putNext(next)
            })
            
            return ActionDisposable { [weak self] in
                disposable.dispose()
                if let strongSelf = self {
                    strongSelf.queue.async {
                        strongSelf.viewTracker.removeCombinedView(index)
                    }
                }
            }
        }
    }
    
    fileprivate func getPreferencesEntry(key: ValueBoxKey) -> PreferencesEntry? {
        return self.preferencesTable.get(key: key)
    }
    
    fileprivate func setPreferencesEntry(key: ValueBoxKey, value: PreferencesEntry?) {
        self.preferencesTable.set(key: key, value: value, operations: &self.currentPreferencesOperations)
    }
    
    fileprivate func replaceOrderedItemListItems(collectionId: Int32, items: [OrderedItemListEntry]) {
        self.orderedItemListTable.replaceItems(collectionId: collectionId, items: items, operations: &self.currentOrderedItemListOperations)
    }
    
    fileprivate func addOrMoveToFirstPositionOrderedItemListItem(collectionId: Int32, item: OrderedItemListEntry, removeTailIfCountExceeds: Int?) {
        self.orderedItemListTable.addItemOrMoveToFirstPosition(collectionId: collectionId, item: item, removeTailIfCountExceeds: removeTailIfCountExceeds, operations: &self.currentOrderedItemListOperations)
    }
    
    fileprivate func removeOrderedItemListItem(collectionId: Int32, itemId: MemoryBuffer) {
        self.orderedItemListTable.remove(collectionId: collectionId, itemId: itemId, operations: &self.currentOrderedItemListOperations)
    }
    
    fileprivate func getOrderedListItemIds(collectionId: Int32) -> [MemoryBuffer] {
        return self.orderedItemListTable.getItemIds(collectionId: collectionId)
    }
    
    fileprivate func getOrderedItemListItem(collectionId: Int32, itemId: MemoryBuffer) -> OrderedItemListEntry? {
        return self.orderedItemListTable.getItem(collectionId: collectionId, itemId: itemId)
    }
    
    fileprivate func setAccessChallengeData(_ data: PostboxAccessChallengeData) {
        self.currentUpdatedAccessChallengeData = data
        self.metadataTable.setAccessChallengeData(data)
    }
    
    public func installStoreMessageAction(peerId: PeerId, _ f: @escaping ([StoreMessage], Modifier) -> Void) -> Disposable {
        let disposable = MetaDisposable()
        self.queue.async {
            if self.installedMessageActionsByPeerId[peerId] == nil {
                self.installedMessageActionsByPeerId[peerId] = Bag()
            }
            let index = self.installedMessageActionsByPeerId[peerId]!.add(f)
            disposable.set(ActionDisposable {
                self.queue.async {
                    if let bag = self.installedMessageActionsByPeerId[peerId] {
                        bag.remove(index)
                    }
                }
            })
        }
        return disposable
    }
    
    fileprivate func scanMessages(peerId: PeerId, tagMask: MessageTags, _ f: (ScanMessageEntry) -> Bool) {
        var index = MessageIndex.lowerBound(peerId: peerId)
        outer: while true {
            let entries = self.fetchLaterHistoryEntries(peerId, index: index, count: 10, tagMask: tagMask)
            for entry in entries {
                var shouldContinue = false
                switch entry {
                    case let .HoleEntry(hole, _):
                        shouldContinue = f(.hole(hole))
                    case let .IntermediateMessageEntry(message, _, _):
                        shouldContinue = f(.message(self.renderIntermediateMessage(message)))
                    case .MessageEntry:
                        assertionFailure()
                        break
                }
                if !shouldContinue {
                    break outer
                }
            }
            if let last = entries.last {
                index = last.index
            } else {
                break
            }
        }
    }
    
    fileprivate func invalidateMessageHistoryTagsSummary(peerId: PeerId, namespace: MessageId.Namespace, tagMask: MessageTags) {
        self.invalidatedMessageHistoryTagsSummaryTable.insert(InvalidatedMessageHistoryTagsSummaryKey(peerId: peerId, namespace: namespace, tagMask: tagMask), operations: &self.currentInvalidateMessageTagSummaries)
    }
    
    fileprivate func removeInvalidatedMessageHistoryTagsSummaryEntry(_ entry: InvalidatedMessageHistoryTagsSummaryEntry) {
        self.invalidatedMessageHistoryTagsSummaryTable.remove(entry, operations: &self.currentInvalidateMessageTagSummaries)
    }
    
    func getMessage(_ id: MessageId) -> Message? {
        if let entry = self.messageHistoryIndexTable.get(id) {
            if case let .Message(index) = entry {
                if let message = self.messageHistoryTable.getMessage(index) {
                    return self.renderIntermediateMessage(message)
                }
            }
        }
        return nil
    }
    
    func getMessageGroup(_ id: MessageId) -> [Message]? {
        if let entry = self.messageHistoryIndexTable.get(id) {
            if case let .Message(index) = entry {
                if let messages = self.messageHistoryTable.getMessageGroup(index) {
                    return messages.map(self.renderIntermediateMessage)
                }
            }
        }
        return nil
    }
    
    fileprivate func resetChatList(keepPeerNamespaces: Set<PeerId.Namespace>, replacementHole: ChatListHole?) {
        let entries = self.chatListTable.allEntries()
        for entry in entries {
            switch entry {
                case let .message(chatListIndex, _):
                    if !keepPeerNamespaces.contains(chatListIndex.messageIndex.id.peerId.namespace) {
                        self.updatePeerChatListInclusion(chatListIndex.messageIndex.id.peerId, inclusion: .notSpecified)
                    }
                case let .hole(hole):
                    self.chatListTable.replaceHole(hole.index, hole: nil, operations: &self.currentChatListOperations)
            }
        }
        
        if let replacementHole = replacementHole {
            self.chatListTable.addHole(replacementHole, operations: &self.currentChatListOperations)
        }
    }
    
    public func isMasterClient() -> Signal<Bool, NoError> {
        return self.modify { modifier -> Signal<Bool, NoError> in
            let sessionClientId = self.sessionClientId
            return self.masterClientId.get()
                |> distinctUntilChanged
                |> map({ $0 == sessionClientId })
        } |> switchToLatest
    }
    
    public func becomeMasterClient() {
        let _ = self.modify({ modifier in
            if self.metadataTable.masterClientId() != self.sessionClientId {
                self.currentUpdatedMasterClientId = self.sessionClientId
            }
        }).start()
    }
    
    public func clearCaches() {
        let _ = self.modify({ _ in
            for table in self.tables {
                table.clearMemoryCache()
            }
        }).start()
    }
}
