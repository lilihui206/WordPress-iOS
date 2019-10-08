import Foundation

enum PostAutoUploadMessages {
    static let postWillBePublished = NSLocalizedString("Post will be published next time your device is online",
                                                       comment: "Text displayed in notice after a post if published while offline.")
    static let draftWillBeUploaded = NSLocalizedString("Draft will be uploaded next time your device is online",
                                                       comment: "Text displayed in notice after the app fails to upload a draft.")
    static let pageFailedToUpload = NSLocalizedString("Page failed to upload",
                                                      comment: "Title of notification displayed when a page has failed to upload.")
    static let postFailedToUpload = NSLocalizedString("Post failed to upload",
                                                      comment: "Title of notification displayed when a post has failed to upload.")
    static let changesWillBeUploaded = NSLocalizedString("Changes will be uploaded next time your device is online",
                                                         comment: "Text displayed in notice after the app fails to upload a post.")
    static let willAttemptToPublishLater = NSLocalizedString("Post couldn't be published. We'll try again later",
                                                       comment: "Text displayed in notice after the app fails to upload a post, it will attempt to upload it later.")
    static let willNotAttemptToPublishLater = NSLocalizedString("Couldn't perform operation. Post not published",
                                                        comment: "Text displayed in notice after the app fails to upload a post, not new attempt will be made.")
    static let willSubmitLater = NSLocalizedString("Post will be submitted for review when your device is back online",
                                                        comment: "Text displayed in notice after the app fails to upload a post, it will attempt to upload it later.")
    static let willAttemptToSubmitLater = NSLocalizedString("Post couldn't be submitted. We'll try again later",
                                                       comment: "Text displayed in notice after the app fails to upload a post, it will attempt to upload it later.")
    static let willNotAttemptToSubmitLater = NSLocalizedString("Couldn't perform operation. Post not submitted",
                                                        comment: "Text displayed in notice after the app fails to upload a post, not new attempt will be made.")
    static let privateWillBeUploaded = NSLocalizedString("Private post will be published when your device is back online",
                                                       comment: "Text displayed in notice after the app fails to upload a draft.")
    static let willAttemptToPublishPrivateLater = NSLocalizedString("Private post couldn't be published. We'll try again later",
                                                        comment: "Text displayed after the app fails to upload a private post, it will attempt to upload it later.")
    static let willNotAttemptToPublishPrivateLater = NSLocalizedString("Couldn't perform operation. Private post not published",
                                                        comment: "Text displayed after the app fails to upload a private post, no new attempt will be made.")
    static let scheduledWillBeUploaded = NSLocalizedString("Post will be scheduled when your device is back online",
                                                       comment: "Text displayed after the app fails to upload a scheduled post.")
    static let willAttemptToScheduleLater = NSLocalizedString("Post couldn't be scheduled. We'll try again later",
                                                        comment: "Text displayed after the app fails to upload a scheduled post, it will attempt to upload it later.")
    static let willNotAttemptToScheduleLater = NSLocalizedString("Couldn't perform operation. Post not scheduled",
                                                        comment: "Text displayed after the app fails to upload a scheduled post, no new attempt will be made.")
    static let changesWillNotBePublished = NSLocalizedString("Changes will not be published",
                                                        comment: "Title for notice displayed on canceling auto-upload published post")
    static let changesWillNotBeSubmitted = NSLocalizedString("Changes will not be submitted",
                                                         comment: "Title for notice displayed on canceling auto-upload pending post")
    static let changesWillNotBeScheduled = NSLocalizedString("Changes will not be scheduled",
                                                         comment: "Title for notice displayed on canceling auto-upload of a scheduled post")
    static let changesWillNotBeSaved = NSLocalizedString("We won't save the latest changes to your draft.",
                                                         comment: "Title for notice displayed on canceling auto-upload of a draft post")
    static let failedMedia = NSLocalizedString("Couldn't upload media.",
                                                         comment: "Text displayed if a media couldnt be uploaded.")
    static let failedMediaForPublish = NSLocalizedString("Couldn't upload media. Post not published",
                                                         comment: "Text displayed if a media couldn't be uploaded for a published post.")
    static let failedMediaForPrivate = NSLocalizedString("Couldn't upload media. Private post not published",
                                                         comment: "Text displayed if a media couldn't be uploaded for a private post.")
    static let failedMediaForScheduled = NSLocalizedString("Couldn't upload media. Post not scheduled",
                                                         comment: "Text displayed if a media couldn't be uploaded for a scheduled post.")
    static let failedMediaForPending = NSLocalizedString("Couldn't upload media. Post not submitted",
                                                         comment: "Text displayed if a media couldn't be uploaded for a pending post.")

    static func cancelMessage(for postStatus: BasePost.Status?) -> String {
        switch postStatus {
        case .publish:
            return PostAutoUploadMessages.changesWillNotBePublished
        case .publishPrivate:
            return PostAutoUploadMessages.changesWillNotBePublished
        case .scheduled:
            return PostAutoUploadMessages.changesWillNotBeScheduled
        case .draft:
            return PostAutoUploadMessages.changesWillNotBeSaved
        default:
            return PostAutoUploadMessages.changesWillNotBeSubmitted
        }
    }

    static func attemptFailures(for post: AbstractPost,
                                withState state: PostAutoUploadInteractor.AutoUploadAttemptState) -> String? {
        switch state {
        case .attempted:
            return PostAutoUploadMessages.willAttemptToAutoUpload(for: post.status)
        case .reachedLimit:
            return post.hasFailedMedia ? PostAutoUploadMessages.failedMedia(for: post.status) : PostAutoUploadMessages.willNotAttemptToAutoUpload(for: post.status)
        default:
            return nil
        }
    }

    static func failedMedia(for postStatus: BasePost.Status?) -> String {
        switch postStatus {
        case .publish:
            return PostAutoUploadMessages.failedMediaForPublish
        case .publishPrivate:
            return PostAutoUploadMessages.failedMediaForPrivate
        case .scheduled:
            return PostAutoUploadMessages.failedMediaForScheduled
        case .pending:
            return PostAutoUploadMessages.failedMediaForPending
        default:
            return PostAutoUploadMessages.failedMedia
        }
    }

    private static func willAttemptToAutoUpload(for postStatus: BasePost.Status?) -> String {
        switch postStatus {
        case .publish:
            return PostAutoUploadMessages.willAttemptToPublishLater
        case .publishPrivate:
            return PostAutoUploadMessages.willAttemptToPublishPrivateLater
        case .scheduled:
            return PostAutoUploadMessages.willAttemptToScheduleLater
        default:
            return PostAutoUploadMessages.willAttemptToSubmitLater
        }
    }

    private static func willNotAttemptToAutoUpload(for postStatus: BasePost.Status?) -> String {
        switch postStatus {
        case .publish:
            return PostAutoUploadMessages.willNotAttemptToPublishLater
        case .publishPrivate:
            return PostAutoUploadMessages.willNotAttemptToPublishPrivateLater
        case .scheduled:
            return PostAutoUploadMessages.willNotAttemptToScheduleLater
        default:
            return PostAutoUploadMessages.willNotAttemptToSubmitLater
        }
    }
}
