module Spree::ZoneDecorator
  def self.prepended(base)
    base.with_options through: :zone_members, source: :zoneable do
      has_many :counties, source_type: 'Spree::County'
    end

    base.scope :moova, -> { where(is_moova: true) }

    def base.match(address)
      return unless address &&
                    matches = includes(:zone_members).
                    order('spree_zones.zone_members_count', 'spree_zones.created_at').
                    where("(spree_zone_members.zoneable_type = 'Spree::Country' AND " \
                                      'spree_zone_members.zoneable_id = ?) OR ' \
                                      "(spree_zone_members.zoneable_type = 'Spree::State' AND " \
                                      'spree_zone_members.zoneable_id = ?) OR ' \
                                      "(spree_zone_members.zoneable_type = 'Spree::County' AND " \
                                      'spree_zone_members.zoneable_id = ?)', address.country_id, address.state_id, address.county_id).
                    references(:zones)

      %w[county state country].each do |zone_kind|
        if match = matches.detect { |zone| zone_kind == zone.kind }
          return match
        end
      end
      matches.first
    end

    def base.potential_matching_zones(zone)
      if zone.country?
        # Match zones of the same kind with similar countries
        joins(countries: :zones).
          where('zone_members_spree_countries_join.zone_id = ?', zone.id).
          distinct
      else
        # Match zones of the same kind with similar states in AND match zones
        # that have the states countries in
        joins(:zone_members).where(
          "(spree_zone_members.zoneable_type = 'Spree::County' AND
            spree_zone_members.zoneable_id IN (?))
           OR (spree_zone_members.zoneable_type = 'Spree::State' AND
            spree_zone_members.zoneable_id IN (?))
           OR (spree_zone_members.zoneable_type = 'Spree::Country' AND
            spree_zone_members.zoneable_id IN (?))",
          zone.county_ids,
          zone.state_ids,
          zone.states.pluck(:country_id)
        ).distinct
      end
    end
  end

  def county?
    kind == 'county'
  end

  def county_ids
    if county?
      members.pluck(:zoneable_id)
    else
      []
    end
  end

  def include?(address)
    return false unless address

    members.any? do |zone_member|
      case zone_member.zoneable_type
      when 'Spree::Country'
        zone_member.zoneable_id == address.country_id
      when 'Spree::State'
        zone_member.zoneable_id == address.state_id
      when 'Spree::County'
        zone_member.zoneable_id == address.county_id
      else
        false
      end
    end
  end

  Spree::Zone.prepend self
end
