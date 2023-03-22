using HTTP, Gumbo

const PAGE_URL = "https://en.wikipedia.org/wiki/Julia_(programming_language)"
const LINKS = String[] # same as Array{String,1}()

function fetchpage(url)
  response = HTTP.get(url)

  if response.status == 200 && parse(Int, Dict(response.headers)["content-length"]) > 0
    String(response.body)
  else
    ""
  end
end

function extractlinks(elem)
  if isa(elem, HTMLElement) && tag(elem) == :a && in("href", collect(keys(attrs(elem))))
    link_url = getattr(elem, "href")
    startswith(link_url, "/wiki/") && !occursin(":", link_url) && push!(LINKS, link_url)
  end

  for child in children(elem)
    extractlinks(child)
  end
end

content = fetchpage(PAGE_URL)

if !isempty(content)
  dom = Gumbo.parsehtml(content)
  extractlinks(dom.root)
end

display(unique(LINKS))
