class RutValidator < ActiveModel::Validator
  def validate(record)
    rut = record.respond_to?(:company_rut) ? record.company_rut&.strip : record.rut&.strip
    record.errors[:rut] << Spree.t(:invalid_rut) if rut.present? && !Rut.validar(rut)
  end
end
