//
//  ContentView.swift
//  Account
//
//  Created by Hossein Zare on 3/21/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var firstname = ""
    @State private var lastname = ""
    @State private var email = ""
    @State private var birthday = Date()
    @State private var gender = "Male"
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var profileImage: Image? = nil
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    let genders = ["Male", "Female", "Other"]

    // Form validation
    var isFormValid: Bool {
        !firstname.isEmpty &&
        !lastname.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        !password.isEmpty &&
        password == confirmPassword
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Profile image section
                Section {
                    HStack {
                        Spacer()
                        if let image = profileImage {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                )
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    PhotosPicker("Select Profile Image", selection: $selectedPhoto, matching: .images)
                        .onChange(of: selectedPhoto) {
                            Task {
                                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    profileImage = Image(uiImage: uiImage)
                                    // Save selected profile image
                                    UserProfileManager.shared.saveProfileImage(data)
                                }
                            }
                        }
                }
                
                // Personal information section
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstname).autocapitalization(.words)
                    TextField("Last Name", text: $lastname).autocapitalization(.words)
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                    Picker("Gender", selection: $gender) {
                        ForEach(genders, id: \.self) { Text($0) }
                    }
                }
                
                // Contact section
                Section(header: Text("Contact")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                // Security section
                Section(header: Text("Security")) {
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                    if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                        Text("Passwords do not match").foregroundColor(.red)
                    }
                }
                
                // Save button
                Section {
                    Button(action: saveUserData) {
                        Text("Save")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isFormValid ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(radius: 8)
                            .scaleEffect(isFormValid ? 1.1 : 1.1)
                            .animation(.spring(), value: isFormValid)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Account")
            .onAppear(perform: loadUserData)
        }
    }
    
    // MARK: - Save user data
    func saveUserData() {
        let user = UserProfile(
            firstname: firstname,
            lastname: lastname,
            email: email,
            birthday: birthday,
            gender: gender,
            password: password
        )
        UserProfileManager.shared.saveUser(user)
        print("✅ User saved successfully!")
    }
    
    // MARK: - Load user data
    func loadUserData() {
        let (user, image) = UserProfileManager.shared.loadCompleteUserData()
        if let user = user {
            firstname = user.firstname
            lastname = user.lastname
            email = user.email
            birthday = user.birthday
            gender = user.gender
            password = user.password
            confirmPassword = user.password
        }
        if let uiImage = image {
            profileImage = Image(uiImage: uiImage)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
