# Certificate store
class Certificate < ActiveRecord::Base
  has_many :certificate_services, dependent: :destroy

  validates :certificate, presence: true, x509_certificate: true
end
