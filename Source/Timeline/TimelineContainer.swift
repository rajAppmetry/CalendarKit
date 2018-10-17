import UIKit

public class TimelineContainer: UIScrollView, ReusableView {
    
    public let timeline: TimelineView
    public let emptyContainerView : UIView
    
    public init(_ timeline: TimelineView,emptyContainerView : UIView) {
        self.timeline = timeline
        self.emptyContainerView = emptyContainerView
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func showEmptyViewIfNeeded() {
        if self.timeline.layoutAttributes.isEmpty {
            print("showing empty view")
            self.timeline.isHidden = true
            self.isScrollEnabled = false
            self.emptyContainerView.isHidden = false
            emptyContainerView.subviews.forEach { $0.frame = emptyContainerView.bounds  }
        } else {
            print("hideing empty view")
            self.emptyContainerView.isHidden = true
            self.isScrollEnabled = true
            self.timeline.isHidden = false
        }
    }
    
    override public func layoutSubviews() {
        timeline.frame = CGRect(x: 0, y: 0, width: width, height: timeline.fullHeight)
        timeline.offsetAllDayView(by: contentOffset.y)
        emptyContainerView.frame = self.bounds
        
        showEmptyViewIfNeeded()
        
        //adjust the scroll insets
        let allDayViewHeight = timeline.allDayViewHeight
        let bottomSafeInset: CGFloat
        if #available(iOS 11.0, *) {
            bottomSafeInset = window?.safeAreaInsets.bottom ?? 0
        } else {
            bottomSafeInset = 0
        }
        scrollIndicatorInsets = UIEdgeInsets(top: allDayViewHeight, left: 0, bottom: bottomSafeInset, right: 0)
        contentInset = UIEdgeInsets(top: allDayViewHeight, left: 0, bottom: bottomSafeInset, right: 0)
    }
    
    public func reloadEmptyView() {
        //emptyContainerView.subviews.forEach { $0.removeFromSuperview() }
        if let view = timeline.delegate?.getEmptyView() {
            emptyContainerView.subviews.forEach { $0.removeFromSuperview() }
            print("creating empty view")
            view.frame = emptyContainerView.bounds
            emptyContainerView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.leadingAnchor.constraint(equalTo: emptyContainerView.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: emptyContainerView.trailingAnchor).isActive = true
            view.topAnchor.constraint(equalTo: emptyContainerView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: emptyContainerView.bottomAnchor).isActive = true
        } else {
            print("invalid timeline delegate")
        }
        
        showEmptyViewIfNeeded()
    }
    
    public func prepareForReuse() {
        timeline.prepareForReuse()
    }
    
    public func scrollToFirstEvent() {
        let allDayViewHeight = timeline.allDayViewHeight
        let padding = allDayViewHeight + 8
        if let yToScroll = timeline.firstEventYPosition {
            setTimelineOffset(CGPoint(x: contentOffset.x, y: yToScroll - padding), animated: true)
        }
    }
    
    public func scrollTo(hour24: Float) {
        let percentToScroll = CGFloat(hour24 / 24)
        let yToScroll = contentSize.height * percentToScroll
        let padding: CGFloat = 8
        setTimelineOffset(CGPoint(x: contentOffset.x, y: yToScroll - padding), animated: true)
    }
    
    private func setTimelineOffset(_ offset: CGPoint, animated: Bool) {
        let yToScroll = offset.y
        let bottomOfScrollView = contentSize.height - bounds.size.height
        let newContentY = (yToScroll < bottomOfScrollView) ? yToScroll : bottomOfScrollView
        setContentOffset(CGPoint(x: offset.x, y: newContentY), animated: animated)
    }
}
