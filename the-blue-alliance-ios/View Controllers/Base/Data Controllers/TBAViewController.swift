import Foundation
import UIKit
import CoreData

typealias DataController = Persistable & Refreshable & Alertable

class TBAViewController: UIViewController, DataController {
    
    var persistentContainer: NSPersistentContainer!
    var requests: [URLSessionDataTask] = []
    var dataView: UIView {
        return view
    }
    var refreshView: UIScrollView {
        return scrollView
    }
    var noDataView: UIView?
    @IBOutlet var scrollView: UIScrollView!
    var refreshControl: UIRefreshControl? {
        didSet {
            scrollView.refreshControl = refreshControl
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This allows us to see the no data view
        scrollView.backgroundColor = .clear
        view.backgroundColor = .backgroundGray

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        fatalError("Implement this downstream")
    }
    
    func shouldNoDataRefresh() -> Bool {
        fatalError("Implement this downstream")
    }
    
    // TODO: https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/133
    // FWIW, this name also sucks
    func optionallyShowNoDataView() {
        fatalError("Implement this downstream")
    }
}
