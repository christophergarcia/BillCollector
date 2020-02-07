//
//  BillViewController.swift
//  BillCollector
//
//  Created by Christopher Garcia on 5/4/16.
//  Copyright © 2016 Christopher Garcia. All rights reserved.
//

import UIKit

class BillViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    //MARK: Properties
    
    @IBOutlet weak var billNameTextField: UITextField!
    @IBOutlet weak var amountDueTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var estimateSwitch: UISwitch!
    weak var estimateIndicator: UIView!
    
    let df = DateFormatter(), nf = NumberFormatter(), datePicker = UIDatePicker()
    
    var billName: String = "",
        amountDue: NSDecimalNumber = NSDecimalNumber.zero,
        dueDate: Date = Date(),
        isEstimate: Bool = false,
        bill: Bill?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        df.dateFormat = "MMMM d, yyyy"
        nf.numberStyle = .currency
        nf.generatesDecimalNumbers = true
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 2
        nf.locale = Locale.current
        
        billNameTextField.delegate = self
        amountDueTextField.delegate = self
        dueDateTextField.delegate = self
        
        // Set up views if editing existing bill
        if let bill = bill {
            navigationItem.title = bill.billName
            billNameTextField.text = bill.billName
            amountDueTextField.text = nf.string(from: bill.amountDue)
            dueDateTextField.text = df.string(from: bill.dueDate as Date)
            estimateSwitch.isOn = bill.isEstimate
        }
        
        // Enable the Save button only if billNameTextField has a value
        checkValidBillData()
        
        // Add toolbar to decimal pad
        configureAmountDueField()
        
        // Add toolbar to date picker
        configureDueDateField()
        
        // Configure selector action for switch
        estimateSwitch.addTarget(self, action: #selector(BillViewController.estimateSwitchChanged(_:)), for: UIControl.Event.valueChanged)
        
        // Add selector for textfield did change to format amount due
        amountDueTextField.addTarget(self, action: #selector(BillViewController.amountDueDidChange(_:)), for:UIControl.Event.editingChanged)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === amountDueTextField {
            let currentCharacterCount = textField.text?.characters.count ?? 0
            
            if (range.length + range.location > currentCharacterCount) {
                return false
            }
            
            let newLength = currentCharacterCount + string.characters.count - range.length
            
            return newLength <= 8
        }
        
        return true
    }
    
    @objc func amountDueDidChange(_ sender: UITextField) {
        var text = sender.text, textForFormatting = ""
        
        let digits = CharacterSet.decimalDigits
        
        for scalar in (text?.unicodeScalars)! {
            if digits.contains(UnicodeScalar(scalar.value)!) { textForFormatting.append(String(scalar)) }
        }
        
        let formattedValue = (NSString(string: textForFormatting).doubleValue) / 100
        let newText = nf.string(from: NSDecimalNumber(value: formattedValue))!
        amountDueTextField.text = newText
    }
    
    override func viewDidAppear(_ animated: Bool) {
        billNameTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case billNameTextField:
            amountDueTextField.becomeFirstResponder()
        case amountDueTextField:
            dueDateTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    
    func checkValidBillData() {
        var complete: Bool? = false
        
        if !(billNameTextField.text ?? "").isEmpty && !(amountDueTextField.text ?? "").isEmpty && !(dueDateTextField.text ?? "").isEmpty {
            complete = true
        }
        
        saveButton.isEnabled = complete!
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidBillData()
        navigationItem.title = billNameTextField.text
        textField.resignFirstResponder()
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Dismiss view controller in a manner fitting of its presentation style
        self.view.endEditing(true)
        let isPresentingInAddBillMode = presentingViewController is UINavigationController
        if isPresentingInAddBillMode {
            dismiss(animated: true, completion: nil)
        }
        else {
            navigationController!.popViewController(animated: true)
        }
    }

    func configureDueDateField() {
        datePicker.datePickerMode = .date
        
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.month, .day, .year], from: datePicker.date)
        components.day = 1
        components.month = components.month! + 1
        datePicker.date = calendar.date(from: components)!
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(BillViewController.dateFieldDoneButtonPressed(_:)))
        doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 40/255, green: 50/255, blue: 60/255, alpha: 1.0)], for: UIControl.State())
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        dueDateTextField.inputView = datePicker
        dueDateTextField.inputAccessoryView = toolBar
    }
    
    func configureAmountDueField() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(BillViewController.amountDueFieldDoneButtonPressed(_:)))
        doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 40/255, green: 50/255, blue: 60/255, alpha: 1.0)], for: UIControl.State())
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        amountDueTextField.inputAccessoryView = toolBar
    }
    
    @objc func dateFieldDoneButtonPressed(_ sender: UIButton){
        dueDateTextField.text = df.string(from: datePicker.date)
        dueDateTextField.resignFirstResponder()
    }
    
    @objc func amountDueFieldDoneButtonPressed(_ sender: UIButton){
        amountDueTextField.resignFirstResponder()
        dueDateTextField.becomeFirstResponder()
    }
    
    @objc func estimateSwitchChanged(_ sender: UISwitch) {
        checkValidBillData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if saveButton === sender as! UIBarButtonItem {
            bill = Bill(billName: billName, amountDue: amountDue, dueDate: dueDate, isEstimate: isEstimate)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var isValid = false
        var reformattedAmount: String
        
        reformattedAmount = amountDueTextField.text!.replacingOccurrences(of: ",", with: "")
        reformattedAmount = reformattedAmount.replacingOccurrences(of: "$", with: "")
        
        billName = billNameTextField.text ?? ""
        amountDue = NSDecimalNumber(string: reformattedAmount)
        dueDate = df.date(from: dueDateTextField.text!)!
        isEstimate = estimateSwitch.isOn
        
        if amountDue.compare(NSDecimalNumber.zero) == .orderedAscending {
            let alert = UIAlertController(title: "Invalid Bill Amount", message: "Your bill amount can't be a negative number, text, or empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            isValid = false
        }
        else {
            isValid = true
        }
        
        return isValid
    }
}

