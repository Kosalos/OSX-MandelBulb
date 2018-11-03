import Cocoa
import MetalKit

var histogram = Histogram()
var g = Graphics()
var device: MTLDevice! = nil
let bulb = Bulb()
var camera:float3 = float3(0,0,-170)
var vc:ViewController! = nil

let ifsEquationOptions:[String] = [ "Half Tet1","Half Tet2","Full Tet","Cubic","half Octa","Full Octa","Kaleido" ]
let equationOptions:[String] = [ "Bulb 1","Bulb 2","Bulb 3","Bulb 4","Bulb 5","Julia","Box","Q Julia","IFS","Apollonian" ]
let pointSizeOptions:[String] = [ "PtSz 1","PtSz 2","PtSz 4","PtSz 8" ]

class ViewController: NSViewController, NSWindowDelegate, WGDelegate {
    var hv:HistogramView! = nil
    var pm:PColorView! = nil
    var rendererL: Renderer!
    var rendererR: Renderer!
    
    @IBOutlet var wg: WidgetGroup!
    @IBOutlet var mtkViewL: MTKView!
    @IBOutlet var mtkViewR: MTKView!
    
    var pointSizeIndex:Int = 1
    var controlColorRange = Float()
    var controlColorOffset = Float()
    var controlCenter = Float()
    var controlSpread = Float()
    var paceRotate = CGPoint()

    var control = Control()
    var undoControl1 = Control()
    var undoControl2 = Control()
    
    var isStereo:Bool = false
    var showAxesFlag = true

    override func viewDidLoad() {
        super.viewDidLoad()
        vc = self
        setControlPointer(&control)
        device = MTLCreateSystemDefaultDevice()
        mtkViewL.device = device
        mtkViewR.device = device

        guard let newRenderer = Renderer(metalKitView: mtkViewL, 0) else { fatalError("Renderer cannot be initialized") }
        rendererL = newRenderer
        rendererL.mtkView(mtkViewL, drawableSizeWillChange: mtkViewL.drawableSize)
        mtkViewL.delegate = rendererL

        guard let newRenderer2 = Renderer(metalKitView: mtkViewR, 1) else { fatalError("Renderer cannot be initialized") }
        rendererR = newRenderer2
        rendererR.mtkView(mtkViewR, drawableSizeWillChange: mtkViewR.drawableSize)
        mtkViewR.delegate = rendererR
        
        pm = PColorView()
        view.addSubview(pm)
        pm.isHidden = true
    }
    
    override func viewDidAppear() {
        super.viewWillAppear()

        pm = PColorView()
        view.addSubview(pm)
        pm.initialize()
        
        hv = HistogramView()
        view.addSubview(hv)
        
        view.window?.delegate = self
        resizeIfNecessary()
        dvrCount = 1 // resize metalviews without delay

        wg.delegate = self
        initializeWidgetGroup()
        layoutViews()

        Timer.scheduledTimer(withTimeInterval:0.01, repeats:true) { timer in self.paceTimerHandler() }
        reset()
        bulb.reset()
        bulb.newBusy(.calc)
    }
    
    //MARK: -
    
    func resizeIfNecessary() {
        let minWinSize:CGSize = CGSize(width:700, height:735)
        var r:CGRect = (view.window?.frame)!
        var changed:Bool = false
        
        if r.size.width < minWinSize.width {
            r.size.width = minWinSize.width
            changed = true
        }
        if r.size.height < minWinSize.height {
            r.size.height = minWinSize.height
            changed = true
        }
        
        if changed { view.window?.setFrame(r, display: true) }

        layoutViews()
    }
    
    func windowDidResize(_ notification: Notification) {
        resizeIfNecessary()
        resetDelayedViewResizing()
    }
    
    //MARK: -
    
    var dvrCount:Int = 0
    
    // don't alter layout until they have finished resizing the window
    func resetDelayedViewResizing() {
        dvrCount = 10 // 20 = 1 second delay
    }
    
    var viewCenter = CGPoint()
    
    func rotate(_ pt:CGPoint) {
        arcBall.mouseDown(viewCenter)
        arcBall.mouseMove(CGPoint(x:viewCenter.x + pt.x, y:viewCenter.y + pt.y))
    }
    
    //MARK: -

    @objc func paceTimerHandler() {
        _ = wg.update()
        rotate(paceRotate)
        
        if dvrCount > 0 {
            dvrCount -= 1
            if dvrCount <= 0 {
                layoutViews()
            }
        }
    }
    
    //MARK: -

    let WGWIDTH:CGFloat = 120
    var chgScale:Float = 1
    var hvYcoord = CGFloat()
    
    func initializeWidgetGroup() {
        wg.reset()
        
        wg.addOptionSelect("E",.equation,"Equation","Select Equation Type",equationOptions);
        
        switch Int(control.formula) {
        case BULB_1,BULB_2,BULB_3,BULB_4,BULB_5 :
            wg.add1Float("P",&control.power,2,12,0.1,"Power",.power)
        case BOX :
            wg.add2Float("2",UnsafeMutableRawPointer(&control.re1),UnsafeMutableRawPointer(&control.im1),0.1,4, 0.13,"B Fold")
            wg.add2Float("3",UnsafeMutableRawPointer(&control.mult1),UnsafeMutableRawPointer(&control.zoom1),0.1,4, 0.13,"S Fold")
            wg.add2Float("4",UnsafeMutableRawPointer(&control.re2),UnsafeMutableRawPointer(&control.im2),0.1,10,0.5,"Scale")
        case JULIA :
            wg.add2Float("2",UnsafeMutableRawPointer(&control.re1),  UnsafeMutableRawPointer(&control.re2), -4,4,0.1,"Real")
            wg.add2Float("3",UnsafeMutableRawPointer(&control.im1),  UnsafeMutableRawPointer(&control.im2), -4,4,0.1,"Imag")
            wg.add2Float("4",UnsafeMutableRawPointer(&control.mult1),UnsafeMutableRawPointer(&control.mult2),-3,3, 0.025,"Mult")
            wg.add2Float("5",UnsafeMutableRawPointer(&control.zoom1),UnsafeMutableRawPointer(&control.zoom2),20,500,10,"Zoom")
        case QJULIA :
            wg.add2Float("2",UnsafeMutableRawPointer(&control.re1),  UnsafeMutableRawPointer(&control.re2), -1,1,0.05,"P 1,2")
            wg.add2Float("3",UnsafeMutableRawPointer(&control.im1),  UnsafeMutableRawPointer(&control.im2), -1,1,0.05,"P 3,4")
            wg.add1Float("4",UnsafeMutableRawPointer(&control.mult1),-1,1,0.05,"P 5")
            wg.add1Float("5",UnsafeMutableRawPointer(&control.mult2),-3,3,0.1,"P 6")
        case IFS :
            wg.addOptionSelect("I",.ifsEquation,"IFS Equation","Select Equation Style",ifsEquationOptions);
            let v1:Float = -6, v2:Float = 6, v3:Float = 0.1
            wg.add2Float("2",UnsafeMutableRawPointer(&control.re1),  UnsafeMutableRawPointer(&control.re2), v1,v2,v3,"Scl/Off")
            wg.add1Float("3",UnsafeMutableRawPointer(&control.im1), v1,v2,v3,"Shift")
            wg.add2Float("4",UnsafeMutableRawPointer(&control.mult1),  UnsafeMutableRawPointer(&control.mult2), v1,v2,v3,"Rot 1")
            wg.add2Float("5",UnsafeMutableRawPointer(&control.zoom1),  UnsafeMutableRawPointer(&control.zoom2), v1,v2,v3,"Rot 2")
        case APOLLONIAN :
            wg.add1Float("2",&control.mult1,0.001,100,2,"Mult")
            wg.add1Float("3",&control.mult2, 10,300,3,"P1")
            wg.add1Float("4",&control.re1, 0.5,1,0.01,"P2")
            wg.add1Float("5",&control.re2, 0.5,1,0.01,"P3")
        default : break
        }

        wg.addLine()
        let v1:Float = -8, v2:Float = 8, v3:Float = 0.03
        wg.addColor(.none,Float(RowHT)); wg.add1Float("R",&control.basex,v1,v2,v3, "Red",.cageXYZ)
        wg.addColor(.none,Float(RowHT)); wg.add1Float("G",&control.basey,v1,v2,v3, "Green",.cageXYZ)
        
        if  control.formula != JULIA {
            wg.addColor(.none,Float(RowHT)); wg.add1Float("B",&control.basez,v1,v2,v3, "Blue",.cageXYZ)
        }
        
        wg.add1Float("S",&chgScale,0.99,1.01,0.05,"Scale",.cageScale)
        wg.addCommand("","Show Axes",.showAxes)
        
        wg.addLine()
        hvYcoord = wg.nextYCoord()+2
        
        wg.addGap(30) // room for histo graph
        wg.add1Float("N",&controlCenter,0,40,0.5,"Center",.histo)
        wg.add1Float("",&controlSpread,0,10,0.2,"Spread",.histo)
        wg.addString("",.numPoints)
        wg.addOptionSelect("",.pointSize,"Point Size","Select Point Size",pointSizeOptions);

        wg.addLine()
        wg.addCommand("C","ColorEdit",.colorEdit)
        wg.addCommand("","Palette",.palette)
        
        wg.addLine()
        wg.addCommand("J","Smooth 1",.smooth)
        wg.addCommand("K","Smooth 2",.smooth2)
        wg.addCommand("L","Quant  1",.quant)
        wg.addCommand("M","Quant  2",.quant2)

        wg.addLine()
        wg.addCommand("U","Undo",.undo)
        wg.addCommand("L","Save/Load",.saveLoad)
        wg.addCommand("8","Reset",.reset)
        wg.addCommand("H","Help",.help)
        wg.refresh()
        
        wg.addLine()
        wg.addColor(.stereo,Float(RowHT))
        wg.addCommand("O","Stereo",.stereo)
        
        wg.refresh()
    }
    
    //MARK: -
    
    var calcWhenDone:Bool = false
    
    func wgCommand(_ cmd: WgIdent) {
        func presentPopover(_ name:String) {
            let mvc = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            let vc = mvc.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue:name)) as! NSViewController
            self.presentViewController(vc, asPopoverRelativeTo: wg.bounds, of: wg, preferredEdge: .maxX, behavior: .transient)
        }
        
        switch(cmd) {
        case .saveLoad : presentPopover("SaveLoadVC")
        case .help : presentPopover("HelpVC")
        case .stereo :
            isStereo = !isStereo
            layoutViews()
        case .reset :
            reset()
            bulb.newBusy(.calc)
        case .undo :
            vc.control = undoControl2
            control.hop = 1
            bulb.newBusy(.calc)
        case .cageXYZ, .cageScale :
            if cmd == .cageScale { changeScale(control.scale * chgScale) }
            showAxesFlag = true
            bulb.calcCages()
            calcWhenDone = true
        case .changeEnd :
            if calcWhenDone {
                calcWhenDone = false
                bulb.newBusy(.calc)
            }
        case .power :
            if bulb.busyCode != .idle { return }
            control.hop = 1
            bulb.newBusy(.calc)
        case .palette :
            bulb.loadNextColorMap()
            pm.refresh()
            bulb.newBusy(.vertices)
        case .colorEdit :
            pm.isHidden = false
            layoutViews()
            pm.refresh()
        case .color :
            updateRenderColor()
            bulb.newBusy(.vertices)
        case .histo :
            updateControlCenter()
            bulb.newBusy(.vertices)
        case .fastCalc : bulb.fastCalc()
        case .smooth   : bulb.smoothData()
        case .smooth2  : bulb.smoothData2()
        case .quant    : bulb.quantizeData()
        case .quant2   : bulb.quantizeData2()
        case .showAxes : showAxesFlag = !showAxesFlag
        default : break
        }
        
        wg.refresh()
    }
    
    func wgToggle(_ ident:WgIdent) {}
    
    func wgGetString(_ ident:WgIdent) -> String {
        switch(ident) {
        case .numPoints  :
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            return numberFormatter.string(from: NSNumber(value:vCount))!
        default : return "unused"
        }
    }
    
    func wgGetColor(_ ident:WgIdent) -> NSColor {
        var highlight:Bool = false
        switch(ident) {
        case .stereo : highlight = isStereo
        default : break
        }
        
        return highlight ? wgHighlightColor : wgBackgroundColor
    }
    
    func wgOptionSelected(_ ident: WgIdent, _ index: Int) {
        switch(ident) {
        case .equation :
            control.formula = Int32(index)
            resetControlSettings()
            initializeWidgetGroup()
            bulb.newBusy(.calc)
            layoutViews()   // so histo view is relocated
        case .pointSize :
            pointSizeIndex = index
            updateRenderPointSize()
        case .ifsEquation :
            control.ifsIndex = Int32(index)
            loadIFSDefaultSettings()
            bulb.newBusy(.calc)
            wg.refresh()
        default : break
        }
    }
    
    func wgGetOptionString(_ ident: WgIdent) -> String {
        switch(ident) {
        case .pointSize : return pointSizeOptions[pointSizeIndex]
        case .equation : return equationOptions[Int(control.formula)]
        case .ifsEquation : return ifsEquationOptions[Int(control.ifsIndex)]
        default : return "noOption"
        }
    }
    
    func wgGetOptionDefaultIndex(_ ident:WgIdent) -> Int {
        switch(ident) {
        case .pointSize : return pointSizeIndex
        case .equation : return Int(control.formula)
        case .ifsEquation : return Int(control.ifsIndex)
        default : return 0
        }
    }
    
    //MARK: -
    
    func updateRenderPointSize() {
        let pList:[Float] = [ 1,2,4,8 ]
        pointSize = pList[pointSizeIndex]
    }
    
    func updateRenderColor() {
        control.range = Int32(controlColorRange)
        control.offset = Int32(controlColorOffset)
    }
    
    func updateControlCenter() {
        control.center = Int32(controlCenter)
        control.spread = Int32(controlSpread)
        pm.bellCurveColorScheme()
    }
    
    func reset() {
        resetControlSettings()
        
        undoControl1 = vc.control
        undoControl2 = vc.control
        
        pointSizeIndex = 1
        updateRenderPointSize()
        
        updateRenderColor()
        updateControlCenter()
    }
    
    //MARK: -
    
    func resetControlSettings() {
        control.basex = -1.14133 * basePositionScaleFactor
        control.basey = -1.12 * basePositionScaleFactor
        control.basez = -1.102 * basePositionScaleFactor
        
        switch Int(control.formula) {
        case JULIA :
            control.re1 = -2.17020011
            control.re2 = -0.0822001174
            control.im1 = 0.534700274
            control.im2 = -1.15230012
            control.mult1 = 1.42700005
            control.mult2 = 1.3253746
            control.zoom1 = 189.199997
            control.zoom2 = 211.949921
        case BOX :
            control.re1 = 1.671
            control.im1 = 0.7316
            control.mult1 = 1.6804
            control.zoom1 = 1.266
            control.re2 = 2.4677
            control.im2 = 2.52
        case QJULIA :
            control.scale = 0.00800000038
            control.re1 = 0.0912499353
            control.im1 = 0.485499978
            control.mult1 = -0.389624834
            control.mult2 = 1
            control.re2 = -0.238750175
            control.im2 = -0.389999956
            control.center = 12
            control.spread = 2
        case IFS :
            loadIFSDefaultSettings()
        case APOLLONIAN :
            control.basex = -1.34111273 * basePositionScaleFactor
            control.basey = -1.31978285 * basePositionScaleFactor
            control.basez = -1.30178273 * basePositionScaleFactor
            control.scale = 0.00933188479
            control.re1 = 0.998799979
            control.mult1 = 62.9147491
            control.mult2 = 143.37999
            control.re2 = 0.827500105
            control.center = 3
            control.spread = 2
            control.pColor.1 = 255
            control.pColor.3 = 179
            control.pColor.5 = 37
        default : break
        }
        
        controlColorRange = 128
        controlColorOffset = 128
        controlCenter = 10
        controlSpread = 2
    }
    
    func loadIFSDefaultSettings() {
        control.spread = 2
        control.offset = 128
        control.range = 128
        
        switch Int(control.ifsIndex) {
        case 0 : // Half Tet1
            control.basex = -5.50529909 * basePositionScaleFactor
            control.basey = -6.0948205 * basePositionScaleFactor
            control.basez = -6.12346792 * basePositionScaleFactor
            control.scale = 0.0350538194
            control.re1 = 1.03141177
            control.im1 = 1.12100089
            control.mult1 = 0.657745481
            control.zoom1 = -0.292500138
            control.re2 = 0.50168997
            control.mult2 = -0.309054941
            control.zoom2 = -0.318499744
            control.center = 10
        case 1 : // Half Tet2
            control.basex = -4.41710472 * basePositionScaleFactor
            control.basey = -3.91180563 * basePositionScaleFactor
            control.basez = -3.54410887 * basePositionScaleFactor
            control.scale = 0.027799191
            control.re1 = -1.20458925
            control.im1 = 0.0612261444
            control.mult1 = 0.734745502
            control.zoom1 = -1.78650033
            control.re2 = -0.455810547
            control.mult2 = 0.320944995
            control.zoom2 = 1.64700031
            control.center = 2
        case 2 : // Full Tet
            control.basex = -7.01420116 * basePositionScaleFactor
            control.basey = -5.96500015 * basePositionScaleFactor
            control.basez = -5.34282541 * basePositionScaleFactor
            control.scale = 0.0373393223
            control.re1 = -1.63158834
            control.im1 = 1.12100089
            control.mult1 = 0.780245482
            control.zoom1 = 0.507999897
            control.re2 = 0.267190039
            control.mult2 = -0.150054947
            control.zoom2 = -0.786999702
            control.center = 10
        case 3 : // cubic
            control.basex = -5.50529909 * basePositionScaleFactor
            control.basey = -6.0948205 * basePositionScaleFactor
            control.basez = -6.12346792 * basePositionScaleFactor
            control.scale = 0.0350538194
            control.re1 = 1.12741172
            control.im1 = 1.83650088
            control.mult1 = 1.6752454
            control.zoom1 = -0.0265000463
            control.re2 = 1.17418993
            control.mult2 = -0.584054947
            control.zoom2 = -0.318499833
            control.center = 15
        case 4 : // half octa
            control.basex = -5.50529909 * basePositionScaleFactor
            control.basey = -6.0948205 * basePositionScaleFactor
            control.basez = -6.12346792 * basePositionScaleFactor
            control.scale = 0.0350538194
            control.re1 = -1.80258822
            control.im1 = 1.09200096
            control.mult1 = -0.0567545593
            control.zoom1 = 0.569999814
            control.re2 = 0.573689878
            control.mult2 = -0.288055122
            control.zoom2 = -0.467999756
            control.center = 4
        case 5 : // full octa
            control.basex = -5.50529909 * basePositionScaleFactor
            control.basey = -6.0948205 * basePositionScaleFactor
            control.basez = -6.12346792 * basePositionScaleFactor
            control.scale = 0.0350538194
            control.re1 = 1.31841183
            control.im1 = 1.12100089
            control.mult1 = 0.657745481
            control.zoom1 = -0.292500138
            control.re2 = 0.942689955
            control.mult2 = -0.309054941
            control.zoom2 = -0.318499744
            control.center = 10
        default : // Kaleido
            control.basex = -1.0784421 * basePositionScaleFactor
            control.basey = -1.25651312 * basePositionScaleFactor
            control.basez = -1.69661307 * basePositionScaleFactor
            control.scale = 0.00554144336
            control.re1 = -1.21631932
            control.im1 = 0.931500792
            control.mult1 = 3.09924626
            control.zoom1 = -0.0305000525
            control.re2 = 2.94115138
            control.mult2 = -1.23205495
            control.zoom2 = 0.102000162
            control.center = 8
        }
    }
    
    //MARK: -
    
    func changeScale(_ ns:Float) {
        let sMin:Float = 0.00001
        let sMax:Float = 0.07
        let cc = Float(WIDTH)/2
        let q1 = control.scale * cc
        
        let centerx = control.basex + q1
        let centery = control.basey + q1
        let centerz = control.basez + q1
        
        control.scale = ns
        if control.scale < sMin { control.scale = sMin } else
            if control.scale > sMax { control.scale = sMax }
        
        let q2 = control.scale * cc
        control.basex = centerx - q2
        control.basey = centery - q2
        control.basez = centerz - q2
        
        bulb.calcCages()
    }
    
    //MARK: -
    
    func layoutViews() {
        let xs = view.bounds.width
        let ys = view.bounds.height
        let wgWidth:CGFloat = wg.isHidden ? 0 : WGWIDTH
        let pmWidth:CGFloat = pm.isHidden ? 0 : PMWIDTH
        var xBase:CGFloat = 1
        
        hv.isHidden = wg.isHidden

        if !wg.isHidden {
            wg.frame = CGRect(x:xBase, y:1, width:wgWidth, height:ys-2)
            xBase += wgWidth
            
            hv.frame = CGRect(x:5, y:ys-hvYcoord-43, width:WGWIDTH-10, height:44)
        }
        if !pm.isHidden {
            pm.frame = CGRect(x:xBase, y:1, width:pmWidth, height:ys-2)
            xBase += pmWidth
        }

        if isStereo {
            mtkViewR.isHidden = false
            let xs2:CGFloat = (xs - xBase)/2
            mtkViewL.frame = CGRect(x:xBase+1, y:1, width:xs2, height:ys-2)
            mtkViewR.frame = CGRect(x:xBase+xs2+1, y:1, width:xs2-2, height:ys-2)
        }
        else {
            mtkViewR.isHidden = true
            mtkViewL.frame = CGRect(x:xBase+1, y:1, width:xs-xBase-2, height:ys-2)
        }
        
        viewCenter.x = mtkViewL.frame.width/2
        viewCenter.y = mtkViewL.frame.height/2
        arcBall.initialize(Float(mtkViewL.frame.width),Float(mtkViewL.frame.height))
    }
    
    func controlJustLoaded() {
        initializeWidgetGroup()
        bulb.newBusy(.calc)
    }
    
    //MARK: -
    
    var shiftKeyDown:Bool = false
    var optionKeyDown:Bool = false
    var letterAKeyDown:Bool = false
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        
        updateModifierKeyFlags(event)
        
        switch event.keyCode {
        case 123:   // Left arrow
            wg.hopValue(-1,0)
            return
        case 124:   // Right arrow
            wg.hopValue(+1,0)
            return
        case 125:   // Down arrow
            wg.hopValue(0,-1)
            return
        case 126:   // Up arrow
            wg.hopValue(0,+1)
            return
        case 43 :   // '<'
            wg.moveFocus(-1)
            return
        case 47 :   // '>'
            wg.moveFocus(1)
            return
        case 53 :   // Esc
            NSApplication.shared.terminate(self)
        case 0 :    // A
            letterAKeyDown = true
        case 18 :   // 1
            wg.isHidden = !wg.isHidden
            if wg.isHidden { pm.isHidden = true }
            layoutViews()
        default:
            break
        }
        
        let keyCode = event.charactersIgnoringModifiers!.uppercased()
        //print("KeyDown ",keyCode,event.keyCode)
        
        wg.hotKey(keyCode)
    }
    
    override func keyUp(with event: NSEvent) {
        super.keyUp(with: event)
        
        wg.stopChanges()
        wgCommand(.changeEnd)
        
        switch event.keyCode {
        case 0 :    // A
            letterAKeyDown = false
        default:
            break
        }        
    }
    
    //MARK: -
    
    func flippedYCoord(_ pt:NSPoint) -> NSPoint {
        var npt = pt
        npt.y = view.bounds.size.height - pt.y
        return npt
    }
    
    func updateModifierKeyFlags(_ ev:NSEvent) {
        let rv = ev.modifierFlags.intersection(.deviceIndependentFlagsMask).rawValue
        shiftKeyDown   = rv & (1 << 17) != 0
        optionKeyDown  = rv & (1 << 19) != 0
    }
    
    var pt = NSPoint()
    
    override func mouseDown(with event: NSEvent) {
        pt = flippedYCoord(event.locationInWindow)
        
        if optionKeyDown {      // optionKey + mouse click = stop rotation
            paceRotate = CGPoint()
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        updateModifierKeyFlags(event)
        
        var npt = flippedYCoord(event.locationInWindow)
        
        npt.x -= pt.x
        npt.y -= pt.y
        

        if optionKeyDown {      // optionKey + mouse drag = set rotation speed & direction
            updateRotationSpeedAndDirection(npt)
            return
        }
        
        wg.focusMovement(npt,1)
    }
    
    override func mouseUp(with event: NSEvent) {
        pt.x = 0
        pt.y = 0
        wg.focusMovement(pt,0)
        wgCommand(.changeEnd)
    }

    //MARK: -

    func updateRotationSpeedAndDirection(_ pt:NSPoint) {
        let scale:Float = 0.01
        let rRange = float2(-3,3)
    
        func fClamp(_ v:Float, _ range:float2) -> Float {
            if v < range.x { return range.x }
            if v > range.y { return range.y }
            return v
        }
    
        paceRotate.x = CGFloat(fClamp(Float(pt.x) * scale, rRange))
        paceRotate.y = CGFloat(fClamp(Float(pt.y) * scale, rRange))
    }
}

// ===============================================

class BaseNSView: NSView {
    override var acceptsFirstResponder: Bool { return true }
}
