# frozen_string_literal: true

FactoryBot.define do
  factory :oneclick_user, class: Tbk::WebpayOneclickMall::User do
    tbk_user { '1e284697-d3d2-40a3-b280-df48aa926ed6' }
    authorization_code { '1234' }
    card_type { 'Visa' }
    card_number { '6623' }
    subscribed { true }
    token { '01abaf22ecee12f780180880f74ffb7f5ac0d63978d15934726007e60b2c1560' }
    default { false }
    user
  end
end
