import SwiftUI
import Alamofire
import SwiftyJSON

struct Photo: Identifiable {
    let id: String
    let thumbnailLink: String
}

struct PhotosView: View {
    let itemName: String
    @State private var photos = [Photo]()

    var body: some View {
        // Use GeometryReader to make the ScrollView take the full width
        
        VStack{
            HStack{
                Text("Powered By")
                Image("google").resizable().frame(width:70 , height: 30)
            }
            
            GeometryReader { geometry in
                
                ScrollView {
                    VStack {
                       
                        
                        ForEach(photos) { photo in
                            AsyncImage(url: URL(string: photo.thumbnailLink)) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width - 90, height: 300) // Subtract total padding from the width
                            .clipped()
                        }
                    }
                    .padding(.horizontal, 40) // Add horizontal padding to VStack
                }
            } .onAppear {
                loadPhotosDetails()
            }
            
        }
       
    }

    func loadPhotosDetails() {
        let urlStr = "https://ebayhw3-404502.wl.r.appspot.com/get_photos/\(itemName)"
        AF.request(urlStr).responseData { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                if let items = json["items"].array {
                    self.photos = items.map { item in
                        if let id = item["link"].string,
                           let thumbnail = item["image"]["thumbnailLink"].string {
                            return Photo(id: id, thumbnailLink: thumbnail)
                        }
                        return nil
                    }
                    .compactMap { $0 } // Removes nil values from the array
                }
            case .failure(let error):
                print("Error fetching photos: \(error)")
            }
        }
    }
}

struct PhotosView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosView(itemName: "Apple")
    }
}














////
////  PhotosView.swift
////  EbaySearch
////
////  Created by Onkar Bagwe on 04/12/23.
////
//
//import SwiftUI
//import Alamofire
//import SwiftyJSON
//
//struct Photo: Identifiable {
//    let id: String
//    let thumbnailLink: String
//}
//
//struct PhotosView: View {
//    let itemName: String
//    @State private var photos = [Photo]()
//
//    var body: some View {
//        ScrollView {
//            
//            VStack {
//                HStack{
//                    Text("Powered By")
//                    Image("google").resizable().frame(width:70 , height: 30)
//                }
//                ForEach(photos) { photo in
//                    AsyncImage(url: URL(string: photo.thumbnailLink)) { image in
//                        image.resizable()
//                    } placeholder: {
//                        Color.gray
//                    }
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 300, height: 300) // Set this to your desired width and height
//                    .clipped()
//                }
//            }
//        }
//        .onAppear {
//            loadPhotosDetails()
//        }
//    }
//
//    func loadPhotosDetails() {
//        let urlStr = "https://ebayhw3-404502.wl.r.appspot.com/get_photos/\(itemName)"
//        AF.request(urlStr).responseData { response in
//            switch response.result {
//            case .success(let data):
//                let json = JSON(data)
//                if let items = json["items"].array {
//                    self.photos = items.map { item in
//                        if let id = item["link"].string,
//                           let thumbnail = item["image"]["thumbnailLink"].string {
//                            return Photo(id: id, thumbnailLink: thumbnail)
//                        }
//                        return nil
//                    }
//                    .compactMap { $0 } // Removes nil values from the array
//                }
//            case .failure(let error):
//                print("Error fetching photos: \(error)")
//            }
//        }
//    }
//}
//
//struct PhotosView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotosView(itemName: "Apple")
//    }
//}
