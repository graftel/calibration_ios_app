import Foundation

/// The `RetrieveSpamReports` class represents the API call to [retrieve the
/// spam reports list](https://sendgrid.com/docs/API_Reference/Web_API_v3/spam_reports.html#List-all-spam-reports-GET).
/// You can use it to retrieve the entire list, or specific entries on the
/// list.
///
/// ## Get All Spam Reports
///
/// To retrieve the list of all spam reports, use the `RetrieveSpamReports` class
/// with the `init(start:end:page:)` initializer. The library will
/// automatically map the response to the `SpamReport` struct model,
/// accessible via the `model` property on the response instance you get
/// back.
///
/// ```swift
/// do {
///     // If you don't specify any parameters, then the first page of your
///     // entire spam report list will be fetched:
///     let request = RetrieveSpamReports()
///     try Session.shared.send(modeledRequest: request) { result in
///         switch result {
///         case .success(let response, let model):
///             // The `model` property will be an array of `SpamReport` structs.
///             model.forEach { print($0.email) }
///
///             // The response object has a `Pagination` instance on it as well.
///             // You can use this to get the next page, if you wish.
///             if let nextPage = response.pages?.next {
///                 let nextRequest = RetrieveSpamReports(page: nextPage)
///             }
///         case .failure(let err):
///             print(err)
///         }
///     }
/// } catch {
///     print(error)
/// }
/// ```
///
/// You can also specify any or all of the init parameters to filter your
/// search down:
///
/// ```swift
/// do {
///     // Retrieve page 2
///     let page = Page(limit: 500, offset: 500)
///     // Spam Reports starting from yesterday
///     let now = Date()
///     let start = now.addingTimeInterval(-86400) // 24 hours
///
///     let request = RetrieveSpamReports(start: start, end: now, page: page)
///     try Session.shared.send(modeledRequest: request) { result in
///         switch result {
///         case .success(_, let model):
///             // The `model` property will be an array of `SpamReport`
///             // structs.
///             model.forEach { print($0.email) }
///         case .failure(let err):
///             print(err)
///         }
///     }
/// } catch {
///     print(error)
/// }
/// ```
///
/// ## Get Specific Spam Report
///
/// If you're looking for a specific email address in the spam report list,
/// you can use the `init(email:)` initializer on `RetrieveSpamReports`:
///
/// ```swift
/// do {
///     let request = RetrieveSpamReports(email: "foo@example.none")
///     try Session.shared.send(modeledRequest: request) { result in
///         switch result {
///         case .success(_, let model):
///             // The `model` value will be an array of `SpamReport`
///             // structs.
///             model.forEach { print($0.email) }
///         case .failure(let err):
///             print(err)
///         }
///     }
/// } catch {
///     print(error)
/// }
/// ```
public class RetrieveSpamReports: SuppressionListReader<SpamReport> {
    /// :nodoc:
    internal override init(path: String?, email: String?, start: Date?, end: Date?, page: Page?) {
        super.init(
            path: "/v3/suppression/spam_reports",
            email: email,
            start: start,
            end: end,
            page: page
        )
    }
}
