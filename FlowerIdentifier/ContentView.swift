//  ContentView.swift
//  InvasivaArter
//  Created by Ola Knutsson on 2025-07-15,
//  Modified by Kim Lindfors & Miguel Pérez dos Santos

import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    // variabel för bilderna
    @State private var nsImage: NSImage?
    // variabel för prediktionen som kommer att komma som en String från modellen
    @State private var prediction: String = "No prediction yet"
    // variabel för hur säker modellen är på prediktionen
    @State private var highestConfidence: Float = 0.33

    var body: some View {
        VStack {
            if let nsImage = nsImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 300)
            } else {
                Text("Select an image")
            }
            VStack()
            {
                Text("Prediction: "+prediction)
                // Spacer()
                Text("Confidence: "+"\(highestConfidence)")
            }
                .padding()
            Button("Open Image") {
                openImage()
            }
        }
        .frame(width: 400, height: 400)
    }
    // funktion för att ta fram en bild genom filhanteraren och be om klassificering
    func openImage() {
        let panel = NSOpenPanel()
   //     panel.allowedFileTypes = ["png", "jpg", "jpeg"]
        panel.begin { response in
            if response == .OK, let url = panel.url, let image = NSImage(contentsOf: url) {
                nsImage = image
                classifyImage(image)
            }
        }
    }

    // funktion som använder modellen InvasivaKlassificeraren för att klassificera bilden
    func classifyImage(_ nsImage: NSImage) {
        guard let tiffData = nsImage.tiffRepresentation,
              let ciImage = CIImage(data: tiffData) else {
            prediction = "Invalid image"
            return
        }
        do {
            let mlModel = try FlowerIdentifier(configuration: MLModelConfiguration()).model
            let model = try VNCoreMLModel(for: mlModel)
            let request = VNCoreMLRequest(model: model) { request, _ in
                if let results = request.results as? [VNClassificationObservation],
                  
                    // Bästa prediktionen, som vi nöjer oss med
                 let first = results.first
                
                 // Kontrollerar vilken växt som har predikats
                 {
                 
                    if first.identifier == "storBlaklocka" {
                        prediction = "Stor blåklocka"
                    } else if first.identifier == "jatteBjornloka" {
                        prediction = "Jätteloka"
                    }
                    else if first.identifier == "rallarros" {
                        prediction = "Mjölke"
                    }
                    else if first.identifier == "fackelBlomster" {
                        prediction = "Fackelblomster"
                        
                    }
                    // Hur säker modellen är på prediktionen
                   let confBest = first.confidence
                    
                    print(results) // skriver till console för att enkelt kolla utdata
                    print(confBest)
                    print(prediction)
                    highestConfidence = confBest
                 //   print(confBest)
                    
                } else {
                    prediction = "Could not classify image"
                }
            }
            let handler = VNImageRequestHandler(ciImage: ciImage)
            try handler.perform([request])
        } catch {
            prediction = "Model error: \(error.localizedDescription)"
        }
    } // end classifyImage
}


#Preview {
    ContentView()
}

