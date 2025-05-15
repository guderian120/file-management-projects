import smtplib
import sys
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.message import EmailMessage
from datetime import datetime

from_email = "andyprojects7@gmail.com"  # Email address to send from
password = "ifho cyae dpin cwew"  # my google app password, will expire soon
body = 'Please find the attached log file.'

def send_email_to_admin(log_file_path, to_email, subject): # send log file to admin
    msg = EmailMessage()
    msg['From'] = from_email
    msg['To'] = to_email
    msg['Subject'] = f"Log File For {subject} Files: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
    msg.set_content(body)
    with open(log_file_path, 'rb') as f:
        file_data = f.read()
        file_name = f.name
    msg.add_attachment(file_data, maintype='application', subtype='octet-stream', filename=file_name)

 
    try:
        with smtplib.SMTP('smtp.gmail.com', 587) as server:
            server.starttls()  # Start TLS encryption
            server.login(from_email, password)
            server.sendmail(from_email, to_email, msg.as_string())
    except Exception as e:
        print(f"Failed to send email to {to_email}: {str(e)}")



if __name__ == "__main__":
    try:
        if len(sys.argv) < 2:
            print("Usage: send_email.py <email_address> <log_file_dir> <subject>")
        else:
            send_email_to_admin(sys.argv[2], sys.argv[1], sys.argv[3])
    except IndexError:
        print("Admin Usage : send_email.py  <email_address> <log_file_dir> <subject>")
