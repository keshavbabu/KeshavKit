//
//  NetworkImageView.swift
//  KeshavKit
//
//  Created by Keshav Babu on 11/5/23.
//

import SwiftUI

public struct NetworkImageView<I: View, P: View, O: View, E: View>: View {
    var networkManager: NetworkManager
    var url: URL?
    @ViewBuilder let content: (Image) -> I
    @ViewBuilder let placeholder: () -> P
    @ViewBuilder var offline: () -> O
    @ViewBuilder let error: (Error) -> E
    
    public init(networkManager: NetworkManager, url: URL? = nil, content: @escaping (Image) -> I, placeholder: @escaping () -> P, offline: @escaping () -> O, error: @escaping (Error) -> E) {
        self.networkManager = networkManager
        self.url = url
        self.content = content
        self.placeholder = placeholder
        self.offline = offline
        self.error = error
    }
    
    public var body: some View {
        if networkManager.networkState == .connected {
            AsyncImage(url: url, content: view)
        } else {
            offline()
        }
    }
    
    @ViewBuilder
       private func view(for phase: AsyncImagePhase) -> some View {
           switch phase {
           case .empty:
               placeholder()
           case .success(let image):
               content(image)
           case .failure(let e):
               error(e)
           @unknown default:
               Text("Unknown")
                   .foregroundColor(.gray)
           }
       }
}

#Preview {
    NetworkImageView(networkManager: NetworkManager(), url: URL(string: "https://i.imgur.com/1Edz3bJ.jpeg")) { image in
        image
    } placeholder: {
        ProgressView()
    } offline: {
        Text("offline")
    } error: { error in
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray)
                .blur(radius: 10)
            VStack {
                Image(systemName: "exclamationmark")
            }
        }
    }

}
