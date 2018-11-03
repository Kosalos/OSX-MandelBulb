import Cocoa

let PMWIDTH:CGFloat = 100
let TOP:CGFloat = 10
let XMARGIN:CGFloat = 10
let YMARGIN:CGFloat = 2
let BAR_HEIGHT:CGFloat = 10
let FULL_HEIGHT:CGFloat = CGFloat(MAX_ITERATIONS) * BAR_HEIGHT

class PColorView: NSView {
    var context : CGContext?
    var clearTouchFlag:Bool = false
    
    func initialize() {
        var yCoord:CGFloat = FULL_HEIGHT + 20
        
        func addButton(_ legend:String, _ callBack:Selector) {
            let btn = NSButton()
            btn.title = legend
            btn.target = self
            btn.action = callBack
            btn.frame = CGRect(x:10, y:yCoord, width:80, height:26)
            addSubview(btn)
            yCoord += 30
        }
        
        addButton("Slide Up",#selector(slideUpTapped))
        addButton("Slide Down",#selector(slideDownTapped))
        yCoord += 10
        addButton("Clear All",#selector(clearTapped))
        addButton("Finished",#selector(finishedTapped))
        
        isHidden = true
    }
    
    func refresh() { setNeedsDisplay(bounds) }
    override var isFlipped: Bool { return true }

    //MARK:-
    
    var cIndex:Int = 0
    var vIndex:Int = 0
    
    func determineCIndex(_ pt:CGPoint) -> Bool {
        cIndex = Int((pt.y - TOP) / BAR_HEIGHT)
        vIndex = Int(-20 + 280 * pt.x / bounds.width)
        if vIndex < 0 { vIndex = 0 } else if vIndex > 255 { vIndex = 255 }
        
        return cIndex >= 0 && cIndex < Int(MAX_ITERATIONS)
    }
    
    var pt = NSPoint()
  
    func flippedYCoord(_ pt:NSPoint) -> NSPoint {
        var npt = pt
        npt.y = bounds.size.height - pt.y
        npt.x -= frame.origin.x
        return npt
    }

    override func mouseDown(with event: NSEvent) {
        pt = flippedYCoord(event.locationInWindow)

        if determineCIndex(pt) {
            setPColor(Int32(cIndex),Int32(vIndex))
            refresh()
        }
    }
    
    override func mouseDragged(with event: NSEvent) { mouseDown(with: event) }
    override func mouseUp(with event: NSEvent) { bulb.newBusy(.vertices) }

    //MARK:-
    
    @objc func slideUpTapped()   { self.slideEntries(-1) }
    @objc func slideDownTapped() { self.slideEntries(+1) }
    
    @objc func clearTapped() {
        pColorClear()
        self.refresh()
        bulb.newBusy(.vertices)
    }
    
    @objc func finishedTapped() {
        self.isHidden = true
        vc.layoutViews()
    }
    
    //MARK:-
    
    func slideEntries(_ dir:Int) {  // skip entries 0,1
        if dir > 0 {
            for i in (3 ..< MAX_ITERATIONS).reversed() { setPColor(i,getPColor(i-1)) } // skip 0,1
            setPColor(2,0)
        }
        else {
            for i in 2 ..< MAX_ITERATIONS-1 { setPColor(i,getPColor(i+1)) }
            setPColor(MAX_ITERATIONS-1,0)
        }
        
        refresh()
        bulb.newBusy(.vertices)
    }
    
    //MARK:-
    
    func bellCurveColorScheme() {
        pColorClear()
        let width:Int = Int(vc.control.spread) + 1
        let scale = Float(255) / Float(width)
        
        for i in -width ... width {
            let index:Int = Int(vc.control.center) + i
            
            if index >= 0 && index < Int(MAX_ITERATIONS) {
                setPColor(Int32(index), Int32( Float(255) - Float(abs(i)) * scale))
            }
        }
        
        refresh()
    }
    
    //MARK:-
    
    func colorValue(_ index:Int) -> CGColor {
        var color = vector_float3()
        
        switch colorMapIndex {
        case 0 : color = colorLookup1(Int32(index))
        case 1 : color = colorLookup2(Int32(index))
        case 2 : color = colorLookup3(Int32(index))
        default: color = colorLookup4(Int32(index))
        }
        
        let c = NSColor(red:CGFloat(color.x), green:CGFloat(color.y), blue:CGFloat(color.z), alpha:1)
        return c.cgColor
    }
    
    override func draw(_ rect: CGRect) {
        context = NSGraphicsContext.current?.cgContext
        
        func drawColorBar(_ index:Int) {
            let rect = CGRect(x:XMARGIN, y:TOP + CGFloat(index) * BAR_HEIGHT + YMARGIN, width:bounds.width - XMARGIN * 2, height:BAR_HEIGHT - YMARGIN)
            
            context?.setFillColor(colorValue(Int(getPColor(Int32(index)))))
            context?.setStrokeColor(NSColor.black.cgColor)
            context?.addRect(rect)
            context?.fillPath()
            context?.addRect(rect)
            context?.strokePath()
        }
        
        context?.setFillColor(NSColor.darkGray.cgColor)
        NSBezierPath(rect:rect).fill()
        
        for i in 1 ..< Int(MAX_ITERATIONS) {
            drawColorBar(i)
        }
    }
}
