//
//  ItemDetailView.swift
//  aryass4
//
//  Created by Arya Patki on 12/4/23.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct ItemDetailView: View {
//    let productId:String;

    let product: Product
    
    
    @State private var isInfoOn=true;
    @State private var isShippingOn=false;
    @State private var isPhotosOn=false;
    @State private var isSimilarOn=false;
    var body: some View {
        VStack{
            
            if isInfoOn{
                InfoView(itemId: product.id).onAppear{
                    ItemDetail()
                }
            }
            if isShippingOn{
                ShippingView(itemId: product.id)
            }
            if isPhotosOn{
                PhotosView(itemName: product.title)
            }
            if isSimilarOn{
                SimilarItemsView(itemId: product.id)
            }
           
    
            Spacer()
            
            HStack{
                Spacer()
                Button(action: {
                    isInfoOn=true;
                    isShippingOn=false;
                    isPhotosOn=false;
                    isSimilarOn=false;
                    
                }) {
                    VStack{
                        Image(systemName: "info.circle.fill")
                        Text("info")
                    }.foregroundColor(isInfoOn ? .blue : .gray)
                    
                }
                Spacer()
                Button(action: {
                    isInfoOn=false;
                    isShippingOn=true;
                    isPhotosOn=false;
                    isSimilarOn=false;             // Shipping action
               }) {
                   VStack{
                       Image(systemName: "shippingbox.fill")
                       Text("Shipping")
                   }.foregroundColor(isShippingOn ? .blue : .gray)
               }
                
                Spacer()
                Button(action: {
                    isInfoOn=false;
                    isShippingOn=false;
                    isPhotosOn=true;
                    isSimilarOn=false;// Photos action
                }) {
                    VStack{
                        Image(systemName: "photo.stack.fill")
                        Text("Photos")
                    }.foregroundColor(isPhotosOn ? .blue : .gray)
                }
                Spacer()
                Button(action: {
                    isInfoOn=false;
                    isShippingOn=false;
                    isPhotosOn=false;
                    isSimilarOn=true;// Similar action
                }) {
                    VStack{
                        Image(systemName: "list.bullet.indent")
                        Text("Similar")
                    }.foregroundColor(isSimilarOn ? .blue : .gray)
                    
                }
                Spacer()
            }.padding()
            .background(Color.gray.opacity(0.1))
        }
    }
    
    func ItemDetail(){
        let urlStr = "https://ebayhw3-404502.wl.r.appspot.com/get_item_details/"+product.id
        AF.request(urlStr).responseData { response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    print("JSON: \(json)")
//                    print("Item: \(json["findItemsAdvancedResponse"][0]["searchResult"][0]["item"][0])")
                    // Handle your json as required
//                        self.products = products
                case .failure(let error):
                    print(error)
                    // Handle the error case
                }
            }
    }
}

//#Preview {
//    ItemDetailView(productId: "12345")
//}

struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailView(product: Product(
            id: "1",
            title: "Apple iPhone 11 A2111 (Fully Unlocked) 128GB Black w/ Fast Charging Station",
            price: 437.48,
            shippingCost: 10.00,
            condition: "Used",
            imageUrl: "https://example.com/image.jpg",
            shippingType: "Free"
        ))
    }
}






