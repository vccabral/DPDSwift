//
//  DPDCredenntials.swift
//  DPDSwift
//
//Created by Sylveus, Steeven on 11/8/18.
//

import UIKit

open class DPDCredentials: DPDObject {
    
    public var accessToken: String?
    public var installationId: String?
    public var sessionId: String?
    
    fileprivate static let appCredentialKey = "AppCredentials"
    
    public static let sharedCredentials = DPDCredentials.loadSaved()
    
    private enum CodingKeys: String, CodingKey {
        case accessToken
        case installationId
        case sessionId
    }
    
    override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try? container.decode(String.self, forKey: .accessToken)
        self.installationId = try? container.decode(String.self, forKey: .installationId)
        self.sessionId = try? container.decode(String.self, forKey: .sessionId)
        try super.init(from: decoder)
    }
    
    override open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(accessToken, forKey: .accessToken)
        try? container.encode(installationId, forKey: .installationId)
        try? container.encode(sessionId, forKey: .sessionId)
        try? super.encode(to: encoder)
    }
    
    func save() {
        do {
           let data = try encode()
            UserDefaults.standard.set(data, forKey: DPDCredentials.appCredentialKey)
            UserDefaults.standard.synchronize()
        } catch  {
            print("Unable to save credentials")
        }
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: DPDCredentials.appCredentialKey)
    }
    
    class func loadSaved() -> DPDCredentials {
        if let data = UserDefaults.standard.object(forKey: DPDCredentials.appCredentialKey) as? Data {
            do {
                let credentials = try JSONDecoder().decode(DPDCredentials.self, from: data)
                return credentials
            } catch {
                return DPDCredentials()
            }
        }
        
        return DPDCredentials()
    }
    
    class func generateDeviceId() {
        let uuid = UUID().uuidString
        DPDCredentials.sharedCredentials.installationId = uuid
        
        DPDCredentials.sharedCredentials.save()
    }
    
}
