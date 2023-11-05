//
//  NetworkManager.swift
//  KeshavKit
//
//  Created by Keshav Babu on 11/5/23.
//

import Foundation
import Network

@Observable
public class NetworkManager {
    
    enum NetworkState {
        case pending
        case connected
        case disconnected
    }
    
    var networkState: NetworkState = .pending
    private var hasStatus: Bool = false
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkMonitor")
    
    init(){
        monitor.pathUpdateHandler = { path in
            #if targetEnvironment(simulator)
                if (!self.hasStatus) {
                    Task {
                        await MainActor.run {
                            self.networkState = path.status == .satisfied ? .connected : .disconnected
                        }
                    }
                    self.hasStatus = true
                } else {
                    Task {
                        await MainActor.run {
                            self.networkState = self.networkState == .connected ? .disconnected : .connected
                        }
                    }
                }
            #else
            Task {
                await MainActor.run {
                    self.networkState = path.status == .satisfied ? .connected : .disconnected
                }
            }
            #endif
        }
        monitor.start(queue: queue)
    }
}
