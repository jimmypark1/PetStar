//
//  CameraViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 2..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import GPUImage
import AFNetworking
import PinterestSegment
import RSLoadingView
//import TTSegmentedControl
//import Twinkle
import Segmentio

import MBCircularProgressBar


import NVActivityIndicatorView

//import CircleProgressBar

class CameraViewController: UIViewController {
    @IBOutlet weak var renderView: GPUImageView!
    @IBOutlet weak var captureBt: UIButton!
    @IBOutlet weak var filterBt: UIButton!
    @IBOutlet weak var homeBt: UIButton!
    @IBOutlet weak var notiBt: UIButton!
    @IBOutlet weak var myBt: UIButton!
    @IBOutlet weak var rationBt: UIButton!
    @IBOutlet weak var overlayBt: UIButton!
    
    @IBOutlet weak var filterView:UICollectionView!
    @IBOutlet weak var filterMenu:UICollectionView!
   
    @IBOutlet weak var noneView: UIView!
   
    @IBOutlet weak var renderWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var renderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var renderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var renderBottomConstraint: NSLayoutConstraint!
    @IBOutlet var titleView:UIView!
    @IBOutlet var titleLabel:UILabel!
    
    @IBOutlet weak var segmentedControl : Segmentio!
    
    var navi:UINavigationController!
    var  type:Int!
    
    var  videoCamera:GPUImageStillCamera!
    var  frontCamera:GPUImageStillCamera!
    var  backCamera:GPUImageStillCamera!
   
    
    var  frontCamera0:GPUImageStillCamera!
    var  backCamera0:GPUImageStillCamera!
    var  frontCamera1:GPUImageStillCamera!
    var  backCamera1:GPUImageStillCamera!
    var  frontCamera2:GPUImageStillCamera!
    var  backCamera2:GPUImageStillCamera!
    
    
    var filter:GPUImageFilter!
    var cropFilter:CropFilter!
    var movieWriter:GPUImageMovieWriter!
    
    var  bFront:Bool!
    var exportUrl:NSURL!
    
    var filters:NSMutableArray!
    var filterSource:FilterDelegate!
    var filterMenuSource:FilterMenuDelegate!
    var lookupImageSource:GPUImagePicture!
    
    var overlays:NSMutableArray!
    var overlaySource:OverlayDelegate!
    
    var capturedImage:UIImage!
    
    var cameraInit:Bool!
    
    var ratioStatus:Int = 2
    
    @IBOutlet weak var ibSegment: PinterestSegment!
    
    var selectedFilter:FilterData!
    var selectedCell:ThumbCell?
    var blendImage: GPUImagePicture!
    var blendWaterImage: GPUImagePicture!
    var blendFilter: GPUImageFilter!
    var filterGroup: GPUImageFilterGroup!
    var lookupFilter: GPUImageFilter!
    var toneFilter: GPUImageFilter!
    var blendWaterFilter: GPUImageFilter!
    
    var selFilterData:Data!
    var selOverlayData:Data!
    var selFilterType:Int!
    var sourceType:Int!
   
    
    var circleView: CircleProgressBar!
    
    var timer:Timer!
    var count:CGFloat!
    
    var record:Bool!
    func initSourceSegment()
    {
       
        
        ibSegment.titles = ["Everything", "Geek", "Humor", "Art", "Food", "Home", "DIY", "Wemoent' Style", "Man's Style", "Beauty", "Travel"]
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func initTopView()
    {
        var offset:Bool = false
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
            case 1334:
                print("iPhone 6/6S/7/8")
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                print("iPhone X")
           //     offset = 20.0
            default:
                print("unknown")
                offset = true
            }
        }
        if(offset == true)
        {
            renderTopConstraint.constant = 0
        }
        titleView.layer.shadowColor = UIColor.lightGray.cgColor
        titleView.layer.shadowOpacity = 1
        titleView.layer.shadowOffset = CGSize.zero
        titleView.layer.shadowRadius = 2
        titleView.backgroundColor = UIColor.clear
        
     //   titleLabel.font = UIFont(name: "Amaranth", size: 18)
     //   titleLabel.textColor = UIColor.init(red: 27.0/256.0, green: 147.0/256.0, blue: 216.0/256.0, alpha: 1.0)
        
    }
    func buttonTouched(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.2,
                         animations: {
                            sender.transform = CGAffineTransform(scaleX: 0.975, y: 0.96)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                sender.transform = CGAffineTransform.identity
                            })
        })
    }
    
    func animationScaleEffect(view:UIView,animationTime:Float)
    {
        UIView.animate(withDuration: TimeInterval(animationTime), animations: {
            
            view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            
        },completion:{completion in
            UIView.animate(withDuration: TimeInterval(animationTime), animations: { () -> Void in
                
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        })
        
    }
    
    /*
    @IBOutlet weak var perform: UIButton!
    
    @IBAction func prefo(sender: AnyObject) {
        self.animationScaleEffect(view: perform, animationTime: 0.7)
    }
 */
    override func viewDidLoad() {
        super.viewDidLoad()

        JunSoftUtil.shared.isDetail = true
      
        //print(navi)
        initTopView()
        
        
        cameraInit = true
        
        //captureBt.twinkle()
        count = 0
        record = false
        ////
        ///
        
        var content = [SegmentioItem]()
        
         let photo = SegmentioItem(title: "PHOTO",
                                        image: nil )
        
        let video = SegmentioItem(title: "VIDEO",
                                   image: nil )
        
         
        content.append(photo)
        content.append(video)
       
       
        let indicator =  SegmentioIndicatorOptions(
            type: .bottom,
            ratio: 1,
            height: 5,
            color: .red
        )
        let states = SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                titleTextColor: .black
            ),
            selectedState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                titleTextColor: .black
            ),
            highlightedState: SegmentioState(
                backgroundColor: UIColor.lightGray.withAlphaComponent(0.6),
                titleFont: UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize),
                titleTextColor: .black
            )
        )
        let options = SegmentioOptions(
            backgroundColor: .white,
            segmentPosition: SegmentioPosition.dynamic,
            scrollEnabled: true,
            indicatorOptions: indicator,
            horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(color:UIColor.clear),
            verticalSeparatorOptions: SegmentioVerticalSeparatorOptions(color:UIColor.clear),
            imageContentMode: .center,
            labelTextAlignment: .center,
            segmentStates: states
        )
        segmentedControl.setup(
            content: content,
            style: SegmentioStyle.onlyLabel,
            options: options
        )
        segmentedControl.selectedSegmentioIndex = 0
        //segmentioView.backgroundColor = UIColor.white
        
      
        
        segmentedControl.valueDidChange = { segmentio, segmentIndex in
            print("Selected item: ", segmentIndex)
            
            if( segmentIndex == 0)
            {
                self.captureBt.setImage(UIImage(named: "record_rev3"),  for: UIControlState.normal)
                
            }
            else
            {
                self.captureBt.setImage(UIImage(named: "video_cap"),  for: UIControlState.normal)
             
                
            }
           
        }
        
        
        /*
        segmentedControl.backgroundColor = UIColor.clear
        segmentedControl.itemTitles = ["Photo","Video"]
        segmentedControl.thumbGradientColors = [ UIColor.init(red: 27.0/256.0, green: 147.0/256.0, blue: 216.0/256.0, alpha: 1.0),
         UIColor.init(red: 102.0/256.0, green: 189.0/256.0, blue: 238.0/256.0, alpha: 1.0)]

        segmentedControl.cornerRadius = 15
        segmentedControl.didSelectItemWith = { (index, title) -> () in
            print("Selected item \(index)")
            self.sourceType = index
            if( index == 0)
            {
                self.captureBt.setImage(UIImage(named: "record_rev3"),  for: UIControlState.normal)
                
            }
            else
            {
                self.captureBt.setImage(UIImage(named: "video_cap"),  for: UIControlState.normal)
             
                
            }
        }
    */
        let bounds = self.view.bounds
        if(ratioStatus == 2)
        {
            renderWidthConstraint.constant = bounds.size.width
            renderHeightConstraint.constant = bounds.size.width
          //  renderTopConstraint.constant = 0
           // renderBottomConstraint.constant = 0
            
        }
        else if(ratioStatus == 1)
        {
            renderWidthConstraint.constant = bounds.size.width
            renderHeightConstraint.constant = 1.333 * bounds.size.width
            renderTopConstraint.constant = 0
            renderBottomConstraint.constant =  bounds.size.height - 1.333 * bounds.size.width
            
        }
        else if(ratioStatus == 0)
        {
            renderWidthConstraint.constant = bounds.size.width
            renderHeightConstraint.constant = bounds.size.height
            renderTopConstraint.constant = 0
            renderBottomConstraint.constant = 0
            
        }
        
        // Do any additional setup after loading the view.
        filters = NSMutableArray()
        overlays = NSMutableArray()
        
        filterGroup = GPUImageFilterGroup()
        
        
        let longPress = UILongPressGestureRecognizer(target: self, action:
            #selector(self.handleLongPressGesture))
        
        longPress.minimumPressDuration = 0.2
        captureBt.gestureRecognizers = [longPress]
        
        filterView.isHidden = true
        filterMenu.isHidden = true
        noneView.isHidden = true
        
       // filterView?.collectionViewLayout.
        filterView?.backgroundColor = UIColor.clear
        filterMenu?.backgroundColor = UIColor(red: 239.0/255.0,green: 239.0/255.0,blue: 239.0/255.0,alpha: 1.0)
        
        noneView?.backgroundColor = UIColor(red: 239.0/255.0,green: 239.0/255.0,blue: 239.0/255.0,alpha: 1.0)//UIColor(red: 52.0/255.0,green: 182.0/255.0,blue: 237.0/255.0,alpha: 1.0)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: self.view.frame.size.width/5, height: self.view.frame.size.width/5)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        filterView!.collectionViewLayout = layout
        
      //  initSourceSegment()
        
     
    }
    override func viewDidAppear(_ animated: Bool) {
        
        DispatchQueue.main.async(execute: {
            self.cameraInit = true
            self.initCamera()
            let loadingView = RSLoadingView()
         //   loadingView.show(on: self.view)
            
          //  print(self.selectedFilter.name)
            let defaults = UserDefaults.standard
            let name =  defaults.string(forKey: "FILTER_NAME")
            let type = defaults.string(forKey: "FILTER_TYPE")
            let cell = defaults.object(forKey: "FILTER_CELL")
            
            let overlayName = defaults.string(forKey:"OVERLAY_NAME")
            
            
            if( name == nil || name == "none")
            {
                self.openVideoCamera()
                
            }
            else
            {
                let loadingView = RSLoadingView()
                loadingView.show(on: self.view)
                
                print(name)
                print(type)
              //  print(cell)
                self.openVideoCamera()
                
                if(overlayName != nil && (overlayName?.count)! > 0 )
                {
                    let manager = FileManager.default
                    
                    let pathUrl = self.dataFilterURL(fileName: overlayName!)//dataFileURL(fileName: filename)
                    self.selOverlayData = manager.contents(atPath: pathUrl.path!)
                    
                }
                
                self.processFilter(item: name as! String, type: type as! String)
            
                loadingView.hide()
                
            }
            
         //   self.videoCamera.startCapture()
            
        
            
        })
       
 //        videoCamera.startCapture()

    }
    override func viewDidDisappear(_ animated: Bool) {
     //   super.viewDidDisappear(animated)
        if(self.filter != nil)
        {
            self.filter.removeAllTargets()
            
        }
        if(self.cropFilter != nil)
        {
            self.cropFilter.removeAllTargets()
            
        }
        if(videoCamera != nil)
        {
            videoCamera.pauseCapture()
            
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    @IBAction func setRatioProcess()
    {
        let bounds = self.view.bounds
        
    //    openVideoCamera()
        
        if(ratioStatus == 0)
        {
            //
            ratioStatus = 1
            
            rationBt.setImage(UIImage(named: "ratio2_w"),  for: UIControlState.normal)
            
        }
        else if(ratioStatus == 1)
        {
            ratioStatus = 2
            rationBt.setImage(UIImage(named: "ratio1_w"),  for: UIControlState.normal)
        }
        else if(ratioStatus == 2)
        {
            ratioStatus = 0
            rationBt.setImage(UIImage(named: "ratio3_w"),  for: UIControlState.normal)
        }
        if(ratioStatus == 2)
        {
            renderWidthConstraint.constant = bounds.size.width
            renderHeightConstraint.constant = bounds.size.width
            //  renderTopConstraint.constant = 0
            // renderBottomConstraint.constant = 0
            renderTopConstraint.constant = 70
            renderBottomConstraint.constant =  bounds.size.height - bounds.size.width - 70
            
            
        }
        else if(ratioStatus == 1)
        {
            renderWidthConstraint.constant = bounds.size.width
            renderHeightConstraint.constant = 1.333 * bounds.size.width
            renderTopConstraint.constant = 0
            renderBottomConstraint.constant =  bounds.size.height - 1.333 * bounds.size.width
            
        }
        else if(ratioStatus == 0)
        {
            renderWidthConstraint.constant = bounds.size.width
            renderHeightConstraint.constant = bounds.size.height
            renderTopConstraint.constant = 0
            renderBottomConstraint.constant = 0
            
        }
        DispatchQueue.main.async(execute: {
            self.initCamera()
            self.openVideoCamera()
            
            self.videoCamera.startCapture()
        })
        
    }
    @IBAction func close(){
       // dismiss(animated: true, completion: nil)

        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    @IBAction func goProfile()
    {
        performSegue(withIdentifier: "exec_profile", sender: nil)
        
    }
    func documentsDirectoryURL() -> NSURL {
        let manager = FileManager.default
        let URLs = manager.urls(for: .documentDirectory, in: .userDomainMask)
        return URLs[0] as NSURL
    }
    func dataFileURL(fileName:String) -> NSURL {
        
        let path = String(format: "sticker/%@", fileName)
        let targetPath = documentsDirectoryURL().appendingPathComponent("sticker")! as NSURL
        
        let manager = FileManager.default
        
        if(manager.fileExists(atPath: targetPath.path!))
        {
            print("exist")
        }
        else
        {
            do{
                try   manager.createDirectory(at: targetPath as URL, withIntermediateDirectories: false, attributes: nil)
                
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        
        
        return documentsDirectoryURL().appendingPathComponent(path)! as NSURL
        
    }
    func dataFilterURL(fileName:String) -> NSURL {
        
        let path = String(format: "filter/%@", fileName)
        let targetPath = documentsDirectoryURL().appendingPathComponent("filter")! as NSURL
        
        let manager = FileManager.default
        
        if(manager.fileExists(atPath: targetPath.path!))
        {
            print("exist")
        }
        else
        {
            do{
                try   manager.createDirectory(at: targetPath as URL, withIntermediateDirectories: false, attributes: nil)
                
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        
        
        return documentsDirectoryURL().appendingPathComponent(path)! as NSURL
        
    }
    @IBAction func setNoneFilter()
    {
        initNoneFilter()
        selFilterType = 0
        selFilterData = Data()
        selOverlayData = Data()
    }
    func initNoneFilter()
    {
        if(filter != nil)
        {
            filter.removeAllTargets()
            videoCamera.removeAllTargets()
            cropFilter.removeAllTargets()
        }
        if(lookupImageSource != nil)
        {
            lookupImageSource.removeAllTargets()
        }
        exportUrl = documentsDirectoryURL().appendingPathComponent("test.mp4")! as NSURL
        let fileManaer =  FileManager.default
        
        if(fileManaer.fileExists(atPath: (exportUrl?.path!)!))
        {
            do{
                try    fileManaer.removeItem(at: exportUrl as! URL)
                
                
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        filter = ImageFilter()
        
        cropFilter = CropFilter(cropRegion: CGRect(x:0,y:0,width:1,height:0.5625))
        cropFilter.forceProcessing(at: CGSize(width: 720, height: 720))
        videoCamera.forceProcessing(at: CGSize(width: 720, height: 720))
        
        cropFilter?.addTarget(filter)
        movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL!, size: CGSize(width: 720     , height: 720))
        
        videoCamera?.audioEncodingTarget = movieWriter
        videoCamera.addTarget(cropFilter)
        
        filter?.addTarget(movieWriter)
        renderView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        filter.addTarget(renderView)
        
        let defaults = UserDefaults.standard
        defaults.set("none", forKey: "FILTER_NAME")
        defaults.set("none", forKey: "FILTER_TYPE")
        //  defaults.set(self.selectedCell , forKey: "FILTER_CELL")
        
        defaults.synchronize()
        
    }
    
    
    func initCamera()
    {
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if(appDelegate != nil && appDelegate.isSimulator == true)
        {
           // return
        }
        let user:UserDefaults = UserDefaults.standard
        
     //   let silence:Bool = user.bool(forKey: "SILENCE")
        let mirroring:Bool = user.bool(forKey: "MIRRORING")
        selFilterType = 0
        if(ratioStatus == 0)
        {
            self.frontCamera0 = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue, cameraPosition: .front)
            self.frontCamera0!.outputImageOrientation = .portrait;
            self.frontCamera0!.horizontallyMirrorFrontFacingCamera = mirroring
            self.backCamera0 = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue, cameraPosition: .back)
            self.backCamera0!.outputImageOrientation = .portrait;
            self.backCamera0!.horizontallyMirrorFrontFacingCamera = mirroring
            
         
        }
        else if(ratioStatus == 1)
        {
            self.frontCamera1 = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: .front)
            self.frontCamera1!.outputImageOrientation = .portrait;
            self.frontCamera1!.horizontallyMirrorFrontFacingCamera = mirroring
            self.backCamera1 = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: .back)
            self.backCamera1!.outputImageOrientation = .portrait;
            self.backCamera1!.horizontallyMirrorFrontFacingCamera = mirroring
            
         
        }
        else if(ratioStatus == 2)
        {
            self.frontCamera2 = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue, cameraPosition: .front)
            self.frontCamera2!.outputImageOrientation = .portrait;
            self.frontCamera2!.horizontallyMirrorFrontFacingCamera = mirroring
            self.backCamera2 = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue, cameraPosition: .back)
            self.backCamera2!.outputImageOrientation = .portrait;
            self.backCamera2!.horizontallyMirrorFrontFacingCamera = mirroring
            
            
        }
    }
    func imageFilter() -> GPUImageFilter
    {
        filter = ImageFilter()
        filterGroup.addFilter(filter)
        
        return filter
    }
    
    func lookupFilter(data:Data) -> GPUImageFilter
    {
        //filterGroup = GPUImageFilterGroup()
        
        let image = UIImage(data: data)
        
        lookupImageSource = GPUImagePicture(image: image)
        lookupFilter = GPUImageLookupFilter()
      
        lookupImageSource.addTarget(lookupFilter, atTextureLocation: 1)
        lookupImageSource.processImage()
        
        
        filterGroup.addFilter(lookupFilter)
        
        return lookupFilter
    }
    func toneFilter(data:Data) -> GPUImageFilter
    {
       // filterGroup = GPUImageFilterGroup()
        
        let image = UIImage(data: data)
       
        toneFilter = GPUImageToneCurveFilter(acvData: data)
        
        filterGroup.addFilter(toneFilter)
        
        return toneFilter
    }
    func overlayFilter(data:Data) -> GPUImageFilter
    {
        //filterGroup = GPUImageFilterGroup()
        
   //     blendFilter = GPUImageLinearBurnBlendFilter()
        blendFilter = GPUImageLinearBurnBlendFilter()
        // filter = ImageFilter()
        let image = UIImage(data: data)
     //   let image = UIImage(named: "overlay0.png")
        blendImage = GPUImagePicture(image: image)
        blendImage.addTarget(blendFilter, atTextureLocation: 3)
        blendImage.processImage()
    
        filterGroup.addFilter(blendFilter)

        return blendFilter
    }
    func overlayWaterFilter() -> GPUImageFilter
    {
        //filterGroup = GPUImageFilterGroup()
        
        //     blendFilter = GPUImageLinearBurnBlendFilter()
        blendWaterFilter = GPUImageLinearBurnBlendFilter()
        // filter = ImageFilter()
        let image = UIImage(named: "overlay12")
        blendWaterImage = GPUImagePicture(image: image)
        blendWaterImage.addTarget(blendWaterFilter, atTextureLocation: 4)
        blendWaterImage.processImage()
        
        filterGroup.addFilter(blendWaterFilter)
        
        return blendWaterFilter
    }
    func setFilterChain(filterType:Int, filterData:Data, isOverlay:Bool = false, overlayData:Data ) -> GPUImageFilter
    {
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if(appDelegate != nil && appDelegate.isSimulator == true)
        {
         //   return GPUImageFilter()
        }
        if(filter != nil)
        {
            filter.removeAllTargets()
        }
        if(blendFilter != nil)
        {
            blendImage.removeAllTargets()
            blendFilter.removeAllTargets()
        }
        if(blendWaterFilter != nil)
        {
            blendWaterImage.removeAllTargets()
            blendWaterFilter.removeAllTargets()
        }
        if(lookupFilter != nil)
        {
            lookupImageSource.removeAllTargets()
             lookupFilter.removeAllTargets()
        }
        
         if(cropFilter != nil)
        {
            videoCamera.removeAllTargets()
            cropFilter.removeAllTargets()
            
        }
        
        
        /*
            filterType
         0 : none
         1 : Tone
         2 : Lookup
        */
        var firstFilter: GPUImageFilter!
        var sencondFilter: GPUImageFilter!
        var thirdFilter: GPUImageFilter!
        switch(filterType)
        {
        case 0:
            firstFilter = imageFilter()
                break
        case 1:
            firstFilter = toneFilter(data:filterData)
            
            break
        case 2:
            firstFilter = lookupFilter(data:filterData)
          
            break
        default:
            break
            
        }
        
        cropFilter = CropFilter(cropRegion: CGRect(x:0,y:0,width:1,height:0.5625))
        cropFilter.forceProcessing(at: CGSize(width: 720, height: 720))
        videoCamera.forceProcessing(at: CGSize(width: 720, height: 720))
        cropFilter.setFrameBuffer(ratioStatus)
       
        if(isOverlay == true)
        {
            
            let user:UserDefaults = UserDefaults.standard
            
            let bWater:Bool = user.bool(forKey: "isWaterPurchased")
            
            if(bWater == false)
            {
                sencondFilter = overlayFilter(data: overlayData)
                thirdFilter = overlayWaterFilter()
                firstFilter.addTarget(sencondFilter)
                sencondFilter.addTarget(thirdFilter)
            
                filterGroup.initialFilters = [firstFilter]
                filterGroup.terminalFilter = thirdFilter
                
            }
            else
            {
                sencondFilter = overlayFilter(data: overlayData)
                filterGroup.initialFilters = [firstFilter]
                filterGroup.terminalFilter = sencondFilter
                
                firstFilter.addTarget(sencondFilter)
                
            }
            
             cropFilter?.addTarget(filterGroup)
     
            movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL!, size: CGSize(width: 720     , height: 720))
            
            videoCamera?.audioEncodingTarget = movieWriter
            videoCamera.addTarget(cropFilter)
            
            filterGroup?.addTarget(movieWriter)
            renderView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
            filterGroup.addTarget(renderView)
            
            return sencondFilter
        }
        else{
            let user:UserDefaults = UserDefaults.standard
            
            let bWater:Bool = user.bool(forKey: "isWaterPurchased")
            
            if(bWater == false)
            {
                sencondFilter = overlayWaterFilter()
                filterGroup.initialFilters = [firstFilter]
                filterGroup.terminalFilter = sencondFilter
                firstFilter.addTarget(sencondFilter)
                
            }
            else
            {
                filterGroup.initialFilters = [firstFilter]
                filterGroup.terminalFilter = firstFilter
                
            }
            
            /////
            
            cropFilter?.addTarget(filterGroup)
            
            movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL!, size: CGSize(width: 720     , height: 720))
            
            videoCamera?.audioEncodingTarget = movieWriter
            videoCamera.addTarget(cropFilter)
            
            filterGroup?.addTarget(movieWriter)
            renderView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
            filterGroup.addTarget(renderView)
            
            return firstFilter
            
        }
        
        
    }
    func clearFilter()
    {
        if(filterGroup != nil)
        {
            filterGroup.removeAllTargets()
            lookupFilter.removeAllTargets()
            toneFilter.removeAllTargets()
            filter.removeAllTargets()
        }
        
    }
    
    func openVideoCamera()
    {
        
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if(appDelegate != nil && appDelegate.isSimulator == true)
        {
            //return
        }
        
        if(self.filter != nil)
        {
           // [self.filter .removeAllTargets()]
            self.videoCamera.removeAllTargets()
       //     self.frontCamera.removeAllTargets()
       //     self.backCamera.removeAllTargets()
            
            self.filter.removeAllTargets()
            self.cropFilter.removeAllTargets()
      //      self.blendFilter.removeAllTargets()
        }
      
        
      
        let fileManaer =  FileManager.default
       
     
        exportUrl = documentsDirectoryURL().appendingPathComponent("test.mp4")! as NSURL
       
        
        if(lookupImageSource != nil)
        {
            lookupImageSource.removeAllTargets()
        }
        if(fileManaer.fileExists(atPath: (exportUrl?.path!)!))
        {
            do{
                try    fileManaer.removeItem(at: exportUrl as! URL)
                
                
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
      //  filter = ImageFilter()
        if(ratioStatus == 0)
        {
            if(self.bFront == true)
            {
                self.videoCamera = self.frontCamera0
            }
            else
            {
                self.videoCamera = self.backCamera0
            }
         //   self.videoCamera.resumeCameraCapture()

            cropFilter = CropFilter(cropRegion: CGRect(x:0,y:0,width:1,height:1.0))
            cropFilter.forceProcessing(at: CGSize(width: 720, height: 1280))
            videoCamera.forceProcessing(at: CGSize(width: 720, height: 1280))
            cropFilter.setFrameBuffer(ratioStatus)
            cropFilter?.addTarget(filter)
            movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL!, size: CGSize(width: 720     , height: 1280))
            
        }
        else if(ratioStatus == 1)
        {
            
            if(self.bFront == true)
            {
                self.videoCamera = self.frontCamera1
            }
            else
            {
                self.videoCamera = self.backCamera1
            }
           // self.videoCamera.resumeCameraCapture()

            cropFilter = CropFilter(cropRegion: CGRect(x:0,y:0,width:1,height:1))
           // cropFilter.forceProcessing(at: CGSize(width: 480, height: 640))
           // videoCamera.forceProcessing(at: CGSize(width: 480, height: 640))
            cropFilter.setFrameBuffer(ratioStatus)
            cropFilter?.addTarget(filter)
            
            movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL!, size: CGSize(width: 480     , height: 640))
            

        }
        else if(ratioStatus == 2)
        {
             if(self.bFront == true)
            {
                self.videoCamera = self.frontCamera2
            }
            else
            {
                self.videoCamera = self.backCamera2
            }
            /*
            
            filter = GPUImageLinearBurnBlendFilter()
           // filter = ImageFilter()
            let image = UIImage(named: "overlay0.png")
            blendImage = GPUImagePicture(image: image)
            blendImage.addTarget(filter, atTextureLocation: 3)
            blendImage.processImage()
           
            cropFilter = CropFilter(cropRegion: CGRect(x:0,y:0,width:1,height:0.5625))
            cropFilter.forceProcessing(at: CGSize(width: 720, height: 720))
            videoCamera.forceProcessing(at: CGSize(width: 720, height: 720))
            cropFilter.setFrameBuffer(ratioStatus)
            
            cropFilter?.addTarget(filter)
          
            */
          //  func setFilterChain(filterType:Int, filterData:Data, isOverlay:Bool = false, overlayData:Data ) -> GPUImageFilter
            let filterData:Data = Data()
            let overlayData:Data = Data()
            setFilterChain(filterType: 0, filterData: filterData, isOverlay: false, overlayData: overlayData)
 //           movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL!, size: CGSize(width: 720     , height: 720))
            
       }
    
        videoCamera.startCapture()
        
     //   movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL!, size: CGSize(width: 720     , height: 720))
        
        
    }
    
    
    
    func selectToneFilter( data :Data)
    {
        if(filter != nil)
        {
            filter.removeAllTargets()
            videoCamera.removeAllTargets()
            cropFilter.removeAllTargets()
        }
        if(lookupImageSource != nil)
        {
            lookupImageSource.removeAllTargets()
        }
        filter = GPUImageToneCurveFilter(acvData: data)
       
        if(ratioStatus == 0)
        {
          
            cropFilter = CropFilter(cropRegion: CGRect(x:0,y:0,width:1,height:1.0))
            // cropFilter.forceProcessing(at: CGSize(width: 1280, height: 720))
            // videoCamera.forceProcessing(at: CGSize(width: 1280, height: 720))
            cropFilter.setFrameBuffer(ratioStatus)
            cropFilter?.addTarget(filter)
            movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL!, size: CGSize(width: 720     , height: 1280))
            
        }
        else if(ratioStatus == 1)
        {
              cropFilter = CropFilter(cropRegion: CGRect(x:0,y:0,width:0.5,height:0.375))
            // cropFilter.forceProcessing(at: CGSize(width: 640, height: 480))
            // videoCamera.forceProcessing(at: CGSize(width: 640, height: 480))
            cropFilter.setFrameBuffer(ratioStatus)
            cropFilter?.addTarget(filter)
            
            movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL!, size: CGSize(width: 480     , height: 640))
            
            
        }
        else if(ratioStatus == 2)
        {
            cropFilter = CropFilter(cropRegion: CGRect(x:0,y:0,width:1,height:0.5625))
            cropFilter.forceProcessing(at: CGSize(width: 720, height: 720))
            videoCamera.forceProcessing(at: CGSize(width: 720, height: 720))
            cropFilter.setFrameBuffer(ratioStatus)
            cropFilter?.addTarget(filter)
            
            movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL!, size: CGSize(width: 720     , height: 720))
            
        }
        
        videoCamera?.audioEncodingTarget = movieWriter
        videoCamera.addTarget(cropFilter)
        
        filter?.addTarget(movieWriter)
        renderView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        filter.addTarget(renderView)
    }
    func selectLookupFilter( image :UIImage)
    {
        if(filter != nil)
        {
            filter.removeAllTargets()
            videoCamera.removeAllTargets()
            cropFilter.removeAllTargets()
        }
        if(lookupImageSource != nil)
        {
            lookupImageSource.removeAllTargets()
        }
      
        filterGroup = GPUImageFilterGroup()
        
        lookupImageSource = GPUImagePicture(image: image)
        filter = GPUImageLookupFilter()
        lookupImageSource.addTarget(filter, atTextureLocation: 1)
        lookupImageSource.processImage()
        
       // filter = GPUImageSepiaFilter()
        
        filterGroup.addFilter(filter)
        
    
        //////
        
        blendFilter = GPUImageLinearBurnBlendFilter()
        
        let image = UIImage(named: "overlay13.png")
        blendImage = GPUImagePicture(image: image)
        blendImage.addTarget(blendFilter, atTextureLocation: 2)
        blendImage.processImage()
        
        filterGroup.addFilter(blendFilter)
        
        filter.addTarget(blendFilter)
        //   filter.addTarget(blendFilter)
        
        
        /////
       
        
        if(ratioStatus == 0)
        {
            /*
             cropFilter = CropFilter(cropRegion: CGRect(x:0,y:0,width:1,height:0.75))
             cropFilter.forceProcessing(at: CGSize(width: 480, height: 480))
             videoCamera.forceProcessing(at: CGSize(width: 480, height: 480))
             */
            cropFilter = CropFilter(cropRegion: CGRect(x:0,y:0,width:1,height:1.0))
            // cropFilter.forceProcessing(at: CGSize(width: 1280, height: 720))
            // videoCamera.forceProcessing(at: CGSize(width: 1280, height: 720))
            cropFilter.setFrameBuffer(ratioStatus)
            cropFilter?.addTarget(filter)
            movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL!, size: CGSize(width: 720     , height: 1280))
            
        }
        else if(ratioStatus == 1)
        {
            /*
             cropFilter = CropFilter(cropRegion: CGRect(x:0,y:0,width:1,height:0.75))
             cropFilter.forceProcessing(at: CGSize(width: 480, height: 480))
             videoCamera.forceProcessing(at: CGSize(width: 480, height: 480))
             */
            cropFilter = CropFilter(cropRegion: CGRect(x:0,y:0,width:0.5,height:0.375))
            // cropFilter.forceProcessing(at: CGSize(width: 640, height: 480))
            // videoCamera.forceProcessing(at: CGSize(width: 640, height: 480))
            cropFilter.setFrameBuffer(ratioStatus)
            cropFilter?.addTarget(filter)
            
            movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL!, size: CGSize(width: 480     , height: 640))
            
            
        }
        else if(ratioStatus == 2)
        {
            filterGroup.initialFilters = [filter]
            filterGroup.terminalFilter =  blendFilter
            
            cropFilter = CropFilter(cropRegion: CGRect(x:0,y:0,width:1,height:0.5625))
            cropFilter.forceProcessing(at: CGSize(width: 720, height: 720))
            videoCamera.forceProcessing(at: CGSize(width: 720, height: 720))
            cropFilter.setFrameBuffer(ratioStatus)
            cropFilter?.addTarget(filterGroup)
            
            movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL!, size: CGSize(width: 720     , height: 720))
            
        }
        videoCamera?.audioEncodingTarget = movieWriter
        videoCamera.addTarget(cropFilter)
        
        filterGroup?.addTarget(movieWriter)
        renderView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        filterGroup.addTarget(renderView)
    }
    
    @objc func handleLongPressGesture(recogizer: UILongPressGestureRecognizer) {
        let user:UserDefaults = UserDefaults.standard
        
        switch recogizer.state {
        case .began:
            do {
                    self.type = 1
                    movieWriter?.startRecording()
                    
                }
                break
            
            
        case .ended:
            do {
        
                    self.movieWriter?.finishRecording(completionHandler: {
                        self.goVideo()
                    })
                
                break
                
            }
            
            
        default: break
        }
    }
    func goVideo()
    {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "exec_edit", sender: self.exportUrl)
            
        })
    }
    func startTimer(){
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    func stopTimer(){
        self.timer?.invalidate()
        self.timer = nil
        count = 0
      /*
        self.segmentedControl.disable = false
        
        let labels = self.segmentedControl.allItemLabels
        let label:UILabel =  labels[0]
        label.textColor = UIColor.black
       */
        
        circleView.removeFromSuperview()
        self.captureBt.setImage(UIImage(named: "video_cap"),  for: UIControlState.normal)
        self.movieWriter?.finishRecording(completionHandler: {
            self.record = false
            self.goVideo()
        })
    }
    @objc func update(){
        //0.5초마다 반복
        print("update")
        let user:UserDefaults = UserDefaults.standard
        let timerCnt:Int = user.integer(forKey: "SNAPSHOT_TIMER")
        
        
        count = count + 0.1
        var ratio:CGFloat = CGFloat(count)/15.0
        circleView.setProgress(ratio, animated: true)
        if(count >= 15)
        {
            count = 0
            self.stopTimer()
        }
        
        /*
        let strokeTextAttributes: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.strokeColor : UIColor.gray,
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.strokeWidth : -1.0,
            ]
        
        
        self.displayTitle?.attributedText = NSAttributedString(string:String(timerCnt-count), attributes: strokeTextAttributes)
        
        
        if( count >= timerCnt )
        {
            self.stopTimer()
            
        }
 */
    }
    
    func createCircleView()
    {
        if(circleView != nil)
        {
            circleView.removeFromSuperview()
        }
        
        
        circleView = CircleProgressBar(frame:self.captureBt.frame)
        circleView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        circleView.backgroundColor = UIColor.clear
        circleView.progressBarWidth = 2
        circleView.startAngle = -90
        circleView.progressBarProgressColor = UIColor.red
        circleView.progressBarTrackColor = UIColor(red: 250.0/255.0, green: 221.0/255.0, blue: 221.0/255.0, alpha: 1.0)
        circleView.hintHidden = true
        self.view.addSubview(circleView)
    }
    func isCameraAccess( completion:@escaping ( Bool) -> Void)
    {
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        
        switch cameraAuthorizationStatus {
        case .denied:
            completion(false)
            break
        case .authorized:
            completion(true)
            break
        case .restricted:
            completion(false)
            break
            
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                if granted {
                    print("Granted access to \(cameraMediaType)")
                    completion(true)
                } else {
                    print("Denied access to \(cameraMediaType)")
                    completion(false)
                    
                }
            }
        }
    }
    @IBAction func capture()
    {
        
        isCameraAccess(completion: { (success) in
            if( success == true )
            {
                self.processCapture()
            }
            else
            {
                let okAlert = UIAlertController(title: "Warning", message: "You need camera access permission to take pictures.\nYou need to enable camera access to the PetStar app in your iPhone settings before you can use it", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "OK", style: .default){ (action) in
                    // self.dismiss(animated: true, completion: nil)
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    }
                })
                self.present(okAlert, animated: true)
                
            }
        })
      
  
        
        
    }
    func processBuy()
    {
        
        performSegue(withIdentifier: "exec_buy", sender: nil)
        
    }
    
    func processCapture()
    {
        if(segmentedControl.selectedSegmentioIndex == 1)
        {
            self.type = 1
            
            // self.animationScaleEffect(view: captureBt, animationTime: 10.0)
            
            if(record == false)
            {
                record = true
                /*
                segmentedControl.disable = true
                
                let labels = segmentedControl.allItemLabels
                let label:UILabel =  labels[0]
                label.textColor = UIColor.lightGray
                */
                // captureBt.layer.zPosition = 10000
                createCircleView()
                // circleView.isUserInteractionEnabled = true
                //  circleView.layer.zPosition = 10
                self.view.addSubview(captureBt)
                startTimer()
                self.type = 1
                movieWriter?.startRecording()
                
                
                captureBt.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               usingSpringWithDamping: 0.32,
                               initialSpringVelocity: 6.0,
                               options: .allowUserInteraction,
                               animations: { [weak self] in
                                //self?.captureBt.transform = .identity
                                if( self?.filterView.isHidden == false)
                                {
                                    var t = CGAffineTransform.identity
                                    t = t.translatedBy(x: 0, y: 75)
                                    t = t.scaledBy(x: 0.75, y: 0.75)
                                    
                                    self?.captureBt.transform = t
                                    
                                }
                                else
                                {
                                    self?.captureBt.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                    
                                }
                                self?.captureBt.setImage(UIImage(named: "video_cap_stop"),  for: UIControlState.normal)
                                
                                // indicator.startAnimating()
                    },
                               completion: nil)
            }
            else{
                
                stopTimer()
            }
            
        }
        else
        {
            self.type = 0
            
            // Photo
            let user:UserDefaults = UserDefaults.standard
            
            let silence:Bool = user.bool(forKey: "SILENCE")
            
            if(silence == true)
            {
                var size = CGSize(width: 720, height: 1280)
                if(ratioStatus == 1)
                {
                    size = CGSize(width: 480, height: 640)
                }
                else if(ratioStatus == 2)
                {
                    size = CGSize(width: 720, height: 720)
                }
                
                
                filterGroup.useNextFrameForImageCapture()
                self.capturedImage = filterGroup.imageFromCurrentFramebuffer()
                performSegue(withIdentifier: "exec_edit", sender: nil)
                
            }
            else
            {
                
                
                
                videoCamera.capturePhotoAsImageProcessedUp(toFilter: filterGroup, withCompletionHandler: { (image, error) in
                    
                    self.capturedImage = image
                    self.performSegue(withIdentifier: "exec_edit", sender: nil)
                    
                })
            }
        }
        
        //
    }
    @IBAction func rotateCamera()
    {
        videoCamera.rotateCamera()
    }
    
    func makeMenu()
    {
        let user:UserDefaults = UserDefaults.standard
        
        let index:Int = user.integer(forKey: "FILTER_MENU")
        
        self.filterMenuSource = FilterMenuDelegate(owner: self)
        self.filterMenuSource?.oldIndex = index
        
        self.filterMenu.delegate = self.filterMenuSource
        self.filterMenu.dataSource  = self.filterMenuSource
        
    }
    
    @IBAction func showFilter()
    {
        var offset:CGFloat = 0.0
        var dummy:CGFloat = 0.0
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
            case 1334:
                print("iPhone 6/6S/7/8")
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                print("iPhone X")
                offset = 20.0
                dummy = 25
            default:
                print("unknown")
            }
        }
       
        if(circleView != nil)
        {
            circleView.removeFromSuperview()
            circleView = nil
            
        }
        
        UIView.animate(withDuration:0.2, animations: {
            if(self.filterView.isHidden)
            {
                
                //self.makeVintage()
                
                self.noneView.layer.zPosition = 100
                
                var t = CGAffineTransform.identity
                t = t.translatedBy(x: 0, y: 75 + offset)
                t = t.scaledBy(x: 0.75, y: 0.75)
                
                self.captureBt.transform = t
                
              
                self.filterView.isHidden = false
                self.filterMenu.isHidden = false
                self.noneView.isHidden = false
                self.segmentedControl.isHidden = true
                
                self.filterBt.isHidden = false
                //  self.homeBt.isHidden = true
                //  self.notiBt.isHidden = true
                // self.myBt.isHidden = true
                
                // self.captureBt.isHidden = true
                let user:UserDefaults = UserDefaults.standard
                
                let index:Int = user.integer(forKey: "FILTER_MENU")
                
                self.makeFilterList(category: index)
                self.makeMenu()
                //
                //let user:UserDefaults = UserDefaults.standard
                
                //let index:Int = user.integer(forKey: "FILTER_MENU")
                
                
            }
            else
            {
                self.filters.removeAllObjects()
                self.filterView.isHidden = true
                self.filterMenu.isHidden = true
                self.noneView.isHidden = true
                self.segmentedControl.isHidden = false
                
                self.filterBt.isHidden = false
                //   self.homeBt.isHidden = false
                //   self.notiBt.isHidden = false
                //   self.myBt.isHidden = false
                // self.captureBt.isHidden = false
                
                var t = CGAffineTransform.identity
                t = t.translatedBy(x: 0, y: 0)
                t = t.scaledBy(x: 1.0, y: 1.0)
                
                self.captureBt.transform = t
                
                self.filterView.delegate = nil
                self.filterView.dataSource = nil
                
                
                self.filterMenu.delegate = nil
                self.filterMenu.dataSource  = nil
                
              
                
            }
            if(self.sourceType == 1)
            {
                // self.animationScaleEffect(view: captureBt, animationTime: 10.0)
                
              //  self.segmentedControl.disable = true
                
                
                
                self.createCircleView()
            }
         }, completion: {(_) -> Void in
            
            
        })
      
    }
    @IBAction func showOverlay()
    {
        var offset:CGFloat = 0.0
        var dummy:CGFloat = 0.0
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
            case 1334:
                print("iPhone 6/6S/7/8")
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                print("iPhone X")
                offset = 20.0
                dummy = 25
            default:
                print("unknown")
            }
        }
        if(circleView != nil)
        {
            circleView.removeFromSuperview()
            circleView = nil
            
        }
        UIView.animate(withDuration: 0.5) {
            if(self.filterView.isHidden)
            {
                
                //self.makeVintage()
                
                
                
                var t = CGAffineTransform.identity
                t = t.translatedBy(x: 0, y: 75 + offset)
                t = t.scaledBy(x: 0.75, y: 0.75)
                
                self.captureBt.transform = t
                
                self.filterView.isHidden = false
                self.filterMenu.isHidden = true
                self.noneView.isHidden = true
                self.segmentedControl.isHidden = true
                
                self.filterBt.isHidden = false
                //  self.homeBt.isHidden = true
                //  self.notiBt.isHidden = true
                // self.myBt.isHidden = true
                
                // self.captureBt.isHidden = true
                let user:UserDefaults = UserDefaults.standard
                
                let index:Int = user.integer(forKey: "FILTER_MENU")
                
                self.makeOverlayList()
                //
                //let user:UserDefaults = UserDefaults.standard
                
                //let index:Int = user.integer(forKey: "FILTER_MENU")
                
                
            }
            else
            {
                self.filters.removeAllObjects()
                self.filterView.isHidden = true
                self.filterMenu.isHidden = true
                self.noneView.isHidden = true
                self.segmentedControl.isHidden = false
                
                
                self.filterBt.isHidden = false
                //   self.homeBt.isHidden = false
                //   self.notiBt.isHidden = false
                //   self.myBt.isHidden = false
                // self.captureBt.isHidden = false
                
                var t = CGAffineTransform.identity
                t = t.translatedBy(x: 0, y: 0)
                t = t.scaledBy(x: 1.0, y: 1.0)
                
                self.captureBt.transform = t
                
                self.filterView.delegate = nil
                self.filterView.dataSource = nil
                
                
                self.filterMenu.delegate = nil
                self.filterMenu.dataSource  = nil
                
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "exec_edit"{
            
            if let videoViewController = segue.destination as? EditVideoViewController{
                
                videoViewController.exportUrl = self.exportUrl
                videoViewController.type = self.type
                videoViewController.ratioStatus = self.ratioStatus
                if(self.capturedImage != nil)
                {
                    videoViewController.image = self.capturedImage
                    
                }
            }
            
        }
      
    }
    func makeFilterList(category:Int)
    {
        filters?.removeAllObjects()
        if(category == 0)
        {
            var items:NSMutableArray?
            items = makeBasic()
            self.filterSource = FilterDelegate(items: items!, owner: self)
            
        }
        if(category == 1)
        {
            var items:NSMutableArray?
            items = makeVintage()
            self.filterSource = FilterDelegate(items: items!, owner: self)
            
        }
        if(category == 2)
        {
            var items:NSMutableArray?
            items = makeHaze()
            self.filterSource = FilterDelegate(items: items!, owner: self)
            
        }
        if(category == 3)
        {
            var items:NSMutableArray?
            items = makeModern()
            self.filterSource = FilterDelegate(items: items!, owner: self)
            
        }
        if(category == 4)
        {
            var items:NSMutableArray?
            items = makeWdding()
            self.filterSource = FilterDelegate(items: items!, owner: self)
            
        }
        if(category == 5)
        {
            var items:NSMutableArray?
            items = makeStudio()
            self.filterSource = FilterDelegate(items: items!, owner: self)
            
        }
        if(category == 6)
        {
            var items:NSMutableArray?
            items = makeFloral()
            self.filterSource = FilterDelegate(items: items!, owner: self)
            
        }
        self.filterView?.delegate = self.filterSource
        self.filterView?.dataSource = self.filterSource
        
        self.filterView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                      at: .left,
                                      animated: true)
        
        self.filterView?.reloadData()
    }
    func makeOverlayList()
    {
        filters?.removeAllObjects()
      
        
        var items:NSMutableArray?
        items = makeOverlays()
        self.overlaySource = OverlayDelegate(items: items!, owner: self)
        
        
        self.filterView?.delegate = self.overlaySource
        self.filterView?.dataSource = self.overlaySource
        
        self.filterView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                      at: .left,
                                      animated: true)
        
        self.filterView?.reloadData()
    }
    func makeOverlays() -> NSMutableArray
    {
    //    setOverlay(name: "overlay0.png", filterName: "overlay0", thumb: "", type: "Overlay",category:"Basic")
   //     setOverlay(name: "overlay1.png", filterName: "overlay1", thumb: "", type: "Overlay",category:"Basic")
   //     setOverlay(name: "overlay2.png", filterName: "overlay2", thumb: "", type: "Overlay",category:"Basic")
   //     setOverlay(name: "overlay3.png", filterName: "overlay3", thumb: "", type: "Overlay",category:"Basic")
    //    setOverlay(name: "overlay4.png", filterName: "overlay4", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay5.png", filterName: "overlay5", thumb: "", type: "Overlay",category:"Basic")
    //    setOverlay(name: "overlay6.png", filterName: "overlay6", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay7.png", filterName: "overlay7", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay8.png", filterName: "overlay8", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay9.png", filterName: "overlay9", thumb: "", type: "Overlay",category:"Basic")
    //    setOverlay(name: "overlay10.png", filterName: "overlay10", thumb: "", type: "Overlay",category:"Basic")
   //     setOverlay(name: "overlay11.png", filterName: "overlay11", thumb: "", type: "Overlay",category:"Basic")
    //    setOverlay(name: "overlay12.png", filterName: "overlay12", thumb: "", type: "Overlay",category:"Basic")
    //    setOverlay(name: "overlay13.png", filterName: "overlay13", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay14.png", filterName: "overlay14", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay15.png", filterName: "overlay15", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay16.png", filterName: "overlay16", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay17.png", filterName: "overlay17", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay18.png", filterName: "overlay18", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay19.png", filterName: "overlay19", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay20.png", filterName: "overlay20", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay21.png", filterName: "overlay21", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay22.png", filterName: "overlay22", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay23.png", filterName: "overlay23", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay24.png", filterName: "overlay24", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay25.png", filterName: "overlay25", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay26.png", filterName: "overlay26", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay27.png", filterName: "overlay27", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay28.png", filterName: "overlay28", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay29.png", filterName: "overlay29", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay30.png", filterName: "overlay30", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay31.png", filterName: "overlay31", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay32.png", filterName: "overlay32", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay33.png", filterName: "overlay33", thumb: "", type: "Overlay",category:"Basic")
        setOverlay(name: "overlay34.png", filterName: "overlay34", thumb: "", type: "Overlay",category:"Basic")

        return overlays!
        
    }
    func makeBasic() -> NSMutableArray
    {
        setTexture(name: "midnight.acv", filterName: "Midnight", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "coffee.acv", filterName: "Coffee", thumb: "", type: "ToneCurve",category:"Basic")
        
        setTexture(name: "sweet_day.acv", filterName: "Sweet Day", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "canela.acv", filterName: "Canela", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "winter.acv", filterName: "Winter", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "warm_pink.acv", filterName: "Warm Pink", thumb: "", type: "ToneCurve",category:"Basic")
        
        setTexture(name: "haze_green.acv", filterName: "Haze Green", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "old_memories.acv", filterName: "Old Memories", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "wine.acv", filterName: "Wine", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "old_magenta.acv", filterName: "Old Magenta", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "night.acv", filterName: "Night", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "christmas.acv", filterName: "Christmas", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "orange_dream.acv", filterName: "Orange Dream", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "red_dream.acv", filterName: "Red Dream", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "uva.acv", filterName: "UVA", thumb: "", type: "ToneCurve",category:"Basic")
        
        return filters!
        
    }
    
    func makeVintage() -> NSMutableArray
    {
        
        setTexture(name: "lookup_vintage_aged.png", filterName: "Vintage Aged", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_antique.png", filterName: "Vintage Antique", thumb: "", type: "Lookup",category:"Vintage")
        
        setTexture(name: "lookup_vintage_blue_fade.png", filterName: "Vintage Blue Fade", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_brash.png", filterName: "Vintage Brashs", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_classic_fade.png", filterName: "Vintage Classic Fade", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_classica.png", filterName: "Vintage Classica", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_colors.png", filterName: "Vintage Colors", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_cool.png", filterName: "Vintage Cool", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_cool2.png", filterName: "Vintage Cool2", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_creamy.png", filterName: "Vintage Creamy", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_darkness.png", filterName: "Vintage Darkness", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_days_gone_by.png", filterName: "Vintage Days Gone by", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_depth.png", filterName: "Vintage Depth", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_earthy.png", filterName: "Vintage Earthy", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_earthy2.png", filterName: "Vintage Earthy2", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_fade.png", filterName: "Vintage Fade", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_fade2.png", filterName: "Vintage Fade2", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_glory_days.png", filterName: "Vintage Glory Days", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_golden_fade.png", filterName: "Vintage Golden Fade", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_haze.png", filterName: "Vintage Haze", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_heaven.png", filterName: "Vintage Heaven", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_history.png", filterName: "Vintage History", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_icy.png", filterName: "Vintage Icy", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_insomnia.png", filterName: "Vintage Insomnia", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_intense.png", filterName: "Vintage Intense", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_light.png", filterName: "Vintage Light", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_lostdays.png", filterName: "Vintage Lost Days", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_matte.png", filterName: "Vintage Matte", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_matte2.png", filterName: "Vintage Matte2", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_memories.png", filterName: "Vintage Memories", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_morning.png", filterName: "Vintage Morning", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_old_timer.png", filterName: "Vintage Old Timer", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_outdated.png", filterName: "Vintage Outdated", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_overcast.png", filterName: "Vintage Overcast", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_past_tense.png", filterName: "Vintage Past Tense", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_peach.png", filterName: "Vintage Peach", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_pressed.png", filterName: "Vintage Pressed", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_purpleish.png", filterName: "Vintage Purple-ish", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_retro_fix.png", filterName: "Vintage Retro Fix", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_retro_red.png", filterName: "Vintage Retro Red", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_retro_red2.png", filterName: "Vintage Retro Red2", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_rose.png", filterName: "Vintage Rose", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_second_hand.png", filterName: "Vintage Second Hand", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_serious.png", filterName: "Vintage Serious", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_soft.png", filterName: "Vintage Soft", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_something_blue.png", filterName: "Vintage Something Blue", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_something_old.png", filterName: "Vintage Something Old", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_sun.png", filterName: "Vintage Sun", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_sun2.png", filterName: "Vintage Sun2", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_timid.png", filterName: "Vintage Timid", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_touch.png", filterName: "Vintage Touch", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_very.png", filterName: "Vintage Very", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_wash.png", filterName: "Vintage Wash", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_whisper.png", filterName: "Vintage Whisper", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_old_beach.png", filterName: "Vintage Beach", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_old_broadway.png", filterName: "Vintage Broadway", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_old_covershot.png", filterName: "Vintage Covershot", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_oldmemories.png", filterName: "Vintage Memories", thumb: "", type: "Lookup",category:"Vintage")
        
        return filters!
        
    }
    func makeHaze()->NSMutableArray
    {
        
        
        setTexture(name: "lookup_haze_basic.png", filterName: "Haze Basic", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_blueberry.png", filterName: "Haze Blueberry", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_bw_heavy.png", filterName: "Haze B&W Heavy", thumb: "", type: "Lookup",category:"Haze")
        
        setTexture(name: "lookup_haze_bw_high_contrast.png", filterName: "Haze High Contrast", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_bw.png", filterName: "Haze B&W", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_cool.png", filterName: "Haze Cool", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_desaturation.png", filterName: "Haze Desaturation", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_gold.png", filterName: "Haze Gold", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_heavy.png", filterName: "Haze Heavy", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_high_contrast.png", filterName: "Haze High Contrast", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_purple.png", filterName: "Haze Purple", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_strawberry.png", filterName: "Haze Strawberry", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_vibrant.png", filterName: "Haze Vibrant", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_warm.png", filterName: "Haze Warm", thumb: "", type: "Lookup",category:"Haze")
        
        return filters!
        
    }
    func makeFloral()->NSMutableArray
    {
        setTexture(name: "lookup_floral_aureolin.png", filterName: "Floral Aureolin", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_black_cherry.png", filterName: "Floral Black Cherry", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_bliss.png", filterName: "Floral Bliss", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_california.png", filterName: "Floral California", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_caramel.png", filterName: "Floral Caramel", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_colorwheel.png", filterName: "Floral Color Wheel", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_cross_proccesing.png", filterName: "Floral Cross processing", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_echo.png", filterName: "Floral Echo", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_edition.png", filterName: "Floral Edition", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_expedition.png", filterName: "Floral Expedition", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_extravagant.png", filterName: "Floral Extravagant", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_focus_highlight.png", filterName: "Floral Focus Highlight", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_frontpage.png", filterName: "Floral Frontpage", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_gamma.png", filterName: "Floral Gamma", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_golden_yellow.png", filterName: "Floral Golden Yellow", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_hazel.png", filterName: "Floral Hazel", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_infrared.png", filterName: "Floral Infra Red", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_iris.png", filterName: "Floral Iris", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_lavender.png", filterName: "Floral Lavender", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_long_journey.png", filterName: "Floral Long Journey", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_neutral_density.png", filterName: "Floral Neutral Density", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_nonphoto_blue.png", filterName: "Floral Nonphoto Blue", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_orton.png", filterName: "Floral Orton", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_overexposure_soft.png", filterName: "Floral Overexposure Soft", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_passion.png", filterName: "Floral Passion", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_pole.png", filterName: "Floral Pole", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_raw_filter.png", filterName: "Floral Raw Filter", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_saffron.png", filterName: "Floral Saffron", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_seashell.png", filterName: "Floral Sea Shell", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_silent_night.png", filterName: "Floral Silent Night", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_skin.png", filterName: "Floral Skin", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_spring.png", filterName: "Floral Spring", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_twistedline.png", filterName: "Floral Twisted line", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_velvet.png", filterName: "Floral Velvet", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_white.png", filterName: "Floral White", thumb: "", type: "Lookup",category:"Floral")
        
        return filters!
    }
    func makeStudio()->NSMutableArray
    {
        
        setTexture(name: "lookup_studio_coldfocus.png", filterName: "Studio Cold Focus", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_studio_elegant.png", filterName: "Studio Elegant", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_studio_memories.png", filterName: "Studio Memories", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_studio_overexposure_soft.png", filterName: "Studio Over Exposure", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_studio_ultracontrast.png", filterName: "Studio Ultra Contrast", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_studio_wavelength.png", filterName: "Studio Wavelength", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_classic.png", filterName: "Studio Classic", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_hill.png", filterName: "Studio Hill", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_photo_master.png", filterName: "Studio Photo Master", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_toning_classic_summer.png", filterName: "Studio Toning Classic Summer", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_toning_everest.png", filterName: "Studio Toning Everest", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_toning_polaroid.png", filterName: "Studio Toning Polaroid", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_toning_selenium.png", filterName: "Studio Toning Selenium", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_toning_strawberry.png", filterName: "Studio Toning Strawberry", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_waves.png", filterName: "Studio Waves", thumb: "", type: "Lookup",category:"Studio")
        
        return filters!
    }
    func makeWdding()->NSMutableArray
    {
        
        setTexture(name: "lookup_wdding_apollo.png", filterName: "Wedding Apollo", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wdding_aquamarine.png", filterName: "Wedding Aqua Marine", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wdding_bronzer.png", filterName: "Wedding Bronzer", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_autumnal.png", filterName: "Wedding Autumnal", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_bw_diana.png", filterName: "Wedding B&W Diana", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_bw_lowkey.png", filterName: "Wedding B&W Lowkey", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_dramatic_light.png", filterName: "Wedding Dramatic Light", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_enhance.png", filterName: "Wedding Enhance", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_ezon.png", filterName: "Wedding Ezon", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_fashion.png", filterName: "Wedding Fashion", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_galaxy.png", filterName: "Wedding Galaxy", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_hazel.png", filterName: "Wedding Hazel", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_highbubble.png", filterName: "Wedding High Bubble", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_layan.png", filterName: "Wedding Layan", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_pastel.png", filterName: "Wedding Pastel", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_summer.png", filterName: "Wedding Summer", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_urban_style.png", filterName: "Wedding Urbal Style", thumb: "", type: "Lookup",category:"Wedding")
        
        return filters!
    }
    
    func makeModern()->NSMutableArray
    {
        setTexture(name: "lookup_modern_apricot.png", filterName: "Modern Apicot", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_delicate.png", filterName: "Modern Delicate", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_deluxe.png", filterName: "Modern Deluxe", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_dot_digital.png", filterName: "Modern Dot Digital1", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_dot_digital2.png", filterName: "Modern Dot Digital2", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_ecru.png", filterName: "Modern Ecru", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_emerald.png", filterName: "Modern Emerald", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_exquisite.png", filterName: "Modern Exquisite", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_graceful.png", filterName: "Modern Graceful", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_light_faded.png", filterName: "Modern Light Faded", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_muted.png", filterName: "Modern Muted", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_orange_peel.png", filterName: "Modern Orange Peel", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_peri_winkle.png", filterName: "Modern Periwinkle", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_pistachio.png", filterName: "Modern Pistachio", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_sunny.png", filterName: "Modern Sunny", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_vanilla.png", filterName: "Modern Vanilla", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_white_smoke.png", filterName: "Modern White Smoke", thumb: "", type: "Lookup",category:"Modern")
        
        return filters!
    }
    func setTexture(name:String, filterName:String, thumb:String, type:String, category:String)
    {
        var data:FilterData
        data = FilterData(name: name, filterName:filterName,thumb: thumb,type: type,category: category)
        
        filters.add(data)
    }
    
    func setOverlay(name:String, filterName:String, thumb:String, type:String, category:String)
    {
        var data:FilterData
        data = FilterData(name: name, filterName:filterName,thumb: thumb,type: type,category: category)
        
        overlays.add(data)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let touch = touches.first
        let position:CGPoint = (touch?.location(in: self.view))!
        var rect:CGRect = renderView.frame;
       // self.videoCamera.captureSession
        if(rect.contains(position))
        {
            let device: AVCaptureDevice! = self.videoCamera.inputCamera!
            var error: NSError? = nil
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus)
                {
                    device.focusMode = .autoFocus
                    device.focusPointOfInterest = position
                }
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(.autoExpose){
                    
                    device.exposurePointOfInterest = position
                    device.exposureMode = .autoExpose
                }
                device.isSubjectAreaChangeMonitoringEnabled = true//monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch let error1 as NSError {
                error = error1
                print(error)
            } catch {
                fatalError()
            }
            
        }
        
      
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let touch = touches.first
        let position = touch?.location(in: self.view)
        
        var rect:CGRect = filterView.frame;
        var rect2:CGRect = filterMenu.frame;
        rect.origin.y = rect2.origin.y
        rect.size.height = rect.size.height + rect2.size.height
        UIView.animate(withDuration: 0.5) {
            if(!rect.contains(position!))
            {
                self.filterView.isHidden = true
                
                self.filterBt.isHidden = false
                self.segmentedControl.isHidden = false
                
              //  self.homeBt.isHidden = false
              //  self.notiBt.isHidden = false
              //  self.myBt.isHidden = false
               // self.captureBt.isHidden = false
                
                var t = CGAffineTransform.identity
                t = t.translatedBy(x: 0, y: 0)
                t = t.scaledBy(x: 1.0, y: 1.0)
                
                self.captureBt.transform = t
                if(self.filters != nil && self.filters.count > 0)
                {
                    self.filters.removeAllObjects()
                    
                }
                 self.filterView.delegate = nil
                self.filterView.dataSource = nil
                self.filterMenu.isHidden = true
                self.filterMenu.delegate = nil
                self.filterMenu.dataSource  = nil
                self.noneView.isHidden = true
                
                if(self.sourceType == 1)
                {
                    // self.animationScaleEffect(view: captureBt, animationTime: 10.0)
                    
                    //  self.segmentedControl.disable = true
                    
                  //  let labels = self.segmentedControl.allItemLabels
                   // let label:UILabel =  labels[0]
                 //   label.textColor = UIColor.lightGray
                    
                    self.createCircleView()
                }
            }
            
        }
        
    }
    func downloadFilter(url : String, filename : String,type:String, stickerName:String)
    {
        
        let request = URLRequest( url: URL(string: url)!)
        let session = AFHTTPSessionManager()
        
        let pathUrl = dataFilterURL(fileName: filename)//dataFileURL(fileName: filename)
   //     self.selFilterData = manager.contents(atPath: pathUrl.path!)
        let manager = FileManager.default
        
       // sceneType = type
       // filterName = filename
        
        if(manager.fileExists(atPath: pathUrl.path!))
        {
            
            if(type=="Lookup")
            {
             //   self.setStickerFilter(name: filename,sceneName: "Filter")
             //   self.setStickerFilter(name: filename,sceneName: "Filter")
                //UIImage *image = [UIImage imageWithData:data];
               // let data = manager.contents(atPath: pathUrl.path!)
               // let image = UIImage(data: data!)
             //   selectLookupFilter(image: image!)
                selFilterType = 2
            }
            if(type=="ToneCurve")
            {
                //setToneFilter
               // let data = manager.contents(atPath: pathUrl.path!)
              //  selectToneFilter(data: data!)
                selFilterType = 1
                
            }
 
            self.selFilterData = manager.contents(atPath: pathUrl.path!)
            let overlayData:Data = Data()
            if(self.selOverlayData != nil && self.selOverlayData.count > 0 )
            {
                self.setFilterChain(filterType: selFilterType, filterData: self.selFilterData, isOverlay: true, overlayData: self.selOverlayData)
                
            }
            else
            {
                self.setFilterChain(filterType: selFilterType, filterData: self.selFilterData, isOverlay: false, overlayData: overlayData)
                
            }
            
            
            //cell.indicator?.isHidden = true
            //cell.indicator?.stopAnimating()
            return
        }
        
        let downloadTask = session.downloadTask(with: request, progress: nil, destination: {(file, responce) in (pathUrl as URL)},
                                                completionHandler:
            {
                response, localfile, error in
                
                if(error == nil)
                {
                    /*
                    if(type=="Lookup")
                    {
                      //  self.setStickerFilter(name: filename,sceneName: "Filter")
                        let data = manager.contents(atPath: pathUrl.path!)
                        let image = UIImage(data: data!)
                        self.selectLookupFilter(image: image!)
                        
                    }
                    if(type=="ToneCurve")
                    {
                        //setToneFilter
                        let data:NSData = manager.contents(atPath: pathUrl.path!) as! NSData
                        
                        if(data.length != 0 )
                        {
                       //     self.setToneFilter(toneData: data as! NSData)
                            self.selectToneFilter(data: data as Data)
                            
                        }
                    }
                        */
                    if(type=="Lookup")
                    {
                        self.selFilterType = 2
                    }
                    if(type=="ToneCurve")
                    {
                        self.selFilterType = 1
                        
                    }
                    
                    self.selFilterData = manager.contents(atPath: pathUrl.path!)
                    let overlayData:Data = Data()
                    if(self.selOverlayData != nil && self.selOverlayData.count > 0 )
                    {
                        self.setFilterChain(filterType: self.selFilterType, filterData: self.selFilterData, isOverlay: true, overlayData: self.selOverlayData)
                        
                    }
                    else
                    {
                        self.setFilterChain(filterType: self.selFilterType, filterData: self.selFilterData, isOverlay: false, overlayData: overlayData)
                        
                    }
                    
                   
                 //   cell.indicator?.isHidden = true
                 //   cell.indicator?.stopAnimating()
                    
                }
                else
                {
               //     cell.indicator?.isHidden = true
               //     cell.indicator?.stopAnimating()
               //     self.errorMsg()
                    
                }
                
                
                
                //print(ret)
                
                
        })
        
        downloadTask.resume()
    }
    func downloadOverlay(url : String, filename : String,type:String, stickerName:String)
    {
        
        let request = URLRequest( url: URL(string: url)!)
        let session = AFHTTPSessionManager()
        
        let pathUrl = dataFilterURL(fileName: filename)//dataFileURL(fileName: filename)
        let manager = FileManager.default
        
        
        if(manager.fileExists(atPath: pathUrl.path!))
        {
            let data:Data = manager.contents(atPath: pathUrl.path!)!
            self.selOverlayData = data
            
            let filterData:Data = Data()
            if(self.selFilterType > 0 )
            {
                self.setFilterChain(filterType: self.selFilterType, filterData: self.selFilterData, isOverlay: true, overlayData: data)

            }
            else
            {
                self.setFilterChain(filterType: self.selFilterType, filterData: filterData, isOverlay: true, overlayData: data)
            }
            
       
         
            return
        }
        
        let downloadTask = session.downloadTask(with: request, progress: nil, destination: {(file, responce) in (pathUrl as URL)},
                                                completionHandler:
            {
                response, localfile, error in
                
                if(error == nil)
                {
                  
                    let data:Data = manager.contents(atPath: pathUrl.path!)!
                    
                    let filterData:Data = Data()
                    self.selOverlayData = data
                    
                    if(self.selFilterType > 0 )
                    {
                        self.setFilterChain(filterType: self.selFilterType, filterData: self.selFilterData, isOverlay: true, overlayData: data)
                        
                    }
                    else
                    {
                        self.setFilterChain(filterType: self.selFilterType, filterData: filterData, isOverlay: true, overlayData: data)
                    }
                    
                    //   cell.indicator?.isHidden = true
                    //   cell.indicator?.stopAnimating()
                    
                }
                else
                {
                    //     cell.indicator?.isHidden = true
                    //     cell.indicator?.stopAnimating()
                    //     self.errorMsg()
                    
                }
                
                
                
                //print(ret)
                
                
        })
        
        downloadTask.resume()
    }
    func processFilter(item:String,type:String)
    {
        let url:String = String(format: "http://www.junsoft.org/filter/%@", item as CVarArg)
        
        self.selectedFilter?.type = type
        self.selectedFilter?.name = item
       // self.selectedCell = cell
        
        let defaults = UserDefaults.standard
        defaults.set(item, forKey: "FILTER_NAME")
        defaults.set(type, forKey: "FILTER_TYPE")
      //  defaults.set(self.selectedCell , forKey: "FILTER_CELL")
        
        defaults.synchronize()
        
        /*
        sceneType = ""
        bBeauty = true
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\(item)",
            AnalyticsParameterItemName: item,
            AnalyticsParameterContentType: "filter_select"
            ])
        */
        downloadFilter(url: url,filename: item, type: type, stickerName: "")
        
    }
    func processOverlay(item:String,type:String)
    {
        let url:String = String(format: "http://www.junsoft.org/overlay/%@", item as CVarArg)
        
        self.selectedFilter?.type = type
        self.selectedFilter?.name = item
        // self.selectedCell = cell
        
        let defaults = UserDefaults.standard
        defaults.set(item, forKey: "OVERLAY_NAME")
       // defaults.set(type, forKey: "FILTER_TYPE")
        //  defaults.set(self.selectedCell , forKey: "FILTER_CELL")
        
        defaults.synchronize()
        
       
        downloadOverlay(url: url,filename: item, type: type, stickerName: "")
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension CameraViewController : GPUImageVideoCameraDelegate{
    
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        
        if(self.cameraInit == true)
        {
            DispatchQueue.main.async(execute: {
                
                RSLoadingView.hide(from: self.view)
                self.cameraInit = false
                print("loading")

            })
        }
      
        
    }
}

