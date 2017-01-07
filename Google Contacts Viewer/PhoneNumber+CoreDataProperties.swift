//
//  PhoneNumber+CoreDataProperties.swift
//  Google Contacts Viewer
//
//  Created by Kalyan Vishnubhatla on 12/18/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PhoneNumber {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhoneNumber> {
        return NSFetchRequest<PhoneNumber>(entityName: "PhoneNumber");
    }

    @NSManaged public var number: String?
    @NSManaged public var contact: GoogleContact?

}
