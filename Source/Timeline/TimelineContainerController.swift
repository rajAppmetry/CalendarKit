import UIKit

public class TimelineContainerController: UIViewController {
    /// Content Offset to be set once the view size has been calculated
    var pendingContentOffset: CGPoint?
    private var emptyView : UIView = UIView()
    lazy var timeline = TimelineView()
    lazy var container: TimelineContainer = {
       let view = TimelineContainer(timeline,emptyContainerView : emptyView)
        view.addSubview(timeline)
        view.addSubview(emptyView)
        return view
    }()
    
    public override func loadView() {
        view = container
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.contentSize = timeline.frame.size
        
        if let newOffset = pendingContentOffset {
            // Apply new offset only once the size has been determined
            if view.bounds != .zero {
                container.setContentOffset(newOffset, animated: false)
                container.setNeedsLayout()
                pendingContentOffset = nil
            }
        }
    }
}

