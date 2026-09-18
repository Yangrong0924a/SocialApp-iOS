import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthService
    @State private var username = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var toast: ToastMessage?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 60)

                    // Logo
                    VStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.pink)
                        Text("社交圈")
                            .font(.largeTitle.bold())
                        Text("记录属于我们的每一天")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer().frame(height: 20)

                    // 表单
                    VStack(spacing: 16) {
                        TextField("用户名", text: $username)
                            .textContentType(.username)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        SecureField("密码", text: $password)
                            .textContentType(.password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        Button(action: login) {
                            if auth.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                            } else {
                                Text("登录")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                            }
                        }
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(auth.isLoading || username.isEmpty || password.isEmpty)
                    }
                    .padding(.horizontal, 32)

                    Button("还没有账号？立即注册") {
                        showRegister = true
                    }
                    .font(.subheadline)
                    .padding(.top, 8)
                }
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            .toast(toast: $toast)
        }
    }

    private func login() {
        guard !username.isEmpty, !password.isEmpty else { return }
        Task {
            do {
                try await auth.login(username: username, password: password)
            } catch {
                toast = ToastMessage(message: error.localizedDescription, type: .error)
            }
        }
    }
}