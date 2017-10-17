import UIKit
import Charts
import Alamofire
import SwiftyJSON
import SwiftSpinner

class PointViewController : UIViewController, ChartViewDelegate {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  view component
  /* ------------------------------------ */
  lazy var chartView : PieChartView = {
    let cv = PieChartView(frame: self.view.frame)
    cv.entryLabelColor = UIColor.white
    cv.entryLabelFont = UIFont(name: "HelveticaNeue-Light", size: CGFloat(12.0))!
    cv.delegate = self
    return cv
  }()
  
  //  data
  /* ------------------------------------ */
  var usablePoints : [Int]!
  var rankPoint : Int = 0
  
  
  /* ------------------------------------------------------------------ */
  //  Function
  /* ------------------------------------------------------------------ */
  
  //  life cycle
  /* ------------------------------------ */
  override func viewDidLoad() {
    log.verbose("called")
  }
  override func viewWillAppear(_ animated: Bool) {
    log.verbose("called")
    //SwiftSpinner.show("Loading...")
  }
  override func viewDidAppear(_ animated: Bool) {
    log.verbose("called")
    
    let url = "\(BASE_URL)/point.php?total_team_count=\(mSettings.sharedInstance.totalTeamCount)"
    log.debug(url)
    let params : [String : Int] = ["our_team":mSettings.sharedInstance.ourTeam, "total_team_count":mSettings.sharedInstance.totalTeamCount]
    
    Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
      if let result = response.result.value {
        let json = JSON(result)
        log.verbose(["json points --> " , json])
        guard let response_code = json["response_code"].int, response_code == 201 else {
          log.error("FAIL ON GET POINTS")
          return
        }
        if let ups = json["value"]["usable_points"].array, let rp = json["value"]["rank_point"].int {
          self.rankPoint = rp
          self.usablePoints = ups.map({ v in return Int(v.stringValue)! })
          log.verbose(["usablePoints --> " , self.usablePoints])
          log.verbose(["rankPoint --> " , self.rankPoint])
          //이제부터 작업 들어갑니다
          self.setupChartView()
          self.setDataCount(self.usablePoints.count, range: 1.0)
        }
      }
    })
  }
  override func viewWillLayoutSubviews() {
    log.verbose("called")
  }
  override func viewDidLayoutSubviews() {
    log.verbose("called")
  }
  
  //  setup
  /* ------------------------------------ */
  func setupChartView() {
    self.view.addSubview(chartView)
    chartView.snp.makeConstraints({ make in
      make.edges.equalToSuperview()
    })
    
    chartView.usePercentValuesEnabled = false
    chartView.drawSlicesUnderHoleEnabled = false
    chartView.holeRadiusPercent = 0.5
    chartView.transparentCircleRadiusPercent = 0.58
    chartView.chartDescription = nil
    chartView.setExtraOffsets(left: 5.0, top: 10.0, right: 5.0, bottom: 5.0)
    chartView.drawCenterTextEnabled = true
    
    let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
    paragraphStyle.alignment = NSTextAlignment.center
    
    let centerText = NSMutableAttributedString(string: "\(self.rankPoint)점")
    centerText.setAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: CGFloat(32.0))!, NSParagraphStyleAttributeName: paragraphStyle], range: NSRange(location: 0, length: centerText.length))
    
    chartView.centerAttributedText = centerText
    chartView.drawHoleEnabled = true
    chartView.rotationAngle = 0.0
    chartView.rotationEnabled = true
    chartView.highlightPerTapEnabled = true
  }
  func setDataCount(_ count: Int, range: Double) {
    var values = [ChartDataEntry]()
    log.debug(count)
    for i in 0..<count {
      //let randomValue : Double = Double(arc4random_uniform(UInt32(mult))) + (mult/5)
      values.append(PieChartDataEntry(value: Double(self.usablePoints[i]), label: "\(i+1)팀"))
    }
    let dataSet = PieChartDataSet(values: values, label: "모든 팀 점수")
    dataSet.sliceSpace = 2.0
    // add a lot of colors
    var colors = [UIColor]()
    colors = ChartColorTemplates.vordiplom()
    colors.append(UIColor(red: CGFloat(51 / 255.0), green: CGFloat(181 / 255.0), blue: CGFloat(229 / 255.0), alpha: CGFloat(1.0)))
    
    dataSet.colors = colors
    let data = PieChartData(dataSet: dataSet)
    let pFormatter = NumberFormatter()
    pFormatter.numberStyle = .decimal
    //pFormatter.maximumFractionDigits = 1
    //pFormatter.multiplier! = 1.0
    //pFormatter.percentSymbol = " %"
    data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
    data.setValueFont(UIFont(name: "HelveticaNeue-Medium", size: CGFloat(16.0))!)
    data.setValueTextColor(UIColor.black)
    self.chartView.data = data
    chartView.highlightValues(nil)
  }
}
