//
//  FileStorage.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 02/01/2023.
//

import Foundation
import UIKit
import ProgressHUD
import FirebaseStorage

let storage = Storage.storage()

class FileStorage {
    // MARK: - Uploud Images.
    
    class func uploudImage(_ image:UIImage , directory:String , completion :@escaping(_ documentLink:String?)->Void){
        // MARK: 1- create folder on firebase.
        let storageRef = storage.reference(forURL: KURL).child(directory)
        
        // MARK: 2- convert the image to data.
        let imageData = image.jpegData(compressionQuality: 0.5)
        // MARK: - Put the data into firestore and return link .
        var task : StorageUploadTask!
        task = storageRef.putData(imageData!,metadata: nil, completion: { (metaData, error) in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            if error != nil {
                print("error uplouding image \(error!.localizedDescription)")
                return
            }
            storageRef.downloadURL { url, error in
                guard let downloadUrl = url else{
                    completion (nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            }
            
            
        })
        // MARK: - Observe persantage uploud.
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }

   
    class func downloadImage (imgUrl:String , compelition:@escaping(_ image :UIImage? )->Void){
    //    print (fileNameFrom(fileUrl: imgUrl))
        let imageFileName = fileNameFrom(fileUrl: imgUrl)
        if fileExistsPath(path: imageFileName){
            // MARK: - get image locally.
            if let contentOfFile = UIImage(contentsOfFile: fileInDocumentDirectory(fileName: imageFileName)){
                compelition(contentOfFile)
            }else{
                print("could not convert local image")
                compelition(UIImage(named: "Ellipse 3")!)
            }

        }else{
            // MARK: - download image from firestore.
            if imgUrl != ""{
                let documentUrl = URL(string: imgUrl)
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    if data != nil{
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        DispatchQueue.main.async {
                            compelition(UIImage(data: data! as Data))
                        }
                    }else{
                        print("no document found in datastore")
                        compelition (nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Uploud Video.
    
    class func uploudVideo(_ video:NSData , directory:String , completion :@escaping(_ videoLink:String?)->Void){
        // MARK: 1- create folder on firebase.
        let storageRef = storage.reference(forURL: KURL).child(directory)
        
        // MARK: - Put the data into firestore and return link .
        var task : StorageUploadTask!
        task = storageRef.putData(video as Data,metadata: nil, completion: { (metaData, error) in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            if error != nil {
                print("error uplouding image \(error!.localizedDescription)")
                return
            }
            storageRef.downloadURL { url, error in
                guard let downloadUrl = url else{
                    completion (nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            }
            
            
        })
        // MARK: - Observe persantage uploud.
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    class func downloadVideo(videoUrl:String,complation:@escaping(_ isReadyToPlay:Bool,_ videoFileName:String)->Void){
        
        let videoFileName = fileNameFrom(fileUrl: videoUrl) + ".mov"
        
        if fileExistsPath(path: videoFileName){
                complation(true,videoFileName)
        
        }
        else{
            if videoUrl != ""{
                let docomentUrl = URL(string: videoUrl)
                let downloadQueue = DispatchQueue(label: "videoDownloadQueue")
                
                downloadQueue.async {
                    let data = NSData(contentsOf: docomentUrl!)
                    if data != nil{
                        FileStorage.saveFileLocally(fileData: data!, fileName: videoFileName)
                        DispatchQueue.main.async {
                            complation(true,videoFileName)
                            print(videoUrl)
                        }
                    }else{
                        print("no document found in database")
                        
                    }
                }
            }
        }
    }
    // MARK: - uploud audio.
    class func uploudAudio(_ audioFileName:String , directory:String , completion :@escaping(_ audioLink:String?)->Void){
        // MARK: 1- create folder on firebase.
        let fileName = audioFileName + ".m4a"
        
        let storageRef = storage.reference(forURL: KURL).child(directory)
        
        // MARK: - Put the data into firestore and return link .
        var task : StorageUploadTask!
        if fileExistsPath(path: fileName){
            if let audioData = NSData(contentsOfFile: fileInDocumentDirectory(fileName: fileName)) {
                
                task = storageRef.putData(audioData as Data,metadata: nil, completion: { (metaData, error) in
                    task.removeAllObservers()
                    ProgressHUD.dismiss()
                    if error != nil {
                        print("error uplouding audio \(error!.localizedDescription)")
                        return
                    }
                    storageRef.downloadURL { url, error in
                        guard let downloadUrl = url else{
                            completion (nil)
                            return
                        }
                        completion(downloadUrl.absoluteString)
                    }
                    
                    
                })
                // MARK: - Observe persantage uploud.
                task.observe(StorageTaskStatus.progress) { (snapshot) in
                    let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
                    ProgressHUD.showProgress(CGFloat(progress))
                }
            }
        }
        else{
            print("No thing to Upload")
        }
    }
    
    // MARK: - dowmload Audio.
    
    class func downloadAudio(audioUrl:String,complation:@escaping(_ audioFileName:String)->Void){
        
        let audioFileName = fileNameFrom(fileUrl: audioUrl) + ".m4a"
        
        if fileExistsPath(path: audioFileName){
                complation(audioFileName)
        
        }
        else{
            if audioUrl != ""{
                let docomentUrl = URL(string: audioUrl)
                let downloadQueue = DispatchQueue(label: "audioDownloadQueue")
                
                downloadQueue.async {
                    let data = NSData(contentsOf: docomentUrl!)
                    if data != nil{
                        FileStorage.saveFileLocally(fileData: data!, fileName: audioFileName)
                        DispatchQueue.main.async {
                            complation(audioFileName)
                        //    print(audioUrl)
                        }
                    }else{
                        print("no document found in database")
                        
                    }
                }
            }
        }
    }


    
    //MARK: - save file Localy
    
    class func saveFileLocally(fileData:NSData,fileName:String){
        let docUrl = getDocumentUrl().appendingPathComponent(fileName,isDirectory: false)
        fileData.write(to: docUrl, atomically: true)
    }
    
    }


// helper function

func getDocumentUrl()->URL{
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileInDocumentDirectory(fileName:String)->String{
    return getDocumentUrl().appendingPathComponent(fileName).path
}


func fileExistsPath(path:String)->Bool{
    return FileManager.default.fileExists(atPath: fileInDocumentDirectory(fileName: path))
}
