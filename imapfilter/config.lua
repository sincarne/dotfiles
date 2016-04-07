-------------
-- Options --
-------------
options.cache        = true
options.certificates = true
options.create       = true
options.close        = true
options.expunge      = false

--------------
-- Accounts --
--------------
personal = IMAP {
  server = "",
  username = "",
  password = "",
  ssl = "tls1"
}

freelance = IMAP {
  server = "",
  username = "",
  password = "",
  ssl = "tls1"
}

function moveSentMessages()
  --------------------------------
  -- On the first of the month  --
  -- move all older messages to --
  -- a date marked sent folder  --
  --------------------------------

  theDate = os.date("*t")

  months = {
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  }

  if (theDate["day"] == 1) then
    dateString = "Sent-" .. months[theDate["month"] - 1] .. "-" .. theDate["year"]

    messages = personal["Sent"]:is_older(1) + personal["Sent Messages"]:is_older(1)
    messages:move_messages(personal[dateString])

    messages = freelance["Sent"]:is_older(1) + freelance["Sent Messages"]:is_older(1)
    messages:move_messages(freelance[dateString])
  end
end

function moveMessage(searchField, searchTable, destination)
  for k, v in pairs(searchTable) do
    if searchField == "body" then
      messages = personal["Inbox"]:contain_body(v) * personal["Inbox"]:is_unseen()
      messages:move_messages(personal[destination])
      messages = freelance["Inbox"]:contain_body(v) * freelance["Inbox"]:is_unseen()
      messages:move_messages(freelance[destination])
    elseif searchField == "sender" then
      messages = personal["Inbox"]:contain_from(v) * personal["Inbox"]:is_unseen()
      messages:move_messages(personal[destination])
      messages = freelance["Inbox"]:contain_from(v) * freelance["Inbox"]:is_unseen()
      messages:move_messages(freelance[destination])
    elseif searchField == "subject" then
      messages = personal["Inbox"]:contain_subject(v) * personal["Inbox"]:is_unseen()
      messages:move_messages(personal[destination])
      messages = freelance["Inbox"]:contain_subject(v) * freelance["Inbox"]:is_unseen()
      messages:move_messages(freelance[destination])
    end
  end
end

function flagSenders(senders)
  for k, v in pairs(senders) do
    messages = personal["Inbox"]:contain_from(v) + freelance["Inbox"]:contain_from(v)
    messages:mark_flagged()
  end
end


function sortMail()

  ------------------
  -- Housekeeping --
  ------------------

  moveSentMessages()

  -- My mail clients all create Trash folders
  -- Deleted Messages is canonical
  messages = personal["Trash"]:select_all()
  messages:move_messages(personal["Deleted Messages"])
  messages = freelance["Trash"]:select_all()
  messages:move_messages(freelance["Deleted Messages"])

  -- Move everything in spam to Inbox because Hover's spam detection is
  -- truly terrible
  messages = personal["Spam"]:select_all()
  messages:move_messages(personal["Inbox"])
  messages = freelance["Spam"]:select_all()
  messages:move_messages(freelance["Inbox"])

  -- Mark stuff read I don't need to review
  messages = personal["Receipts"]:select_all() + freelance["Receipts"]:select_all()
  messages:mark_seen()

  -- Permanently delete old Deleted Messages
  messages = personal["Deleted Messages"]:is_older(31) * freelance["Deleted Messages"]:is_older(31)
  messages:delete_messages()

  ----------------------------------------
  -- Define tables for sorting messages --
  ----------------------------------------

  binBody = {
    "Hey man fortune,",
    "Hey smbdy_mprtnt,"
  }

  binSubjects = {
    "Fever Refresh Cron",
    "From Sharone Bar-David:"
  }

  bundleSenders = {
    "contact@humblebundle.com",
    "contact@indiegamestand.com",
    "newsletter@bundlestars.com",
    "newsletter@storybundle.com",
    "support@indiegala.com"
  }

  newsletterBody = {
    "Medium Daily Digest",
    "Now I Know:",
    "Three Things Weekly"
  }

  newsletterSenders = {
    "admin@pycoders.com",
    "alexis.madrigal@gmail.com",
    "announcement@fancyfootage.club",
    "clark@noonpacific.com",
    "collection@fancyfootage.club",
    "contact@gamedevjsweekly.com",
    "dave@davenetics.com",
    "digest-noreply@quora.com",
    "digital@tiff.net",
    "Disqus Picks on Disqus",
    "from Buffer",
    "hello@wpmail.me",
    "holdfastmagazine@gmail.com",
    "info@atlasobscura.com",
    "info@themoderndesk.com",
    "tim@fourhourbody.com",
    "jeremiah@jeremiahshoaf.com",
    "jsw@peterc.org",
    "kale@graceletter.com",
    "katie@phpweekly.com",
    "Kickstarter HQ",
    "Kickstarter Staff",
    "liz@thinkful.com",
    "Matter",
    "news@edx.org",
    "news@makeuseof.com",
    "newsletter@aeon.co",
    "newsletter@ifttt.com",
    "newsletter@indiegogo.com",
    "newsletter@longreads.com",
    "newsletters@sitepoint.com",
    "nuzzel@mail.nuzzel.com",
    "rahul@pythonweekly.com",
    "Responsive Design Weekly",
    "steve@itsonvillage.com",
    "taco@trello.com",
    "tordotcom@mail.macmillan.com",
    "upvotedweekly@reddit.com",
    "versioning@sitepoint.com",
    "yo@sassnews.com",
    "Yummly",
    "help@hndigest.com",
    "info@unmatchedstyle.com",
    "newsletter@brainpickings.org",
    "newsletter@css-weekly.com",
    "editorialstaff@flipboard.com"
  }

  newsletterSubjects = {
    "10 for Today",
    "Hammer and Tusk",
    "Hammer & Tusk",
    "Inner Vision for the weekend of",
    "JSFiddle Newsletter",
    "MacStories Weekly",
    "So What, Who Cares",
    "The Optimist:",
    "The Platter",
    "The Weekender from Now I Know",
    "Upvoted Weekly:",
    "Web Design Weekly",
    "Project Update",
    "AutoShare Newsletter"
  }

  offersBody = {
    "Deal of the Day"
  }

  offersSenders = {
    "toysrus@email.toysrus.ca",
    "no-reply@newsletter.gamersgate.com",
    "bungie@info.bungie.net",
    "Newsletter@email.blizzard.com",
    "chapters.indigo@email.indigo.ca",
    "click@photojojo.com",
    "contact@twodollartues.com",
    "customerservice@fendrihan.ca",
    "udemy@email.udemy.com",
    "noreply@creativemarket.com",
    "dhnews@darkhorse.com",
    "digitalnews@darkhorse.com",
    "donotreply@edge.ebgames.ca",
    "ebates@mail.ebates.ca",
    "eblast@eblastservices.com",
    "hello@deals.touchofmodern.com",
    "hello@fivesimplesteps.com",
    "help@paddle.com",
    "support@groupees.com",
    "hi@stacksocial.com",
    "hudsonsbay@enews.thebay.com",
    "info@torontodealsblog.com",
    "info@torontodealsblog.com",
    "My Starbucks Rewards",
    "news@em.mec.ca",
    "news@gameagent.com",
    "newsletter@bestbuy.ca",
    "newsletter@bundlestars.com",
    "newsletter@e.redflagdeals.com",
    "newsletter@gog.com",
    "nintendo@em-news.nintendo.com",
    "no-reply@drivethrustuff.com",
    "noreply@thehouseofmarley.com",
    "notifications@appshopper.com",
    "offers@checkout51.com",
    "oldnavy@email.oldnavy.ca",
    "paypal@e.paypal.ca",
    "PlayStation@playstationemail.com",
    "pr@darkhorse.com",
    "store@menessentials.com",
    "support@sitepoint.com",
    "updates@comms.packtpub.com",
    "gap@email.gapcanada.ca",
    "NoReply@TDRewards.com",
    "promo@email.newegg.ca",
    "no-reply@macupdate.com",
    "Starbucks@e.starbucks.com"
  }

  offersSubjects = {
    "Hot Title Alert",
    "My Starbucks Rewards",
    "New this week:",
    "Skill Up",
    "Weekend Deals:",
    "Your PlayStation weekly update"
  }

  receiptsSubjects = {
    "Order Confirmation",
    "Payment Confirmation",
    "Receipt for",
    "Thank you for your purchase!",
    "Your Humble Bundle, Inc. receipt",
    "Your Indiegala s.r.l. receipt",
    "Your purchase of",
    "Your Paddle.com Receipt",
    "Your receipt from Apple.",
    "Your VODO bundle purchase",
    "Your payment has been sent"
  }

  -----------------------
  -- Move the messages --
  -----------------------
  moveMessage('body', binBody, 'Deleted Messages')
  moveMessage('subject', binSubjects, 'Deleted Messages')
  moveMessage('sender', bundleSenders, 'Bundles')
  moveMessage('body', newsletterBody, 'Newsletters')
  moveMessage('sender', newsletterSenders, 'Newsletters')
  moveMessage('subject', newsletterSubjects, 'Newsletters')
  moveMessage('body', offersBody, 'Offers')
  moveMessage('sender', offersSenders, 'Offers')
  moveMessage('subject', offersSubjects, 'Offers')
  moveMessage('subject', receiptsSubjects, 'Receipts')

  -------------------
  -- Consolidation --
  -------------------
  messages = freelance["Newsletters"]:select_all()
  messages:move_messages(personal["Newsletters"])

  -------------------
  -- Special cases --
  -------------------

  messages = personal["Bundles"]:contain_subject("Your Humble Bundle order is ready") +
             personal["Bundles"]:contain_subject("Indiegala purchase!")
  messages:move_messages(personal["Receipts"])

end --sortMail

become_daemon(120, sortMail)
