åimport UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct CustomData {
    var anInt: Int
    var aString: String
    var aCGPoint: CGPoint
}

struct SectionOfCustomData {
    var header: String
    var items: [Item]
}

extension SectionOfCustomData: SectionModelType {
    typealias Item = CustomData
    
    init(original: SectionOfCustomData, items: [Item]) {
        self = original
        self.items = items
    }
}

class ViewController: UIViewController {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let disposeBag = DisposeBag()
    
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
        let configureCell = { (ds: TableViewSectionedDataSource<SectionOfCustomData>, tv: UITableView, ip: IndexPath, item: SectionOfCustomData.Item) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell", for: ip)
            cell.textLabel?.text = "Item \(item.anInt): \(item.aString) - \(item.aCGPoint.x):\(item.aCGPoint.y)"
            return cell
        }
      
        let datasource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>(configureCell: configureCell)
        
        datasource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        
        let sections = [
            SectionOfCustomData(header: "First section", items: [CustomData(anInt: 0, aString: "zero", aCGPoint: CGPoint.zero), CustomData(anInt: 1, aString: "one", aCGPoint: CGPoint(x: 1, y: 1)) ]),
            SectionOfCustomData(header: "Second section", items: [CustomData(anInt: 2, aString: "two", aCGPoint: CGPoint(x: 2, y: 2)), CustomData(anInt: 3, aString: "three", aCGPoint: CGPoint(x: 3, y: 3)) ])
        ]
        
        Observable.just(sections)
            .bind(to: tableView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
    }
    
    func setupViews() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
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
    class CustomHeader: UITableViewHeaderFooterView {
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        <#code#>
    }
}

