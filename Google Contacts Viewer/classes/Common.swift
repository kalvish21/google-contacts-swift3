//
//  Common.swift
//  Google Contacts Viewer
//
//  Created by Kalyan Vishnubhatla on 12/18/16.
//
//

let MainScreenWidth: CGFloat = UIScreen.main.bounds.size.width
let MainScreenHeight: CGFloat = UIScreen.main.bounds.size.height


// Google constants
let Scope = "https://www.googleapis.com/auth/contacts.readonly"
let ContactsEndPointURLString = "https://www.google.com/m8/feeds/contacts/default/thin?max-results=10000"
let ClientId = "YOUR_KEY"

// UserDefault Keys
let UserAccessToken = "UserAccessToken"

// Notification Keys
let DataChanged: String = "DataChanged"
