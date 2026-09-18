import SwiftUI

struct ChatBubble: View {
    let message: Message
    let isFromMe: Bool

    var body: some View {
        HStack {
            if isFromMe { Spacer(minLength: 60) }

            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 2) {
                // 内容
                if let text = message.content, !text.isEmpty {
                    Text(text)
                        .font(.body)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isFromMe ? Color.blue : Color(.systemGray5))
                        .foregroundColor(isFromMe ? .white : .primary)
                        .cornerRadius(16)
                }

                // 图片
                if let url = message.mediaURL, message.isImage {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 200, maxHeight: 250)
                                .cornerRadius(12)
                        case .failure:
                            Color.gray.opacity(0.3)
                                .frame(width: 150, height: 150)
                                .cornerRadius(12)
                                .overlay(Image(systemName: "photo"))
                        case .empty:
                            ProgressView()
                                .frame(width: 150, height: 150)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                // 时间
                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }

            if !isFromMe { Spacer(minLength: 60) }
        }
    }
}