//
//  ContentView.swift
//  AnalizzaImmagine
//
//  Created by Michele Manniello on 09/10/21.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State var image : Image? = nil
    @State var showCaptureImageView : Bool = false
    @State var txt : String = ""
    @State var calcolomodello : Bool = false
    
   
    
    var body: some View {
        ZStack{
            VStack{
                
                image?.resizable()
                    .frame(width: 250, height: 250)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white,lineWidth: 4))
                    .shadow(radius: 10)
                
                Button(action: {
                    self.showCaptureImageView.toggle()
                    
                }, label: {
                    Text("Choose photos")
                })
                .padding()
                
                if image != nil && txt == "" {
                    ProgressView()
                }else{
                    Text(txt)
                        .padding()
                }
            }
            if(showCaptureImageView){
                CatturaImmagine(isShow: $showCaptureImageView, image: $image,testo: $txt)
            }
        }
    }
   
}
func modello(image: UIImage) -> String{
    var testo = ""
    let configuration = MLModelConfiguration()
    guard let resize = image.resize(size: CGSize(width: 224, height: 224)),
          let buffer = resize.getCVPixelBuffer() else{
              return "Error"
          }
    
    do {
        let model = try MobileNetV2(configuration: configuration)
        let output = try? model.prediction(image: buffer)
        
        if let output = output{
//                "Banan" : 10.9%
//            testo = output.classLabel
               let resuts =  output.classLabelProbs.sorted{ $0.1 > $1.1}
                let result = resuts.map { key,value -> String in
                let number = (value * 100)
                    if number > 5{
                        return "\(key) = \(String(format: "%.0f", number))%\n"
                    }else{
                        return ""
                    }
                }
                for c in result{
                    if c != ""{
                        testo += c
                    }
                }
        }
        
    } catch {
        print(error.localizedDescription)
        testo = "Errore\(error.localizedDescription) "
    }
    return testo
    
}
extension View {
// This function changes our View to UIView, then calls another function
// to convert the newly-made UIView to a UIImage.
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
// here is the call to the function that converts UIView to UIImage: `.asUIImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
