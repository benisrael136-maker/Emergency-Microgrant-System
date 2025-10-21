(define-constant ERR_UNAUTHORIZED u401)
(define-constant ERR_APPLICATION_NOT_FOUND u402)
(define-constant ERR_INSUFFICIENT_FUNDS u403)
(define-constant ERR_INVALID_AMOUNT u404)
(define-constant ERR_ALREADY_APPLIED u405)
(define-constant ERR_APPLICATION_CLOSED u406)
(define-constant ERR_INVALID_STATUS u407)
(define-constant ERR_EMERGENCY_DECLARED u408)
(define-constant ERR_NO_EMERGENCY u409)
(define-constant ERR_FUND_NOT_FOUND u410)

(define-constant APPLICATION_STATUS_PENDING u0)
(define-constant APPLICATION_STATUS_APPROVED u1)
(define-constant APPLICATION_STATUS_REJECTED u2)
(define-constant APPLICATION_STATUS_DISBURSED u3)
(define-constant APPLICATION_STATUS_EXPIRED u4)

(define-constant EMERGENCY_TYPE_NATURAL_DISASTER u0)
(define-constant EMERGENCY_TYPE_MEDICAL u1)
(define-constant EMERGENCY_TYPE_UNEMPLOYMENT u2)
(define-constant EMERGENCY_TYPE_HOUSING u3)
(define-constant EMERGENCY_TYPE_OTHER u4)

(define-constant PRIORITY_CRITICAL u0)
(define-constant PRIORITY_HIGH u1)
(define-constant PRIORITY_MEDIUM u2)
(define-constant PRIORITY_LOW u3)

(define-constant MAX_GRANT_AMOUNT u5000000)
(define-constant MIN_GRANT_AMOUNT u100000)
(define-constant APPLICATION_VALIDITY_PERIOD u4320)
(define-constant EMERGENCY_RESPONSE_PERIOD u144)

(define-data-var application-counter uint u0)
(define-data-var emergency-fund-counter uint u0)
(define-data-var total-fund-balance uint u0)
(define-data-var total-disbursed uint u0)
(define-data-var emergency-declared bool false)
(define-data-var contract-admin principal tx-sender)

(define-map grant-applications uint {
    applicant: principal,
    emergency-type: uint,
    requested-amount: uint,
    priority: uint,
    description: (string-ascii 500),
    location: (string-ascii 100),
    application-date: uint,
    review-date: (optional uint),
    disbursement-date: (optional uint),
    status: uint,
    reviewer: (optional principal),
    disbursed-amount: uint
})

(define-map emergency-funds uint {
    fund-id: uint,
    creator: principal,
    fund-name: (string-ascii 100),
    total-amount: uint,
    available-amount: uint,
    emergency-type: uint,
    creation-date: uint,
    is-active: bool
})

(define-map fund-contributions { fund-id: uint, contributor: principal } {
    total-contributed: uint,
    contribution-count: uint,
    first-contribution-date: uint,
    last-contribution-date: uint
})

(define-map applicant-profiles principal {
    total-applications: uint,
    approved-applications: uint,
    total-received: uint,
    last-application-date: uint,
    emergency-score: uint
})

(define-map reviewers principal {
    approved-by: principal,
    approval-date: uint,
    total-reviews: uint,
    approval-rate: uint,
    is-active: bool
})

(define-map emergency-declarations uint {
    declaration-id: uint,
    declared-by: principal,
    emergency-type: uint,
    description: (string-ascii 300),
    declaration-date: uint,
    end-date: uint,
    is-active: bool
})

(define-public (create-emergency-fund (fund-name (string-ascii 100)) (emergency-type uint) (initial-amount uint))
    (let (
        (fund-id (+ (var-get emergency-fund-counter) u1))
    )
        (asserts! (> initial-amount u0) (err ERR_INVALID_AMOUNT))
        (asserts! (<= emergency-type EMERGENCY_TYPE_OTHER) (err ERR_INVALID_STATUS))
        
        (try! (stx-transfer? initial-amount tx-sender (as-contract tx-sender)))
        
        (map-set emergency-funds fund-id {
            fund-id: fund-id,
            creator: tx-sender,
            fund-name: fund-name,
            total-amount: initial-amount,
            available-amount: initial-amount,
            emergency-type: emergency-type,
            creation-date: burn-block-height,
            is-active: true
        })
        
        (map-set fund-contributions { fund-id: fund-id, contributor: tx-sender } {
            total-contributed: initial-amount,
            contribution-count: u1,
            first-contribution-date: burn-block-height,
            last-contribution-date: burn-block-height
        })
        
        (var-set emergency-fund-counter fund-id)
        (var-set total-fund-balance (+ (var-get total-fund-balance) initial-amount))
        (ok fund-id)
    )
)

(define-public (contribute-to-fund (fund-id uint) (amount uint))
    (let (
        (fund (unwrap! (map-get? emergency-funds fund-id) (err ERR_FUND_NOT_FOUND)))
        (existing-contribution (default-to { total-contributed: u0, contribution-count: u0, first-contribution-date: burn-block-height, last-contribution-date: burn-block-height }
                               (map-get? fund-contributions { fund-id: fund-id, contributor: tx-sender })))
    )
        (asserts! (> amount u0) (err ERR_INVALID_AMOUNT))
        (asserts! (get is-active fund) (err ERR_APPLICATION_CLOSED))
        
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        
        (map-set fund-contributions { fund-id: fund-id, contributor: tx-sender } {
            total-contributed: (+ (get total-contributed existing-contribution) amount),
            contribution-count: (+ (get contribution-count existing-contribution) u1),
            first-contribution-date: (get first-contribution-date existing-contribution),
            last-contribution-date: burn-block-height
        })
        
        (map-set emergency-funds fund-id (merge fund {
            total-amount: (+ (get total-amount fund) amount),
            available-amount: (+ (get available-amount fund) amount)
        }))
        
        (var-set total-fund-balance (+ (var-get total-fund-balance) amount))
        (ok true)
    )
)

(define-public (submit-grant-application (emergency-type uint) (requested-amount uint) (priority uint) (description (string-ascii 500)) (location (string-ascii 100)))
    (let (
        (application-id (+ (var-get application-counter) u1))
        (existing-profile (default-to { total-applications: u0, approved-applications: u0, total-received: u0, last-application-date: u0, emergency-score: u0 }
                          (map-get? applicant-profiles tx-sender)))
    )
        (asserts! (>= requested-amount MIN_GRANT_AMOUNT) (err ERR_INVALID_AMOUNT))
        (asserts! (<= requested-amount MAX_GRANT_AMOUNT) (err ERR_INVALID_AMOUNT))
        (asserts! (<= emergency-type EMERGENCY_TYPE_OTHER) (err ERR_INVALID_STATUS))
        (asserts! (<= priority PRIORITY_LOW) (err ERR_INVALID_STATUS))
        
        (map-set grant-applications application-id {
            applicant: tx-sender,
            emergency-type: emergency-type,
            requested-amount: requested-amount,
            priority: priority,
            description: description,
            location: location,
            application-date: burn-block-height,
            review-date: none,
            disbursement-date: none,
            status: APPLICATION_STATUS_PENDING,
            reviewer: none,
            disbursed-amount: u0
        })
        
        (map-set applicant-profiles tx-sender {
            total-applications: (+ (get total-applications existing-profile) u1),
            approved-applications: (get approved-applications existing-profile),
            total-received: (get total-received existing-profile),
            last-application-date: burn-block-height,
            emergency-score: (calculate-emergency-score emergency-type priority)
        })
        
        (var-set application-counter application-id)
        (ok application-id)
    )
)

(define-public (review-application (application-id uint) (approved bool) (disbursement-amount uint))
    (let (
        (application (unwrap! (map-get? grant-applications application-id) (err ERR_APPLICATION_NOT_FOUND)))
        (reviewer-info (unwrap! (map-get? reviewers tx-sender) (err ERR_UNAUTHORIZED)))
        (applicant (get applicant application))
        (applicant-profile (unwrap! (map-get? applicant-profiles applicant) (err ERR_APPLICATION_NOT_FOUND)))
    )
        (asserts! (get is-active reviewer-info) (err ERR_UNAUTHORIZED))
        (asserts! (is-eq (get status application) APPLICATION_STATUS_PENDING) (err ERR_APPLICATION_CLOSED))
        (asserts! (or (not approved) (<= disbursement-amount (get requested-amount application))) (err ERR_INVALID_AMOUNT))
        
        (map-set grant-applications application-id (merge application {
            status: (if approved APPLICATION_STATUS_APPROVED APPLICATION_STATUS_REJECTED),
            review-date: (some burn-block-height),
            reviewer: (some tx-sender),
            disbursed-amount: (if approved disbursement-amount u0)
        }))
        
        (if approved
            (map-set applicant-profiles applicant (merge applicant-profile {
                approved-applications: (+ (get approved-applications applicant-profile) u1)
            }))
            true
        )
        
        (update-reviewer-stats tx-sender approved)
        (ok approved)
    )
)

(define-public (disburse-grant (application-id uint))
    (let (
        (application (unwrap! (map-get? grant-applications application-id) (err ERR_APPLICATION_NOT_FOUND)))
        (disbursement-amount (get disbursed-amount application))
        (applicant (get applicant application))
        (applicant-profile (unwrap! (map-get? applicant-profiles applicant) (err ERR_APPLICATION_NOT_FOUND)))
    )
        (asserts! (is-eq tx-sender (var-get contract-admin)) (err ERR_UNAUTHORIZED))
        (asserts! (is-eq (get status application) APPLICATION_STATUS_APPROVED) (err ERR_INVALID_STATUS))
        (asserts! (>= (var-get total-fund-balance) disbursement-amount) (err ERR_INSUFFICIENT_FUNDS))
        
        (try! (as-contract (stx-transfer? disbursement-amount tx-sender applicant)))
        
        (map-set grant-applications application-id (merge application {
            status: APPLICATION_STATUS_DISBURSED,
            disbursement-date: (some burn-block-height)
        }))
        
        (map-set applicant-profiles applicant (merge applicant-profile {
            total-received: (+ (get total-received applicant-profile) disbursement-amount)
        }))
        
        (var-set total-fund-balance (- (var-get total-fund-balance) disbursement-amount))
        (var-set total-disbursed (+ (var-get total-disbursed) disbursement-amount))
        (ok true)
    )
)

(define-public (declare-emergency (emergency-type uint) (description (string-ascii 300)) (duration uint))
    (let (
        (declaration-id (+ (var-get emergency-fund-counter) u1))
    )
        (asserts! (is-eq tx-sender (var-get contract-admin)) (err ERR_UNAUTHORIZED))
        (asserts! (<= emergency-type EMERGENCY_TYPE_OTHER) (err ERR_INVALID_STATUS))
        (asserts! (> duration u0) (err ERR_INVALID_AMOUNT))
        
        (map-set emergency-declarations declaration-id {
            declaration-id: declaration-id,
            declared-by: tx-sender,
            emergency-type: emergency-type,
            description: description,
            declaration-date: burn-block-height,
            end-date: (+ burn-block-height duration),
            is-active: true
        })
        
        (var-set emergency-declared true)
        (ok declaration-id)
    )
)

(define-public (approve-reviewer (reviewer-principal principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-admin)) (err ERR_UNAUTHORIZED))
        (map-set reviewers reviewer-principal {
            approved-by: tx-sender,
            approval-date: burn-block-height,
            total-reviews: u0,
            approval-rate: u0,
            is-active: true
        })
        (ok true)
    )
)

(define-public (deactivate-fund (fund-id uint))
    (let (
        (fund (unwrap! (map-get? emergency-funds fund-id) (err ERR_FUND_NOT_FOUND)))
    )
        (asserts! (is-eq tx-sender (get creator fund)) (err ERR_UNAUTHORIZED))
        (map-set emergency-funds fund-id (merge fund { is-active: false }))
        (ok true)
    )
)

(define-public (emergency-disburse (application-id uint))
    (let (
        (application (unwrap! (map-get? grant-applications application-id) (err ERR_APPLICATION_NOT_FOUND)))
        (disbursement-amount (get requested-amount application))
        (applicant (get applicant application))
    )
        (asserts! (is-eq tx-sender (var-get contract-admin)) (err ERR_UNAUTHORIZED))
        (asserts! (var-get emergency-declared) (err ERR_NO_EMERGENCY))
        (asserts! (is-eq (get status application) APPLICATION_STATUS_PENDING) (err ERR_INVALID_STATUS))
        (asserts! (>= (var-get total-fund-balance) disbursement-amount) (err ERR_INSUFFICIENT_FUNDS))
        
        (try! (as-contract (stx-transfer? disbursement-amount tx-sender applicant)))
        
        (map-set grant-applications application-id (merge application {
            status: APPLICATION_STATUS_DISBURSED,
            disbursement-date: (some burn-block-height),
            disbursed-amount: disbursement-amount
        }))
        
        (var-set total-fund-balance (- (var-get total-fund-balance) disbursement-amount))
        (var-set total-disbursed (+ (var-get total-disbursed) disbursement-amount))
        (ok true)
    )
)

(define-private (calculate-emergency-score (emergency-type uint) (priority uint))
    (+ (* emergency-type u10) (* (- u3 priority) u5))
)

(define-private (update-reviewer-stats (reviewer principal) (approved bool))
    (match (map-get? reviewers reviewer)
        reviewer-info 
            (let (
                (new-total (+ (get total-reviews reviewer-info) u1))
                (new-approvals (if approved (+ (get approval-rate reviewer-info) u1) (get approval-rate reviewer-info)))
            )
                (map-set reviewers reviewer (merge reviewer-info {
                    total-reviews: new-total,
                    approval-rate: (if (> new-total u0) (/ (* new-approvals u100) new-total) u0)
                }))
                true
            )
        false
    )
)

(define-read-only (get-application (application-id uint))
    (map-get? grant-applications application-id)
)

(define-read-only (get-emergency-fund (fund-id uint))
    (map-get? emergency-funds fund-id)
)

(define-read-only (get-fund-contribution (fund-id uint) (contributor principal))
    (map-get? fund-contributions { fund-id: fund-id, contributor: contributor })
)

(define-read-only (get-applicant-profile (applicant principal))
    (map-get? applicant-profiles applicant)
)

(define-read-only (get-reviewer-info (reviewer principal))
    (map-get? reviewers reviewer)
)

(define-read-only (is-emergency-active)
    (var-get emergency-declared)
)

(define-read-only (get-application-status (application-id uint))
    (match (map-get? grant-applications application-id)
        application (some {
            status: (get status application),
            days-since-application: (/ (- burn-block-height (get application-date application)) u144),
            is-expired: (> (- burn-block-height (get application-date application)) APPLICATION_VALIDITY_PERIOD),
            requested-amount: (get requested-amount application),
            disbursed-amount: (get disbursed-amount application)
        })
        none
    )
)

(define-read-only (get-fund-stats (fund-id uint))
    (match (map-get? emergency-funds fund-id)
        fund (some {
            utilization-rate: (if (> (get total-amount fund) u0)
                                (/ (* (- (get total-amount fund) (get available-amount fund)) u100) (get total-amount fund))
                                u0),
            available-amount: (get available-amount fund),
            total-amount: (get total-amount fund),
            is-active: (get is-active fund)
        })
        none
    )
)

(define-read-only (get-system-stats)
    {
        total-applications: (var-get application-counter),
        total-funds: (var-get emergency-fund-counter),
        total-fund-balance: (var-get total-fund-balance),
        total-disbursed: (var-get total-disbursed),
        emergency-declared: (var-get emergency-declared),
        contract-admin: (var-get contract-admin)
    }
)