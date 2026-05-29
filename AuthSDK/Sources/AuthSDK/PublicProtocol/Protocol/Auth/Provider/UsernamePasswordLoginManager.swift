//
//  UsernamePasswordLoginManager.swift
//  AuthSDK
//

import Foundation
import Combine

public protocol UsernamePasswordLoginManager {
    func login(username: String, password: String) -> AnyPublisher<AuthSessionResponse, Error> 

    func logout() -> AnyPublisher<DatalessResponse, Error> 
    
    func getAuthSesssion() -> AnyPublisher<AuthSessionResponse, Error>
    
    func getPhoneNumber() throws -> String?
    
    func getServerId() -> Int? 
    
    func getGameId() -> Int?
    
    func getCharacter(gameId: Int, serverId: Int) -> AnyPublisher<Void, Error>
}
