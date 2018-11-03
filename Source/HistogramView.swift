import Cocoa

class HistogramView: NSView {
    let maxX:Int = Int(MAX_ITERATIONS)
    var xScale:CGFloat = 0
    
    var context : CGContext?
    var highest:Int32 = 0
    
    func percentX(_ percent:CGFloat) -> CGFloat { return CGFloat(bounds.size.width) * percent }
    
    override func draw(_ rect: CGRect) {
        context = NSGraphicsContext.current!.cgContext
        
        if xScale == 0 { xScale = bounds.size.width / CGFloat(maxX) }
        
        NSColor(red:0.2, green:0.2, blue:0.2, alpha: 1).set()
        NSBezierPath(rect:bounds).fill()
        
        if hBuffer == nil { return }
        let hPtr = hBuffer.contents().bindMemory(to: Int32.self, capacity:HBUFFERSIZE)
        
        // highest value ----------------------------------------
        highest = 1
        for i in 0 ..< maxX { if hPtr[i] > highest { highest = hPtr[i] }}
        let ratio = bounds.size.height / CGFloat(highest)
        
        // data -------------------------------------------------
        let y2 = bounds.size.height-1
        
        NSColor.gray.set()
        context?.setLineWidth(xScale)
        for i in 0 ..< maxX {
            let fi = CGFloat(i) * xScale
            let ht = CGFloat(hPtr[i]) * ratio
            drawLine(CGPoint(x:fi, y:y2-ht),CGPoint(x:fi, y:y2))
        }
        
        // cursors ----------------------------------------------
        let ccenter = Int(Float(vc.control.center) * Float(xScale))
        let spread = 1 + Int(Float(vc.control.spread) * Float(xScale))
        let low = CGFloat(ccenter - spread)
        let hgh = CGFloat(ccenter + spread)
        let cnt = CGFloat(ccenter)
        NSColor.white.set()
        context?.setLineWidth(2)
        drawLine(CGPoint(x:low, y:0),CGPoint(x:low, y:y2))
        drawLine(CGPoint(x:hgh, y:0),CGPoint(x:hgh, y:y2))
        drawLine(CGPoint(x:cnt, y:0),CGPoint(x:cnt, y:y2))
        
        // edge -------------------------------------------------
        context?.setStrokeColor(NSColor.black.cgColor)
        NSBezierPath(rect:rect).stroke()
    }
    
    func refresh() { setNeedsDisplay(bounds) }
    override var isFlipped: Bool { return true }

    //MARK: -
    
    func flippedYCoord(_ pt:NSPoint) -> NSPoint {
        var npt = pt
        npt.y = bounds.size.height - pt.y
        return npt
    }
    
    var pt = NSPoint()
    
    override func mouseDown(with event: NSEvent) {
        pt = flippedYCoord(event.locationInWindow)
        
        bulb.newBusy(.vertices)
        
        vc.control.center = Int32(pt.x / xScale)
        if vc.control.center < 0 { vc.control.center = 0 } else
            if vc.control.center > Int32(maxX) { vc.control.center = Int32(maxX) }
        refresh()
        
        vc.wg.refresh() // so #pts is updated
        vc.pm.bellCurveColorScheme()
    }
    
    override func mouseDragged(with event: NSEvent) { mouseDown(with: event) }

    func drawLine(_ p1:CGPoint, _ p2:CGPoint) {
        context?.beginPath()
        context?.move(to:p1)
        context?.addLine(to:p2)
        context?.strokePath()
    }
}
