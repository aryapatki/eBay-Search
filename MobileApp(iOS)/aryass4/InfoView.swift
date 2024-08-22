//
//  InfoView.swift
//  aryass4
//
//  Created by Arya Patki on 12/4/23.
//


import SwiftUI
import Alamofire
import SwiftyJSON


struct ProductDetails {
    let title: String
    let price: Double
    let condition: String
    let imageUrls: [String]
    let features: [String: [String]] // Assuming each feature has a name and multiple values
}

struct InfoView: View {
    let itemId: String
    @State var productDetails: ProductDetails?
    
    
    let data: [(String, String)] = [
        ("Brand", "Apple"),
        ("MPN", "A2111"),
        ("Model", "Apple iPhone 11"),
        ("Storage Capacity", "128 GB"),
        ("Color", "Black"),
        ("Network", "Unlocked"),
        ("Camera Resolution", "12.0 MP"),
        ("Screen Size", "6.1 in"),
        ("Connectivity", "4G, Bluetooth, Wi-Fi"),
        ("Lock Status", "Network Unlocked"),
        ("RAM", "4 GB")
    ]
    

    var body: some View {
            ScrollView {
                VStack {
                    if let imageURLs = productDetails?.imageUrls, !imageURLs.isEmpty {
                        TabView {
                            ForEach(imageURLs, id: \.self) { imageUrl in
                                AsyncImage(url: URL(string: imageUrl)) { phase in
                                    if let image = phase.image {
                                        image.resizable()
                                    } else if phase.error != nil {
                                        Color.red // Indicates an error.
                                    } else {
                                        Color.blue // Acts as a placeholder.
                                    }
                                }
                                .aspectRatio(contentMode: .fit)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .frame(height: 250)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(productDetails?.title ?? "")
                            .font(.title)
                        
                        Text(String(format: "$%.2f", productDetails?.price ?? 0.0))
                            .font(.headline)
                            .foregroundColor(.blue)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                            
                        HStack{
                            Image(systemName: "magnifyingglass")
                            Text("Description")
                        }
                        
//                        VStack(alignment: .leading) {
//                                    ForEach(data, id: \.0) { (key, value) in
//                                        HStack {
//                                            Text(key)
//                                                .font(.subheadline)
//                                                .bold()
//                                                .frame(width: 140, alignment: .leading) // Fixed width for the first column
//                                            
//                                            Text(value)
//                                                .font(.subheadline)
//                                                .frame(maxWidth: .infinity, alignment: .leading) // Allow the second column to fill the rest of the space
//                                        }
//                                        Divider().fontWeight(.bold)
//                                    }
//                                }
//                                .padding()
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .background(Color.white)
//                                .cornerRadius(10)
                        
                        
                        
                        // Assuming 'features' is a dictionary of [String: [String]]
                        VStack(alignment: .leading) {
                            ForEach(productDetails?.features.sorted(by: { $0.key < $1.key }) ?? [], id: \.key) { key, values in
                                HStack {
                                    
                                        Text(key)
                                        .font(.subheadline)
                                        .bold()
                                        .frame(width: 140, alignment: .leading)
                                    
                                    
                                    HStack{
                                        ForEach(values, id: \.self) { value in
                                            Text(value)
                                                .font(.subheadline)
                                        } .font(.subheadline)
                                            .frame(maxWidth: .infinity, alignment: .leading) // Allow the second column to fill the rest of the space

                                    }

                                }
                                Divider()
                            }
                        }                                
                        .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(10)

                    }
                    .padding()
                }
            }
            .onAppear {
                loadItemDetails()
            }
        }
    func loadItemDetails() {
        let urlStr = "https://ebayhw3-404502.wl.r.appspot.com/get_item_details/\(itemId)"
        AF.request(urlStr).responseData { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                // Parse the JSON into your ProductDetails struct
                // This is a simplistic parsing. You will need to modify it based on your actual JSON structure
                if let title = json["Item"]["Title"].string,
                   let priceValue = json["Item"]["CurrentPrice"]["Value"].double,
                   let condition = json["Item"]["ConditionDisplayName"].string {
                    
                    // Construct URLs from the PictureURL array
                    let imageUrls = json["Item"]["PictureURL"].arrayValue.compactMap { $0.string }
                    
                    // Map the ItemSpecifics to a dictionary
                    let features = Dictionary(grouping: json["Item"]["ItemSpecifics"]["NameValueList"].arrayValue) { $0["Name"].stringValue }
                    .mapValues { $0.compactMap { $0["Value"][0].string } }
                    
                    // Now update the state variable on the main thread
                    DispatchQueue.main.async {
                        self.productDetails = ProductDetails(
                            title: title,
                            price: priceValue,
                            condition: condition,
                            imageUrls: imageUrls,
                            features: features
                        )
                    }
                }
            case .failure(let error):
                print("Error fetching item details: \(error)")
            }
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(itemId: "123")
    }
}
