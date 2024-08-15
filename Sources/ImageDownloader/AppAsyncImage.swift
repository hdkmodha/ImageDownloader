//
//  File.swift
//  
//
//  Created by Hardik Modha on 15/05/24.
//

import Foundation
import FetchingView
import SwiftUI

public struct AppAsyncImage: View {
    let url: URL
    @State private var fetchingState: FetchingState<Image> = .idle
    private let downloader = ImageDownloaderClient.downloader
    
    public init(url: URL) {
        self.url = url
    }
    
    public var body: some View {
        FetchingView(fetchingState: self.fetchingState) { image in
            image
                .resizable()
        }
        .onAppear {
            self.loadImage(url: url)
        }
        
    }
        
    
    private func loadImage(url: URL) {
        Task {
            do {
                self.fetchingState = .fetching
                let image = try await downloader.loadImage(url: url)
                let latestImage = Image(uiImage: image)
                self.fetchingState = .fetched(latestImage)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct AppAsyncImageViewPreview: View {
    var urls: [URL] = [
        URL(string: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg")!,
        URL(string: "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg")!
    ]
    @State var isFirst: Bool = false
    
    var body: some View {
        AppAsyncImage(url: isFirst ? urls[0] : urls[1])
        Toggle("IsFirst", isOn: $isFirst)
            .padding()
    }
}

#Preview {
    AppAsyncImageViewPreview()
}
