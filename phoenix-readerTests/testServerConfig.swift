//
//  testServerConfig.swift
//  phoenix-reader
//
//  Created by Scott Ferwerda on 3/7/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

import XCTest

class testServerConfig: XCTestCase {
    
    // Core Data store stuff
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
//        let modelURL = NSBundle.mainBundle().URLForResource("phoenix_reader", withExtension: "momd")!
//        return NSManagedObjectModel(contentsOfURL: modelURL)!
//        return NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
        let result = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
        return result
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("phoenix_reader_unit_tests.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            // 2016.03.08 sferwerda - can't use in-memory datastore because it gets re-created for each individual test
//            try coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        do {
            try managedObjectContext.save()
        }
        catch {
            fatalError("cannot save core data in cleanup")
        }
    }
    
    func paveDatastore() {
        let fetchRequest = NSFetchRequest(entityName: "MNIServerConfig")
        fetchRequest.includesPropertyValues = false;
        var fetchedManagedObjects: [NSManagedObject]
        do {
            fetchedManagedObjects = try managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        }
        catch {
            fatalError("fetch of server configs failed")
        }
        
        for aManagedObject in fetchedManagedObjects {
            managedObjectContext.deleteObject(aManagedObject)
        }
        fetchedManagedObjects.removeAll(keepCapacity: false)
        
        do {
            try managedObjectContext.save()
        }
        catch {
            fatalError("Failed to save cleaned context to Core Data")
        }
    }
    
    // clear the datastore so we can run the rest of the tests
    func test005PaveDatastore() {
        self.paveDatastore()
    }
    
    func test010Create() {
        
        // load up the test JSON
        let bundle = NSBundle(forClass: self.dynamicType)
        guard let filepath = bundle.pathForResource("testing-server-config", ofType:"json")
            else {
                fatalError("Cannot find sample data in bundle")
        }
        
        guard let contentOfSampleFile = NSData(contentsOfFile: filepath)
            else {
                fatalError("Cannot read sample data file from bundle")
        }
   
        let jsonDict: [String : AnyObject]?
        // construct dictionary from sample JSON data
        do {
            jsonDict = try NSJSONSerialization.JSONObjectWithData(contentOfSampleFile, options: NSJSONReadingOptions.MutableContainers) as? [String : AnyObject]
        }
        catch {
            fatalError("Cannot parse sample JSON data into dictionary")
        }
        
        guard let serverConfigDict = jsonDict
            else {
                fatalError("Sample JSON data is empty")
        }
        
        // create entity
        guard let entity = NSEntityDescription.insertNewObjectForEntityForName("MNIServerConfig", inManagedObjectContext: managedObjectContext) as? MNIServerConfig
            else {
                fatalError("Invalid Core Data model.")
        }
        
        // populate entity data
        entity.version = 1
        entity.lastUpdated = NSDate()
        entity.setMniServerConfigModelFromDictionary(serverConfigDict)
 
        do {
            try managedObjectContext.save()
        }
        catch {
            fatalError("Failed to save object to Core Data")
        }
        
    }
    
    func test020Read() {
        
        // check the object is still there
        let fetchRequest = NSFetchRequest(entityName: "MNIServerConfig")
        let fetchedServerConfigs: [MNIServerConfig]
        do {
            fetchedServerConfigs = try managedObjectContext.executeFetchRequest(fetchRequest) as! [MNIServerConfig]
        }
        catch {
            fatalError("fetch of server configs failed")
        }
        
        XCTAssert(fetchedServerConfigs.count > 0, "unexpectedly retrieved no results on read")
        for aServerConfig in fetchedServerConfigs {
            guard let aConfigModel = aServerConfig.mniServerConfigModel
                else {
                    fatalError("cannot get a config model from the retrieved rawobject")
            }
            if aConfigModel.app_store_id != "485784497" {
                fatalError("app store id property doesn't match expected value")
            }
        }
        
    }
    
    func test030Update() {
        
        // get the object
        let fetchRequest = NSFetchRequest(entityName: "MNIServerConfig")
        let fetchedServerConfigs: [MNIServerConfig]
        do {
            fetchedServerConfigs = try managedObjectContext.executeFetchRequest(fetchRequest) as! [MNIServerConfig]
        }
        catch {
            fatalError("fetch of server configs failed")
        }
        
        XCTAssert(fetchedServerConfigs.count == 1, "unexpectedly failed to retrieve exactly one result on read")
        guard let aServerConfig = fetchedServerConfigs.first
            else {
                fatalError("no results fetched")
        }
        
        // verify we can construct a Mantle-based config model from the persisted data
        guard let _ = aServerConfig.mniServerConfigModel
            else {
                fatalError("first fetched result doesn't have a config model")
        }
        
        // modify the persisted data and update:
        // note that transformable attributes must be copied, the copy modified, and the result reassigned in order for Core Data to detect that they've changed.
        guard var newConfigModelDict = aServerConfig.serverConfigModelDict!.copy() as? [String: AnyObject]
            else {
                fatalError("first fetched result doesn't have a config model")
        }
        newConfigModelDict["app_store_id"] = "MODIFIED"
        aServerConfig.serverConfigModelDict = newConfigModelDict
        aServerConfig.lastUpdated = NSDate()
        
        do {
            try managedObjectContext.save()
        }
        catch {
            fatalError("Failed to save object to Core Data")
        }
        
    }
    
    func test040ReadUpdated() {
        
        // check the modified object is there
        let fetchRequest = NSFetchRequest(entityName: "MNIServerConfig")
        let fetchedServerConfigs: [MNIServerConfig]
        do {
            fetchedServerConfigs = try managedObjectContext.executeFetchRequest(fetchRequest) as! [MNIServerConfig]
        }
        catch {
            fatalError("fetch of server configs failed")
        }
        
        XCTAssert(fetchedServerConfigs.count == 1, "unexpectedly failed to retrieve exactly one result on read")
        guard let aServerConfig = fetchedServerConfigs.first
            else {
                fatalError("no results fetched")
        }
        
        guard let aConfigModel = aServerConfig.mniServerConfigModel
            else {
                fatalError("cannot get a config model from the retrieved rawobject")
        }
        if aConfigModel.app_store_id != "MODIFIED" {
            fatalError("app store id property doesn't match expected value")
        }
        
    }
    
    func test050Lookup() {
        
        // check the modified object is there
        let fetchRequest = NSFetchRequest(entityName: "MNIServerConfig")
        let fetchedServerConfigs: [MNIServerConfig]
        do {
            fetchedServerConfigs = try managedObjectContext.executeFetchRequest(fetchRequest) as! [MNIServerConfig]
        }
        catch {
            fatalError("fetch of server configs failed")
        }
        
        XCTAssert(fetchedServerConfigs.count == 1, "unexpectedly failed to retrieve exactly one result on read")
        guard let aServerConfig = fetchedServerConfigs.first
            else {
                fatalError("no results fetched")
        }
        
        guard let aConfigModel = aServerConfig.mniServerConfigModel
            else {
                fatalError("cannot get a config model from the retrieved rawobject")
        }
        
        let aSectionModel = aConfigModel.sectionModelWithID("3402");
        XCTAssertNotNil(aSectionModel, "failed to find section model by id")

        let aSectionModel2 = aConfigModel.sectionModelWithID("NotThere");
        XCTAssertNil(aSectionModel2, "erroneously returned a section for a bad ID")

    }
    
    func test100PaveDatastore() {
        self.paveDatastore()
    }

    func test110CreateWithNullAdsProperty() {
        
        // load up the test JSON
        let bundle = NSBundle(forClass: self.dynamicType)
        guard let filepath = bundle.pathForResource("testing-server-config", ofType:"json")
            else {
                fatalError("Cannot find sample data in bundle")
        }
        
        guard let contentOfSampleFile = NSData(contentsOfFile: filepath)
            else {
                fatalError("Cannot read sample data file from bundle")
        }
        
        let jsonDict: [String : AnyObject]?
        // construct dictionary from sample JSON data
        do {
            jsonDict = try NSJSONSerialization.JSONObjectWithData(contentOfSampleFile, options: NSJSONReadingOptions.MutableContainers) as? [String : AnyObject]
        }
        catch {
            fatalError("Cannot parse sample JSON data into dictionary")
        }
        
        guard var serverConfigDict = jsonDict
            else {
                fatalError("Sample JSON data is empty")
        }
        
        // break the json by inserting a null for ads
        serverConfigDict["ads"] = nil;
        
        // create entity
        guard let entity = NSEntityDescription.insertNewObjectForEntityForName("MNIServerConfig", inManagedObjectContext: managedObjectContext) as? MNIServerConfig
            else {
                fatalError("Invalid Core Data model.")
        }
        
        // populate entity data
        entity.version = 1
        entity.lastUpdated = NSDate()
        entity.setMniServerConfigModelFromDictionary(serverConfigDict)
        
        do {
            try managedObjectContext.save()
        }
        catch {
            fatalError("Failed to save object to Core Data")
        }
        
    }
    
    func test120ReadWithNullAdsProperty() {
        
        // check the modified object is there
        let fetchRequest = NSFetchRequest(entityName: "MNIServerConfig")
        let fetchedServerConfigs: [MNIServerConfig]
        do {
            fetchedServerConfigs = try managedObjectContext.executeFetchRequest(fetchRequest) as! [MNIServerConfig]
        }
        catch {
            fatalError("fetch of server configs failed")
        }
        
        XCTAssert(fetchedServerConfigs.count == 1, "unexpectedly failed to retrieve exactly one result on read")
        guard let aServerConfig = fetchedServerConfigs.first
            else {
                fatalError("no results fetched")
        }
        
        guard let aConfigModel = aServerConfig.mniServerConfigModel
            else {
                fatalError("cannot get a config model from the retrieved rawobject")
        }
        
        let adsConfigModel = aConfigModel.ads as MNIConfigAdsModel?
        XCTAssertNil(adsConfigModel, "ads config model unexpectedly is not nil")
        
    }
    
}
