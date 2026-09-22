//
//  ApiServices.swift
//  MSA
//
//  Created by Mohab Mowafy on 22/07/2026.
//

import Foundation
import Foundation
import Foundation
import UIKit
import Alamofire
//import MaterialComponents.MaterialSnackbar

var Country_Code = ""

class ApiServices : NSObject {
    var lang : String = "ar"
    private static var instance : ApiServices? = nil
    
    private override init() { }
   
    
    static func GetInstance()->ApiServices{
        if instance == nil {
            instance = ApiServices()
        }
        return instance!
    }
    
    func checkConnection() -> Bool {
        let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
        return (reachabilityManager?.isReachable)!
    }
    
    
    func moveToOffilne(VC: UIViewController) {
       // logInfo(message: "3 >> \(VC.classForCoder)")
        let controller = OfflineVC()
        controller.modalPresentationStyle = .fullScreen
        controller.oldVC = VC
        VC.present(controller, animated: true, completion: nil)
    }
    
    func getPosts<T: Decodable>(
        methodType: HTTPMethod = .post,
        parameters: [String: Any]? = nil,
        url: String,
        lang: String = L102Language.currentAppleLanguage(),
        Completion: @escaping (T?, String?) -> Void
    ) {
        var headers: HTTPHeaders = [
            "Accept-Language": lang,
            "Content-Type": "application/json",
            "Accept": "application/json",
            "user-type": "\(tail_link)"
        ]
        
//        if let token = AuthService.userData?.token, !token.isEmpty {
//            headers.add(name: "Authorization", value: "Bearer \(token)")
//        }
//        
        guard let encodedLink = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
              let encodedURL = URL(string: encodedLink) else {
            Completion(nil, "Invalid URL")
            return
        }
        
       // print("url: -> \(url) Token: -> \(AuthService.userData?.token ?? "") Header: -> \(headers) Param :-> \(parameters ?? [:])")

        AF.request(
            encodedURL,
            method: methodType,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
     //   .validate()
        .responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    print(dict ?? [:])
                    
                    let status = dict?["status"]
                    let isSuccess = (status as? Bool == true) || (status as? Int == 1) || (status as? String == "success")
                    
                    if isSuccess {
                        let decoded = try JSONDecoder().decode(T.self, from: data)
                        Completion(decoded, nil)
                    } else {
                        let code = response.response?.statusCode
                        if code == 401 || code == 503 || code == 426 {
                            let decoded = try JSONDecoder().decode(T.self, from: data)
                            Completion(decoded, "\(code ?? 0)")
                        } else {
                            if let errorMsg = dict?["message"] as? String {
                                Completion(nil, errorMsg)
                            } else if let errorDict = dict?["message"] as? [String: Any],
                                      let errorArr = errorDict.values.first as? [String],
                                      let firstError = errorArr.first {
                                Completion(nil, firstError)
                            } else {
                                Completion(nil, "Unknown error")
                            }
                        }
                    }
                } catch {
                    print("Decoding error: \(error)")
                    Completion(nil, "\(error)")
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                let statusCode = response.response?.statusCode
                if let code = statusCode {
                    Completion(nil, "\(code)")
                } else {
                    Completion(nil, error.localizedDescription)
                }
            }
        }
    }

    func uploadImage<T: Decodable>(
        methodType: HTTPMethod,
        parameters: [String: AnyObject],
        url: String,
        imagesArray: [UIImage]? = nil,
        additional_images: [UIImage]? = nil,
        main_image: UIImage? = nil,
        profile_image: UIImage? = nil,
        chat_image: UIImage? = nil,
        Logo_image: UIImage? = nil,
        file: Upload_file? = nil,
        Completion: @escaping (T?, String?) -> Void
    ) {
        let lang: String = {
            switch L102Language.currentAppleLanguage() {
            case arabicLang: return "ar"
            case englishLang: return "en"
            default: return "ur"
            }
        }()
        
        var headers: HTTPHeaders = [
            "Accept": "application/json",
            "Accept-Language": lang,
            "country_id": Helper.getisCountry() ?? "1",
            "App-Version": "v\(currentVersion)",
            "App-Platform": "ios"
        ]
        
//        if let token = AuthService.userData?.token, !token.isEmpty {
//            headers.add(name: "Authorization", value: "Bearer \(token)")
//        }

        AF.upload(
            multipartFormData: { multipartFormData in
                func appendImage(_ image: UIImage?, withName name: String) {
                    if let data = image?.jpegData(compressionQuality: 0.3) {
                        multipartFormData.append(data, withName: name, fileName: "\(name).jpg", mimeType: "image/jpeg")
                    }
                }

                appendImage(main_image, withName: "main_image")
                appendImage(chat_image, withName: "message")
                appendImage(profile_image, withName: "profile_image")
                appendImage(Logo_image, withName: "logo")
                
                if let images = imagesArray {
                    for (index, image) in images.enumerated() {
                        if let data = image.jpegData(compressionQuality: 0.3) {
                            multipartFormData.append(data, withName: "images[]", fileName: "image\(index).jpg", mimeType: "image/jpeg")
                        }
                    }
                }
                
                if let images = additional_images {
                    for (index, image) in images.enumerated() {
                        if let data = image.jpegData(compressionQuality: 0.3) {
                            multipartFormData.append(data, withName: "additional_images[]", fileName: "image\(index).jpg", mimeType: "image/jpeg")
                        }
                    }
                }
                
                if let file = file {
                    multipartFormData.append(file.file_data, withName: "video", fileName: "file.\(file.ext)", mimeType: file.mimeType)
                }

                for (key, value) in parameters {
                    if let stringValue = value as? String,
                       let data = stringValue.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            },
            to: url,
            method: methodType,
            headers: headers
        )
       // .validate(statusCode: 200..<500)
        .responseData { response in
            
            print(response.result)
            switch response.result {
            case .success(let data):
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    print(json)
                    let status = json?["status"]
                    let isSuccess = (status as? Bool == true) || (status as? Int == 1) || (status as? String == "success")
                    
                    if !isSuccess {
                        let errorMsg = json?["message"] as? String
                        let code = json?["code"] as? String
                        Completion(nil, code ?? errorMsg ?? "Unknown Error")
                        return
                    }

                    let result = try JSONDecoder().decode(T.self, from: data)
                    Completion(result, nil)
                } catch {
                    Completion(nil, error.localizedDescription)
                }

            case .failure(let error):
                Completion(nil, error.localizedDescription)
            }
        }
    }

    
}



struct Upload_file {
    var ext : String
    var file_data : Data
    var mimeType : String
}
