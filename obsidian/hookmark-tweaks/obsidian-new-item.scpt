use framework "Foundation"
use scripting additions

property NSString : a reference to current application's NSString
property NSMutableCharacterSet : a reference to current application's NSMutableCharacterSet

set sysinfo to system info
set osver to system version of sysinfo

considering numeric strings
	set isBigSur to osver ≥ "10.16"
end considering

if not isBigSur then
	display dialog "Hook to New > Obsidian requires macOS 11 or more recent. You have macOS " & osver & "."
	return
end if



set fileType to ".md"

set prefUrl to ""
try
	set prefUrl to (do shell script "defaults read com.cogsciapps.hook integration.obsidian.URL.scheme")

on error errMsg
end try

if prefUrl is not "" and prefUrl is not "obsidian-default" and prefUrl is not "hook-file" and prefUrl is not "obsidian-advanced-URI" then


	-- An invalid value for com.cogsciapps.hook integration.obsidian.URL.scheme  has been set. There, we present the following options and set the default here.

	set thePrefChoices to {"obsidian-default (obsidian://)", "obsidian-advanced-URI (obsidian://advanced-uri)", "hook-file (hook://file/)"}
	set thePrefChoice to choose from list thePrefChoices with prompt "Please select one of the following URL schemes with which to interact with Obsidian:" default items {"obsidian-default (obsidian://)"}
	if thePrefChoice is not false then
		set x to thePrefChoice as text
		set AppleScript's text item delimiters to {" "}
		set prefUrl to text item 1 of x
		do shell script "defaults write com.cogsciapps.hook integration.obsidian.URL.scheme  " & prefUrl
	else
		return
	end if


end if



set callbackURL to "hook://x-callback-url/link-to-new"
set encodedSrc to "$encoded_link"
set callbackURLError to "hook://x-callback-url/error"

set encodedTitle to "$encoded_title"
set encodedLink to "$user_link"

set theString to NSString's stringWithString:encodedLink
set charset to NSMutableCharacterSet's URLQueryAllowedCharacterSet's mutableCopy
charset's removeCharactersInString:"&=?"
set encodedLink to theString's stringByAddingPercentEncodingWithAllowedCharacters:charset

if encodedTitle ends with fileType then
	set fileType to ""

end if

set theString to NSString's stringWithString:encodedTitle

--remove / \ :  because Obsidian would not create a file if the file name contains those characters
set theString to theString's stringByReplacingOccurrencesOfString:"/" withString:""
set theString to theString's stringByReplacingOccurrencesOfString:"%5C" withString:""
set theString to theString's stringByReplacingOccurrencesOfString:":" withString:""

--remove | ^ because they will cause file existence validation problem
set theString to theString's stringByReplacingOccurrencesOfString:"%5E" withString:""
set theString to theString's stringByReplacingOccurrencesOfString:"%7C" withString:""

set encodedTitle to theString as string


if prefUrl is "obsidian-advanced-URI" then
	set urlKey to "advanceduri"
    set destinationFolder to "Inbox/"

	-- An invalid value for com.cogsciapps.hook integration.obsidian.URL.scheme  has been set. There, we present the following options and set the default here.

	set encodedTitle to theString's stringByAddingPercentEncodingWithAllowedCharacters:charset

	set callbackURL to callbackURL & "?src=" & encodedSrc & "&urlKey=advanceduri&plusencoded=yes"


	set theString to NSString's stringWithString:callbackURL

	set callbackURL to theString's stringByAddingPercentEncodingWithAllowedCharacters:charset

	set myURL to "obsidian://advanced-uri?filepath=" & destinationFolder & encodedTitle & fileType & "&data=[" & encodedTitle & "](" & encodedLink & ")&mode=new&x-success=" & callbackURL & "&x-error=" & callbackURLError
	set myScript to "open " & quoted form of myURL

	do shell script myScript

	return "hook://link-to-new"


end if

if prefUrl is "" or prefUrl is "obsidian-default" then
	set urlKey to ""
else
	set urlKey to "%26urlKey%3Dfile"
end if


set callbackURL to callbackURL & "%3Fsrc%3D" & encodedSrc & "%26titleKey%3Dname" & urlKey


set myURL to "obsidian://new?name=" & encodedTitle & fileType & "&content=[" & encodedTitle & "](" & encodedLink & ")&x-success=" & callbackURL & "&x-error=" & callbackURLError
set myScript to "open " & quoted form of myURL

do shell script myScript

return "hook://link-to-new"
