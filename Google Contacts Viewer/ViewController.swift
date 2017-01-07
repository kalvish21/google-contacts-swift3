//
//  ViewController.swift
//  Google Contacts Viewer
//
//  Created by Kalyan Vishnubhatla on 12/13/16.
//
//

import UIKit
import Foundation
import Google
import CoreData
import SDWebImage
import CRToast

class ViewController: UITableViewController, GIDSignInUIDelegate {

    static let cacheName: String? = "ViewControllerCacheName"
    private var _fetchedResultsController: NSFetchedResultsController<GoogleContact>?
    private var fetchedResultsController: NSFetchedResultsController<GoogleContact> {
        get {
            if (_fetchedResultsController == nil) {
                let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = delegate.persistentContainer.viewContext
                
                let query = NSFetchRequest<GoogleContact>(entityName: "GoogleContact")
                query.sortDescriptors = [
                    NSSortDescriptor(key: "name", ascending: true),
                    NSSortDescriptor(key: "email", ascending: true),
                    NSSortDescriptor(key: "primaryPhoneNumber", ascending: true)
                ]
                
                _fetchedResultsController = NSFetchedResultsController(fetchRequest: query, managedObjectContext: context, sectionNameKeyPath: "name", cacheName: ViewController.cacheName)
                _fetchedResultsController?.delegate = FetchDelegate(tableView: self.tableView)
            }
            return _fetchedResultsController!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Contacts"
        GIDSignIn.sharedInstance().uiDelegate = self
        self.loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name(rawValue: DataChanged), object: nil)
        
        self.setBarButtonItems()
    }
    
    func setBarButtonItems() {
        // Set the bar button items
        let token = UserDefaults.standard.string(forKey: UserAccessToken)
        if token == nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign in", style: .plain, target: self, action: #selector(signIn))
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(signOut))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        }
    }
    
    func signIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func signOut() {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            GIDSignIn.sharedInstance().signOut()
            
            UserDefaults.standard.removeObject(forKey: UserAccessToken)
            UserDefaults.standard.synchronize()
            
            let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            delegate.clearCoreDataStore()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: DataChanged), object: nil)
            
            alert.dismiss(animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func refresh() {
        let options = [
            kCRToastTextKey: "Refreshing data ...",
            kCRToastTextAlignmentKey : kCAAlignmentCenter,
            kCRToastBackgroundColorKey : UIColor.colorFromHex(rgbValue: 0x518793),
            kCRToastAnimationInTypeKey : CRToastAnimationType.gravity,
            kCRToastAnimationOutTypeKey : CRToastAnimationType.gravity,
            kCRToastAnimationInDirectionKey : CRToastAnimationDirection.left,
            kCRToastAnimationOutDirectionKey : CRToastAnimationDirection.right
            ] as [String : Any]
        CRToastManager.showNotification(options: options, completionBlock: nil)
        
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.contactsHandler.loadContacts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        self.setBarButtonItems()
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: ViewController.cacheName)
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            NSLog("Unresolved error %@", [error.localizedDescription])
            exit(-1)
        }
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections?[section] as NSFetchedResultsSectionInfo!
        if sectionInfo == nil {
            return 0
        }
        return sectionInfo!.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            let CellIdentifier = "ViewControllerTableViewCell"
            var cell: ContactCell? = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? ContactCell
            if (cell == nil) {
                cell = ContactCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: CellIdentifier)
                cell?.selectionStyle = UITableViewCellSelectionStyle.gray
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 16)
                cell?.accessoryType = .disclosureIndicator
            }
            return cell!
        } ()
        
        let doc: GoogleContact = self.fetchedResultsController.object(at: indexPath as IndexPath)
        if doc.name != nil {
            cell.textLabel?.text = doc.name
        } else if doc.email != nil {
            cell.textLabel?.text = doc.email
        } else if doc.numbers!.count > 0 {
            let number = doc.numbers?.object(at: 0) as! PhoneNumber
            cell.textLabel?.text = number.number
        } else {
            cell.textLabel?.text = "N/A"
        }
        
        if doc.url != nil {
            cell.imageView!.sd_setImage(with: NSURL(string: doc.url!) as! URL, placeholderImage:UIImage(named:"contacts.png")!)
        } else {
            cell.imageView!.image = UIImage(named:"contacts.png")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let doc: GoogleContact = self.fetchedResultsController.object(at: indexPath as IndexPath)
        print(doc)
        
        let controller = ViewContactViewController(coreDataId: doc.objectID)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
