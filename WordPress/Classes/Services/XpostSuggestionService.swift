import Foundation

/// A service to fetch and persist a list of sites that can be used for x-posting.
struct XpostSuggestionService {

    enum ServiceError: Error {
        case missingAPI
        case missingManagedObjectContext
        case hostnameNotAvailable
        case noResultsAvailable
    }

    static var requestDates = [Blog: Date]()

    /**
    Fetch cached suggestions if available, otherwise from the network if the device is online.

    @param the blog/site to retrieve suggestions for
    @param completion callback containing list of suggestions, or nil if unavailable
    */
    static func suggestions(for blog: Blog, completion: ((Result<[SiteSuggestion], Error>) -> Void)?) {

        if wereSuggestionsFetchedRecently(for: blog), let results = retrieveSortedPersistedResults(for: blog), results.isEmpty == false {
            completion?(.success(results))
        } else if ReachabilityUtils.isInternetReachable() {
            requestDates[blog] = Date()
            fetchAndPersistSuggestions(for: blog, completion: completion)
        } else {
            completion?(.failure(ServiceError.noResultsAvailable))
        }
    }

    private static func wereSuggestionsFetchedRecently(for blog: Blog) -> Bool {
        let throttleDuration: TimeInterval = 60 // seconds
        if let requestDate = requestDates[blog], requestDate.timeIntervalSince(Date()) < throttleDuration {
            return true
        }
        return false
    }

    private static func fetchAndPersistSuggestions(for blog: Blog, completion: ((Result<[SiteSuggestion], Error>) -> Void)?) {

        guard let api = blog.wordPressComRestApi() else {
            completion?(.failure(ServiceError.missingAPI))
            return
        }

        guard let managedObjectContext = blog.managedObjectContext else {
            completion?(.failure(ServiceError.missingManagedObjectContext))
            return
        }

        guard let hostname = blog.hostname else {
            completion?(.failure(ServiceError.hostnameNotAvailable))
            return
        }

        let urlString = "/wpcom/v2/sites/\(hostname)/xposts"

        api.GET(urlString, parameters: [
            "decode_html": true,
        ] as [String: AnyObject]) { responseObject, httpResponse in
            do {
                let data = try JSONSerialization.data(withJSONObject: responseObject)
                try self.purgeExistingResults(for: blog, using: managedObjectContext)
                try self.persist(data: data, to: blog, using: managedObjectContext)
                guard let suggestions = self.retrieveSortedPersistedResults(for: blog) else {
                    completion?(.failure(ServiceError.noResultsAvailable))
                    return
                }
                completion?(.success(suggestions))
            } catch {
                completion?(.failure(error))
            }
        } failure: { error, _ in
            completion?(.failure(error))
        }
    }

    private static func purgeExistingResults(for blog: Blog, using managedObjectContext: NSManagedObjectContext) throws {
        blog.siteSuggestions?.forEach { siteSuggestion in
            managedObjectContext.delete(siteSuggestion)
        }
        try managedObjectContext.save()
    }

    private static func persist(data: Data, to blog: Blog, using managedObjectContext: NSManagedObjectContext) throws {
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.managedObjectContext] = managedObjectContext
        let siteSuggestions = try decoder.decode([SiteSuggestion].self, from: data)
        blog.siteSuggestions = Set(siteSuggestions)
        try managedObjectContext.save()
    }

    static func retrieveSortedPersistedResults(for blog: Blog) -> [SiteSuggestion]? {
        return blog.siteSuggestions?.sorted(by: { suggestionA, suggestionB in
            guard let subdomainA = suggestionA.subdomain else { return false }
            guard let subdomainB = suggestionB.subdomain else { return false }
            return subdomainA < subdomainB
        })
    }
}

extension XpostSuggestionService.ServiceError: CustomNSError {
    static var errorDomain: String { return "XpostSuggestionService.ServiceError" }

    var errorCode: Int { return 0 }

    var errorUserInfo: [String: Any] {
        switch self {
        case .missingAPI: return [NSDebugDescriptionErrorKey: "Blog hostname not available"]
        case .missingManagedObjectContext: return [NSDebugDescriptionErrorKey: "Managed object context not available"]
        case .hostnameNotAvailable: return [NSDebugDescriptionErrorKey: "Blog hostname not available"]
        case .noResultsAvailable: return [NSDebugDescriptionErrorKey: "The device is offline and there are no suggestions in the cache"]
        }
    }
}
