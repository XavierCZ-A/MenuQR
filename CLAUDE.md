# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

menuQr: a Rails 8.1 app where restaurant owners register, manage their menu (categories/items) from an admin dashboard, and expose a public menu per restaurant (`/restaurants/:slug`). UI copy and user-facing validation messages are in Spanish.

Stack: SQLite, Hotwire (Turbo + Stimulus), esbuild (jsbundling), Tailwind CSS v4 via `@tailwindcss/cli` (cssbundling), ViewComponent, Solid Queue/Cache/Cable, Kamal for deploys.

## Commands

```bash
bin/setup                 # install deps, prepare DB
bin/dev                   # Procfile.dev: rails server + esbuild --watch + tailwind --watch
bin/rails test            # all tests (parallelized)
bin/rails test test/models/restaurant_test.rb:12   # single test by file:line
bin/rails test:system     # system tests (Capybara + Selenium), not run in CI
bin/rubocop               # rubocop-rails-omakase style
bin/brakeman              # security scan
bin/ci                    # full CI pipeline defined in config/ci.rb (setup, rubocop, audits, brakeman, tests, seeds)
```

If CSS/JS changes don't show up outside `bin/dev`, rebuild with `npm run build` / `npm run build:css` (output goes to `app/assets/builds`).

ERB templates are linted/formatted by Herb (`.herb.yml`): no instance variables in partials, strict locals (`<%# locals: (...) %>`) required in partials, no interpolated class names (breaks Tailwind class detection), no `<%== %>`.

## Architecture

**Authentication** — Rails 8 built-in auth generator. `Authentication` concern (`app/controllers/concerns/authentication.rb`) is included in `ApplicationController`, so every action requires login unless the controller calls `allow_unauthenticated_access`. The current user is `Current.user` (delegated from `Current.session`, a DB-backed `Session` looked up by signed cookie). In integration tests, use `sign_in_as(user)` from `test/test_helpers/session_test_helper.rb`.

**Registration** — `UsersController#create` creates the `User` and its `Restaurant` together via `accepts_nested_attributes_for :restaurants`. `User::MAX_RESTAURANTS` (currently 1) caps restaurants per user, enforced both in the nested-attributes limit and a `Restaurant` validation. `Restaurant` generates a unique, accent-stripped `slug` from its name on create; public restaurant routes use `param: :slug`.

**Routing** — custom paths: login is `/login`, registration is `/register`, and the `Admin::` namespace is mounted at `/dashboard` (e.g. `admin_items_path` → `/dashboard/items`). Admin controllers live in `app/controllers/admin/`. Data scoping to the owner's restaurant is done manually via `Current.user.restaurant_ids`.

**Domain** — `User has_many :restaurants`; `Category belongs_to :restaurant`; `Item` is the menu item (associations still being built out).

**UI components** — ViewComponents live in `app/components/<name>/component.rb` + `component.html.erb`, namespaced as `<Name>::Component` (e.g. `render Button::Component.new(...)`). Convention used across components:
- Variant/size class maps as frozen constants holding full literal Tailwind class strings (so Tailwind can detect them).
- Final classes are merged through `helpers.tw(...)` (`ApplicationHelper#tw`, wraps `tailwind_merge`), with a `classes:` param for overrides and `**options` passed through as HTML attributes.

Note: `rails g component` generates flat `FooComponent` classes and tests referencing them; rename to the `Foo::Component` folder layout to match the existing components.

**Styling** — design tokens (`--primary`, `--destructive`, `--border`, etc., shadcn-style) are defined in `app/assets/stylesheets/application.tailwind.css`; use the semantic token classes (`bg-primary`, `text-foreground`) rather than raw colors. `render_svg(name, styles:)` inlines SVGs from `app/assets/images` with Tailwind classes.
