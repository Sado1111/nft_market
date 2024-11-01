;; nft.clar
;; An enhanced NFT implementation in Clarity 6.0 with batch minting, burn and URI update functionality

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-token-exists (err u102))
(define-constant err-token-not-found (err u103))
(define-constant err-invalid-token-uri (err u104))
(define-constant err-burn-failed (err u105))
(define-constant err-already-burned (err u106))
(define-constant err-not-token-owner-update (err u107))
(define-constant err-invalid-batch-size (err u108))
(define-constant err-batch-mint-failed (err u109))
(define-constant max-batch-size u100)  ;; Maximum tokens that can be minted in a single batch

;; Data Variables
(define-non-fungible-token simple-nft uint)
(define-data-var last-token-id uint u0)

;; Maps
(define-map token-uri uint (string-ascii 256))
(define-map burned-tokens uint bool)  ;; Track burned tokens
(define-map batch-metadata uint (string-ascii 256))  ;; Store batch metadata

;; Private Functions
(define-private (is-token-owner (token-id uint) (sender principal))
    (is-eq sender (unwrap! (nft-get-owner? simple-nft token-id) false)))

(define-private (is-valid-token-uri (uri (string-ascii 256)))
    (let ((uri-length (len uri)))
        (and (>= uri-length u1)
             (<= uri-length u256))))

(define-private (is-token-burned (token-id uint))
    (default-to false (map-get? burned-tokens token-id)))

(define-private (mint-single (token-uri-data (string-ascii 256)))
    (let ((token-id (+ (var-get last-token-id) u1)))
        (asserts! (is-valid-token-uri token-uri-data) err-invalid-token-uri)
        (try! (nft-mint? simple-nft token-id tx-sender))
        (map-set token-uri token-id token-uri-data)
        (var-set last-token-id token-id)
        (ok token-id)))

;; Public Functions
(define-public (mint (token-uri-data (string-ascii 256)))
    (begin
        ;; Validate that the caller is the contract owner
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)

        ;; Validate the token URI
        (asserts! (is-valid-token-uri token-uri-data) err-invalid-token-uri)

        ;; Proceed with minting the token
        (mint-single token-uri-data)))

(define-public (batch-mint (uris (list 100 (string-ascii 256))))
    (let 
        ((batch-size (len uris)))
        (begin
            (asserts! (is-eq tx-sender contract-owner) err-owner-only)
            (asserts! (<= batch-size max-batch-size) err-invalid-batch-size)
            (asserts! (> batch-size u0) err-invalid-batch-size)

            ;; Use fold to process the URIs and mint tokens
            (ok (fold mint-single-in-batch uris (list)))
        )))

(define-private (mint-single-in-batch (uri (string-ascii 256)) (previous-results (list 100 uint)))
    (match (mint-single uri)
        success (unwrap-panic (as-max-len? (append previous-results success) u100))
        error previous-results))

(define-public (burn (token-id uint))
    (let ((token-owner (unwrap! (nft-get-owner? simple-nft token-id) err-token-not-found)))
        (asserts! (is-eq tx-sender token-owner) err-not-token-owner)
        (asserts! (not (is-token-burned token-id)) err-already-burned)
        (try! (nft-burn? simple-nft token-id token-owner))
        (map-set burned-tokens token-id true)
        (ok true)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq recipient tx-sender) err-not-token-owner)
        (asserts! (not (is-token-burned token-id)) err-already-burned)
        (let ((actual-sender (unwrap! (nft-get-owner? simple-nft token-id) err-not-token-owner)))
            (asserts! (is-eq actual-sender sender) err-not-token-owner)
            (try! (nft-transfer? simple-nft token-id sender recipient))
            (ok true))))

(define-public (update-token-uri (token-id uint) (new-uri (string-ascii 256)))
    (begin
        (let ((token-owner (unwrap! (nft-get-owner? simple-nft token-id) err-token-not-found)))
            (asserts! (is-eq token-owner tx-sender) err-not-token-owner-update)
            (asserts! (is-valid-token-uri new-uri) err-invalid-token-uri)
            (map-set token-uri token-id new-uri)
            (ok true))))

