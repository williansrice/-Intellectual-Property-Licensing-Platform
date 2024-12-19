(define-fungible-token fraction)

(define-map fraction-owners
  { asset-id: uint, owner: principal }
  { fraction-count: uint }
)

(define-data-var total-supply uint u0)

(define-public (create-fractions (asset-id uint) (total-fractions uint))
  (let
    ((current-supply (var-get total-supply)))
    (try! (ft-mint? fraction total-fractions tx-sender))
    (var-set total-supply (+ current-supply total-fractions))
    (ok (map-set fraction-owners { asset-id: asset-id, owner: tx-sender } { fraction-count: total-fractions }))
  )
)

(define-public (transfer-fractions (asset-id uint) (recipient principal) (amount uint))
  (let
    ((sender-balance (unwrap! (map-get? fraction-owners { asset-id: asset-id, owner: tx-sender }) (err u404)))
     (recipient-balance (default-to { fraction-count: u0 } (map-get? fraction-owners { asset-id: asset-id, owner: recipient }))))
    (asserts! (>= (get fraction-count sender-balance) amount) (err u401))
    (try! (ft-transfer? fraction amount tx-sender recipient))
    (map-set fraction-owners { asset-id: asset-id, owner: tx-sender } { fraction-count: (- (get fraction-count sender-balance) amount) })
    (map-set fraction-owners { asset-id: asset-id, owner: recipient } { fraction-count: (+ (get fraction-count recipient-balance) amount) })
    (ok true)
  )
)

(define-read-only (get-fraction-balance (asset-id uint) (owner principal))
  (ok (get fraction-count (default-to { fraction-count: u0 } (map-get? fraction-owners { asset-id: asset-id, owner: owner }))))
)

