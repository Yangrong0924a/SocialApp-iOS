import SwiftUI

struct ChatDetailView: View {
    let chatUserId: Int
    let title: String

    @StateObject private var vm = ChatViewModel()
    @State private var messageText = ""
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack(spacing: 0) {
            // 消息列表
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(vm.messages) { msg in
                            ChatBubble(message: msg, isFromMe: msg.senderId == AuthService.shared.currentUser?.id)
                                .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: vm.messages.count) { _ in
                    if let last = vm.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            // 输入栏
            Divider()
            HStack(spacing: 8) {
                Button(action: { showImagePicker = true }) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }

                TextField("输入消息...", text: $messageText)
                    .textFieldStyle(.roundedBorder)

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .blue)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toast(toast: $vm.toast)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage, let data = image.jpegData(compressionQuality: 0.7) {
                Task { await vm.sendMedia(to: chatUserId, imageData: data) }
                selectedImage = nil
            }
        }
        .task { await vm.loadMessages(with: chatUserId) }
    }

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        messageText = ""
        Task { await vm.sendMessage(to: chatUserId, content: text) }
    }
}