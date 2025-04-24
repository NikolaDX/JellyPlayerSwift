//
//  JellyfinService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import Foundation
import JellyfinAPI
import UIKit

class JellyfinService {
    private var serverUrl: String? {
        get { return UserDefaults.standard.string(forKey: serverKey) }
        set { UserDefaults.standard.set(newValue, forKey: serverKey) }
    }
    
    private var userId: String? {
        get { return UserDefaults.standard.string(forKey: userKey) }
        set { UserDefaults.standard.set(newValue, forKey: userKey) }
    }
    
    private var accessToken: String? {
        get { return UserDefaults.standard.string(forKey: accessKey) }
        set { UserDefaults.standard.set(newValue, forKey: accessKey) }
    }
    
    func authenticateUser(server: String, username: String, password: String) async throws {
        guard let url = URL(string: "\(server)") else {
            throw URLError(.badURL)
        }
        
        let clientName = "JellyPlayerApp"
        let deviceName = await UIDevice.current.name
        let deviceID = await UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "UnknownVersion"
        
        let configuration = JellyfinClient.Configuration(
            url: url,
            client: clientName,
            deviceName: deviceName,
            deviceID: deviceID,
            version: version
        )
        
        let client = JellyfinClient(configuration: configuration)
        let response = try await client.signIn(username: username, password: password)
        userId = response.user?.id
        accessToken = response.accessToken
        serverUrl = server
    }
    
    func fetchItems(queryItems: [URLQueryItem]) async -> Data? {
        guard let server = serverUrl, let userId = userId, let token = accessToken else {
            return nil
        }

        var components = URLComponents(string: "\(server)/Users/\(userId)/Items")
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "X-Emby-Token")
        request.httpMethod = "GET"
        
        if let (data, response) = try? await URLSession.shared.data(for: request) {
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return data
            }
        }
        
        return nil
    }
    
    func fetchSpecific(queryItems: [URLQueryItem], toFetch itemType: String) async -> Data? {
        guard let server = serverUrl, let token = accessToken else {
            return nil
        }

        var components = URLComponents(string: "\(server)/\(itemType)")
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "X-Emby-Token")
        request.httpMethod = "GET"
        
        if let (data, response) = try? await URLSession.shared.data(for: request) {
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return data
            }
        }
        
        return nil
    }
    
    func addToServer(queryItems: [URLQueryItem], path: String) {
        guard let server = serverUrl, let userId = userId, let token = accessToken else {
            return
        }
        
        var components = URLComponents(string: "\(server)/Users/\(userId)/\(path)")
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "X-Emby-Token")
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            
        }.resume()
    }
    
    func removeFromServer(queryItems: [URLQueryItem], path: String) {
        guard let server = serverUrl, let userId = userId, let token = accessToken else {
            return
        }
        
        var components = URLComponents(string: "\(server)/Users/\(userId)/\(path)")
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "X-Emby-Token")
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            
        }.resume()
    }
}
