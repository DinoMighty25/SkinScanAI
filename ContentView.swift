//
//  ContentView.swift
//  skinscan
//
//  Created by Troy on 6/19/24.
//

import SwiftUI
import AVFoundation
import CoreML
import Vision

// Model for Disease
struct Disease: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let detail: String // Detailed information for each disease
}

// Log Entry Model (With Prediction)
struct LogEntry: Identifiable {
    let id = UUID()
    let image: UIImage
    let date: Date
    let prediction: String // This stores the AI prediction
}

// Photo Detail View

struct PhotoDetailView: View {
    let logEntry: LogEntry

    var body: some View {
        ScrollView {
            Image(uiImage: logEntry.image.cropToTopSquare()) // Apply the cropping to the top half
                .resizable()
                .scaledToFit()
                .padding()
            Text("Date: \(logEntry.date.customFormatted())")
                .font(.headline)
                .padding()
            Text("Prediction: \(logEntry.prediction)")
                .font(.headline)
                .foregroundColor(.red)
                .padding()
        }
        .navigationTitle("Photo Detail")
    }
}


// The main ContentView with a TabView
struct ContentView: View {
    @State private var logEntries: [LogEntry] = []

    var body: some View {
        TabView {
            DatabaseView()
                .tabItem {
                    Label("Database", systemImage: "book.circle")
                }
            ScanView(logEntries: $logEntries)
                .tabItem {
                    Label("Scan", systemImage: "camera.circle")
                }
            PhotoLogView(logEntries: logEntries)
                .tabItem {
                    Label("Log", systemImage: "list.bullet")
                }
        }
        .accentColor(.blue)
    }
}

// View for displaying detailed information about a disease
struct DiseaseDetailView: View {
    let disease: Disease
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(disease.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(disease.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text("How to Identify")
                    .font(.title2)
                    .fontWeight(.bold)
                Text(disease.detail)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                
                Divider()
                
                Text("Treatment")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Treatments vary depending on the severity and location of the disease. For mild cases, topical medications are commonly prescribed. Severe cases may require oral medications or even surgery.")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                
                Divider()
                
                Text("Dangers")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("If left untreated, some skin conditions may worsen or lead to complications. In the case of certain conditions like melanoma, early detection is crucial for preventing life-threatening outcomes.")
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .navigationTitle(disease.name)
    }
}

// View to display a list of diseases
struct DatabaseView: View {
    let diseases = [
        Disease(name: "Actinic Keratosis", description: "• Actinic Keratosis are rough, scaly patches on the skin caused by excessive sun exposure.", detail: "• Often found on sun-exposed areas like the face, lips, ears, neck, and forearms.\n• The patches are typically red, pink, or brown, and may feel itchy or tender."),
        Disease(name: "Atopic Dermatitis", description: "• Atopic Dermatitis (Eczema) is a condition that causes red, itchy skin, often flaring up periodically.", detail: "• It usually appears in childhood and is often linked to allergies or asthma.\n• Affected areas can become cracked, thickened, or scaly."),
        Disease(name: "Benign Keratosis", description: "• Benign Keratosis are non-cancerous skin growths that are often rough and wart-like.", detail: "• Often found on older adults and appear waxy or scaly in texture.\n• Colors range from light tan to black, and they are often mistaken for skin cancer."),
        Disease(name: "Dermatofibroma", description: "• Dermatofibroma is a common benign skin growth that feels firm under the skin.", detail: "• These small, round, reddish-brown nodules are usually found on the lower legs.\n• They may itch or become tender, and pressing on them may create a dimple-like indentation."),
        Disease(name: "Melanocytic Nevus", description: "• Melanocytic Nevus (moles) are benign skin growths that can be flat or raised.", detail: "• Moles can vary in color from pink to dark brown.\n• Changes in size, color, or shape should be monitored as they can signal melanoma."),
        Disease(name: "Melanoma", description: "• Melanoma is a dangerous form of skin cancer arising from melanocytes, often caused by UV exposure.", detail: "• Look for asymmetrical moles, irregular borders, and a variety of colors.\n• Early detection is key as melanoma can spread to other parts of the body."),
        Disease(name: "Squamous Cell Carcinoma", description: "• Squamous Cell Carcinoma is a type of skin cancer that forms in the squamous cells of the skin.", detail: "• Often appears as a firm, red nodule or a flat lesion with a scaly crust.\n• Commonly caused by prolonged sun exposure and can spread if not treated."),
        Disease(name: "Tinea (Ringworm)", description: "• Tinea, commonly known as ringworm, is a fungal infection that causes a circular, red, and scaly rash.", detail: "• The rash is often itchy and can spread across various parts of the body.\n• It is highly contagious and can be spread through direct contact with infected individuals or objects."),
        Disease(name: "Candidiasis", description: "• Candidiasis is a fungal infection caused by yeast, often affecting moist areas of the skin.", detail: "• Common in skin folds, it can cause redness, swelling, and an itchy rash.\n• It is more prevalent in individuals with weakened immune systems or diabetes."),
        Disease(name: "Vascular Lesion", description: "• Vascular lesions are abnormal clusters of blood vessels visible on the skin’s surface.", detail: "• They can appear as red or purple spots and are often harmless.\n• However, they can sometimes indicate underlying conditions like bleeding disorders.")
    ]
    
    var body: some View {
        NavigationView {
            List(diseases) { disease in
                NavigationLink(destination: DiseaseDetailView(disease: disease)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(disease.name)
                            .font(.headline)
                        Text(disease.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Disease Database")
        }
    }
}

// View for logging and taking photos
struct ScanView: View {
    @Binding var logEntries: [LogEntry]
    @State private var isCameraAuthorized = false
    @State private var isPermissionDenied = false
    @State private var currentImage: UIImage? = nil
    @State private var predictionText: String = "Prediction will appear here"

    var body: some View {
        NavigationView {
            VStack {
                if isCameraAuthorized {
                    CameraView(currentImage: $currentImage)
                        .frame(height: 400)
                        .cornerRadius(10)
                        .padding()
                    
                    // Repositioning the prediction text and button
                    Text(predictionText)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.top, 20) // Add padding to the top
                    
                    Button(action: {
                        if let image = currentImage {
                            savePhoto(image)
                        }
                    }) {
                        Text("Take Photo")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20) // Add padding to the top
                    .padding(.bottom) // Optional bottom padding
                } else {
                    Text("Camera access is required to scan your skin. Please allow camera access in the app settings.")
                        .multilineTextAlignment(.center)
                        .padding()
                    if isPermissionDenied {
                        Button(action: {
                            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                if UIApplication.shared.canOpenURL(appSettings) {
                                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                                }
                            }
                        }) {
                            Text("Open Settings")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        self.isCameraAuthorized = granted
                        self.isPermissionDenied = !granted
                    }
                }
            }
            .navigationTitle("Scan")
        }
    }

    // Save the photo with the prediction
    func savePhoto(_ image: UIImage) {
        // Make a prediction using the captured image
        predictSkinCondition(from: image) { result in
            DispatchQueue.main.async {
                // Create a new log entry with the fixed image orientation
                let fixedImage = image.rotate90Clockwise() // This now refers to the correct method
                let newLogEntry = LogEntry(image: fixedImage, date: Date(), prediction: result)
                // Add the log entry to the logEntries array
                logEntries.append(newLogEntry)
                // Update the prediction text below the camera
                self.predictionText = result
            }
        }
    }

    // CoreML Model Prediction
    func predictSkinCondition(from image: UIImage, completion: @escaping (String) -> Void) {
        guard let model = try? VNCoreMLModel(for: skinAIv3().model) else {
            completion("Failed to load model")
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNClassificationObservation] {
                // Ensure there's at least one result
                if let topResult = results.first {
                    let confidence = topResult.confidence * 100 // Convert to percentage
                    let prediction = "\(topResult.identifier) (\(String(format: "%.2f", confidence))% confidence)"
                    completion(prediction) // Return prediction with confidence
                } else {
                    completion("No predictions found")
                }
            } else {
                completion("Prediction failed")
            }
        }

        guard let ciImage = CIImage(image: image) else {
            completion("Failed to convert image")
            return
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion("Error making prediction")
            }
        }
    }
}

// Log view to display saved photos with timestamps and predictions
// Log view to display saved photos with timestamps and predictions
struct PhotoLogView: View {
    let logEntries: [LogEntry]

    var body: some View {
        NavigationView {
            List(logEntries) { entry in
                NavigationLink(destination: PhotoDetailView(logEntry: entry)) {
                    Image(uiImage: entry.image.cropToTopSquare()) // Crop the top half
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 100) // Keep the display consistent
                    VStack(alignment: .leading) {
                        Text("Date: \(entry.date.customFormatted())")
                        Text("Prediction: \(entry.prediction)")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Photo Log")
        }
    }
}



// Camera view implementation
struct CameraView: UIViewControllerRepresentable {
    @Binding var currentImage: UIImage?
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
            DispatchQueue.main.async {
                self.parent.currentImage = UIImage(cgImage: cgImage)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let session = AVCaptureSession()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return viewController }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            return viewController
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            return viewController
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        } else {
            return viewController
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        session.startRunning()
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// Extension to fix image orientation
extension UIImage {
    func rotate90Clockwise() -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: self.size))
        let t = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size

        UIGraphicsBeginImageContext(rotatedSize)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        context?.rotate(by: CGFloat.pi / 2)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.draw(cgImage, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return rotatedImage ?? self
    }
    func cropToTopSquare() -> UIImage {
            let originalWidth = self.size.width
            let originalHeight = self.size.height

            let cropSize = min(originalWidth, originalHeight / 2) // Crop from the top half
            let cropRect = CGRect(
                x: 0, // Start from the left edge
                y: 0, // Start from the top
                width: cropSize,
                height: cropSize
            )

            guard let cgImage = self.cgImage?.cropping(to: cropRect) else { return self }
            return UIImage(cgImage: cgImage)
        }

}

// Date extension for custom formatting
extension Date {
    func customFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}


#Preview {
    ContentView()
}
