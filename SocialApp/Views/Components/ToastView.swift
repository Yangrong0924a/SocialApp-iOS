import SwiftUI

// MARK: - Toast 消息模型
struct ToastMessage: Equatable {
    let message: String
    let type: ToastType

    enum ToastType {
        case success, error, info
    }

    var backgroundColor: Color {
        switch type {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        }
    }

    var icon: String {
        switch type {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

// MARK: - Toast View
struct ToastView: View {
    let message: ToastMessage

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: message.icon)
                .foregroundColor(.white)
            Text(message.message)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(message.backgroundColor)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}

// MARK: - Toast Modifier
struct ToastModifier: ViewModifier {
    @Binding var toast: ToastMessage?
    @State private var workItem: DispatchWorkItem?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast = toast {
                    ToastView(message: toast)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(), value: toast.message)
                        .onAppear {
                            workItem?.cancel()
                            let item = DispatchWorkItem { in
                                if item?.isCancelled == false {
                                    withAnimation { self.toast = nil }
                                }
                            }
                            workItem = item
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: item)
                        }
                }
            }
    }
}

extension View {
    func toast(toast: Binding<ToastMessage?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}