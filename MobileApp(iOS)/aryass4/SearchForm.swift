//Working code with form inside section

//
//  SearchForm.swift
//  aryass4
//
//  Created by Arya Patki on 11/14/23.
//

import SwiftUI

import SwiftUI
import Alamofire
import SwiftyJSON

struct Product: Identifiable {
    let id: String
    let title: String
    let price: Double
    let shippingCost: Double
    let condition: String
    let imageUrl: String
//    let postalCode: String
    let shippingType: String // Example: "Free"
}


struct SearchForm: View {
    @State private var refreshID = UUID()
    
    @State private var products: [Product] = []
    @State private var showSearchResults = false
    @State private var isActive = false
    
    @State private var keyword: String = ""
    @State private var zipcode: String = ""
    @State private var selectedCategory: String = "All"
    @State private var conditionUsed: Bool = false
    @State private var conditionNew: Bool = false
    @State private var conditionUnspecified: Bool = false
    @State private var shippingPickup: Bool = false
    @State private var shippingFree: Bool = false
    @State private var distance: String = ""
    @State private var customLocation: Bool = false
    @State private var distanceText: String = ""
    @State private var errorMessage: String?
    @State private var showErrorMessage = false
    
    var categories = ["All", "Electronics", "Books", "Clothing", "Sports", "Home"]
    
    
    var body: some View {
        NavigationView {

                VStack{
                    
                    Form {
                        
                        Section{
                            HStack{
                                Text("Keyword:")
                                TextField(" Required", text: $keyword).autocapitalization(.none).disableAutocorrection(true)
                            }
                            
                            Picker("Category", selection: $selectedCategory) {
                                Text("All").tag("all")
                                Text("Art").tag("art")
                                Text("Baby").tag("baby")
                                Text("Books").tag("books")
                                Text("Clothing, Shoes & Accessories").tag("csa")
                                Text("Computers/Tablets & Networking").tag("ctn")
                                Text("Health & Beauty").tag("hb")
                                Text("Music").tag("music")
                                Text("Video Games & Consoles").tag("vgc")
                            }
                            .padding(.vertical, 6.0)
                            
                            VStack{
                                HStack{
                                    Text("Condition")
                                    Spacer()
                                }
                                .padding(.vertical, 3.0)
                                
                                HStack{
                                    Spacer()
                                    checkboxButton(label: "Used", isSelected: $conditionUsed)
                                    Spacer()
                                    checkboxButton(label: "New", isSelected: $conditionNew)
                                    Spacer()
                                    checkboxButton(label: "Unspecified", isSelected: $conditionUnspecified)
                                    Spacer()
                                }
                                .padding(.vertical, 3.0)
                            }
                            
                            
                            VStack{
                                HStack{
                                    Text("Shipping")
                                    Spacer()
                                }
                                .padding(.vertical, 3.0)
                                HStack {
                                    Spacer()
                                    checkboxButton(label: "Pickup", isSelected: $shippingPickup)
                                    
                                    Spacer()
                                    
                                    checkboxButton(label: "Free Shipping", isSelected: $shippingFree)
                                    Spacer()
                                } .padding(.vertical, 3.0)
                            }
                            
                            
                                HStack{
                                    Text("Distance: ")
                                    TextField("10", text: $distance)
                                        .frame(width: 20.0)
                                        .multilineTextAlignment(.trailing)
                                        .keyboardType(.numberPad) // if you want to use number pad
                                        .onReceive(distance.publisher.collect()) {
                                            self.distance = String($0.prefix(5)) // Limits the number of characters
                                        }
                                }
                            
                            
                            VStack{
                                Toggle("Custom location", isOn: $customLocation)
                                
                                if(customLocation){
                                    HStack{
                                        Text("Zipcode: ").foregroundColor(Color.black)
                                        
                                        TextField(" Required",text: $zipcode)
                                            .keyboardType(.numberPad )
                                    }
                                }
                                
                            }
                            
                            
                            
                            HStack {
                                Spacer()
                                Button("Submit") {
                                    submitForm()
                                    // Handle the submit action
                                }
                                .frame(width: 90, height: 30)
                                .padding()
                            
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                //                    .buttonStyle(.borderedProminent)
                                //                    .controlSize(.large)
                                Spacer()
                                Button("Clear") {
                                    //                        clearForm()
                                    // Handle the clear action
                                }
                                .frame(width: 90, height: 30)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                
                                Spacer()
                            }
                            .padding(.vertical, 3.0)
                            
                        }
                        
                        
                        //Results
                        Section{
                            
                            if showSearchResults {
                                Text("Results").font(.title).fontWeight(.bold)
                                ForEach(products){ product in
                                    NavigationLink(destination: ItemDetailView(product: product)) {
                                        
                                        HStack {
                                            AsyncImage(url: URL(string: product.imageUrl)) { image in
                                                image.resizable()
                                            } placeholder: {
                                                Color.gray
                                            }
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(8)

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(product.title)
                                                    .font(.headline)
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)

                                                Text("Price: \(product.price, specifier: "$%.2f")")
                                                    .font(.subheadline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.blue)

                                                if product.shippingCost == 0 {
                                                    Text("Free Shipping")
                                                        .font(.caption)
                                                } else {
                                                    Text("Shipping: \(product.shippingCost, specifier: "$%.2f")")
                                                        .font(.caption)
                                                }

                                                HStack {
//                                                    Text("Zipcode: \(String(product.zipcode.prefix(3)))**")
//                                                        .font(.caption)
                                                    Text("900**")
                                                    
                                                    Spacer()
                                                    
                                                    Text(product.condition)
                                                        .font(.caption)
                                                }
                                            }

                                            Spacer()

                                            Button(action: {
                                                // Action for heart button
                                            }) {
                                                Image(systemName: "heart")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                   

                                        
                                        
                                    }
                                }
                                .listStyle(PlainListStyle())
                                }
                        }
                    }
                   
                    .navigationTitle("Product Search")
//                    .padding(2.5)
                    .navigationBarItems(trailing: Button(action: {
                        // Action for the heart button
                    }, label: {
                        Image(systemName: "heart.circle")
                            .font(.title)
                        
                    }))
                    .overlay(
                        Group{
                            if showErrorMessage{
                                Text("Keyword is Mandatory")
                                    .foregroundColor(.white)
                                    
                                    .background(Color.black)
                                    .cornerRadius(5)
                                    .transition(.opacity)
                                    .zIndex(1)
                                    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                                    .onAppear{
                                        DispatchQueue.main.asyncAfter(deadline:.now()+3){
                                            withAnimation{showErrorMessage=false}
                                        }
                                    }
                            }
                        }
                        
                            .frame(maxWidth:.infinity, maxHeight:.infinity,alignment:.bottom)
                    )
                    .background(Color(.systemGroupedBackground))
                    
                    

                        
                    
            } .background(Color(.systemGroupedBackground))

        }.navigationViewStyle(StackNavigationViewStyle())
            .background(Color(.systemGroupedBackground))
    }
    func submitForm(){
        errorMessage=nil
        let trimmedKeyword=keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedKeyword.isEmpty{
            withAnimation{
                showErrorMessage=true
            }
        }else{
            var conditions:[String]=[]
            if conditionNew {conditions.append("new")}
            if conditionUsed { conditions.append("used") }
            if conditionUnspecified { conditions.append("unspecified") }
            
            let conditionsString = conditions.joined(separator: ",")
                      
                      // Combine the shipping options into a single string
            var shippingOptions: [String] = []
            if shippingPickup { shippingOptions.append("localPickup") }
            if shippingFree { shippingOptions.append("freeShipping") }
            
            let shippingOptionsString = shippingOptions.joined(separator: ",")
                     
            // Create the dictionary with the format you want
            let formData: [String: Any] = [
                "Keyword": keyword,
                "Category": selectedCategory,
                "Condition": conditionsString,
                "ShippingOptions": shippingOptionsString,
                "Distance": distanceText.isEmpty ? "10" : distanceText,
                "From": zipcode.isEmpty ? "90037" : zipcode  // Assuming 'From' is meant to be 'zipcode'
            ]
            print(formData)
            
            // Convert the formData dictionary to JSON
            if let jsonData = try? JSONSerialization.data(withJSONObject: formData, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                
            }
            
            let urlStr = "https://ebayhw3-404502.wl.r.appspot.com/search_ebay"
            
            AF.request(urlStr, parameters: formData).responseData { response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
//                    print("JSON: \(json)")
//                    print("Item: \(json["findItemsAdvancedResponse"][0]["searchResult"][0]["item"][0])")
                    // Handle your json as required
                    //                        self.products = products
                    self.showSearchResults = true
                    print(self.showSearchResults)
                   parseProducts(json: json)
                    print(self.products[0].price)
                case .failure(let error):
                    print(error)
                    // Handle the error case
                }
            }
        }
        
    }
    
    func parseProducts(json:JSON){
        let items = json["findItemsAdvancedResponse"][0]["searchResult"][0]["item"].arrayValue
        print(items[0])
        self.products = items.map { item in
            Product(
                id: item["itemId"][0].stringValue,
                title: item["title"][0].stringValue,
                price: item["sellingStatus"][0]["convertedCurrentPrice"][0]["_value_"].doubleValue,
                shippingCost: item["shippingInfo"][0]["shippingServiceCost"][0]["_value_"].doubleValue,
                condition: item["condition"][0]["conditionDisplayName"][0].stringValue,
                imageUrl: item["galleryURL"][0].stringValue,

                shippingType: item["shippingInfo"][0]["shippingType"][0].stringValue
            )
        }
    }
    
    func clearForm(){
//        self.showSearchResults=false
        keyword = ""
        selectedCategory = "all"
       conditionNew = false
       conditionUsed = false
       conditionUnspecified = false
       shippingPickup = false
       shippingFree = false
       customLocation = false
       //        distance = 10
       distanceText = ""
    }
}

struct checkboxButton: View {
    var label: String
    @Binding var isSelected: Bool

    
    var body: some View {
        Button(action: {
            self.isSelected.toggle()
        }) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .blue : .gray)
                Text(label)
                    .foregroundColor(.black)
            }
        }
        // This is to ensure the button doesn't show the default highlight style when tapped
        .buttonStyle(BorderlessButtonStyle())
    }
}

#Preview {
    SearchForm()
}
