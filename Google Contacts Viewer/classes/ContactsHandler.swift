//
//  ContactsHandler.swift
//  Google Contacts Viewer
//
//  Created by Kalyan Vishnubhatla on 12/18/16.
//
//

import Foundation
import CoreData
import SDWebImage
import libPhoneNumber_iOS

class ContactsHandler: NSObject, GIDSignInDelegate, XMLParserDelegate {
    
    private var networkController : NetworkController!
    private var xmlParser : XMLParser? = nil
    private var accessToken : String?
    
    private var parsingBuffer : String = ""
    private var parsingAttributes = [String : String]()
    private var context: NSManagedObjectContext!
    private var currentObject: GoogleContact?

    override init() {
        super.init()
        
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = [Scope]
        GIDSignIn.sharedInstance().clientID = ClientId
        
        
        let token = UserDefaults.standard.string(forKey: UserAccessToken)
        if token != nil {
            GIDSignIn.sharedInstance().signInSilently()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            self.accessToken = user.authentication.accessToken
            
            UserDefaults.standard.set(self.accessToken, forKey: UserAccessToken)
            UserDefaults.standard.synchronize()
            
            let formattedToken: String = String(format: "Bearer %@", self.accessToken!)
            let manager = SDWebImageManager.shared().imageDownloader
            manager!.setValue(formattedToken, forHTTPHeaderField: "Authorization")
            manager!.setValue("3.0", forHTTPHeaderField: "GData-Version")
            
            self.networkController = NetworkController(accessToken: self.accessToken!)
            loadContacts()
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    public func loadContacts() {
        let contactsURL : NSURL = NSURL(string: ContactsEndPointURLString)!
        self.networkController.sendRequestToURL(url: contactsURL, completion: { (data, response, error) -> () in
            if (response?.statusCode == 200 && error == nil) {
                
                DispatchQueue.global(qos: .background).async {
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    self.context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    self.context.parent = delegate.persistentContainer.viewContext
                    
                    self.parseContactsFromData(data: data!)
                }
                
            } else {
            }
        })
    }
    
    private func parseContactsFromData(data : NSData) {
        self.parsingBuffer = ""
        self.xmlParser = XMLParser.init(data: data as Data)
        self.xmlParser?.delegate = self
        self.xmlParser?.parse()
    }
    
    // XML Parser delegate methods
    func parserDidStartDocument(_ parser: XMLParser) {
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.clearCoreDataStore()
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        do {
            try self.context.save()
        } catch let error as NSError {
            NSLog("Unresolved error: %@, %@", error, error.userInfo)
        }
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.persistentContainer.viewContext.perform({
            do {
                try delegate.persistentContainer.viewContext.save()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: DataChanged), object: nil)
            } catch let error as NSError {
                NSLog("Unresolved error: %@, %@", error, error.userInfo)
            } catch {
                fatalError()
            }
        })
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.parsingBuffer = ""
        self.parsingAttributes = attributeDict
        
        if elementName == "entry" {
            self.currentObject = GoogleContact(context: self.context)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.parsingBuffer += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "gd:fullName" {
            NSLog("%@", self.parsingBuffer)
            self.currentObject!.name = self.parsingBuffer
            
        } else if elementName == "gd:email" {
            NSLog("%@", self.parsingBuffer)
            
            if self.parsingAttributes["primary"] != nil || self.currentObject!.value(forKey: "email") == nil {
                self.currentObject!.setValue(self.parsingAttributes["address"]! as String, forKey: "email")
            } else {
                let email = EmailAddress(context: self.context)
                email.email = self.parsingAttributes["address"]! as String
                self.currentObject!.addToEmails(email)
            }
            
        } else if elementName == "gd:phoneNumber" {
            NSLog("%@", self.parsingBuffer)
            let fmt = NBPhoneNumberUtil()
            do {
                var nb_number: NBPhoneNumber? = nil
                try nb_number = fmt.parse(self.parsingBuffer, defaultRegion: "US")
                try self.parsingBuffer = fmt.format(nb_number!, numberFormat: .INTERNATIONAL)
            } catch let error as NSError {
                NSLog("error")
            }

            let number = PhoneNumber(context: self.context)
            number.number = self.parsingBuffer
            self.currentObject!.addToNumbers(number)
            self.currentObject!.primaryPhoneNumber = self.parsingBuffer
            
        } else if elementName == "link" {
            let rel = self.parsingAttributes["rel"]
            if rel == "http://schemas.google.com/contacts/2008/rel#photo" {
                self.currentObject!.setValue(self.parsingAttributes["href"]! as String, forKey: "url")
                NSLog("%@", self.parsingAttributes["href"]! as String)
            }
        }
    }
}
