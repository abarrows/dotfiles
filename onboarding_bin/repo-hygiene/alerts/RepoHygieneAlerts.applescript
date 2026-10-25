-- Repo Hygiene Alerts
--
-- Why this exists: a notification posted with `osascript -e 'display notification ...'` is
-- attributed to "Script Editor", and clicking it opens a blank Script Editor window. A
-- notification posted BY an app carries that app's name, and clicking it relaunches the app.
-- So this tiny app does both jobs:
--
--   run with a message    ->  posts the notification, titled "Repo Hygiene"
--   launched with no args ->  (that is what a click on the notification does) opens the report
--
-- The report is ~/Library/Logs/repo-hygiene/latest-report.md, rewritten by the sweep and by the
-- SessionEnd hook, and it lists each item with the command that fixes it.
on run argv
	set reportPath to (POSIX path of (path to home folder)) & "Library/Logs/repo-hygiene/latest-report.md"
	if (count of argv) > 0 then
		display notification (item 1 of argv) with title "Repo Hygiene" subtitle "Click for the list and how to clear it"
	else
		try
			do shell script "test -f " & quoted form of reportPath
			do shell script "open " & quoted form of reportPath
		on error
			display notification "No report yet. Run repo-hygiene sweep." with title "Repo Hygiene"
		end try
	end if
end run
