# vim:ft=sieve
# Sieve Filter
## TODO: add friends rule

require
["fileinto","reject","comparator-i;ascii-numeric","regex","envelope","vacation"];

if allof(
        address :is ["From", "Sender"] "mailings@gmx.net",
        header :matches ["Subject"] "Automatischer Spam-Report"
        )
{
    fileinto "INBOX";
    stop;
}

# delete Spam, and Web.de and GMX mails
if anyof(
        address :is ["From", "Sender"] "keineantwortadresse@web.de",
        address :is ["From", "Sender"] "neu@web.de",
        address :is ["From", "Sender"] "mailings@gmx.net",
        address :is ["From", "Sender"] "mailings@gmxnet.de",
        address :is ["From", "Sender"] "mailings@gmx-gmbh.de",
        header :matches ["Subject"] ["[Spam]"]
        )
{
    fileinto "Trash";
    stop;
}

# Heise newsletters
if header :contains ["From", "Sender"] "newsletter@listserv.heise.de" {
    fileinto "Newsletters/Heise";
    stop;
}

if address :domain ["From", "Sender"] ["sourceforge.net", "newsletters.sourceforge.net>"] {
    fileinto "Newsletters/SourceForge";
    stop;
}

# Psycle ML
if address :is "Reply-To" "psycle-devel@lists.sourceforge.net"
{
    if anyof(
            header :contains "Subject" "psycle-bugs",
            header :contains "Subject" "psycle-qsycle"
            )
    {
        fileinto "Psycle-devel/Bugs";
        stop;
    }
    else
    {
        fileinto "Psycle-devel";
        stop;
    }
}

# Gentoo bugs
if address :matches "From" "bugzilla*@gentoo.org" {
    fileinto "Gentoo/BugZilla";
    stop;
}

if address :domain ["To", "Cc"] ["gentoo.org", "lists.gentoo.org"]
{
    if header :contains ["List-Id"] "gentoo-amd64" {
        fileinto "Gentoo/AMD64";
        stop;
    }
    elsif header :contains ["List-Id"] "gentoo-user.gentoo.org" {
        fileinto "Gentoo/User";
        stop;
    }
    elsif header :contains ["List-Id"] "gentoo-user-de.gentoo.org" {
        fileinto "Gentoo/User-DE";
        stop;
    }
    elsif header :contains ["List-Id"] "gentoo-bugzilla.gentoo.org" {
        fileinto "Gentoo/BugZilla";
        stop;
    }
    elsif header :contains ["List-Id"] "gentoo-announce.gentoo.org" {
        fileinto "Gentoo/Announce";
        stop;
    }
    elsif header :contains ["List-Id"] "gentoo-embedded.gentoo.org" {
        fileinto "Gentoo/Embedded";
        stop;
    }
    else {
        fileinto "Gentoo";
        stop;
    }
}

# Linux Audio MLs
if header :contains "List-Id" "linux-audio-user" {
    fileinto "LinuxAudio/User";
    stop;
}
elsif header :contains "List-Id" "linux-audio-dev" {
    fileinto "LinuxAudio/Dev";
    stop;
}
elsif header :contains "List-Id" "linux-audio-announce" {
    fileinto "LinuxAudio/Announce";
    stop;
}

# VST IHA ML
if address :is ["To", "Sender"] "vst_iha@googlegroups.com" {
    fileinto "VST IHA";
    stop;
}

# BCU SDK (eibd) ML
if header :contains "List-Id" "bcusdk-list" {
    fileinto "BCU SDK";
    stop;
}

if header :contains "List-Id" "iha-verein" {
    fileinto "IHAVerein";
    stop;
}

if address :domain :contains "From" ["marcec", "localhost"]
{
    if header :contains "Subject" "eix-sync" {
        fileinto "Computer/eix-sync";
        stop;
    }
    elsif header :contains "Subject" "eclean" {
        fileinto "Computer/Eclean";
        stop;
    }
    elsif header :contains "From" "fcron" {
        fileinto "Computer/Cron";
        stop;
    }
    elsif address :localpart "From" "portage" {
        fileinto "Computer/Portage elog";
        stop;
    }
    else {
        fileinto "Computer";
        stop;
    }
}

# emails related to studies
if anyof(
        address :domain ["From", "Sender"] ["jade-hs.de", "uni-oldenburg.de"],
        address :is ["To", "Cc"] ["marc.joliet@uni-oldenburg.de"],
        address :matches ["To", "Cc"] ["hua_master_studis@listserv.uni-oldenburg.de"]
        )
{
    fileinto "Studium";
    stop;
}

# family emails
if anyof(
        address :contains ["From", "Sender"] "P.A.C.J@web.de",
        address :contains ["From", "Sender"] "tricialyn@web.de",
        address :contains ["From", "Sender"] "iec.jol@web.de",
        address :contains ["From", "Sender"] "joliet@hft-leipzig.de",
        address :contains ["From", "Sender"] "axeljoliet@web.de"
        )
{
    fileinto "Privat/Familie";
    stop;
}

# friends
if address :localpart ["From", "Sender"] ["potemkin", "Grenzclan", "holgerbraemer", "rjh.l"] {
    fileinto "Privat/Freunde";
    stop;
}

if address :is ["To", "Cc"] "marcec@web.de" {
    fileinto "Privat";
    stop;
}
