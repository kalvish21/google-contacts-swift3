//
//  EmailAddress+CoreDataProperties.swift
//  Google Contacts Viewer
//
//  Created by Kalyan Vishnubhatla on 12/19/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension EmailAddress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EmailAddress> {
        return NSFetchRequest<EmailAddress>(entityName: "EmailAddress");
    }

    @NSManaged public var email: String?
    @NSManaged public var contact: GoogleContact?

}
