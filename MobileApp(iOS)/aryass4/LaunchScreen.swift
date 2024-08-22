import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        HStack {
           
            Text("Powered by")
                    
            Image("ebayLogo") // Replace with your actual image asset name
                .resizable() // Make it resizable
                .scaledToFit() // Keep the aspect ratio while fitting into the container
                .frame(width: 90.0, height: 50) // Adjust the size as needed
//                .padding() // Add some padding if needed


        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}

