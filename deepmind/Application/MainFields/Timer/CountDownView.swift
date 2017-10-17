import UIKit
import SnapKit

class CountDownView : UIView {

  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  view component
  /* ------------------------------------ */
  private lazy var min : UILabel = {
    let l : UILabel = UILabel(frame: .zero)
    l.translatesAutoresizingMaskIntoConstraints = false
    l.font = UIFont(name: "HiraKakuProN-W3", size: 56)
    l.textAlignment = .center
    l.text = "00"
    return l
  }()
  private lazy var second : UILabel = {
    let l : UILabel = UILabel(frame: .zero)
    l.translatesAutoresizingMaskIntoConstraints = false
    l.font = UIFont(name: "HiraKakuProN-W3", size: 56)
    l.textAlignment = .center
    l.text = "00"
    
    return l
  }()
  private lazy var mili : UILabel = {
    let l : UILabel = UILabel(frame: .zero)
    l.translatesAutoresizingMaskIntoConstraints = false
    l.font = UIFont(name: "HiraKakuProN-W3", size: 56)
    l.textAlignment = .center
    l.text = "00"
    
    return l
  }()
  
  //  data
  /* ------------------------------------ */
  private var timer : Timer!
  private var time : Int = 0
  
  
  /* ------------------------------------------------------------------ */
  //  Function
  /* ------------------------------------------------------------------ */
  
  //  life cycle
  /* ------------------------------------ */
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //  setup
  /* ------------------------------------ */
  func setup() {
    setupTimeLabels()
  }
  func setupTimeLabels() {
    let horizontalView = makeHorizontalStackView()
    horizontalView.addArrangedSubview(min)
    horizontalView.addArrangedSubview(second)
    horizontalView.addArrangedSubview(mili)
    
    self.addSubview(horizontalView)
    horizontalView.snp.makeConstraints({ make in
      make.edges.equalToSuperview()
    })
    
    min.snp.makeConstraints({ make in
      make.width.equalToSuperview().dividedBy(3)
    })
    second.snp.makeConstraints({ make in
      make.width.equalToSuperview().dividedBy(3)
    })
    mili.snp.makeConstraints({ make in
      make.width.equalToSuperview().dividedBy(3)
    })
  }
  
  //  custom
  /* ------------------------------------ */
  func update(Down _time: Int){
    let newTime : Int = _time/100
    let min : Int = newTime/60
    let s : Int = newTime%60
    let mil : Int = _time - (newTime*100)
    
    self.min.text = ((min < 10) ? "0\(min)" : "\(min)")
    self.second.text = ((s < 10) ? "0\(s)" : "\(s)")
    self.mili.text = ((mil < 10) ? "0\(mil)" : "\(mil)")
  }
  func update(Up _time: Int){
    let newTime : Int = _time/100
    let min : Int = newTime/60
    let s : Int = newTime%60
    let mil : Int = _time - (newTime*100)
    
    self.min.text = ((min < 10) ? "0\(min)" : "\(min)")
    self.second.text = ((s < 10) ? "0\(s)" : "\(s)")
    self.mili.text = ((mil < 10) ? "0\(mil)" : "\(mil)")
  }
  func changeColorTo(Color _color:UIColor){
    self.min.textColor = _color
    self.second.textColor = _color
    self.mili.textColor = _color
  }
  func go(){
    if #available(iOS 10.0, *) {
      self.timer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true, block: {
        _ in
        //눈으로 보고있을때 시간이 -로 가는경우만 고려!
        if((self.time > -1) && (self.time < 7)){
          self.changeColorTo(Color: UIColor.red)
        }
        self.time -= 6
        if(self.time >= 0){
          self.update(Down: self.time)
        }else{
          self.update(Up: -self.time)
        }
      })
    } else {
      // Fallback on earlier versions
      
    }
  }
  func stop(){
    if(self.timer != nil){
      self.timer.invalidate()
    }else{
      log.error("끌 타이머가 없슴메")
    }
  }
  func set(Time _time: Int){
    self.time = _time
    if(time >= 0){
      self.changeColorTo(Color: UIColor.black)
    }else{
      self.changeColorTo(Color: UIColor.red)
    }
  }
  func makeHorizontalStackView() -> UIStackView {
    let horizontalStackView = UIStackView()
    horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
    horizontalStackView.axis = UILayoutConstraintAxis.horizontal
    horizontalStackView.distribution = UIStackViewDistribution.equalCentering
    return horizontalStackView
  }
}
