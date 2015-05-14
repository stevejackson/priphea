module SearchUtils
  def self.make_searchable_text(text)
    #I18n.transliterate(text.downcase)
    text.downcase
  end

  def self.search_format(text)
    self.make_searchable_text(text)
  end
end

Ransack.configure do |config|
  config.add_predicate 'special_match',
      arel_predicate: 'matches',
      formatter: proc { |s| SearchUtils::search_format(s) },
      validator: proc { |s| s.present? },
      compounds: true,
      type: :string
end
