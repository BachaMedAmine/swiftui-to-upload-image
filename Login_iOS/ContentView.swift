//
//  ContentView.swift
//  Login_iOS
//
//  Created by Becha Med Amine on 15/10/2024.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageFromPicker: Image?

    var body: some View {
        VStack(spacing: 35) {
            // Display either the selected image from the camera or the photo picker
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
            } else if let imageFromPicker {
                imageFromPicker
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
            } else {
                Text("No Image Selected")
                    .font(.headline)
            }
            
            

            // Button to open the camera
            Button(action: {
                self.showCamera.toggle()
            }) {
                Text("Open Camera")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .fullScreenCover(isPresented: self.$showCamera) {
                AccessCameraView(selectedImage: self.$selectedImage)
                    .background(.black)
            }
            
            // Button to select an image from the photo library
            Button(action: {
                self.showPhotoPicker.toggle()
            }) {
                Text("Select from Photos")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotosPickerView(selectedItem: $selectedItem, imageFromPicker: $imageFromPicker)
            }
        }
        .padding()
    }
}

// Camera access view
struct AccessCameraView: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
    
    // Coordinator to handle the selected image
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var picker: AccessCameraView
        
        init(picker: AccessCameraView) {
            self.picker = picker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let selectedImage = info[.originalImage] as? UIImage else { return }
            self.picker.selectedImage = selectedImage
            self.picker.isPresented.wrappedValue.dismiss()
        }
    }
}

// Photos Picker View
struct PhotosPickerView: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var imageFromPicker: Image?
    
    var body: some View {
        PhotosPicker("Select an image", selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                        self.imageFromPicker = Image(uiImage: uiImage)
                    } else {
                        print("Failed to load the image")
                    }
                }
            }
    }
}

#Preview {
    ContentView()
}
