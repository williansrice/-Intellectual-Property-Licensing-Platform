;; Licensing Agreement Contract

(define-map licenses
  uint
  {
    asset-id: uint,
    licensee: principal,
    terms: (string-utf8 1000),
    start-block: uint,
    end-block: uint,
    royalty-rate: uint
  }
)

(define-data-var license-id-nonce uint u0)

(define-public (create-license (asset-id uint) (licensee principal) (terms (string-utf8 1000)) (duration uint) (royalty-rate uint))
  (let
    ((license-id (+ (var-get license-id-nonce) u1)))
    (map-set licenses license-id {
      asset-id: asset-id,
      licensee: licensee,
      terms: terms,
      start-block: block-height,
      end-block: (+ block-height duration),
      royalty-rate: royalty-rate
    })
    (var-set license-id-nonce license-id)
    (ok license-id)
  )
)

(define-read-only (get-license (license-id uint))
  (ok (unwrap! (map-get? licenses license-id) (err u404)))
)

(define-public (terminate-license (license-id uint))
  (let
    ((license (unwrap! (map-get? licenses license-id) (err u404))))
    (asserts! (or (is-eq tx-sender (get licensee license)) (is-eq tx-sender contract-caller)) (err u403))
    (ok (map-delete licenses license-id))
  )
)

