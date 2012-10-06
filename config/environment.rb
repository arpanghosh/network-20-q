# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Network20qApp::Application.initialize!

# Specify certificate file. Mac only!!!!
ENV['SSL_CERT_FILE'] = "/opt/local/etc/openssl/cert.pem"
