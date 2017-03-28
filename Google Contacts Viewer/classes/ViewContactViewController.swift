//
//  ViewContactViewController.swift
//  Google Contacts Viewer
//
//  Created by Kalyan Vishnubhatla on 12/19/16.
//
//

import Foundation
import CoreData
import MessageUI

class ViewContactViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    var doc: GoogleContact!
    
    init(coreDataId: NSManagedObjectID) {
        super.init(style: .grouped)
        
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        doc = context.object(with: coreDataId) as! GoogleContact
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "View contact"
        self.tableView.tableHeaderView = getTableViewHeader()
    }
    
    func getName() -> String {
        if doc.name != nil {
            return doc.name!
        } else if doc.email != nil {
            return doc.email!
        } else if doc.numbers!.count > 0 {
            let number = doc.numbers?.object(at: 0) as! PhoneNumber
            return number.number!
        } else {
            return "N/A"
        }
    }
    
    func getTableViewHeader() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: MainScreenWidth, height: 155))
        
        // Add imageView
        let size = CGFloat(100.0)
        let imageView = UIImageView(frame: CGRect(x: (MainScreenWidth - size) / 2, y: (120 - size) / 2, width: size, height: size))
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        if doc.url != nil {
            imageView.sd_setImage(with: NSURL(string: doc.url!) as! URL, placeholderImage:UIImage(named:"contacts_big.png")!)
        } else {
            imageView.image = UIImage(named:"contacts_big.png")
        }
        view.addSubview(imageView)
        
        // Add label
        let label = UILabel(frame: CGRect(x: 5, y: 135, width: MainScreenWidth - 10, height: 20))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.text = getName()
        view.addSubview(label)
        
        return view
    }
    
    // TableView delegate methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Phone numbers"
        }
        return "Email addresses"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return doc.numbers!.count
        } else if doc.email != nil {
            return 1 + doc.emails!.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            let CellIdentifier = "ViewControllerTableViewCell"
            var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: CellIdentifier)
                cell?.selectionStyle = UITableViewCellSelectionStyle.gray
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 16)
            }
            return cell!
        } ()
        
        if indexPath.section == 0 {
            cell.textLabel?.text = (doc.numbers![indexPath.row] as! PhoneNumber).number
        } else {
            if indexPath.row == 0 {
                cell.textLabel?.text = doc.email!
            } else {
                cell.textLabel?.text = (doc.emails![indexPath.row-1] as! EmailAddress).email
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let alert = UIAlertController(title: "Confirm", message: "Call this number?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Yes", style: .default) { (action) in
                let number = (self.doc.numbers![indexPath.row] as! PhoneNumber).number!
                self.callNumber(phoneNumber: number)
                alert.dismiss(animated: true, completion: nil)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            self.navigationController?.present(alert, animated: true, completion: nil)
        } else {
            
            let mailComposeViewController = self.configuredMailComposeViewController(email: self.doc.email!)
            if !(mailComposeViewController != nil && MFMailComposeViewController.canSendMail()) {
                // If it's nil then there is a system dialog already
                if (mailComposeViewController != nil) {
                    self.showSendMailErrorAlert()
                }
                return
            }
            
            if indexPath.row == 0 {
                self.present(mailComposeViewController!, animated: true, completion: nil)
            } else {
                let mail = self.configuredMailComposeViewController(email: (doc.emails![indexPath.row-1] as! EmailAddress).email!)
                self.present(mail!, animated: true, completion: nil)
            }
        }
    }
    
    // Call phone number
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:URL = URL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    // Sending email
    func showSendMailErrorAlert() {
        let alert = UIAlertController(title: "No Mail Accounts", message: "Please set up a Mail account in order to send email.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func configuredMailComposeViewController(email: String) -> MFMailComposeViewController? {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([email])
        mailComposerVC.setSubject("Inquiry")
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
