// A CV that looks like a ratatui app: bordered blocks with their titles in the
// border, a tab bar on every page, a status line at the bottom, a monospace font.

// Color roles. A scheme is a dictionary with these keys.
//   bg      page background
//   fg      body text
//   muted   dates, locations, separators
//   border  pane borders
//   subtle  tab bar and photo borders
//   accent  pane titles, name, active tab, list markers
//   label   entry titles, skill labels, headline
//   link    links
//   tag     #hashtags
//   code    raw text
#let themes = (
  ferra: (
    bg: rgb("#2b292d"), fg: rgb("#d1d1e0"), muted: rgb("#6f5d63"),
    border: rgb("#6f5d63"), subtle: rgb("#4d424b"), accent: rgb("#ffa07a"),
    label: rgb("#fecdb2"), link: rgb("#f6b6c9"), tag: rgb("#f5d76e"), code: rgb("#b1b695"),
  ),
  // ferra roles, readable on white paper
  paper: (
    bg: rgb("#ffffff"), fg: rgb("#2b292d"), muted: rgb("#7d6a70"),
    border: rgb("#7d6a70"), subtle: rgb("#d9cfd3"), accent: rgb("#c9582c"),
    label: rgb("#a8532e"), link: rgb("#a83c60"), tag: rgb("#8a6b00"), code: rgb("#5f6439"),
  ),
  gruvbox: (
    bg: rgb("#282828"), fg: rgb("#ebdbb2"), muted: rgb("#928374"),
    border: rgb("#665c54"), subtle: rgb("#504945"), accent: rgb("#fe8019"),
    label: rgb("#fabd2f"), link: rgb("#83a598"), tag: rgb("#b8bb26"), code: rgb("#8ec07c"),
  ),
  catppuccin: (
    bg: rgb("#1e1e2e"), fg: rgb("#cdd6f4"), muted: rgb("#7f849c"),
    border: rgb("#6c7086"), subtle: rgb("#45475a"), accent: rgb("#cba6f7"),
    label: rgb("#fab387"), link: rgb("#89b4fa"), tag: rgb("#f9e2af"), code: rgb("#a6e3a1"),
  ),
  nord: (
    bg: rgb("#2e3440"), fg: rgb("#d8dee9"), muted: rgb("#7b88a1"),
    border: rgb("#4c566a"), subtle: rgb("#3b4252"), accent: rgb("#88c0d0"),
    label: rgb("#81a1c1"), link: rgb("#8fbcbb"), tag: rgb("#ebcb8b"), code: rgb("#a3be8c"),
  ),
)

// ratatui's BorderType, as far as a PDF stroke can follow it
#let borders = (
  rounded: (thickness: 0.7pt, radius: 5pt),
  plain: (thickness: 0.7pt, radius: 0pt),
  thick: (thickness: 1.6pt, radius: 0pt),
)

// everything a widget needs to draw itself: the scheme plus `frame` and `hashtags`
#let ui = state("tui-cv", themes.ferra + (frame: borders.rounded, hashtags: false))
#let themed(f) = context f(ui.get())

#let margin = (x: 1.3cm, top: 2.4cm, bottom: 1.5cm)
#let pane-pad = 1.25em

#let bird-palette = (
  "#ddd3a7", "#c6c8c1", "#dfbc69", "#babebc", "#ccaf79", "#b8b0a5", "#aaa9a8",
  "#be9a86", "#a49895", "#999799", "#938f8d", "#9e8a81", "#b57852", "#7f7c82",
).map(rgb)

// colored ascii art, shown when there is no photo
#let bird(size: 4pt) = {
  let chars = read("art/bird30.txt").split("\n")
  let colors = read("art/bird30.colors").split("\n")
  set text(size: size, font: "Fira Code")
  set par(leading: 0.45em, spacing: 0pt)
  for (row, line) in chars.enumerate() {
    let keys = colors.at(row, default: "").clusters()
    for (col, ch) in line.clusters().enumerate() {
      let idx = keys.at(col, default: " ").to-unicode() - "a".to-unicode()
      if ch == " " or idx < 0 or idx >= bird-palette.len() {
        h(0.6em)
      } else {
        box(width: 0.6em, text(fill: bird-palette.at(idx), ch))
      }
    }
    linebreak()
  }
}

#let link-to(dest, body: none) = themed(t => {
  let shown = if body == none { dest.replace(regex("^(https?://|mailto:|tel:)"), "") } else { body }
  link(dest, underline(offset: 2pt, stroke: 0.5pt + t.link, text(fill: t.link, shown)))
})

#let muted(body) = themed(t => text(fill: t.muted, body))
#let accent(body) = themed(t => text(fill: t.label, body))
#let code(body) = themed(t => text(fill: t.code, body))

#let hashtag(s) = "#" + lower(s).replace(regex("[\s/]+"), "-")
#let tag-line(tags) = themed(t => text(fill: t.tag, tags.map(hashtag).join(" ")))

// separator between tabs and status-line items, like ratatui's default divider
#let divider(t) = text(fill: t.muted, h(0.6em) + "│" + h(0.6em))

// a title sitting in a block's top border; place it at the block's content origin
#let border-title(t, body, top-inset, side: left) = place(
  top + side,
  dx: if side == left { -0.45em } else { 0.45em },
  dy: -top-inset - 0.5em,
  box(fill: t.bg, inset: (x: 0.45em, y: 0.1em), body),
)

#let pane-title(t, title) = text(fill: t.accent, weight: "bold", title)

// a bordered block with its title in the top edge
#let section(title, tab: none, body) = themed(t => block(
  width: 100%,
  breakable: true,
  stroke: t.frame.thickness + t.border,
  radius: t.frame.radius,
  inset: (x: pane-pad, top: pane-pad, bottom: 1em),
  above: 1.6em,
  below: 0pt,
  {
    border-title(t, pane-title(t, title), pane-pad)
    [#metadata((title: title, tab: if tab == none { title } else { tab })) <cv-section>]
    body
    [#metadata(none) <cv-section-end>]
  },
))

// a pane split across pages gets its title again on the top edge of each continuation
#let continued-titles = context {
  let t = ui.get()
  let page = here().page()
  for (s, e) in query(<cv-section>).zip(query(<cv-section-end>)) {
    if s.location().page() < page and e.location().page() >= page {
      place(
        top + left,
        dx: margin.x + pane-pad - 0.45em,
        dy: margin.top - 0.6em,
        box(fill: t.bg, inset: (x: 0.45em, y: 0.1em), pane-title(t, s.value.title)),
      )
    }
  }
}

// one item: bold name, label-colored title, date and location on the right,
// description, links. Every field is optional; leave out what would only be filler.
// `tags` only render with `cv(hashtags: true)`.
#let entry(
  society: none,
  title: none,
  date: none,
  location: none,
  description: none,
  tags: (),
  links: (),
) = themed(t => block(breakable: false, above: 1.35em, below: 0pt, {
  let side = (main, meta) => if meta == none { main } else {
    grid(columns: (1fr, auto), column-gutter: 1.5em, main, text(fill: t.muted, meta))
  }
  // date and location sit on the right; if one line is missing, the other moves up
  let metas = (location, date).filter(m => m != none)
  let rows = (
    if society != none { text(weight: "bold", society) },
    if title != none { text(fill: t.label, title) },
  ).filter(r => r != none)
  if rows.len() == 1 and metas.len() == 2 { metas = (metas.join(" · "),) }
  let parts = rows.enumerate().map(((i, r)) => side(r, metas.at(i, default: none)))
  if rows.len() == 0 and metas.len() > 0 { parts.push(muted(metas.join(" · "))) }
  if description != none { parts.push(block(description)) }
  if t.hashtags and tags.len() > 0 { parts.push(tag-line(tags)) }
  parts += links.map(l => link-to(l))
  stack(spacing: 0.6em, ..parts)
}))

#let honor(date: none, title: none, issuer: none, location: none) = themed(t => block(
  breakable: false,
  above: 1em,
  below: 0pt,
  grid(
    columns: (7em, 1fr, auto),
    column-gutter: 1.2em,
    text(fill: t.muted, date),
    stack(spacing: 0.5em, text(weight: "bold", title), text(fill: t.muted, issuer)),
    text(fill: t.muted, location),
  ),
))

#let skills(..rows) = themed(t => grid(
  columns: (auto, 1fr),
  column-gutter: 1.5em,
  row-gutter: 0.8em,
  ..rows
    .pos()
    .map(((label, items)) => (
      text(fill: t.label, label),
      items.join(text(fill: t.muted, " · ")),
    ))
    .flatten(),
))

// first pane: headline, contact rows, photo or the ascii bird
#let profile(headline, contacts, photo) = themed(t => section("About", {
  grid(
    columns: (1fr, auto),
    column-gutter: 1.5em,
    align: (left + horizon, right + horizon),
    {
      if headline != none {
        text(fill: t.label, headline)
        v(1.1em)
      }
      grid(
        columns: (auto, 1fr),
        column-gutter: 1.2em,
        row-gutter: 0.75em,
        ..contacts
          .map(((label, value, url)) => (
            text(fill: t.muted, label),
            if url == none { value } else { link-to(url, body: value) },
          ))
          .flatten(),
      )
    },
    if photo == none { align(left, block(bird())) } else {
      // a path resolves relative to this file; pass image("...") to resolve from yours
      let img = if type(photo) == str { image(photo, width: 2.7cm) } else {
        set image(width: 2.7cm)
        photo
      }
      box(clip: true, radius: t.frame.radius, stroke: t.frame.thickness + t.subtle, img)
    },
  )
}))

// tab bar: name in the border on the left, tagline on the right,
// numbered tabs inside; tabs for the panes on this page are highlighted
#let page-header(name, tagline) = context {
  let t = ui.get()
  let page = here().page()
  let sections = query(<cv-section>)
  let shown = sections
    .zip(query(<cv-section-end>))
    .filter(((s, e)) => s.location().page() <= page and e.location().page() >= page)
    .map(((s, _)) => s)
  let tab = (n, m) => {
    let label = "[" + str(n + 1) + "] " + m.value.tab
    let style = if shown.contains(m) {
      highlight(fill: t.accent, extent: 0.15em, text(fill: t.bg, weight: "bold", label))
    } else { label }
    link(m.location(), style)
  }
  let pad = 1.2em
  block(
    width: 100%,
    stroke: t.frame.thickness + t.subtle,
    radius: t.frame.radius,
    inset: (x: 1.1em, top: pad, bottom: 0.8em),
    {
      border-title(t, text(fill: t.accent, weight: "bold", name), pad)
      if tagline != none {
        border-title(t, text(fill: t.muted, style: "italic", tagline), pad, side: right)
      }
      set par(leading: 0.9em)
      // wrap by hand so dividers only sit between tabs on the same line
      layout(size => {
        let div = box(divider(t))
        let lines = ((),)
        let width = 0pt
        for (n, m) in sections.enumerate() {
          let item = box(tab(n, m))
          let w = measure(item).width
          if lines.last().len() > 0 {
            if width + measure(div).width + w > size.width {
              lines.push(())
              width = 0pt
            } else { width += measure(div).width }
          }
          lines.last().push(item)
          width += w
        }
        lines.map(l => l.join(div)).join(linebreak())
      })
    },
  )
}

// status line: key hint, page count, site link
#let page-footer(site) = context {
  let t = ui.get()
  let total = counter(page).final().first()
  set text(size: 0.9em)
  text(fill: t.label, "←→")
  text(fill: t.muted, " pages ")
  text(fill: t.label, str(here().page()) + "/" + str(total))
  if site != none {
    divider(t)
    link(site, text(fill: t.label, site.replace(regex("^https?://"), "")))
  }
}

#let cv(
  name: "Your Name",
  tagline: none,
  headline: none,
  contacts: (),
  photo: none,
  site: none,
  theme: "ferra", // a name from `themes`, or a dictionary of roles to override ferra's
  border: "rounded", // "rounded", "plain" or "thick"
  hashtags: false,
  font: "Fira Code",
  size: 8.4pt,
  lang: "en",
  body,
) = {
  let scheme = if type(theme) == str { themes.at(theme) } else { themes.ferra + theme }
  let t = scheme + (frame: borders.at(border), hashtags: hashtags)
  ui.update(t)
  set document(title: name + " · CV", author: name)
  set text(font: font, size: size, fill: t.fg, lang: lang)
  set page(
    paper: "a4",
    fill: t.bg,
    margin: margin,
    foreground: continued-titles,
    header: page-header(name, tagline),
    header-ascent: 0.9cm,
    footer: page-footer(site),
    footer-descent: 40%,
  )
  set par(leading: 0.6em, spacing: 0.9em)
  set list(marker: text(fill: t.accent, "-"), indent: 0em, body-indent: 0.7em, spacing: 0.6em)
  show strong: set text(fill: t.label)
  show raw: set text(font: font, fill: t.code, size: 1.25em)

  profile(headline, contacts, photo)
  body
}
