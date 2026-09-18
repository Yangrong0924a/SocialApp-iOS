import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var toast: ToastMessage?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 40)

                Image(systemName: "person.badge.plus")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)

                Text("创建账号")
                    .font(.title.bold())

                VStack(spacing: 14) {
                    TextField("用户名", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    TextField("邮箱", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    SecureField("密码", text: $password)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    SecureField("确认密码", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    Button(action: register) {
                        if auth.isLoading {
                            ProgressView().tint(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        } else {
                            Text("注册")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                    }
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(auth.isLoading || !formValid)
                }
                .padding(.horizontal, 32)

                Button("已有账号？去登录") {
                    dismiss()
                }
                .font(.subheadline)
            }
        }
        .navigationTitle("注册")
        .navigationBarTitleDisplayMode(.inline)
        .toast(toast: $toast)
    }

    private var formValid: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword
    }

    private func register() {
        guard formValid else {
            toast = ToastMessage(message: "请检查表单", type: .error)
            return
        }
        Task {
            do {
                try await auth.register(username: username, email: email, password: password)
            } catch {
                toast = ToastMessage(message: error.localizedDescription, type: .error)
            }
        }
    }
}