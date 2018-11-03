import Cocoa

private let bColors:[NSColor] = [
    NSColor(red:0.0, green:0.0, blue:0.0, alpha:1),     // unused
    NSColor(red:0.1, green:0.1, blue:0.3, alpha:1),     // box1 .. 5
    NSColor(red:0.2, green:0.4, blue:0.3, alpha:1),
    NSColor(red:0.3, green:0.3, blue:0.2, alpha:1),
    NSColor(red:0.4, green:0.2, blue:0.1, alpha:1),
    NSColor(red:0.5, green:0.1, blue:0.0, alpha:1),
    NSColor(red:0.8, green:0.4, blue:0.1, alpha:1),     // julia
    NSColor(red:0.3, green:0.6, blue:0.2, alpha:1),     // box
    NSColor(red:0.6, green:0.3, blue:0.6, alpha:1),     // Q julia
    NSColor(red:0.3, green:0.6, blue:0.6, alpha:1),     // IFS
    NSColor(red:0.9, green:0.1, blue:0.1, alpha:1)      // Apollonian
]

let populatedCellBackgroundColor = NSColor(red:0.1,  green:0.5,  blue:0.1, alpha: 1)

protocol SLCellDelegate: class {
    func didTapButton(_ sender: NSButton)
}

class SaveLoadCell: NSTableCellView {
    weak var delegate: SLCellDelegate?
    @IBOutlet var legend: NSTextField!
    @IBOutlet var saveButton: NSButton!
    @IBAction func saveTapped(_ sender: NSButton) { delegate?.didTapButton(sender) }
    var bkColorIndex:Int = 0
    var row:Int = 0
    
    override func draw(_ rect: CGRect) {
        g.setContext(NSGraphicsContext.current!)
        g.fillRect(bounds,bColors[bkColorIndex].cgColor)
        g.drawBorder(bounds)
    }
}

//MARK:-

let versionNumber:Int32 = 0x55ab

class SaveLoadViewController: NSViewController,NSTableViewDataSource, NSTableViewDelegate,SLCellDelegate {
    @IBOutlet var legend: NSTextField!
    @IBOutlet var scrollView: NSScrollView!
    var tv:NSTableView! = nil
    var dateString:String = ""
    
    func numberOfSections(in tableView: NSTableView) -> Int { return 1 }
    func numberOfRows(in tableView: NSTableView) -> Int { return 50 }
    
    func didTapButton(_ sender: NSButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to:tv)
        saveAndDismissDialog(tv.row(at:buttonPosition))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tv = scrollView.documentView as? NSTableView
        tv.dataSource = self
        tv.delegate = self
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell:SaveLoadCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SLCell"), owner: self) as! SaveLoadCell
        cell.delegate = self
        
        var cc = Control()
        let index = row + 1
        var str:String = ""
        
        if !loadData(row, &dateString, &cc,true) {
            str = "** unused **"
        }
        else {
            func strPad(_ pstr:String) -> String {
                var str = pstr
                while str.count < 18 { str += " " }
                return str
            }
            
            cell.bkColorIndex = Int(cc.formula + 1)     // index 0 = 'unused' color
            
            var name:String = ""
            
            switch Int(cc.formula) {
            case JULIA: name = "Julia"
            case BOX : name = "Box"
            case QJULIA : name = "Q Julia"
            case IFS : name = "IFS " + ifsEquationOptions[Int(cc.ifsIndex)]
            case APOLLONIAN : name = "Apollonian"
            default : name = String(format:"Bulb %d",Int(cc.formula + 1))
            }
            
            str = String(format:"%02d %@ %@", index, strPad(name), dateString)
        }
        
        cell.legend.stringValue = str
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        loadAndDismissDialog(tv.selectedRow)
    }
    
    //MARK:-
    
    var fileURL:URL! = nil
    
    func determineURL(_ index:Int) {
        let name = String(format:"Store%d.dat",index)
        fileURL = try! FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(name)
    }
    
    func saveAndDismissDialog(_ index:Int) {
        let alert = NSAlert()
        alert.messageText = "Save Settings"
        alert.informativeText = "Confirm overwrite of Settings storage"
        alert.addButton(withTitle: "NO")
        alert.addButton(withTitle: "YES")
        alert.beginSheetModal(for: vc.view.window!) {( returnCode: NSApplication.ModalResponse) -> Void in
            if returnCode.rawValue == 1001 {
                do {
                    self.determineURL(index)
                    vc.control.version = versionNumber
                    let data:NSData = NSData(bytes:&vc.control, length:MemoryLayout<Control>.size)
                    try data.write(to: self.fileURL, options: .atomic)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    //MARK:-
    
    func determineDateString(_ index:Int) -> String {
        var dStr = String("**")
        
        determineURL(index)
        
        do {
            let key:Set<URLResourceKey> = [.creationDateKey]
            let value = try fileURL.resourceValues(forKeys: key)
            if let date = value.creationDate { dStr = date.toString() }
        } catch {
            // print(error)
        }
        
        return dStr
    }
    
    //MARK:-
    
    @discardableResult func loadData(_ index:Int, _ dStr: inout String,  _ c: inout Control, _ loadFile:Bool) -> Bool {
        var okay:Bool = true
        
        determineURL(index)
        
        do {
            let key:Set<URLResourceKey> = [.creationDateKey]
            let value = try fileURL.resourceValues(forKeys: key)
            if let date = value.creationDate {
                dStr = date.toString()
            }
            else {
                okay = false
            }
        } catch {
            // print(error)
        }
        
        if loadFile {
            let sz = MemoryLayout<Control>.size
            let data = NSData(contentsOf: fileURL)
            
            if data != nil {
                data?.getBytes(&c, length:sz)
            }
            else {
                okay = false
            }
        }
        
        return okay
    }
    
    func loadAndDismissDialog(_ index:Int) {
        var dStr = String("**")
        if loadData(index, &dStr, &vc.control, true) {
            if vc.control.version != versionNumber { vc.reset() }
            self.dismiss(self)
            vc.controlJustLoaded()
        }
    }
}

//MARK:-

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm"
        return dateFormatter.string(from: self)
    }
}

