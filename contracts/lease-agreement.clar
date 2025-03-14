;; Lease Agreement Contract

;; Data Variables
(define-data-var next-lease-id uint u1)

;; Data Maps
(define-map lease-agreements
  { lease-id: uint }
  {
    landlord: principal,
    tenant: principal,
    property-id: uint,
    start-date: uint,
    end-date: uint,
    rent: uint,
    active: bool
  }
)

;; Public Functions

;; Create a new lease agreement
(define-public (create-lease (tenant principal) (property-id uint) (start-date uint) (end-date uint) (rent uint))
  (let
    (
      (new-id (var-get next-lease-id))
    )
    (map-set lease-agreements
      { lease-id: new-id }
      {
        landlord: tx-sender,
        tenant: tenant,
        property-id: property-id,
        start-date: start-date,
        end-date: end-date,
        rent: rent,
        active: true
      }
    )
    (var-set next-lease-id (+ new-id u1))
    (ok new-id)
  )
)

;; Terminate a lease agreement
(define-public (terminate-lease (lease-id uint))
  (let
    (
      (lease (unwrap! (map-get? lease-agreements { lease-id: lease-id }) (err u404)))
    )
    (asserts! (or (is-eq tx-sender (get landlord lease)) (is-eq tx-sender (get tenant lease))) (err u403))
    (ok (map-set lease-agreements
      { lease-id: lease-id }
      (merge lease { active: false })
    ))
  )
)

;; Read-only function to get lease agreement details
(define-read-only (get-lease (lease-id uint))
  (map-get? lease-agreements { lease-id: lease-id })
)

