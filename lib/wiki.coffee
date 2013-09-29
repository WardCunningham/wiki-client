createSynopsis = require './synopsis'

wiki = { createSynopsis }

wiki.persona = require './persona'

wiki.log = (things...) ->
  console.log things... if console?.log?

wiki.asSlug = (name) ->
  name.replace(/\s/g, '-').replace(/[^A-Za-z0-9-]/g, '').toLowerCase()

wiki.useLocalStorage = ->
  # openId convention
  return true if $(".login").length > 0
  # persona convention
  login = $("#persona-login-btn")
  return true if login.is(':visible') and !login.text().match(/claim/i)
  false

wiki.resolutionContext = []

wiki.resolveFrom = (addition, callback) ->
  wiki.resolutionContext.push addition
  try
    callback()
  finally
    wiki.resolutionContext.pop()

wiki.getData = (vis) ->
  if vis
    idx = $('.item').index(vis)
    who = $(".item:lt(#{idx})").filter('.chart,.data,.calculator').last()
    if who? then who.data('item').data else {}
  else
    who = $('.chart,.data,.calculator').last()
    if who? then who.data('item').data else {}

wiki.getDataNodes = (vis) ->
  if vis
    idx = $('.item').index(vis)
    who = $(".item:lt(#{idx})").filter('.chart,.data,.calculator').toArray().reverse()
    $(who)
  else
    who = $('.chart,.data,.calculator').toArray().reverse()
    $(who)

wiki.createPage = (name, loc) ->
  site = loc if loc and loc isnt 'view'
  $page = $ """
    <div class="page" id="#{name}">
      <div class="twins"> <p> </p> </div>
      <div class="header">
        <h1> <img class="favicon" src="#{ if site then "//#{site}" else "" }/favicon.png" height="32px"> #{name} </h1>
      </div>
    </div>
  """
  $page.find('.page').attr('data-site', site) if site
  $page

wiki.getItem = (element) ->
  $(element).data("item") or $(element).data('staticItem') if $(element).length > 0

wiki.resolveLinks = (string) ->
  renderInternalLink = (match, name) ->
    # spaces become 'slugs', non-alpha-num get removed
    slug = wiki.asSlug name
    "<a class=\"internal\" href=\"/#{slug}.html\" data-page-name=\"#{slug}\" title=\"#{wiki.resolutionContext.join(' => ')}\">#{name}</a>"
  string
    .replace(/\[\[([^\]]+)\]\]/gi, renderInternalLink)
    .replace(/\[(http.*?) (.*?)\]/gi, """<a class="external" target="_blank" href="$1" title="$1" rel="nofollow">$2 <img src="/images/external-link-ltr-icon.png"></a>""")

module.exports = wiki

