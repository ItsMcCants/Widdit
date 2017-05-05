
open class ALEmailValidator {
    fileprivate static var disposableMailList : [String] = ALEmailValidator.buildDisposableList()
    
    fileprivate class func domainComponentsAddressFor(email:String) -> [String] {
        let components = email.lowercased().components(separatedBy: "@")
        if components.count > 1 {
            return components[1].components(separatedBy: ".").slicedJoinedArray()
        }
        
        return []
    }
    
    fileprivate class func isValid(email:String) -> Bool {
        let mailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$"
        let mailPredicate = NSPredicate.init(format: "SELF MATCHES %@",mailRegex)
        let result = mailPredicate.evaluate(with: email)
        return result
    }
    
    fileprivate class func buildDisposableList() -> [String] {
        
        let podBundle = Bundle(for: ALEmailValidator.self)
        
        let bundleURL = podBundle.url(forResource: "NSStringALEmail", withExtension: "bundle")
        let bundle = Bundle.init(url: bundleURL!)!
        
        if let path = bundle.path(forResource: "json-disposable-emails", ofType: "txt"){
            let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: path))
            do {
                let jsonResult = (try JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String])!
                return jsonResult
            } catch {
                print("error: \(error)")
            }
            
        }
        return []
    }
    
    open class func blacklist() -> [String] {
        return ALEmailValidator.buildDisposableList()
    }
    
    fileprivate class func checkDomains(_ domains:[String], withBlackList list:[String]) -> Bool {
        for item in domains {
            for blackListedItem in list {
                if item == blackListedItem.lowercased() {
                    return true
                }
            }
        }
        return false
    }
    
    fileprivate class func isDisposable(email:String) -> Bool {
        let domains = ALEmailValidator.domainComponentsAddressFor(email: email)
        return checkDomains(domains, withBlackList: disposableMailList)
    }
}

extension Array where Element : ExpressibleByStringLiteral  {
    func joinedComponentsArray() -> String {
        var accumulator = ""
        if self.count > 0 {
            accumulator = String(describing: self[0])
        
            if (self.count > 1) {
                for index in 1...self.count-1 {
                    accumulator = accumulator + "." + String(describing: self[index])
                }
            }
        }
        
        
        return accumulator
    }
    
    func slicedJoinedArray() -> [String] {
        var result:[String] = Array<String>()
        for (index, _) in self.reversed().enumerated() {
            let sub = self.subArrayFrom(index: index)
            result.append(sub.joinedComponentsArray())
        }
        
        return result
    }
}

extension Array  {
    func subArrayFrom(index:Int) -> Array {
        return Array(self[index..<self.count])
    }
}

public extension String {
    func isValidEmail() -> Bool {
        return ALEmailValidator.isValid(email: self)
    }
    
    func isDisposableEmail() -> Bool {
        return ALEmailValidator.isDisposable(email: self)
    }
}

public extension NSString {
    func isValidEmail() -> Bool {
        return ALEmailValidator.isValid(email: (self as String))
    }
    
    func isDisposableEmail() -> Bool {
        return ALEmailValidator.isDisposable(email: (self as String))
    }
}
