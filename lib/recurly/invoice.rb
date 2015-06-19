module Recurly
  # Invoices are created through account objects.
  #
  # @example
  #   account = Account.find account_code
  #   account.invoice!
  class Invoice < Resource
    # @macro [attach] scope
    #   @scope class
    #   @return [Pager<Invoice>] A pager that yields +$1+ invoices.
    scope :open,      :state => :open
    scope :collected, :state => :collected
    scope :failed,    :state => :failed
    scope :past_due,  :state => :past_due

    # @return [Account]
    belongs_to :account
    # @return [Subscription]
    belongs_to :subscription
    # @return [Invoice]
    belongs_to :original_invoice, class_name: 'Invoice'

    # @return [Redemption]
    has_one :redemption

    def invoice_number_with_prefix
      "#{invoice_number_prefix}#{invoice_number}"
    end

    define_attribute_methods %w(
      uuid
      state
      invoice_number
      invoice_number_prefix
      po_number
      vat_number
      subtotal_in_cents
      tax_in_cents
      tax_type
      tax_region
      tax_rate
      total_in_cents
      currency
      created_at
      closed_at
      amount_remaining_in_cents
      line_items
      transactions
      terms_and_conditions
      customer_notes
      address
      net_terms
      collection_method
    )
    alias to_param invoice_number_with_prefix

    # Marks an invoice as paid successfully.
    #
    # @return [true, false] +true+ when successful, +false+ when unable to
    #   (e.g., the invoice is no longer open).
    def mark_successful
      return false unless self[:mark_successful]
      reload self[:mark_successful].call
      true
    end

    # Marks an invoice as failing collection.
    #
    # @return [true, false] +true+ when successful, +false+ when unable to
    #   (e.g., the invoice is no longer open).
    def mark_failed
      return false unless self[:mark_failed]
      reload self[:mark_failed].call
      true
    end

    def pdf
      find to_param, :format => 'pdf'
    end

    private

    def initialize attributes = {}
      super({ :currency => Recurly.default_currency }.merge attributes)
    end

    # Invoices are only writeable through {Account} instances.
    embedded! true
    undef save
    undef destroy
  end
end
