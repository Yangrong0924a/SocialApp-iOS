import SwiftUI

// MARK: - 图片加载
struct CachedAsyncImage: View {
    let url: URL?
    let placeholder: String
    var size: CGFloat = 40

    var body: some View {
        if let url = url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                case .failure:
                    AvatarPlaceholder(name: placeholder, size: size)
                case .empty:
                    ProgressView()
                        .frame(width: size, height: size)
                @unknown default:
                    AvatarPlaceholder(name: placeholder, size: size)
                }
            }
        } else {
            AvatarPlaceholder(name: placeholder, size: size)
        }
    }
}

struct AvatarPlaceholder: View {
    let name: String
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            Circle()
                .fill(placeholderColor)
            Text(initials)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
    }

    private var initials: String {
        let chars = name.trimmingCharacters(in: .whitespaces)
        guard let first = chars.first else { return "?" }
        return String(first).uppercased()
    }

    private var placeholderColor: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - 图片选择器
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}