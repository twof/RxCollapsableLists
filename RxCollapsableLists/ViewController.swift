import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxGesture

struct CustomData {
    var anInt: Int
    var aString: String
    var aCGPoint: CGPoint
}

struct SectionOfCustomData {
    var header: String
    var items: [Item]
    
    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
}

extension SectionOfCustomData: SectionModelType {
    typealias Item = CustomData
    
    init(original: SectionOfCustomData, items: [Item]) {
        self = original
        self.items = items
    }
}

extension SectionOfCustomData: Hashable {
    var hashValue: Int {
        return self.header.hashValue
    }

    static func ==(lhs: SectionOfCustomData, rhs: SectionOfCustomData) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

class ViewController: UIViewController {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let disposeBag = DisposeBag()
    
    let collapsed = Variable<[SectionOfCustomData: Bool]>([:])
    var datasource: RxTableViewSectionedReloadDataSource<SectionOfCustomData>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setup() {
        setupViews()
        setupConstraints()
        rxSetup()
    }
    
    func rxSetup() {
        let sections = [
            SectionOfCustomData(header: "First section", items: [CustomData(anInt: 0, aString: "zero", aCGPoint: CGPoint.zero), CustomData(anInt: 1, aString: "one", aCGPoint: CGPoint(x: 1, y: 1)) ]),
            SectionOfCustomData(header: "Second section", items: [CustomData(anInt: 2, aString: "two", aCGPoint: CGPoint(x: 2, y: 2)), CustomData(anInt: 3, aString: "three", aCGPoint: CGPoint(x: 3, y: 3)) ])
        ]
        
        collapsed.value = sections.reduce(into: [:], { $0[$1] = false })
        
        let configureCell = { (ds: TableViewSectionedDataSource<SectionOfCustomData>, tv: UITableView, ip: IndexPath, item: SectionOfCustomData.Item) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell", for: ip)
            cell.textLabel?.text = "Item \(item.anInt): \(item.aString) - \(item.aCGPoint.x):\(item.aCGPoint.y)"
            return cell
        }
      
        self.datasource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>(configureCell: configureCell)
       
        let sectionsObservable = Observable.just(sections)
        
        let collapsedSectionObservable = Observable.combineLatest(sectionsObservable, collapsed.asObservable())
            .map({ (sections, collapsedDS) -> [SectionOfCustomData] in
          
            return sections.map({ (aSection) -> SectionOfCustomData in
                guard let isCollapsed = collapsedDS[aSection] else {return aSection}
                return !isCollapsed ? aSection : SectionOfCustomData(original: aSection, items: [])
            })
        })
        
        collapsedSectionObservable
            .bind(to: tableView.rx.items(dataSource: datasource!))
            .disposed(by: disposeBag)
    }
    
    func setupViews() {
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(CustomHeaderView.self, forHeaderFooterViewReuseIdentifier: CustomHeaderView.identifier)
        self.view.addSubview(tableView)
    }
    
    
    func setupConstraints() {
        let tableViewConstraints: [NSLayoutConstraint] = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(
            tableViewConstraints
        )
    }
}


extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomHeaderView.identifier)
        guard let header = view as? CustomHeaderView else {
            assertionFailure("Expected a CustomHeaderView.")
            return nil
        }
        header.titleLabel.text = "hello"
        
        guard let item = self.datasource?[section],
            let isCollapsed = self.collapsed.value[item] else { return header }
        
        header.titleLabel.text = item.header
        
        header.rx.tapGesture().when(.recognized).subscribe({ _ in
            self.collapsed.value[item] = !isCollapsed
        }).disposed(by: disposeBag)
        
        return header
    }
}

