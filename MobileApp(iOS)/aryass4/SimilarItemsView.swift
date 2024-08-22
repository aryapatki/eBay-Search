//
//  SimilarItemsView.swift
//  EbaySearch
//
//  Created by Onkar Bagwe on 04/12/23.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct SimilarItem: Identifiable {
    let id: String
    let imageURL: String
    let title: String
    let price: String
    let shippingCost: String
    let daysLeft: String
}

struct SimilarItemsView: View {
    let itemId: String
    @State private var similarItems = [SimilarItem]()

    var body: some View {
        Text("Hellooo theerreee")
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(similarItems) { item in
                    VStack {
                        AsyncImage(url: URL(string: item.imageURL)) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(height: 150) // Adjust based on your UI needs
                        .cornerRadius(8)

                        Text(item.title)
                            .font(.headline)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)

                        Text(item.price)
                            .font(.subheadline)
                            .foregroundColor(.green)

                        Text("Shipping: \(item.shippingCost)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("\(item.daysLeft) left")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
            loadSimilarItemsDetails()
        }
    }

    func loadSimilarItemsDetails() {
        let urlStr = "https://ebayhw3-404502.wl.r.appspot.com/get_similar_items/\(itemId)"
        AF.request(urlStr).responseData { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                print("json: ",json)
                if let items = json["getSimilarItemsResponse"]["itemRecommendations"]["item"].array {
                    self.similarItems = items.compactMap { itemJson in
                        guard
                            
                            let id = itemJson["itemId"].string,
                            let imageURL = itemJson["imageURL"].string,
                            let title = itemJson["title"].string,
                            let buyItNowPrice = itemJson["buyItNowPrice"]["_value_"].string,
                            let shippingCost = itemJson["shippingCost"]["_value_"].string,
                            let timeLeft = itemJson["timeLeft"].string
                        else {
                            return nil
                        }
                        print("Similar Items: ", self.similarItems)
                        // Convert time left to days left
                        let daysLeft = convertTimeLeftToDays(timeLeft)
                        return SimilarItem(id: id, imageURL: imageURL, title: title, price: buyItNowPrice, shippingCost: shippingCost, daysLeft: daysLeft)
                    }
                }
            case .failure(let error):
                print("Error fetching similar items: \(error)")
            }
        }
    }

    func convertTimeLeftToDays(_ timeLeft: String) -> String {
        // P30DT10H9M41S -> 30 days left
        // Extract the days from the timeLeft string
        let daysPattern = "P(\\d+)DT"
        if let regex = try? NSRegularExpression(pattern: daysPattern, options: []),
           let match = regex.firstMatch(in: timeLeft, options: [], range: NSRange(location: 0, length: timeLeft.utf16.count)),
           let range = Range(match.range(at: 1), in: timeLeft) {
            return "\(timeLeft[range]) days left"
        }
        return timeLeft // Fallback, return original string if pattern doesn't match
    }
}

struct SimilarItemsView_Previews: PreviewProvider {
    static var previews: some View {
        SimilarItemsView(itemId: "123")
    }
}
