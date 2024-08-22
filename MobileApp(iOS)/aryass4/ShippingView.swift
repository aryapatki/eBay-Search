//
//  ShippingView.swift
//  aryass4
//
//  Created by Arya Patki on 12/4/23.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct ItemDetail: Decodable {
    var storeName: String
    var storeURL: String
    var shippingCost: Double
    var globalShipping: Bool
    var handlingTime: String
    var seller: Seller
    var returnPolicy: ReturnPolicy
    
    struct Seller: Decodable {
        var feedbackScore: Int
        var feedbackPercent: Double
    }
    
    struct ReturnPolicy: Decodable {
        var returnsAccepted: String
        var refund: String
        var returnsWithin: String
        var shippingCostPaidBy: String
    }
    
}
struct ShippingView: View {
    let itemId: String
    @State private var itemDetail: ItemDetail?
    
    var body: some View {
        ScrollView {
            if let details = itemDetail {
                //Seller Info
                VStack{
                    Divider()
                    HStack{
                        Image(systemName: "house")
                        Text("Seller")

                        Spacer()
                    }
                    Divider()
                    
                    VStack(alignment: .leading, spacing:2){
                        HStack{
                            Text("Store Name")
                            Spacer()
                            
                            if let url = URL(string: details.storeURL) {
                                Link(details.storeName, destination: url)
                            } else {
                                Text(details.storeName)
                            }
                        }
                        
                        
                        HStack{
                            Text("Feedback Score")
                            Spacer()
                            Text("\(details.seller.feedbackScore)")
                        }
                        
                        HStack {
                            Text("Popularity")
                            Spacer()
                            Text("\(details.seller.feedbackPercent, specifier: "%.2f")")
                        }
                        
                    }.padding(.horizontal, 50.0)
                    
                    //Shipping Info
                    Divider()
                    HStack{
                        Image(systemName: "sailboat")
                        Text("Shipping Info")

                        Spacer()
                    }
                    Divider()
                    
                    VStack(alignment: .leading, spacing:2){
                        HStack {
                            Text("Shipping Cost")
                            Spacer()
                            Text("\(details.shippingCost, specifier: "%.2f")")
                        }
                        
                        HStack {
                            Text("Global Shipping")
                            Spacer()
                            Text(details.globalShipping ? "Yes" : "No")
                        }
                        HStack {
                            Text("Handling Time")
                            Spacer()
                            Text(details.handlingTime)
                        }
                        
                        
                    }.padding(.horizontal, 50.0)
                    
                    Divider()
                    HStack{
                        Image(systemName: "return")
                        Text("Return Policy")

                        Spacer()
                    }
                    Divider()
                    
                    VStack(alignment: .leading, spacing:2){
                        HStack {
                            Text("Policy")
                            Spacer()
                            Text(details.returnPolicy.returnsAccepted)
                        }
                        HStack {
                            Text("Refund Mode")
                            Spacer()
                            Text(details.returnPolicy.refund)
                        }
                        HStack {
                            Text("Refund Within")
                            Spacer()
                            Text(details.returnPolicy.returnsWithin)
                        }
                        HStack {
                            Text("Shipping Cost Paid By")
                            Spacer()
                            Text(details.returnPolicy.shippingCostPaidBy)
                        }
                        
                    }.padding(.horizontal, 50.0)
                    
                }
                .contentMargins(/*@START_MENU_TOKEN@*/.vertical/*@END_MENU_TOKEN@*/, /*@START_MENU_TOKEN@*/27.0/*@END_MENU_TOKEN@*/)

            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            loadShippingDetails()
        }
    }
    func loadShippingDetails() {
        let urlStr = "https://ebayhw3-404502.wl.r.appspot.com/get_item_details/\(itemId)"
        AF.request(urlStr).responseData { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                // Parse the JSON into your ProductDetails struct
                // This is a simplistic parsing. You will need to modify it based on your actual JSON structure
                let item = ItemDetail(
                    storeName: json["Item"]["Storefront"]["StoreName"].stringValue,
                    storeURL: json["Item"]["Storefront"]["StoreURL"].stringValue,
                    shippingCost: json["Item"]["ShippingCost"].doubleValue,
                    globalShipping: json["Item"]["GlobalShipping"].boolValue,
                    handlingTime: json["Item"]["HandlingTime"].stringValue,
                    seller: ItemDetail.Seller(
                        feedbackScore: json["Item"]["Seller"]["FeedbackScore"].intValue,
                        feedbackPercent: json["Item"]["Seller"]["PositiveFeedbackPercent"].doubleValue
                    ),
                    returnPolicy: ItemDetail.ReturnPolicy(
                        returnsAccepted: json["Item"]["ReturnPolicy"]["ReturnsAccepted"].stringValue,
                        refund: json["Item"]["ReturnPolicy"]["Refund"].stringValue,
                        returnsWithin: json["Item"]["ReturnPolicy"]["ReturnsWithin"].stringValue,
                        shippingCostPaidBy: json["Item"]["ReturnPolicy"]["ShippingCostPaidBy"].stringValue
                    )
                )
                self.itemDetail = item
            case .failure(let error):
                print("Error fetching item details: \(error)")
            }
        }
    }
}

//#Preview {
//    InfoView(itemId: <#T##id#>)
//}

struct ShippingView_Previews: PreviewProvider {
    static var previews: some View {
        ShippingView(itemId: "123")
    }
}


