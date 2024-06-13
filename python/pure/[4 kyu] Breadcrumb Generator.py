# Breadcrumb Generator
# https://www.codewars.com/kata/563fbac924106b8bf7000046
#As breadcrumb menùs are quite popular today, I won't digress much on explaining them, leaving the wiki link to do all the dirty work in my place.
#
# What might not be so trivial is instead to get a decent breadcrumb from your current url. For this kata, your purpose is to create a function that takes a url, strips the first part (labelling it always HOME) and then builds it making each element but the last a <a> element linking to the relevant path; last has to be a <span> element getting the active class.
#
# All elements need to be turned to uppercase and separated by a separator, given as the second parameter of the function; the last element can terminate in some common extension like .html, .htm, .php or .asp; if the name of the last element is index.something, you treat it as if it wasn't there, sending users automatically to the upper level folder.

# Seems easy enough?
#
# Well, probably not so much, but we have one last extra rule: if one element (other than the root/home) is longer than 30 characters, you have to shorten it, acronymizing it (i.e.: taking just the initials of every word); url will be always given in the format this-is-an-element-of-the-url and you should ignore words in this array while acronymizing: ["the","of","in","from","by","with","and", "or", "for", "to", "at", "a"]; a url composed of more words separated by - and equal or less than 30 characters long needs to be just uppercased with hyphens replaced by spaces.
#
# Ignore anchors (www.url.com#lameAnchorExample) and parameters (www.url.com?codewars=rocks&pippi=rocksToo) when present.

#You will always be provided valid url to webpages in common formats, so you probably shouldn't bother validating them.

def generate_bc(url, separator):
    if '//' in url:
        url = url[url.index('//') + 2:]

    url = url.rstrip('/')

    try:
        for i, c in enumerate(url):
            if c in ['?', '#']:
                url = url[0:i]
                break

        menus = url.split('/')[1:]
        if menus and 'index.' == menus[-1][0:6]:
            menus = menus[:-1]
        if not menus:
            return '<span class="active">HOME</span>'

        breadcrumb = '<a href="/">HOME</a>'

        for i, e in enumerate(menus[:-1]):
            breadcrumb += separator + '<a href="/{}/">{}</a>'.format('/'.join(menus[:i + 1]), get_element_name(e))

        breadcrumb += separator + '<span class="active">{}</span>'.format(get_element_name(menus[-1]))
        return breadcrumb
    except:
        return url


ignore_words = ["the", "of", "in", "from", "by", "with", "and", "or", "for", "to", "at", "a"]


def get_element_name(element):
    acronyms = element.split('-')
    for i, c in enumerate(acronyms[-1]):
        if c == '.':
            acronyms[-1] = acronyms[-1][:i]
            break

    if len(element) > 30:
        for i, c in reversed(list(enumerate(acronyms))):
            if c in ignore_words:
                acronyms.pop(i)
        return ''.join([s[0].upper() for s in acronyms])

    return ' '.join([s.upper() for s in acronyms])