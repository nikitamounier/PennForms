public struct AlwaysValidator: Validator {
    public func isValid(_ input: Any) -> Bool {
        true
    }
    
    public let message: String? = nil
}
