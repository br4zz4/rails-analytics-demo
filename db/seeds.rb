# Sementes de demonstração: 30 dias de tráfego fake para o dashboard mostrar algo rico.
# Idempotente — rode quantas vezes quiser (apenas adiciona se a tabela estiver vazia).

require "digest"

if RailsAnalytics::PageView.exists?
  puts "rails_analytics: tabela já tem dados — pulando seed."
  return
end

puts "rails_analytics: gerando tráfego fake (30 dias)..."

pages = [
  "/", "/blog", "/blog/primeiro-post", "/blog/rails-8",
  "/blog/analytics-sem-cookies", "/blog/background-jobs",
  "/produtos", "/contato"
]
titles = {
  "/" => "Acme Store — Home", "/blog" => "Blog — Acme Store",
  "/blog/primeiro-post" => "Primeiro post — Blog",
  "/blog/rails-8" => "Rails 8: o que mudou — Blog",
  "/blog/analytics-sem-cookies" => "Analytics sem cookies — Blog",
  "/blog/background-jobs" => "Background jobs — Blog",
  "/produtos" => "Produtos — Acme Store", "/contato" => "Contato — Acme Store"
}
referrers = ["", "", "", "https://google.com", "https://google.com",
             "https://twitter.com", "https://github.com", "https://duckduckgo.com"]
uas = [
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/126 Safari/537.36",
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/125 Safari/537.36",
  "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 Version/17.5 Mobile/15E148 Safari/604.1",
  "Mozilla/5.0 (X11; Linux x86_64) Firefox/126.0",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 Version/17.4 Safari/605.1.15"
]
screens = [[1440, 900], [1920, 1080], [390, 844], [768, 1024], [1366, 768]]
langs = %w[pt-BR pt-BR pt-BR en-US es-ES]

salt = Rails.application.secret_key_base
random = Random.new(42)

# ~90 visitas/dia, com pico em dias úteis e horário comercial
(30.days.ago.to_date..Date.today).each do |day|
  weekday = day.wday
  base = weekday.zero? || weekday == 6 ? 40 : 95
  views_per_day = base + random.rand(-15..20)

  views_per_day.times do
    path = pages.sample(random: random)
    hour = random.rand(7..23)
    minute = random.rand(60)

    # top 20% das sessões fazem mais de uma página (profundidade de navegação)
    repeat = random.rand < 0.2

    n_views = repeat ? random.rand(2..4) : 1
    n_views.times do |i|
      next_path = pages.sample(random: random)

      RailsAnalytics::PageView.create!(
        path: next_path,
        referrer: referrers.sample(random: random).presence,
        title: titles[next_path],
        screen_width: screens.sample(random: random)[0],
        screen_height: screens.sample(random: random)[1],
        language: langs.sample(random: random),
        user_agent: uas.sample(random: random),
        ip_hash: Digest::SHA256.hexdigest("#{random.rand(50)}#{salt}"),
        session_id: "seed-#{day}-#{random.rand(10_000)}",
        viewed_at: Time.zone.local(day.year, day.month, day.day, hour, (minute + i) % 60)
      )
    end
  end
end

puts "rails_analytics: #{RailsAnalytics::PageView.count} page views criadas. Acesse /rails_analytics!"