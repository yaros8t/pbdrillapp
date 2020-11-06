import Foundation

class Parser<T: Codable> {
    
    static func parse(_ dictionary: [String: Any], _ completion: (T) -> Void) {
        do {
            completion(try JSONDecoder().decode(T.self, from: JSONSerialization.data(withJSONObject: dictionary)))
        } catch {
            print(error.localizedDescription)
        }
    }
}
