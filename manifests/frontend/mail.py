import smtplib
from email.mime.text import MIMEText

smtp_server = "smtp"
smtp_port = 25
#username = "test"
#password = "test"

from_addr = "test@localhost"
to_addr = "mme37005@gmail.com"

msg = MIMEText("Hello! This is a test letter from Python via Docker Postfix&Dovecot bundle.")
msg["Subject"] = "Docker mail test"
msg["From"] = from_addr
msg["To"] = to_addr

with smtplib.SMTP(smtp_server, smtp_port) as server:
#    server.login(username, password)  
    server.send_message(msg)
