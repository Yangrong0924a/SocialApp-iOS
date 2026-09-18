import SwiftUI

struct CreatePostView: View {
    let onPost: (String, Data?) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var content = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var isPosting = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // 文字输入
                TextEditor(text: $content)
                    .frame(minHeight: 150)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("说说你的想法...")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    }

                // 图片预览
                if let image = selectedImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .cornerRadius(10)

                        Button(action: { selectedImage = nil }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                        }
                        .padding(4)
                    }
                }

                // 添加图片按钮
                if selectedImage == nil {
                    Button(action: { showImagePicker = true }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("添加图片")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("发布动态")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: post) {
                        if isPosting {
                            ProgressView()
                        } else {
                            Text("发布")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(content.trimmingCharacters(in: .whitespaces).isEmpty || isPosting)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }

    private func post() {
        guard !content.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isPosting = true
        onPost(content, selectedImage?.jpegData(compressionQuality: 0.8))
    }
}