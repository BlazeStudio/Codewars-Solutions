#Strip Comments
#Complete the solution so that it strips all text that follows any of a set of comment markers passed in. Any whitespace at the end of the line should also be stripped out.

#https://www.codewars.com/kata/51c8e37cee245da6b40000bd

def strip_comments(strng, markers):
    end, result = 0, ""
    strng = strng.replace('\n', '/n')
    for word in range(0, len(strng)):
        if strng[word] in markers:
            end = 1
        elif strng[word - 1] + strng[word] == "/n" and end == 1:
            result += strng[word-1]
            result += strng[word]
            end = 0
        elif end == 0:
            result += strng[word]
    stuff, thing = "", ""
    for word in range(0, len(result)):
        if result[word - 1] + result[word] == "/n":
            thing = thing[:-1]
            thing = thing.rstrip()
            thing += result[word - 1] + result[word]
            stuff += thing
            thing = ""
        else:
            thing += result[word]
            if word == len(result) - 1 and thing != "":
                thing = thing.rstrip()
                stuff += thing

    result = stuff.replace('/n', '\n')
    return result