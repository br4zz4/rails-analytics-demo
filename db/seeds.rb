# frozen_string_literal: true

# Seeds de demonstração: 30 dias de tráfego fake para o dashboard (v1).
# Idempotente — deleta e recria.

require "securerandom"

RailsAnalytics::Event.delete_all
RailsAnalytics::Visit.delete_all

SOURCES = ["google.com", "twitter.com", "github.com", "duckduckgo.com", "direct", "direct", "direct"].freeze
DEVICES = ["desktop", "desktop", "mobile", "mobile", "tablet"].freeze
LANGS = ["pt-BR", "pt-BR", "pt-BR", "en-US", "es-ES"].freeze
PAGES = ["/", "/blog", "/blog/primeiro-post", "/blog/rails-8",
         "/blog/analytics-sem-cookies", "/blog/background-jobs",
         "/produtos", "/contato"].freeze
EVENTS = {
  "doacao-click" => 40,
  "participe-click" => 25,
  "instagram-click" => 20,
  "email-click" => 12,
  "scroll-depth" => 70,
  "form-start:contato" => 15,
  "form-submit:contato" => 6
}.freeze
EVENT_NAMES = EVENTS.keys.freeze

rng = Random.new(42)

puts "rails_analytics: gerando tráfego fake (30 dias)..."

(30.days.ago.to_date..Date.today).each do |day|
  weekday = day.wday
  base = weekday.zero? || weekday == 6 ? 40 : 95
  views_per_day = base + rng.rand(-15..20)

  views_per_day.times do
    started = Time.zone.local(day.year, day.month, day.day, rng.rand(7..23), rng.rand(60))

    source = SOURCES.sample(random: rng)
    device = DEVICES.sample(random: rng)

    visit = RailsAnalytics::Visit.create!(
      anonymity_key:      SecureRandom.hex(16),
      masked_ip:          "#{rng.rand(1..223)}.#{rng.rand(0..255)}.#{rng.rand(0..255)}.0",
      referrer_domain:    source,
      landing_page_path:  PAGES.sample(random: rng),
      device_type:        device,
      viewport:           device == "mobile" ? "390x844" : (device == "tablet" ? "768x1024" : "1440x900"),
      language:           LANGS.sample(random: rng),
      utm_source:         (source == "direct" ? nil : source.gsub(".com", "")),
      started_at:         started
    )

    # ~50% das visits não interagem (bounce)
    next if rng.rand < 0.5

    rng.rand(1..3).times do
      name = EVENT_NAMES.sample(random: rng)
      visit.events.create!(
        name: name,
        time: started + rng.rand(0..30).minutes,
        properties: name == "scroll-depth" ? { "mark" => [25, 50, 75, 100].sample(random: rng) } : {}
      )
    end
  end
end

puts "rails_analytics: #{RailsAnalytics::Visit.count} visits, #{RailsAnalytics::Event.count} events. Acesse /rails_analytics!"
