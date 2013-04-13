"""Script for fectching emails; works for yahoo or gmail
"""
import imaplib, email, sqlite3
import email.utils
import argparse
from time import mktime
from datetime import datetime


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-e', '--email', help = 'full email')
    parser.add_argument('-p', '--password', help = 'full password')
    parser.add_argument('-s', '--subject', help = 'subject line of interest')
    args = parser.parse_args()
    
    domain = args.email.split("@")[1][0:-4]
    if domain == 'yahoo':
        imap_server = imaplib.IMAP4_SSL('imap.mail.yahoo.com', 993)
    elif domain == 'gmail':
        imap_server = imaplib.IMAP4_SSL('imap.gmail.com', 993)
    else:
        raise ValueError("We only support yahoo and gmail at this time")

    imap_server.login(args.email, args.password)
    imap_server.select('Inbox')

    if args.subject:
        typ, response = imap_server.search(None, '(Subject %s)' % args.subject)
    else:
        typ, response = imap_server.search(None, '(From "thelistserve.com")')

    conn = sqlite3.connect('mail.db')
    cursor = conn.cursor()

    body = ""
    for i in response[0].split():
        results, data = imap_server.fetch(i, "(RFC822)")
        if data is None:
            pass
        else:
            test = email.message_from_string(data[0][1])
            message_id = test.__getitem__('Message-ID')
            body = str(test)
            senderx = test.__getitem__('sender')
            date = test.__getitem__('date')
            subject = test.__getitem__('subject')
            print date
            date_parsed = email.utils.parsedate(date)
            dt = datetime.fromtimestamp(mktime(date_parsed))
            
            cursor.execute("""INSERT INTO mail (sender, payload, subject, dt, datetime_text, message_id) 
                    values (?,?,?,?,?,?)""", (senderx, body, subject, dt, date, message_id))
            conn.commit()

if __name__ == "__main__":
    main()
