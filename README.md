# RHEL73DataDog
Instructions
1. Pull this repo 
2. Modify the script to include your API key
3. The line sh -c *sed 's/api_key:.*/api_key: xxxxxxxxxxxxxxxxxxxxxxxxxx/' /etc/dd-agent/datadog.conf.example > /etc/dd-agent/datadog.conf"' replace the xxxxxxxxxxx with your API key
4. Build the container - docker build -t rhel73/datadog:<tag> .
5. Run the container - docker run -d -P rhel73/datadog:<tag>

