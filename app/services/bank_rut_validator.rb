class BankRutValidator < ActiveModel::Validator
  def validate(record)
    rut = record.rut&.strip
    record.errors[:rut] << Spree.t(:invalid_rut) if rut.present? && Rut.remove_points(rut) != rut
  end
end
