//
//  RatesController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 13/11/2020.
//

import UIKit

struct Response: Decodable {
    let base: String
    let date: String
    let rates: Dictionary<String, Double>
}

class RatesController: UIViewController {
    @IBOutlet weak var eurView: ERView!
    @IBOutlet weak var eurLabel: UILabel!
    @IBOutlet weak var eurValueLabel: UILabel!
    @IBOutlet weak var baseLabel1: UILabel!
    
    @IBOutlet weak var usdView: ERView!
    @IBOutlet weak var usdLabel: UILabel!
    @IBOutlet weak var usdValueLabel: UILabel!
    @IBOutlet weak var baseLabel2: UILabel!
    
    @IBOutlet weak var gbpView: ERView!
    @IBOutlet weak var gbpLabel: UILabel!
    @IBOutlet weak var gbpValueLabel: UILabel!
    @IBOutlet weak var baseLabel3: UILabel!
    
    @IBOutlet weak var jpyView: ERView!
    @IBOutlet weak var jpyLabel: UILabel!
    @IBOutlet weak var jpyValueLabel: UILabel!
    @IBOutlet weak var baseLabel4: UILabel!
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var lastUpdatedLabelTitle: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    var usdVal: Double = Double()
    var eurVal: Double = Double()
    var gbpVal: Double = Double()
    var jpyVal: Double = Double()
    var lastUpdated: Date = Date()
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDateFormatter()
        setupLabels()
        setupShadows()
        
        eurView.setupViewStyle()
        usdView.setupViewStyle()
        gbpView.setupViewStyle()
        jpyView.setupViewStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getERData()
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        getERData()
    }
    
    func getERData() {
        print("GETTING ER DATA")
        if let url = URL(string: "https://api.exchangeratesapi.io/latest?symbols=EUR,USD,GBP,JPY&base=CZK") {
            URLSession.shared.dataTask(with: url) { [self]
                data, response, error in
                if let data = data {
                    let jd = JSONDecoder()
                    do {
                        let parsed = try jd.decode(Response.self, from: data)
                        eurVal = 1 / parsed.rates["EUR"]!
                        usdVal = 1 / parsed.rates["USD"]!
                        gbpVal = 1 / parsed.rates["GBP"]!
                        jpyVal = 1 / parsed.rates["JPY"]!
                        lastUpdated = Date()
                        
                        DispatchQueue.main.async {
                            updateValues()
                            lastUpdatedLabel.text = dateFormatter.string(from: lastUpdated)
                        }
                    } catch let error {
                        print("AN ERROR OCCURED: \(error)")
                    }
                }
            }.resume()
        }
    }
    
    func setupDateFormatter() {
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = .current
    }
    
    func setupLabels() {
        eurLabel.text = "EUR"
        usdLabel.text = "USD"
        gbpLabel.text = "GBP"
        jpyLabel.text = "JPY"
        
        baseLabel1.text = "CZK"
        baseLabel2.text = "CZK"
        baseLabel3.text = "CZK"
        baseLabel4.text = "CZK"
        
        eurValueLabel.font = UIFont.monospacedSystemFont(ofSize: 25, weight: .bold)
        usdValueLabel.font = UIFont.monospacedSystemFont(ofSize: 25, weight: .bold)
        gbpValueLabel.font = UIFont.monospacedSystemFont(ofSize: 25, weight: .bold)
        jpyValueLabel.font = UIFont.monospacedSystemFont(ofSize: 25, weight: .bold)
        lastUpdatedLabel.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        
        lastUpdatedLabelTitle.textColor = .secondaryLabel
        lastUpdatedLabel.textColor = .secondaryLabel
    }
    
    func updateValues() {
        eurValueLabel.text = String(format: "%.4f", eurVal)
        usdValueLabel.text = String(format: "%.4f", usdVal)
        gbpValueLabel.text = String(format: "%.4f", gbpVal)
        jpyValueLabel.text = String(format: "%.4f", jpyVal)
    }
    
    func setupShadows() {
        updateButton.layer.shadowColor = UIColor.black.cgColor
        updateButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        updateButton.layer.shadowRadius = 5
        updateButton.layer.shadowOpacity = 0.1
    }
}