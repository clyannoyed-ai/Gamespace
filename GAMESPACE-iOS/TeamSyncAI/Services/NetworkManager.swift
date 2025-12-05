import Foundation

class NetworkManager {
    private let baseURL: String
    private let session = URLSession.shared
    
    init() {
        #if DEBUG
        self.baseURL = "https://your-dev-backend.com/api/v1"
        #else
        self.baseURL = "https://teamsyncai.abacusai.app/api/v1"
        #endif
    }
    
    func get<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addAuthToken(to: &request)
        
        session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func post<T: Decodable>(endpoint: String, body: [String: Any], completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthToken(to: &request)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func addAuthToken(to request: inout URLRequest) {
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}
