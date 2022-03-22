//
//  BillTableViewController.swift
//  BillCollector
//
//  Created by Christopher Garcia on 5/6/16.
//  Copyright © 2016 Christopher Garcia. All rights reserved.
//

import UIKit

class BillTableViewController: UITableViewController {
    
    // MARK: Properties
    //test
    
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var nextTotal: UILabel!
    
    var bills = [Bill]()
    var isOverdue: Bool = false
    
    let df = DateFormatter()
    let nf = NumberFormatter()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        df.dateFormat = "MMMM d, yyyy"
        
        nf.numberStyle = .currency
        
        if let savedBills = loadBills() {
            bills += savedBills
        }
        
        updateTotal()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let defaults = UserDefaults.standard
        
        if (defaults.bool(forKey: "firstLaunch")) {
            UIApplication.shared.isStatusBarHidden = true
            let onboarder = self.storyboard?.instantiateViewController(withIdentifier: "OnboardingPageViewController") as! OnboardingPageViewController
            self.navigationController?.present(onboarder, animated: false, completion: nil)
            defaults.set(false, forKey: "firstLaunch")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bills.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillTableViewCell", for: indexPath) as! BillTableViewCell

        let bill = bills[(indexPath as NSIndexPath).row]
        
        let now = Date()
        
        cell.billNameLabel.text = bill.billName
        cell.amountDueLabel.text = nf.string(from: bill.amountDue)
        cell.dueDateLabel.text = df.string(from: bill.dueDate as Date)
        cell.isEstimateIndicator.isHidden = !bill.isEstimate
        
        isOverdue = (bill.dueDate.compare(now) == .orderedAscending) ? true : false

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! BillTableViewCell
        
        cell.billNameLabel.textColor = (isOverdue) ? UIColor.red : UIColor.darkGray
        cell.dueDateLabel.textColor = (isOverdue) ? UIColor.red : UIColor.darkGray
        cell.amountDueLabel.textColor = (isOverdue) ? UIColor.red : UIColor.darkGray
    }
    
    @IBAction func unwindToBillList(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? BillViewController, let bill = sourceViewController.bill {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                bills[(selectedIndexPath as NSIndexPath).row] = bill
                bills.sort {
                    let dateComparisonResult = $0.dueDate.compare($1.dueDate as Date)
                    if dateComparisonResult == .orderedSame {
                        return $0.billName.lowercased() < $1.billName.lowercased()
                    }
                    return dateComparisonResult == .orderedAscending
                }
                
                tableView.reloadData()
            }
            else {
                bills.append(bill)
                bills.sort {
                    let dateComparisonResult = $0.dueDate.compare($1.dueDate as Date)
                    if dateComparisonResult == .orderedSame {
                        return $0.billName.lowercased() < $1.billName.lowercased()
                    }
                    return dateComparisonResult == .orderedAscending
                }
                
                tableView.reloadData()
            }
            
            saveBills()
        }
    }
    
    func loadBills() -> [Bill]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Bill.ArchiveURL.path) as? [Bill]
    }
    
    func saveBills() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(bills, toFile: Bill.ArchiveURL.path)
        
        if !isSuccessfulSave {
            print("Failed to save bills")
        }
        
        updateTotal()
    }
    
    func updateTotal() {
        var amount: NSDecimalNumber = 0
        for bill in bills {
            amount = amount.adding(bill.amountDue)
        }
        total.text = nf.string(from: amount)
    }
    

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let markPaidAction = UITableViewRowAction(style: .normal, title: "Mark Paid") { (rowAction:UITableViewRowAction, indexPath:IndexPath) -> Void in
            let calendar = Calendar.current
            var newDueDate = Date()
            
            newDueDate = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.month, value: 1, to: self.bills[(indexPath as NSIndexPath).row].dueDate as Date, options: [])!
            
            let newBill = Bill(billName: self.bills[(indexPath as NSIndexPath).row].billName, amountDue: self.bills[(indexPath as NSIndexPath).row].amountDue, dueDate: newDueDate, isEstimate: true)
            
            self.bills.remove(at: (indexPath as NSIndexPath).row)
            self.bills.append(newBill!)
            self.saveBills()
            self.bills.sort {
                let dateComparisonResult = $0.dueDate.compare($1.dueDate as Date)
                if dateComparisonResult == .orderedSame {
                    return $0.billName < $1.billName
                }
                return dateComparisonResult == .orderedAscending
            }
            
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
        
        markPaidAction.backgroundColor = UIColor(red: 66/255, green: 97/255, blue: 210/255, alpha: 1)
        
        let toggleEstimateAction = UITableViewRowAction(style: .normal, title: "Toggle Estimate") { (rowAction:UITableViewRowAction, indexPath:IndexPath) -> Void in
            self.bills[(indexPath as NSIndexPath).row].isEstimate = !self.bills[(indexPath as NSIndexPath).row].isEstimate
            self.saveBills()
            tableView.reloadRows(at: [indexPath], with: .left)
        }
        
        toggleEstimateAction.backgroundColor = UIColor(red: 255/255, green: 155/255, blue: 66/255, alpha: 1.0)
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (rowAction:UITableViewRowAction, indexPath:IndexPath) -> Void in
            self.bills.remove(at: (indexPath as NSIndexPath).row)
            self.saveBills()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        deleteAction.backgroundColor = UIColor(red: 255/255, green: 75/255, blue: 66/255, alpha: 1.0)
        
        return [deleteAction, markPaidAction, toggleEstimateAction]
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let billDetailViewController = segue.destination as! BillViewController
            
            if let selectedBillCell = sender as? BillTableViewCell {
                let indexPath = tableView.indexPath(for: selectedBillCell)!
                let selectedBill = bills[(indexPath as NSIndexPath).row]
                billDetailViewController.bill = selectedBill
            }
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        
    }
}
