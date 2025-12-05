import SwiftUI

struct MessagesView: View {
    @State private var messages: [Message] = []
    @State private var announcements: [Announcement] = []
    @State private var isLoading = true
    @State private var selectedTab = 0
    @State private var newMessageText = ""
    @State private var showNewMessage = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selection
                Picker("Content", selection: $selectedTab) {
                    Text("Messages").tag(0)
                    Text("Announcements").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity, alignment: .center)
                } else if selectedTab == 0 {
                    MessagesListView(messages: messages, newMessage: $newMessageText)
                } else {
                    AnnouncementsListView(announcements: announcements)
                }
            }
            .navigationTitle("Team Chat")
            .toolbar {
                if selectedTab == 0 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showNewMessage = true }) {
                            Image(systemName: "plus.bubble.fill")
                                .font(.title3)
                        }
                    }
                }
            }
        }
        .onAppear {
            loadMessages()
        }
    }
    
    private func loadMessages() {
        isLoading = true
        Task {
            // Load messages and announcements
            isLoading = false
        }
    }
}

struct MessagesListView: View {
    let messages: [Message]
    @Binding var newMessage: String
    @State private var messageText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            if messages.isEmpty {
                EmptyStateView(
                    title: "No Messages",
                    description: "Start a conversation with your team",
                    action: {}
                )
            } else {
                List(messages) { message in
                    MessageBubble(message: message)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
            
            // Message Input
            HStack(spacing: 8) {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .background(Color(.systemGray6))
        }
    }
    
    private func sendMessage() {
        // Send message
        messageText = ""
    }
}

struct MessageBubble: View {
    let message: Message
    @EnvironmentObject var authManager: AuthManager
    
    var isCurrentUser: Bool {
        message.senderId == authManager.currentUser?.id
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.senderName)
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Text(message.content)
                    .padding(12)
                    .background(isCurrentUser ? Color.blue : Color(.systemGray6))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(12)
                
                Text(message.createdAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

struct AnnouncementsListView: View {
    let announcements: [Announcement]
    
    var body: some View {
        if announcements.isEmpty {
            EmptyStateView(
                title: "No Announcements",
                description: "Coach will post announcements here",
                action: {}
            )
        } else {
            List(announcements) { announcement in
                NavigationLink(destination: AnnouncementDetailView(announcement: announcement)) {
                    AnnouncementRow(announcement: announcement)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct AnnouncementRow: View {
    let announcement: Announcement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(announcement.title)
                        .font(.headline)
                    Text(announcement.authorName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                PriorityBadge(priority: announcement.priority)
            }
            
            Text(announcement.content)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .opacity(announcement.read ? 0.6 : 1.0)
        .padding(.vertical, 4)
    }
}

struct AnnouncementDetailView: View {
    let announcement: Announcement
    @State private var isRead = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(announcement.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("by \(announcement.authorName)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        PriorityBadge(priority: announcement.priority)
                    }
                    
                    Text(announcement.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text("Announcement")
                        .font(.headline)
                    Text(announcement.content)
                        .font(.body)
                }
                .padding()
                
                if let expiresAt = announcement.expiresAt {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Expires")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(expiresAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                    }
                    .padding()
                    .background(Color(.systemYellow).opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
        }
        .navigationTitle("Announcement")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            markAsRead()
        }
    }
    
    private func markAsRead() {
        Task {
            // Mark announcement as read
        }
    }
}

struct PriorityBadge: View {
    let priority: AnnouncementPriority
    
    var body: some View {
        Text(priority.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(priorityColor.opacity(0.2))
            .foregroundColor(priorityColor)
            .cornerRadius(4)
    }
    
    private var priorityColor: Color {
        switch priority {
        case .urgent:
            return .red
        case .high:
            return .orange
        case .medium:
            return .blue
        case .low:
            return .gray
        }
    }
}

#Preview {
    MessagesView()
        .environmentObject(AuthManager.shared)
}
