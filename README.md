# Rails Analytics — App de Demonstração

App Rails mínimo que usa a gem **rails_analytics** para coletar tráfego e exibir o dashboard.
Serve como playground para **ver a gem funcionando** de ponta a ponta.

## Pré-requisitos

- Ruby >= 3.0, Rails >= 7.0
- A gem `rails_analytics` clonada em `../rails-analytcs` (este app aponta para ela via `path`)

## Rodando

### 1. Instalar dependências

```bash
bundle install
```

### 2. Criar e migrar o banco

```bash
bin/rails db:create db:migrate
```

### 3. (Opcional) Semear dados fake de 30 dias

Gera ~3.400 page views distribuídas em 30 dias para o dashboard já mostrar gráfico rico:

```bash
bin/rails db:seed
```

### 4. Subir o servidor

```bash
bin/rails server
```

### 5. Ver funcionando

- Abra **http://localhost:3000** e navegue pelas páginas (Home, Blog, Produtos, Contato).
- Acesse o dashboard em **http://localhost:3000/rails_analytics**.
- Volte no app, navegue mais um pouco e **recarregue o dashboard** — suas visitas reais já estão lá.

### 6. (Opcional) Gerar tráfego fake real via pixel

Com o servidor rodando, simula N visitas de navegadores diferentes direto no `px.gif`:

```bash
bin/trafego_fake 100
# ou com URL customizada
bin/trafego_fake 50 http://localhost:3000
```

## O que ver no dashboard

| Métrica | Fonte |
|---------|-------|
| Visitas hoje / 7d / visitantes únicos 30d | KPI cards |
| Gráfico de barras (30 dias) | SVG server-rendered |
| Top páginas + top referências | Tabelas |
| Desktop vs. móvel | Breakdown por resolução |

Tema claro/escuro automático. Tudo sem cookies — o identificador de sessão usa `localStorage`.

## Estrutura da integração

```
config/routes.rb          → mount RailsAnalytics::Engine => "/rails_analytics"
app/views/layouts/application.html.erb → rails_analytics_tracker_tag no <head>
db/migrate/*_rails_analytics_page_views.rb → tabela criada pela migração da gem
```

Tudo gerado automaticamente por:

```bash
bin/rails generate rails_analytics:install
```

## Testes da gem

Os testes de integração da gem rodam no dummy app interno dela:

```bash
cd ../rails-analytcs
bin/rails test   # na raiz da gem, roda a suíte completa
```

---

**Privacidade**: este demo usa a gem em modo padrão — IP é hasheado com `secret_key_base`
antes de ir para o banco, e nenhum cookie é criado.