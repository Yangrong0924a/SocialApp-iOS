import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var nickname = ""
    @State private var bio = ""
    @State private var emergencyName = ""
    @State private var emergencyEmail = ""
    @State private var selectedAvatar: UIImage?
    @State private var showImagePicker = false
    @State private var isSaving = false
    @State private var toast: ToastMessage?

    var body: some View {
        NavigationStack {
            Form {
                // 头像
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            if let image = selectedAvatar {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                CachedAsyncImage(
                                    url: auth.currentUser?.avatarURL,
                                    placeholder: auth.currentUser?.displayName ?? "?",
                                    size: 80
                                )
                            }

                            Button("更换头像") {
                                showImagePicker = true
                            }
                            .font(.subheadline)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .onTapGesture { showImagePicker = true }
                }

                // 基本信息
                Section("基本信息") {
                    TextField("昵称", text: $nickname)
                    ZStack(alignment: .topLeading) {
                        if bio.isEmpty {
                            Text("个人简介")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $bio)
                            .frame(minHeight: 80)
                    }
                }

                // 紧急联系人
                Section("紧急联系人") {
                    TextField("联系人姓名", text: $emergencyName)
                    TextField("联系人邮箱", text: $emergencyEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("编辑资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: save) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("保存")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedAvatar)
            }
            .toast(toast: $toast)
        }
        .onAppear {
            if let user = auth.currentUser {
                nickname = user.nickname ?? user.username
                bio = user.bio ?? ""
                emergencyName = user.emergencyContactName ?? ""
                emergencyEmail = user.emergencyContactEmail ?? ""
            }
        }
    }

    private func save() {
        isSaving = true
        Task {
            do {
                // 先上传头像
                if let image = selectedAvatar, let data = image.jpegData(compressionQuality: 0.8) {
                    let _: AvatarUploadResponse = try await APIService.shared.upload(
                        "/api/profile/avatar",
                        fileData: data,
                        fileName: "avatar.jpg",
                        fieldName: "avatar"
                    )
                }

                // 更新资料
                let _: User = try await APIService.shared.post("/api/profile/update", body: [
                    "nickname": nickname,
                    "bio": bio,
                    "emergency_contact_name": emergencyName,
                    "emergency_contact_email": emergencyEmail
                ])

                await auth.refreshUser()
                toast = ToastMessage(message: "保存成功", type: .success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    dismiss()
                }
            } catch {
                toast = ToastMessage(message: error.localizedDescription, type: .error)
            }
            isSaving = false
        }
    }
}

struct AvatarUploadResponse: Decodable {
    let ok: Bool
    let avatar: String?
}