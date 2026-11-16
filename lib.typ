// A CV that looks like a ratatui app: bordered panes with titles in the border,
// a running header and a status bar. Set `tui: false` for a plain layout.

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
  gruvbox-contrast: (
    bg: rgb("#282828"), fg: rgb("#ebdbb2"), muted: rgb("#bdae93"),
    border: rgb("#7c6f64"), subtle: rgb("#7c6f64"), accent: rgb("#fe8019"),
    label: rgb("#fabd2f"), link: rgb("#83a598"), tag: rgb("#b8bb26"), code: rgb("#8ec07c"),
  ),
  gruvbox-light: (
    bg: rgb("#f9f5d7"), fg: rgb("#282828"), muted: rgb("#504945"),
    border: rgb("#928374"), subtle: rgb("#928374"), accent: rgb("#9d3300"),
    label: rgb("#282828"), link: rgb("#005564"), tag: rgb("#6d3056"), code: rgb("#315d43"),
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
#let page-top = state("tui-cv-page-top", 0pt)

#let margin = (x: 1.3cm, top: 2cm, bottom: 1cm)

// One spacing scale on a 4pt grid. Every gap in the layout comes from here.
#let space = (xs: 4pt, sm: 8pt, md: 12pt, lg: 16pt)
// Padding inside a pane: equal on the left and right, and the visible gap
// below the title matches the gap above the bottom border.
#let pane-pad = space.sm

// Explicit spacing also applies to lists passed through entry descriptions.
#let bullets(..items) = list(tight: false, spacing: space.sm, ..items.pos())

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
  // Project links can be a URL or (URL, label); contacts pass visible body text.
  let target = if type(dest) == array { dest.at(0) } else { dest }
  let shown = if body != none { body }
    else if type(dest) == array { dest.at(1) }
    else if target.starts-with("https://github.com/") { "GitHub ↗" }
    else if target.starts-with("https://huggingface.co/") { "Hugging Face ↗" }
    else { target.replace(regex("^(https?://|mailto:|tel:)"), "") + " ↗" }
  let label = text(fill: t.link, shown)
  link(target, if body == none { label } else {
    underline(offset: 2pt, stroke: 0.3pt + t.link, label)
  })
})

#let muted(body) = themed(t => text(fill: t.muted, body))
#let accent(body) = themed(t => text(fill: t.label, body))
#let code(body) = themed(t => text(fill: t.code, body))

#let hashtag(s) = "#" + lower(s).replace(regex("[\s/]+"), "-")
#let tag-line(tags) = themed(t => text(fill: t.tag, tags.map(hashtag).join(" ")))

// a title sitting in a block's top border; place it at the block's content origin
#let title-box(t, body) = box(fill: t.bg, inset: (x: 0.45em, y: 0.1em), body)

// a title sitting in a block's top border; place it at the block's content origin
// and centre it on the border whatever its size
#let border-title(t, body, top-inset, side: left) = context {
  let label = title-box(t, body)
  place(
    top + side,
    dx: if side == left { -0.45em } else { 0.45em },
    dy: -top-inset - measure(label).height / 2,
    label,
  )
}

// how far a border title hangs below (and above) its border; needs context
#let title-overhang(t, body) = measure(title-box(t, body)).height / 2

#let pane-title(t, title) = text(font: t.heading-font, size: 13pt, fill: t.accent, weight: "bold", title)

// An open section with a quiet divider; the title stays with its first entry.
#let section(title, tab: none, body) = themed(t => {
  let overhang = title-overhang(t, pane-title(t, title))
  block(
  width: 100%,
  breakable: true,
  // the visible gap above a pane's title equals the padding inside it
  above: if t.tui { pane-pad + overhang } else { 2 * space.md },
  below: 0pt,
  stroke: if t.tui { t.frame.thickness + t.border } else { none },
  radius: if t.tui { t.frame.radius } else { 0pt },
  inset: if t.tui { (x: pane-pad, top: pane-pad + overhang, bottom: pane-pad) } else { 0pt },
  {
    if t.tui {
      border-title(t, pane-title(t, title), pane-pad + overhang)
    } else {
      block(sticky: true, below: space.md, grid(
        columns: (auto, 1fr),
        column-gutter: space.md,
        align: horizon,
        pane-title(t, title),
        line(length: 100%, stroke: 0.5pt + t.subtle),
      ))
    }
    [#metadata((title: title, tab: if tab == none { title } else { tab })) <cv-section>]
    body
    [#metadata(none) <cv-section-end>]
  },
  )
})

// a pane split across pages gets its title again on the top edge of each continuation
#let continued-titles = context {
  let t = ui.get()
  let page = here().page()
  for (s, e) in query(<cv-section>).zip(query(<cv-section-end>)) {
    if s.location().page() < page and e.location().page() >= page {
      place(
        top + left,
        dx: margin.x + (if t.tui { pane-pad - 0.45em } else { 0pt }),
        // the top margin is measured in `cv`
        dy: page-top.get() - title-overhang(t, pane-title(t, s.value.title)),
        title-box(t, pane-title(t, s.value.title)),
      )
    }
  }
}

// one item: bold name, smaller neutral subtitle, date and location on the right,
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
) = themed(t => block(breakable: false, above: space.md, below: 0pt, {
  let side = (main, meta) => if meta == none { main } else {
    grid(columns: (1fr, auto), column-gutter: space.md, main, text(size: 8.6pt, fill: t.muted, meta))
  }
  // date and location sit on the right; if one line is missing, the other moves up
  let metas = (date, location).filter(m => m != none)
  let rows = (
    if society != none { text(size: 10.5pt, weight: "bold", society) },
    if title != none { text(size: 9.2pt, fill: t.fg, title) },
  ).filter(r => r != none)
  if rows.len() == 1 and metas.len() == 2 { metas = (metas.join(" · "),) }
  let parts = rows.enumerate().map(((i, r)) => side(r, metas.at(i, default: none)))
  if rows.len() == 0 and metas.len() > 0 { parts.push(muted(metas.join(" · "))) }
  // heading rows sit space.xs apart; description and links get space.sm,
  // made of the stack spacing plus this padding (block `above` is ignored here)
  if description != none { parts.push(block(inset: (top: space.xs), description)) }
  if t.hashtags and tags.len() > 0 { parts.push(tag-line(tags)) }
  if links.len() > 0 {
    parts.push(block(inset: (top: space.xs), text(size: 8.5pt,
      links.map(l => link-to(l)).join(text(fill: t.muted, "  ·  ")),
    )))
  }
  stack(spacing: space.xs, ..parts)
}))

// A dated assignment within one employer, distinct from a separate job.
#let assignment(title, period, body) = themed(t => block(
  breakable: false,
  above: space.md,
  below: 0pt,
  inset: (left: space.md),
  stack(
    spacing: space.sm,
    grid(
      columns: (1fr, auto),
      column-gutter: space.md,
      text(weight: "bold", fill: t.fg, title),
      text(size: 8.6pt, fill: t.muted, period),
    ),
    body,
  ),
))

#let honor(date: none, title: none, issuer: none, location: none) = themed(t => block(
  breakable: false,
  above: space.sm,
  below: 0pt,
  grid(
    columns: (61pt, 1fr, 78pt),
    column-gutter: space.md,
    text(size: 8.6pt, fill: t.muted, date),
    stack(spacing: space.xs, text(weight: "bold", title), text(size: 8.8pt, fill: t.muted, issuer)),
    align(right, text(size: 8.6pt, fill: t.muted, location)),
  ),
))

#let skills(..rows) = themed(t => block(above: space.sm, grid(
  columns: (83pt, 1fr),
  column-gutter: space.md,
  row-gutter: space.sm,
  ..rows
    .pos()
    .map(((label, items)) => (
      text(fill: t.label, label),
      items.map(item => box(item)).join(text(fill: t.muted, " · ")),
    ))
    .flatten(),
)))

// Compact introduction: readable summary, two contact columns, and portrait.
#let profile(headline, contacts, photo) = themed(t => {
  let contact-order = ("web", "github", "email", "phone", "location", "born")
  let ordered = contact-order.map(label => contacts.find(c => c.at(0) == label)).filter(c => c != none)
  let extra = contacts.filter(c => not contact-order.contains(c.at(0)))
  let contents = grid(
    columns: (1fr, auto),
    column-gutter: space.lg,
    align: (left + top, right + top),
    {
      if headline != none {
        text(size: 11pt, fill: t.fg, headline)
        v(space.md)
      }
      set text(size: 8.8pt)
      // size the label column to the longest label so wide fonts don't collide
      context {
        let label-width = calc.max(..(ordered + extra).map(c => measure(c.at(0)).width))
        grid(
          columns: (1.25fr, 1fr),
          column-gutter: space.md,
          row-gutter: space.sm,
          ..(ordered + extra).map(((label, value, url)) => grid(
            columns: (label-width, 1fr),
            column-gutter: space.sm,
            text(fill: t.muted, label),
            if url == none { value } else { link-to(url, body: value) },
          )),
        )
      }
    },
    if photo == none { align(left, block(bird())) } else {
      // a path resolves relative to this file; pass image("...") to resolve from yours
      let img = if type(photo) == str { image(photo, width: 2.1cm) } else {
        set image(width: 2.1cm)
        photo
      }
      box(clip: true, radius: if t.tui { 0pt } else { 4pt }, stroke: if t.tui { 0.6pt + t.subtle } else { none }, img)
    },
  )
  if t.tui { section("About", contents) } else { block(contents) }
})

// Running header: name, role, and a quiet rule instead of application controls.
#let page-header(name, tagline) = context {
  let t = ui.get()
  set text(font: t.heading-font)
  let name-text = text(size: 16pt, fill: t.accent, weight: "bold", name)
  let name-overhang = title-overhang(t, name-text)
  block(
    width: 100%,
    stroke: if t.tui { t.frame.thickness + t.border } else { none },
    radius: if t.tui { t.frame.radius } else { 0pt },
    inset: if t.tui { (x: pane-pad, top: name-overhang + space.sm, bottom: space.sm) } else { 0pt },
    {
      if t.tui {
        border-title(t, name-text, name-overhang + space.sm)
        if tagline != none { text(size: 9pt, fill: t.fg, tagline) }
      } else {
        grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),
          text(size: 17pt, fill: t.accent, weight: "bold", name),
          if tagline != none { text(size: 8.5pt, fill: t.muted, tagline) },
        )
        v(space.sm)
        line(length: 100%, stroke: 0.6pt + t.subtle)
      }
    },
  )
}

// Plain document footer.
#let page-footer(site) = context {
  let t = ui.get()
  let total = counter(page).final().first()
  set text(size: 8pt, fill: if t.tui { t.fg } else { t.muted })
  block(
    width: 100%,
    fill: if t.tui { t.bg.darken(10%) } else { none },
    stroke: if t.tui { (top: 0.6pt + t.border) } else { none },
    inset: if t.tui { (x: pane-pad, y: space.xs) } else { 0pt },
    grid(
      columns: (1fr, auto),
      if site != none { link(site, site.replace(regex("^https?://"), "")) },
      [Page #here().page() of #total],
    ),
  )
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
  tui: true, // false for plain section dividers
  font: "Fira Code",
  body-font: none, // defaults to `font`
  size: 8.4pt,
  lang: "en",
  body,
) = {
  let scheme = if type(theme) == str { themes.at(theme) } else { themes.ferra + theme }
  let t = scheme + (frame: borders.at(border), hashtags: hashtags, heading-font: font, tui: tui)
  ui.update(t)
  set document(title: name + " · CV", author: name)
  // missing glyphs (like ↗) fall back to a monospace face, not Typst's serif
  let body-font = if body-font == none { font } else { body-font }
  set text(font: (body-font, font, "Fira Code", "Fira Mono"), size: size, fill: t.fg, lang: lang)
  set page(
    paper: "a4",
    fill: t.bg,
    margin: margin,
    foreground: continued-titles,
    header: page-header(name, tagline),
    header-ascent: pane-pad,
    footer: page-footer(site),
    footer-descent: 2pt,
  )
  // pane titles stick up above their border, so the gap under the header
  // grows by that much to keep the visible gap at pane-pad
  // The header and footer heights depend on fonts, so measure them: the page
  // edge sits margin.x from the header and footer, as it does at the sides.
  show: doc => context {
    let width = page.width - 2 * margin.x
    let header-height = measure(page-header(name, tagline), width: width).height
    let footer-height = measure(page-footer(site), width: width).height
    let ascent = pane-pad + if tui { title-overhang(t, pane-title(t, "Ag")) } else { 0pt }
    let descent = pane-pad
    let top = margin.x + header-height + ascent
    page-top.update(top)
    set page(
      margin: (
        x: margin.x,
        top: top,
        bottom: margin.x + footer-height + descent,
      ),
      header-ascent: ascent,
      footer-descent: descent,
    )
    doc
  }
  set par(leading: space.xs, spacing: space.sm)
  set list(marker: text(fill: t.accent, size: 8pt, "-"), indent: 0em, body-indent: space.sm, tight: false, spacing: space.sm)
  show strong: set text(fill: t.label)
  show raw: set text(font: font, fill: t.code, size: 1.25em)

  profile(headline, contacts, photo)
  body
}
