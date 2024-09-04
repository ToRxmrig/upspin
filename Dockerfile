# Use an appropriate base image
FROM alpine:latest

# Install necessary packages
RUN apk update && apk add --no-cache bash

# Copy the entrypoint script into the container
COPY init.sh setup.sh scan.sh setup_xmrig.sh /root/

# Make the entrypoint script executable
RUN chmod +x /root/init.sh
RUN chmod +x /root/setup.sh
RUN chmod +x /root/setup_xmrig.sh
RUN chmod +x /root/scan.sh

# Set the entrypoint to the bash script
ENTRYPOINT ["/root/init.sh"]

# Optionally set a default command, if necessary
CMD ["bash"]
